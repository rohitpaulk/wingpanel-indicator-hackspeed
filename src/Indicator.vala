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
    private PopoverWidget popover_widget = null;
	private KeystrokeRecorder keystroke_recorder;
	private DateTime speed_updated_at = null;
	private DateTime last_event_at = null;
	private TimeSpan update_every = 2 * TimeSpan.SECOND;
	private TimeSpan idle_timeout = 10 * TimeSpan.SECOND;

	private TypingSpeedUnit typing_speed_unit = TypingSpeedUnit.WPM;

    public Indicator (Wingpanel.IndicatorManager.ServerType server_type) {
		// Unique name
        Object (code_name: "wingpanel-indicator-hackspeed");

		this.keystroke_recorder = new Hackspeed.KeystrokeRecorder();
		this.keystroke_recorder.start("10");
		this.indicator_widget = new IndicatorWidget(this.speed_formatter().format_idle());

		this.keystroke_recorder.keystroke_recorded.connect(() => {
			this.last_event_at = (new DateTime.now());
			if (this.speed_updated_at == null || (new DateTime.now()).difference(this.speed_updated_at) >= update_every) {
				this.update_speed_label();
			}
		});

		// Value is idle_timeout / 2
		Timeout.add_seconds(5, this.tick_handler);

		// Visible on startup
		this.visible = true;

		this.popover_widget = new PopoverWidget(this.typing_speed_unit);
		this.popover_widget.typing_speed_preference_changed.connect((new_unit) => {
			this.typing_speed_unit = new_unit;
			this.update_speed_label();
		});
    }

	public bool tick_handler() {
		// If we haven't received an event yet, no resetting to do
		if (last_event_at == null) {
			return true;
		}

		// If the last event was within the idle timeout, no resetting to do
		if ((new DateTime.now()).difference(this.last_event_at) < idle_timeout) {
			return true;
		}

		debug("Resetting wpm indicator due to inactivity");
		this.reset();

		return true;
	}

	public void reset() {
		this.speed_updated_at = null;
		this.last_event_at = null;
		this.indicator_widget.set_text(this.speed_formatter().format_idle());

		this.keystroke_recorder.reset_keystrokes();
	}

	private void update_speed_label() {
		var typing_speed = this.keystroke_recorder.get_typing_speed();

		if (typing_speed == null) {
			if (this.keystroke_recorder.has_keystrokes()) {
				this.indicator_widget.set_text(this.speed_formatter().format_calculating());
			} else {
				this.indicator_widget.set_text(this.speed_formatter().format_idle());
			}
		} else {
			this.indicator_widget.set_text(this.speed_formatter().format(typing_speed));
			this.speed_updated_at = new DateTime.now();
		}
	}

	private TypingSpeedFormatter speed_formatter() {
		return new TypingSpeedFormatter(this.typing_speed_unit);
	}


    public override Gtk.Widget get_display_widget () {
        return this.indicator_widget.get_gtk_widget();
    }

    public override Gtk.Widget? get_widget () {
		return this.popover_widget.get_gtk_widget();
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
