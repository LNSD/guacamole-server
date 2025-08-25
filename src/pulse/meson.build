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

pulse_config = configuration_data()
pulse_config.merge_from(config)

# ----------------------------------------------------------------
# Dependencies
# ----------------------------------------------------------------

# libpulse
libpulse_dep = dependency('libpulse', required: get_option('pulse'))

if libpulse_dep.found()
    pulse_config.set(
        'ENABLE_PULSE',
        '/**/',
        description: 'Whether PulseAudio support is enabled',
    )
endif

## libguac
if not is_variable('libguac_dep')
    error('libguac_dep not found. Please build libguac first.')
endif

# ----------------------------------------------------------------
# Static Library
# ----------------------------------------------------------------
pulse_config_h = configure_file(output: 'config.h', configuration: pulse_config)

pulse_deps = [libguac_dep, libpulse_dep]

pulse_inc = include_directories('.')

pulse_src = ['pulse.c']

pulse_lib = static_library(
    'guac_pulse',
    pulse_src + [pulse_config_h],
    dependencies: pulse_deps,
    c_args: ['-Werror', '-Wall', '-pedantic'],
    link_args: ['-Wl,--no-undefined'],
)

pulse_dep = declare_dependency(
    include_directories: pulse_inc,
    link_with: pulse_lib,
)
