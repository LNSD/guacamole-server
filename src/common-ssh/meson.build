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

common_ssh_config = configuration_data()
common_ssh_config.merge_from(config)

# ----------------------------------------------------------------
# Dependencies
# ----------------------------------------------------------------

## threads
thread_dep = dependency('threads', required: true)

## libssh2
libssh2_dep = dependency('libssh2', required: true)

# Underlying crypto library usage of libssh2
# Check if libssh2 was built against libgcrypt
if cc.has_function('gcry_control', dependencies: libssh2_dep)
    if cc.has_header('gcrypt.h')
        common_ssh_config.set(
            'LIBSSH2_USES_GCRYPT',
            '/**/',
            description: 'Whether libssh2 was built against libgcrypt',
        )
    else
        error('libssh2 requires libgcrypt headers')
    endif
endif

## libssl
libssl_dep = dependency('openssl', required: true)

# OpenSSL 1.1 does away with explicit threading callbacks
openssl_threading_check = '''
    #include <openssl/opensslv.h>
    
    #if OPENSSL_VERSION_NUMBER < 0x10100000L
    #error Threading callbacks required.
    #endif
    
    int main() {
        return 0;
    }
'''

if not cc.compiles(
    openssl_threading_check,
    dependencies: libssl_dep,
    name: 'OpenSSL threading callbacks check',
)
    # OpenSSL < 1.1 requires explicit threading callbacks
    common_ssh_config.set(
        'OPENSSL_REQUIRES_THREADING_CALLBACKS',
        '/**/',
        description: 'Whether OpenSSL requires explicit threading callbacks for threadsafety',
    )
endif

## libguac
if not is_variable('libguac_dep')
    error('libguac_dep not found. Please build libguac first.')
endif

## libguac_common
if not is_variable('common_dep')
    error('common_dep not found. Please build libguac_common first.')
endif

# ----------------------------------------------------------------
# Static Library
# ----------------------------------------------------------------
common_ssh_config_h = configure_file(
    output: 'config.h',
    configuration: common_ssh_config,
)

common_ssh_deps = [thread_dep, libssh2_dep, libssl_dep, common_dep, libguac_dep]

common_ssh_inc = include_directories('.')

common_ssh_src = ['buffer.c', 'sftp.c', 'ssh.c', 'key.c', 'user.c']

common_ssh_lib = static_library(
    'guac_common_ssh',
    common_ssh_src + [common_ssh_config_h],
    dependencies: common_ssh_deps,
    c_args: ['-Werror', '-Wall', '-pedantic'],
    link_args: ['-Wl,--no-undefined'],
)

common_ssh_dep = declare_dependency(
    include_directories: common_ssh_inc,
    link_with: common_ssh_lib,
)

# ----------------------------------------------------------------
# Unit tests
# ----------------------------------------------------------------

# CUnit
cunit_dep = dependency('cunit', required: true)

test_common_ssh_src = ['tests/sftp/normalize_path.c']

test_common_ssh_inc = include_directories('tests')

# Generate test runner using the `generate-test-runner.pl` script
test_common_ssh_runner = custom_target(
    'test_common_ssh_runner',
    input: test_common_ssh_src,
    output: '_generated_runner.c',
    command: [
        meson.project_source_root() / 'util/generate-test-runner.pl',
        '@INPUT@',
    ],
    capture: true,
)

test_common_ssh_runner_exe = executable(
    'test_common_ssh',
    [test_common_ssh_runner] + test_common_ssh_src,
    include_directories: test_common_ssh_inc,
    dependencies: [cunit_dep, libguac_dep, common_dep, common_ssh_dep],
    c_args: ['-Werror', '-Wall', '-pedantic'],
)


test(
    'test_common_ssh',
    test_common_ssh_runner_exe,
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
