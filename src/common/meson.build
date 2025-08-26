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

common_config = configuration_data()
common_config.merge_from(config)

# ----------------------------------------------------------------
# Dependencies
# ----------------------------------------------------------------

## cairo
cairo_dep = dependency('cairo', required: true)

if cc.has_function(
  'cairo_format_stride_for_width',
  prefix: '#include <cairo/cairo.h>',
  dependencies: cairo_dep,
)
  common_config.set(
    'HAVE_CAIRO_FORMAT_STRIDE_FOR_WIDTH',
    '/**/',
    description: 'Whether cairo_format_stride_for_width() is defined',
  )
endif

## threads
thread_dep = dependency('threads', required: true)

## libguac
if not is_variable('libguac_dep')
  error('libguac_dep not found. Please build libguac first.')
endif

# ----------------------------------------------------------------
# Static Library
# ----------------------------------------------------------------
common_config_h = configure_file(
  output: 'config.h',
  configuration: common_config,
)

common_deps = [cairo_dep, thread_dep, libguac_dep]

common_inc = include_directories('.')

common_src = [
  'io.c',
  'blank_cursor.c',
  'clipboard.c',
  'cursor.c',
  'dot_cursor.c',
  'ibar_cursor.c',
  'iconv.c',
  'json.c',
  'list.c',
  'pointer_cursor.c',
  'rect.c',
  'string.c',
  'surface.c',
]

common_lib = static_library(
  'guac_common',
  common_src + [common_config_h],
  dependencies: common_deps,
  c_args: ['-Werror', '-Wall', '-pedantic'],
  link_args: ['-Wl,--no-undefined'],
)


common_dep = declare_dependency(
  include_directories: common_inc,
  link_with: common_lib,
)


# ----------------------------------------------------------------
# Unit tests
# ----------------------------------------------------------------

# CUnit
cunit_dep = dependency('cunit', required: true)

test_common_src = [
  'tests/iconv/convert.c',
  'tests/iconv/convert-test-data.c',
  'tests/rect/clip_and_split.c',
  'tests/rect/constrain.c',
  'tests/rect/expand_to_grid.c',
  'tests/rect/extend.c',
  'tests/rect/init.c',
  'tests/rect/intersects.c',
  'tests/string/count_occurrences.c',
  'tests/string/split.c',
]

test_common_inc = include_directories('tests')

# Generate test runner using the `generate-test-runner.pl` script
test_common_runner = custom_target(
  'test_common_runner',
  input: test_common_src,
  output: '_generated_runner.c',
  command: [
    meson.project_source_root() / 'util/generate-test-runner.pl',
    '@INPUT@',
  ],
  capture: true,
)

test_common_runner_exe = executable(
  'test_common',
  [test_common_runner] + test_common_src,
  include_directories: test_common_inc,
  dependencies: [cunit_dep, libguac_dep, common_dep],
  c_args: ['-Werror', '-Wall', '-pedantic'],
)


test(
  'test_common',
  test_common_runner_exe,
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
