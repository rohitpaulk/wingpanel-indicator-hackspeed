void test_honors_minimum_chars() {
	var calculator = new Hackspeed.TypingSpeedCalculator();

	var zero_keys = create_n_keystrokes(0);
	assert (calculator.calculate_speed(zero_keys) == null);

	var below_threshold = create_n_keystrokes(5);
	assert (calculator.calculate_speed(below_threshold) == null);

	var above_threshold = create_n_keystrokes(11);
	assert (calculator.calculate_speed(above_threshold) != null);
}

void test_discards_intervals_greater_than_2_secs() {
	var calculator = new Hackspeed.TypingSpeedCalculator();

	var typing_start = new DateTime.now();
	var pause_start = typing_start.add(TimeSpan.SECOND * 10);

	var pause_end = typing_start.add(TimeSpan.SECOND * 15);
	var typing_end = typing_start.add(TimeSpan.SECOND * 20);

	var keystrokes = create_keystrokes(30, typing_start, typing_end);
	assert (calculator.calculate_speed(keystrokes).words_per_minute() == 18);

	// With a 5 second pause
	keystrokes = create_keystrokes(20, typing_start, pause_start);
	keystrokes.add_all(create_keystrokes(10, pause_end, typing_end));
	assert (calculator.calculate_speed(keystrokes).words_per_minute() == 24);
}

Gee.ArrayList<Keystroke?> create_n_keystrokes(int count) {
	return create_keystrokes(count, new DateTime.now(), (new DateTime.now()).add(TimeSpan.SECOND * 10));
}

Gee.ArrayList<Keystroke?> create_keystrokes(int count, DateTime start_at, DateTime end_at) {
	var interval_microsecs = (int64) end_at.difference(start_at);
	var keystrokes = new Gee.ArrayList<Keystroke?>();
	for (int x = 0; x < count; x++) {
		keystrokes.add(Keystroke() {
			timestamp = start_at.add_seconds(
				(1 / 1000000.0) * interval_microsecs * x / (count - 1)
			),
			character = 'a'
		});
	}

	return keystrokes;
}

void main (string[] args) {
	Test.init(ref args);
	Test.add_func("/typing_speed_calculator/honors_minimum_char", test_honors_minimum_chars);
	Test.add_func("/typing_speed_calculator/discards_intervals", test_discards_intervals_greater_than_2_secs);
	Test.run();
}
