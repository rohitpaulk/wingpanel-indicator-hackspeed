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
    meson.get_compiler('vala').find_library('posix'),
    dependency('gtk+-3.0'),
    dependency('x11'),
    dependency('xtst'),
    wingpanel_dep
]

sources = [
    'src/Indicator.vala',
    'src/IndicatorWidget.vala',
    'src/PopoverWidget.vala',
    'src/KeystrokeRecorder.vala',
    'src/TypingSpeedCalculator.vala',
    'src/keycapture.c',
]

shared_module(
    meson.project_name(),
    sources,
    asresources,
    dependencies: deps,
    install: true,
    install_dir : wingpanel_indicatorsdir
)

typing_speed_calculator_test = executable(
    'test_typing_speed_calculator',
    'src/TypingSpeedCalculatorTest.vala',
    'src/TypingSpeedCalculator.vala',
    'src/KeystrokeRecorder.vala',
    'src/keycapture.c',
    dependencies: deps
)

test('typing_speed_calculator_test', typing_speed_calculator_test)

subdir('data')
subdir('po')
