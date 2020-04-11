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
    private Gtk.Box? display_widget = null;
    private Gtk.StyleContext style_context;
	private Pid child_pid;
	private IOChannel child_stdout_channel;

    public Indicator (Wingpanel.IndicatorManager.ServerType server_type) {
		// Unique name
        Object (code_name: "wingpanel-indicator-hackspeed");

		// Visible on startup
		this.visible = true;

		int child_stdout;

		Process.spawn_async_with_pipes(
			"/tmp",
			{"sh", "-c", "xinput test 10"},
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
			return process_line(channel, condition, "stdout");
		});

		// debug ("Found pid");
		// debug (this.child_pid.to_string());
    }

	private static bool process_line (IOChannel channel, IOCondition condition, string stream_name) {
		if (condition == IOCondition.HUP) {
			debug ("%s: The fd has been closed.\n", stream_name);
			return false;
		}

		debug ("process_line called");

		try {
			string data;
			channel.read_line (out data, null, null);
			print ("%s: %s", stream_name, data);
		} catch (IOChannelError e) {
			print ("%s: IOChannelError: %s\n", stream_name, e.message);
			return false;
		} catch (ConvertError e) {
			print ("%s: ConvertError: %s\n", stream_name, e.message);
			return false;
		}

		return true;
	}

    public override Gtk.Widget get_display_widget () {
        if (display_widget == null) {
            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
            default_theme.add_resource_path ("/com.github.rohitpaulk.wingpanel-indicator-hackspeed");

            var icon = new Gtk.Spinner ();
			var text = new Gtk.Label("66 wpm");
            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("com.github.rohitpaulk.wingpanel-indicator-hackspeed/indicator.css");

            style_context = icon.get_style_context ();
            style_context.add_class ("night-light-icon");
            style_context.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

			icon.button_press_event.connect( (event) => { debug("clicked"); return false; } );

			this.display_widget = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			this.display_widget.add(icon);
			this.display_widget.add(text);
        }

        return this.display_widget;
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
