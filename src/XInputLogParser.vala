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
			this.key_map["38"] = 'a';
			this.key_map["39"] = 'b';
			this.key_map["40"] = 'c';
		}

		return this.key_map;
	}
}
