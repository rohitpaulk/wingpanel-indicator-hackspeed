/*
 * Copyright (c) 2017 elementary LLC. (https://elementary.io)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 */

struct Keystroke {
	DateTime timestamp;
	char character;
}

public struct TypingSpeed {
	int character_count;
	double interval_secs;

	public double words_per_minute() {
		return (characters_per_minute() / 5.0);
	}

	public double characters_per_minute() {
		return ((double) character_count * 60 / interval_secs);
	}
}


public class Hackspeed.KeystrokeRecorder {
	public signal void keystroke_recorded (char character);

	private Gee.ArrayList<Keystroke?> keystrokes;
	private string keyboard_id;

	private Pid child_pid;
	private IOChannel child_stdout_channel;

	public KeystrokeRecorder() {
		this.keystrokes = new Gee.ArrayList<Keystroke?>();
	}

	public void start(string keyboard_id) {
		this.keyboard_id = keyboard_id;
		debug("Recording for keyboard_id %s", keyboard_id);

		int child_stdout;

		Process.spawn_async_with_pipes(
			"/tmp",
			{"xinput", "test", this.keyboard_id},
			Environ.get(),
			SpawnFlags.SEARCH_PATH,
			null,
			out this.child_pid,
			null,
			out child_stdout,
			null
		);

		this.child_stdout_channel = new IOChannel.unix_new(child_stdout);
		child_stdout_channel.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
			return this.process_line(channel, condition, "stdout");
		});
	}

	public int get_recent_keystrokes_count() {
		return this.keystrokes.size;
	}

	public TypingSpeed? get_typing_speed() {
		if (this.keystrokes.size < 2) {
			return null;
		}

		var first_ts = this.keystrokes[0].timestamp;
		var last_ts = this.keystrokes[this.keystrokes.size-1].timestamp;

		return TypingSpeed() {
			character_count = this.keystrokes.size,
			interval_secs = (last_ts.difference(first_ts) / 1000000.0)
		};
	}

	public void stop() {
		debug("Stopping recording");
	}

	private void record_keystroke (char ch) {
		this.keystrokes.add(Keystroke() {
			timestamp = new DateTime.now(),
			character = ch
		});

		this.delete_stale_keystrokes();
		this.keystroke_recorded(ch);

	    debug("Number of keystrokes: %s", this.get_recent_keystrokes_count().to_string());
	}

	private void delete_stale_keystrokes () {
		var now = new DateTime.now();
		var first_ts = this.keystrokes[0].timestamp;
		var interval = TimeSpan.SECOND * 20;

		if (now.difference(first_ts) > interval) {
			debug("deleted stale timestamp");
			this.keystrokes.remove_at(0);
			first_ts = this.keystrokes[0].timestamp;
		}
	}

	private bool process_line (IOChannel channel, IOCondition condition, string stream_name) {
		if (condition == IOCondition.HUP) {
			debug ("%s: The fd has been closed.\n", stream_name);
			return false;
		}

		try {
			string data;
			channel.read_line (out data, null, null);
			print ("%s: %s", stream_name, data);
			var ch = (new XInputLogParser()).parse_line(data);
			debug ("processed char: %s", (ch == null) ? "UNKNOWN" : ch.to_string());
			if (ch != null) {
				this.record_keystroke(ch);
			}
		} catch (IOChannelError e) {
			print ("%s: IOChannelError: %s\n", stream_name, e.message);
			return false;
		} catch (ConvertError e) {
			print ("%s: ConvertError: %s\n", stream_name, e.message);
			return false;
		}

		return true;
	}

}
