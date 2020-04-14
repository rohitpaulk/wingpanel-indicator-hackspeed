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


public class Hackspeed.TypingSpeedCalculator {
	public signal void keystroke_recorded (char character);

	private int minimum_chars_for_calculation = 10;
	private int ignore_intervals_above_secs = 2;

	public TypingSpeed? calculate_speed(Gee.ArrayList<Keystroke?> keystrokes) {
		if (keystrokes.size < minimum_chars_for_calculation) {
			return null;
		}

		var first_ts = keystrokes[0].timestamp;
		var last_ts = keystrokes[keystrokes.size-1].timestamp;
		var total_interval_secs = (last_ts.difference(first_ts) / 1000000.0);

		var ignored_interval_secs = 0.0;

		DateTime previous_ts = keystrokes[0].timestamp;
		for (int i = 0; i < keystrokes.size; i++) {
			var current_ts = keystrokes[i].timestamp;

			var interval_secs = (current_ts.difference(previous_ts) / 1000000.0);
			if (interval_secs > this.ignore_intervals_above_secs) {
				ignored_interval_secs += interval_secs;
			}

			previous_ts = current_ts;
		}

		return TypingSpeed() {
			character_count = keystrokes.size,
			interval_secs = total_interval_secs - ignored_interval_secs
		};
	}
}
