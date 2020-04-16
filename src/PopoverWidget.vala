public enum TypingSpeedUnit {
	WPM,
	CPM
}

public class Hackspeed.PopoverWidget {
	private Gtk.Widget gtk_widget;
	private TypingSpeedUnit typing_speed_unit = TypingSpeedUnit.WPM;

	public signal void typing_speed_preference_changed(TypingSpeedUnit new_unit);

	public PopoverWidget(TypingSpeedUnit typing_speed_unit) {
		this.typing_speed_unit = typing_speed_unit;

		var toggle_switch = new Granite.Widgets.ModeButton();
		toggle_switch.append_text("WPM");
		toggle_switch.append_text("CPM");
		toggle_switch.set_active(0);
		toggle_switch.hexpand = true;

		toggle_switch.mode_changed.connect(() => {
			if (toggle_switch.selected == 0) {
				this.typing_speed_unit = TypingSpeedUnit.WPM;
			} else {
				this.typing_speed_unit = TypingSpeedUnit.CPM;
			}

			this.typing_speed_preference_changed(this.typing_speed_unit);
		});

		var grid = new Gtk.Grid();
		grid.orientation = Gtk.Orientation.VERTICAL;
		grid.margin = 12;
		grid.add(toggle_switch);

		this.gtk_widget = grid;
	}

	public Gtk.Widget get_gtk_widget() {
		return this.gtk_widget;
	}
}
