#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

cc = meson.get_compiler('c')

terminal_config = configuration_data()
terminal_config.merge_from(config)

# ----------------------------------------------------------------
# Dependencies
# ----------------------------------------------------------------

## cairo
cairo_dep = dependency('cairo', required: true)

## pango
pango_dep = dependency('pango', required: true)

## pangocairo
pangocairo_dep = dependency('pangocairo', required: true)

## libm
libm_dep = cc.find_library('m', required: true)

## threads
thread_dep = dependency('threads', required: true)

## libguac
if not is_variable('libguac_dep')
  error('libguac_dep not found. Please build libguac first.')
endif

## libguac_common
if not is_variable('common_dep')
  error('common_dep not found. Please build libguac_common first.')
endif

# ----------------------------------------------------------------
# Shared Library
# ----------------------------------------------------------------
terminal_config_h = configure_file(
  output: 'config.h',
  configuration: terminal_config,
)

terminal_deps = [
  cairo_dep,
  libm_dep,
  pango_dep,
  pangocairo_dep,
  thread_dep,
  common_dep,
  libguac_dep,
]

terminal_inc = include_directories('.')

terminal_src = [
  'buffer.c',
  'char-mappings.c',
  'color-scheme.c',
  'common.c',
  'display.c',
  'named-colors.c',
  'palette.c',
  'scrollbar.c',
  'select.c',
  'selection-point.c',
  'terminal.c',
  'terminal-handlers.c',
  'terminal-stdin-stream.c',
  'typescript.c',
  'xparsecolor.c',
]

terminal_lib = shared_library(
  'guac_terminal',
  terminal_src + [terminal_config_h],
  dependencies: terminal_deps,
  c_args: ['-Werror', '-Wall', '-pedantic'],
  link_args: ['-Wl,--no-undefined'],
  install: true,
)

terminal_dep = declare_dependency(
  include_directories: terminal_inc,
  link_with: terminal_lib,
)

# Public headers
install_headers(['terminal/terminal.h'], subdir: 'libguac/terminal')

# ----------------------------------------------------------------
# Unit tests
# ----------------------------------------------------------------

# CUnit
cunit_dep = dependency('cunit', required: true)

test_terminal_src = [
  'tests/selection-point/enclose-text.c',
  'tests/selection-point/point-after.c',
  'tests/selection-point/rounding.c',
]

test_terminal_inc = include_directories('tests')

# Generate test runner using the `generate-test-runner.pl` script
test_terminal_runner = custom_target(
  'test_terminal_runner',
  input: test_terminal_src,
  output: '_generated_runner.c',
  command: [
    meson.project_source_root() / 'util/generate-test-runner.pl',
    '@INPUT@',
  ],
  capture: true,
)

test_terminal_runner_exe = executable(
  'test_terminal',
  [test_terminal_runner] + test_terminal_src,
  include_directories: test_terminal_inc,
  dependencies: [cunit_dep, terminal_dep],
  c_args: ['-Werror', '-Wall', '-pedantic'],
)


test(
  'test_terminal',
  test_terminal_runner_exe,
  protocol: 'tap',
  env: environment(
    {
      # By default, MALLOC_PERTURB_ is set to a random value between 1..255. This helps find
      # memory leaks on configurations using glibc. Disable this behavior for tests.
      # See: https://mesonbuild.com/Unit-tests.html#malloc_perturb_
      'MALLOC_PERTURB_': '0',
    },
  ),
)
