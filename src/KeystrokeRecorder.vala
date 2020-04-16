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
	private TimeSpan interval_to_record = TimeSpan.SECOND * 20;

	[CCode (cname = "intercept_key_thread")]
	public extern void *intercept_key_thread ();

	public signal void captured (string keyvalue, bool released);

	// Not used, part of keycapture.c
	public signal void captured_mouse (int x, int y, int button);
	public signal void captured_move (int x, int y);

	public KeystrokeRecorder() {
		this.keystrokes = new Gee.ArrayList<Keystroke?>();
	}

	public void start(string keyboard_id) {
		debug("Recording keystrokes");

		try {
			//Thread.create<void*> (this.intercept_key_thread, true);
			new Thread<void*>.try (null, this.intercept_key_thread);
		} catch (Error e) {
			stderr.printf (e.message);
		}

		this.captured.connect((keyvalue, released) => {
			debug("Got key %s", keyvalue);
			if (released == true && keyvalue.length == 1) {
				this.record_keystroke((char) keyvalue);
			}
		});
	}

	public bool has_keystrokes() {
		return this.keystrokes.size > 0;
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
}
