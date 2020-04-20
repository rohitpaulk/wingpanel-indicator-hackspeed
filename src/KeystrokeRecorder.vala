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
	public signal void keystroke_recorded ();

	private KeystrokeCollection keystroke_collection;

	[CCode (cname = "intercept_key_thread")]
	public extern void *intercept_key_thread ();

	public signal void captured (string keyvalue, bool released);

	public signal void captured_mouse (int x, int y, int button);
	public signal void captured_move (int x, int y);

	private Thread<void*> recorder_thread;

	public KeystrokeRecorder() {
		this.keystroke_collection = new KeystrokeCollection();
	}

	public void start() {
		debug("Recording keystrokes");

		this.start_recorder_thread();
		this.captured.connect((keyvalue, released) => {
			if (released == true) {
				debug("Got key %s", keyvalue);
			}
			if (released == true && keyvalue.length == 1) {
				this.record_keystroke((char) keyvalue);
			}
		});
	}

	private void start_recorder_thread() {
		try {
			this.recorder_thread = new Thread<void*>.try ("wpmrecorder", this.intercept_key_thread);
			debug("Intercept thread has been setup");
		} catch (Error e) {
			stderr.printf (e.message);
		}
	}

	public bool has_keystrokes() {
		return this.keystroke_collection.has_keystrokes();
	}

	public TypingSpeed? get_typing_speed() {
		return (new TypingSpeedCalculator()).calculate_speed(this.keystroke_collection.keystrokes);
	}

	public void reset_keystrokes() {
		this.keystroke_collection = new KeystrokeCollection();
	}

	private void record_keystroke (char ch) {
		this.keystroke_collection.add(Keystroke() {
			timestamp = new DateTime.now(),
			character = ch
		});

		this.keystroke_recorded();
	}
}
