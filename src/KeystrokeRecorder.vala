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

public struct Keystroke {
	DateTime timestamp;
	char character;
}

public class Hackspeed.KeystrokeRecorder {
	public signal void keystroke_recorded (char character);

	private Gee.ArrayList<Keystroke?> keystrokes;
	private string keyboard_id;

	private Pid? child_pid = null;
	private IOChannel child_stdout_channel;

	private TimeSpan interval_to_record = TimeSpan.SECOND * 20;

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

	public TypingSpeed? get_typing_speed() {
		return (new TypingSpeedCalculator()).calculate_speed(this.keystrokes);
	}

	public void reset_keystrokes() {
		this.keystrokes = new Gee.ArrayList<Keystroke?>();
	}

	private void record_keystroke (char ch) {
		this.keystrokes.add(Keystroke() {
			timestamp = new DateTime.now(),
			character = ch
		});

		this.delete_duplicate_keystrokes();
		this.delete_stale_keystrokes();
		this.keystroke_recorded(ch);
	}

	private void delete_duplicate_keystrokes () {
		if (this.keystrokes.size <= 3) {
			return;
		}

		var last_char = this.keystrokes[keystrokes.size-1].character;
		var last_last_char = this.keystrokes[keystrokes.size-2].character;
		var last_last_last_char = this.keystrokes[keystrokes.size-3].character;

		if ((last_char == last_last_char) && (last_last_char == last_last_last_char)) {
			this.keystrokes.remove_at(keystrokes.size-1);
		}
	}

	private void delete_stale_keystrokes () {
		var now = new DateTime.now();
		var first_ts = this.keystrokes[0].timestamp;

		while (now.difference(first_ts) > this.interval_to_record) {
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
			debug ("%s: %s", stream_name, data);
			var ch = (new XInputLogParser()).parse_line(data);
			if (ch != null) {
				debug ("processed char: %s", ch.to_string());
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
