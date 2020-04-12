void test_ignores_invalid_line() {
	var parser = new Hackspeed.XInputLogParser();
	assert (parser.parse_line("key press 40") == null);
}

void test_ignores_press_line() {
	var parser = new Hackspeed.XInputLogParser();
	assert (parser.parse_line("key press 40") == null);
}

void test_parses_char() {
	var parser = new Hackspeed.XInputLogParser();
	assert (parser.parse_line("key release 38") == 'a');
	assert (parser.parse_line("key release 39") == 'b');
	assert (parser.parse_line("key release 40") == 'c');
}

void test_ignores_unknown_char() {
	var parser = new Hackspeed.XInputLogParser();
	assert (parser.parse_line("key release 41") == null);
}

void main (string[] args) {
	Test.init(ref args);
	Test.add_func("/xinput_parser/ignores_invalid_line", test_ignores_invalid_line);
	Test.add_func("/xinput_parser/ignores_press_line", test_ignores_press_line);
	Test.add_func("/xinput_parser/parses_char", test_parses_char);
	Test.add_func("/xinput_parser/ignores_unknown_char", test_ignores_unknown_char);
	Test.run();
}
