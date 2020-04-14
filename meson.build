project(
    'hackspeed',
    'vala', 'c',
    version: '2.0.3'
)

gettext_name = meson.project_name() + '-indicator'
gnome = import('gnome')
i18n = import('i18n')

prefix = get_option('prefix')
libdir = join_paths(prefix, get_option('libdir'))

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(gettext_name), language:'c')

asresources = gnome.compile_resources(
    'as-resources', 'data/com.github.rohitpaulk.wingpanel-indicator-hackspeed.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

wingpanel_dep = dependency('wingpanel-2.0')
wingpanel_indicatorsdir = wingpanel_dep.get_pkgconfig_variable('indicatorsdir', define_variable: ['libdir', libdir])

deps = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('granite'),
    dependency('gtk+-3.0'),
    wingpanel_dep
]

shared_module(
    meson.project_name(),
    'src/Indicator.vala',
    'src/IndicatorWidget.vala',
    'src/KeystrokeRecorder.vala',
    'src/XInputLogParser.vala',
    'src/TypingSpeedCalculator.vala',
    asresources,
    dependencies: deps,
    install: true,
    install_dir : wingpanel_indicatorsdir
)

xinput_log_parser_test = executable(
    'test_xinput_log_parser',
    'src/XInputLogParser.vala',
    'src/XInputLogParserTest.vala',
    dependencies: deps
)

typing_speed_calculator_test = executable(
    'test_typing_speed_calculator',
    'src/TypingSpeedCalculator.vala',
    'src/TypingSpeedCalculatorTest.vala',
    'src/KeystrokeRecorder.vala',
    'src/XInputLogParser.vala',
    dependencies: deps
)

test('xinput_log_parser_test', xinput_log_parser_test)
test('typing_speed_calculator_test', typing_speed_calculator_test)

subdir('data')
subdir('po')
