void test_honors_minimum_chars() {
	var calculator = new Hackspeed.TypingSpeedCalculator();
	assert (parser.calculate_speed({}) == null);
}

void main (string[] args) {
	Test.init(ref args);
	Test.add_func("/typing_speed_calculator/honors_minimum_char", honors_minimum_char);
	Test.run();
}
