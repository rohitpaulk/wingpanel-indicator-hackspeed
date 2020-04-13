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

public class Hackspeed.Indicator : Wingpanel.Indicator {
    private IndicatorWidget indicator_widget = null;
	private Hackspeed.KeystrokeRecorder keystroke_recorder;

    public Indicator (Wingpanel.IndicatorManager.ServerType server_type) {
		// Unique name
        Object (code_name: "wingpanel-indicator-hackspeed");

		this.keystroke_recorder = new Hackspeed.KeystrokeRecorder();
		this.keystroke_recorder.start("10");
		this.indicator_widget = new IndicatorWidget("0 wpm");

		this.keystroke_recorder.keystroke_recorded.connect(() => {
			this.indicator_widget.set_text(
				"%s wpm".printf(this.keystroke_recorder.get_recent_keystrokes_count().to_string())
			);
		});

		// Visible on startup
		this.visible = true;
    }

    public override Gtk.Widget get_display_widget () {
        return this.indicator_widget.get_gtk_widget();
    }

    public override Gtk.Widget? get_widget () {
		return new Gtk.Label("testing");
    }

    public override void opened () {}
    public override void closed () {}
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Hackspeed Indicator");

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        // We want to display our sample indicator only in the "normal" session,
        // not on the login screen, so stop here!
        return null;
    }

    var indicator = new Hackspeed.Indicator (server_type);
    return indicator;
}
