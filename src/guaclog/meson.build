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

guaclog_config = configuration_data()
guaclog_config.merge_from(config)

# ----------------------------------------------------------------
# Dependencies
# ----------------------------------------------------------------

## libguac
if not is_variable('libguac_dep')
  error('libguac_dep not found. Please build libguac first.')
endif

# ----------------------------------------------------------------
# Executable
# ----------------------------------------------------------------
guaclog_config_h = configure_file(
  output: 'config.h',
  configuration: guaclog_config,
)

guaclog_deps = [libguac_dep]

guaclog_src = [
  'guaclog.c',
  'instructions.c',
  'instruction-key.c',
  'interpret.c',
  'keydef.c',
  'log.c',
  'state.c',
]

guaclog = executable(
  'guaclog',
  guaclog_src + [guaclog_config_h],
  dependencies: guaclog_deps,
  c_args: ['-Werror', '-Wall', '-pedantic'],
  install: true,
)

# ----------------------------------------------------------------
# Man pages
# ----------------------------------------------------------------
guaclog_man1 = configure_file(
  input: 'man/guaclog.1.in',
  output: 'guaclog.1',
  configuration: guaclog_config,
)

install_man([guaclog_man1])
