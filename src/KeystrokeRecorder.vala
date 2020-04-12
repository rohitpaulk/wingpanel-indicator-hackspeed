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


public class Hackspeed.KeystrokeRecorder {
	private Keystroke[] keystrokes;
	private string keyboard_id;

	private Pid child_pid;
	private IOChannel child_stdout_channel;

	public KeystrokeRecorder() {
		this.keystrokes = {};
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

	public void stop() {
		debug("Stopping recording");
	}

	private bool process_line (IOChannel channel, IOCondition condition, string stream_name) {
		if (condition == IOCondition.HUP) {
			debug ("%s: The fd has been closed.\n", stream_name);
			return false;
		}

		debug ("process_line called");

		try {
			string data;
			channel.read_line (out data, null, null);
			print ("%s: %s", stream_name, data);
			var ch = (new XInputLogParser()).parse_line(data);
			debug ("processed char: %s", (ch == null) ? "UNKNOWN" : ch.to_string());
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
