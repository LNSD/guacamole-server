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

cargo = find_program('cargo', required: true)

# ----------------------------------------------------------------
# Static library
# ----------------------------------------------------------------
core_lib = custom_target(
  'guac-core',
  command: [
    cargo,
    'build',
    '--package',
    'guac-core',
    '--profile',
    get_option('buildtype') == 'release' ? 'release' : 'dev',
    '--target-dir',
    meson.global_build_root() / 'cargo-target',
    '--artifact-dir',
    '@OUTDIR@',
    '--features',
    'ffi',
  ],
  output: ['libguac_core.a', 'libguac_core.rlib'],
  console: true,
  build_by_default: true,
  build_always_stale: true,
)

# Linker script for overriding functions
core_ld_override = meson.current_source_dir() / 'rand_override.ld'

core_dep = declare_dependency(link_with: core_lib[0])
