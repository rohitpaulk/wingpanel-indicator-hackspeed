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

public class Hackspeed.XInputLogParser {
	private Regex key_release_regex = /key release (\d+)/;

    private Gee.HashMap<string, char> key_map;

	// Parses a line of XInput logs and returns the
	// character that was entered.
	//
	// If the character isn't alphanumeric, null is returned.
	public char? parse_line(string log_line) {
		MatchInfo match;
		if (this.key_release_regex.match(log_line, 0, out match)) {
			var key_code = match.fetch(1);
			this.get_key_map();
			if (this.get_key_map().has_key(key_code)) {
				return this.get_key_map()[key_code];
			}
		}

		return null;
	}

	private Gee.HashMap<string, char> get_key_map() {
		if (this.key_map == null) {
			this.key_map = new Gee.HashMap<string, char>();

			// First row
			this.key_map["24"] = 'a';
			this.key_map["25"] = 'b';
			this.key_map["26"] = 'c';
			this.key_map["27"] = 'd';
			this.key_map["28"] = 'e';
			this.key_map["29"] = 'f';
			this.key_map["30"] = 'g';
			this.key_map["31"] = 'g';
			this.key_map["32"] = 'g';
			this.key_map["33"] = 'g';
			this.key_map["34"] = 'g';
			this.key_map["35"] = 'g';
			this.key_map["36"] = 'g';

			// Second row
			this.key_map["38"] = 'a';
			this.key_map["39"] = 'b';
			this.key_map["40"] = 'c';
			this.key_map["41"] = 'd';
			this.key_map["42"] = 'e';
			this.key_map["43"] = 'f';
			this.key_map["43"] = 'g';
			this.key_map["44"] = 'g';
			this.key_map["45"] = 'g';
			this.key_map["46"] = 'g';
			this.key_map["47"] = 'g';
			this.key_map["48"] = 'g';

			// Third row
			this.key_map["52"] = 'a';
			this.key_map["53"] = 'b';
			this.key_map["54"] = 'c';
			this.key_map["55"] = 'd';
			this.key_map["56"] = 'e';
			this.key_map["57"] = 'f';
			this.key_map["58"] = 'g';
			this.key_map["59"] = 'g';
			this.key_map["60"] = 'g';
			this.key_map["61"] = 'g';
			this.key_map["62"] = 'g';
			this.key_map["63"] = 'g';

			// Space bar
			this.key_map["65"] = 's';
		}

		return this.key_map;
	}
}
