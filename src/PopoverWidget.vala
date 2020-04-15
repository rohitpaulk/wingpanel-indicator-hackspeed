public class Hackspeed.PopoverWidget {
	private Gtk.Widget gtk_widget;

	public PopoverWidget() {
		var toggle_switch = new Granite.Widgets.ModeButton();
		toggle_switch.append_text("WPM");
		toggle_switch.append_text("CPM");
		toggle_switch.set_active(0);
		toggle_switch.hexpand = true;

		var keyboard_item_1 = new Gtk.CheckButton.with_label("Coolermaster 10");
		keyboard_item_1.set_active(true);
		keyboard_item_1.margin_top = 3;
		keyboard_item_1.margin_bottom = 3;
		var keyboard_item_2 = new Gtk.CheckButton.with_label("Apple built-in keyboard");
		keyboard_item_2.margin_top = 3;
		keyboard_item_2.margin_bottom = 3;

		var keyboards_grid = new Gtk.Grid();
		keyboards_grid.orientation = Gtk.Orientation.VERTICAL;
		keyboards_grid.margin_top = 6;
		keyboards_grid.margin_bottom = 12;
		keyboards_grid.add(new Granite.HeaderLabel("Keyboards"));
		keyboards_grid.add(keyboard_item_1);
		keyboards_grid.add(keyboard_item_2);

		var grid = new Gtk.Grid();
		grid.orientation = Gtk.Orientation.VERTICAL;
		grid.margin = 12;

		grid.add(toggle_switch);
		grid.add(keyboards_grid);

		this.gtk_widget = grid;
	}

	public Gtk.Widget get_gtk_widget() {
		return this.gtk_widget;
	}
}
