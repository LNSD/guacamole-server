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

telnet_client_config = configuration_data()

# ----------------------------------------------------------------
# Dependencies
# ----------------------------------------------------------------

## threads
thread_dep = dependency('threads', required: true)

## libtelnet
libtelnet_dep = dependency('libtelnet', required: true)

## libguac
if not is_variable('libguac_dep')
  error('libguac_dep not found. Please build libguac first.')
endif

## libguac_common
if not is_variable('common_dep')
  error('common_dep not found. Please build libguac_common first.')
endif

## libguac_terminal
if not is_variable('terminal_dep')
  error('terminal_dep not found. Please build libguac_terminal first.')
endif

# ----------------------------------------------------------------
# Shared Library
# ----------------------------------------------------------------
telnet_client_config_h = configure_file(
  output: 'config.h',
  configuration: telnet_client_config,
)

telnet_client_deps = [
  thread_dep,
  libtelnet_dep,
  libguac_dep,
  common_dep,
  terminal_dep,
]

telnet_client_inc = include_directories('.')

telnet_client_src = [
  'argv.c',
  'client.c',
  'clipboard.c',
  'input.c',
  'pipe.c',
  'settings.c',
  'telnet.c',
  'user.c',
]
telnet_client_lib = shared_library(
  'guac_client_telnet',
  telnet_client_src + [telnet_client_config_h],
  dependencies: telnet_client_deps,
  c_args: ['-Werror', '-Wall', '-pedantic'],
  link_args: ['-Wl,--no-undefined'],
  install: true,
)


telnet_client_dep = declare_dependency(
  include_directories: telnet_client_inc,
  link_with: telnet_client_lib,
)
