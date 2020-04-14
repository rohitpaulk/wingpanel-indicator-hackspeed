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
			this.key_map["24"] = 'q';
			this.key_map["25"] = 'w';
			this.key_map["26"] = 'e';
			this.key_map["27"] = 'r';
			this.key_map["28"] = 't';
			this.key_map["29"] = 'y';
			this.key_map["30"] = 'u';
			this.key_map["31"] = 'i';
			this.key_map["32"] = 'o';
			this.key_map["33"] = 'p';
			this.key_map["34"] = '[';
			this.key_map["35"] = ']';

			// Second row
			this.key_map["38"] = 'a';
			this.key_map["39"] = 's';
			this.key_map["40"] = 'd';
			this.key_map["41"] = 'f';
			this.key_map["42"] = 'g';
			this.key_map["43"] = 'h';
			this.key_map["44"] = 'j';
			this.key_map["45"] = 'k';
			this.key_map["46"] = 'l';
			this.key_map["47"] = ';';
			this.key_map["48"] = '\'';

			// Third row
			this.key_map["52"] = 'z';
			this.key_map["53"] = 'x';
			this.key_map["54"] = 'c';
			this.key_map["55"] = 'v';
			this.key_map["56"] = 'b';
			this.key_map["57"] = 'n';
			this.key_map["58"] = 'm';
			this.key_map["59"] = ',';
			this.key_map["60"] = '.';
			this.key_map["61"] = '/';

			// Space bar
			this.key_map["65"] = ' ';
		}

		return this.key_map;
	}
}
