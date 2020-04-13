public class Hackspeed.IndicatorWidget {
	private string text;
	private Gtk.Label gtk_label;
	private Gtk.Box gtk_widget;
    private Gtk.StyleContext style_context;

	public IndicatorWidget(string text) {
		Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
		default_theme.add_resource_path ("/com.github.rohitpaulk.wingpanel-indicator-hackspeed");

		var icon = new Gtk.Spinner ();
		this.gtk_label = new Gtk.Label(text);

		var provider = new Gtk.CssProvider ();
		provider.load_from_resource ("com.github.rohitpaulk.wingpanel-indicator-hackspeed/indicator.css");

		this.style_context = icon.get_style_context ();
		style_context.add_class ("night-light-icon");
		style_context.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

		icon.button_press_event.connect( (event) => { debug("clicked"); return false; } );

		this.gtk_widget = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		this.gtk_widget.add(icon);
		this.gtk_widget.add(this.gtk_label);
	}

	public Gtk.Widget get_gtk_widget() {
		return this.gtk_widget;
	}

	public void set_text(string text) {
		this.gtk_label.set_label(text);
	}
}
