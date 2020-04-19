
public class Hackspeed.KeystrokeCollection {
	public Gee.ArrayList<Keystroke?> keystrokes;

	private TimeSpan interval_to_keep = TimeSpan.SECOND * 20;

	public KeystrokeCollection() {
		this.keystrokes = new Gee.ArrayList<Keystroke?>();

	}

	public bool has_keystrokes() {
		return this.keystrokes.size > 0;
	}

	public void add(Keystroke keystroke) {
		this.keystrokes.add(keystroke);
		this.delete_duplicate_keystrokes();
		this.delete_stale_keystrokes();
	}

	private void delete_duplicate_keystrokes () {
		if (this.keystrokes.size <= 3) {
			return;
		}

		var last_char = this.keystrokes[keystrokes.size-1].character;
		var last_last_char = this.keystrokes[keystrokes.size-2].character;
		var last_last_last_char = this.keystrokes[keystrokes.size-3].character;

		if ((last_char == last_last_char) && (last_last_char == last_last_last_char)) {
			this.keystrokes.remove_at(keystrokes.size-1);
		}
	}

	private void delete_stale_keystrokes () {
		var now = new DateTime.now();
		var first_ts = this.keystrokes[0].timestamp;

		while (now.difference(first_ts) > this.interval_to_keep) {
			debug("deleted stale timestamp");
			this.keystrokes.remove_at(0);
			first_ts = this.keystrokes[0].timestamp;
		}
	}
}
