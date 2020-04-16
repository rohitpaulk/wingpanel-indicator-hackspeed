public class Hackspeed.TypingSpeedFormatter {
	private TypingSpeedUnit typing_speed_unit;

	public TypingSpeedFormatter(TypingSpeedUnit typing_speed_unit) {
		this.typing_speed_unit = typing_speed_unit;
	}

	public string format(TypingSpeed typing_speed) {
		if (typing_speed_unit == TypingSpeedUnit.WPM) {
			double wpm = typing_speed.words_per_minute();
			return "%s wpm".printf(Math.round(wpm).to_string());
		} else {
			double cpm = typing_speed.characters_per_minute();
			return "%s cpm".printf(Math.round(cpm).to_string());
		}
	}

	public string format_idle() {
		if (typing_speed_unit == TypingSpeedUnit.WPM) {
			return "0 wpm";
		} else {
			return "0 cpm";
		}
	}

	public string format_calculating() {
		if (typing_speed_unit == TypingSpeedUnit.WPM) {
			return "... wpm";
		} else {
			return "... cpm";
		}
	}
}
