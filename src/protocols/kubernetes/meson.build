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

kubernetes_client_config = configuration_data()
kubernetes_client_config.merge_from(config)

# ----------------------------------------------------------------
# Dependencies
# ----------------------------------------------------------------

## threads
thread_dep = dependency('threads', required: true)

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
    kubernetes_client_config.set(
        'OPENSSL_REQUIRES_THREADING_CALLBACKS',
        '/**/',
        description: 'Whether OpenSSL requires explicit threading callbacks for threadsafety',
    )
endif

## libwebsockets
libwebsockets_dep = dependency('libwebsockets', required: true)

if cc.has_header_symbol(
    'libwebsockets.h',
    'LWS_CALLBACK_CLIENT_CLOSED',
    dependencies: libwebsockets_dep,
)
    kubernetes_client_config.set(
        'HAVE_LWS_CALLBACK_CLIENT_CLOSED',
        '/**/',
        description: 'Whether LWS_CALLBACK_CLIENT_CLOSED is defined',
    )
endif

# Older versions of libwebsockets may not define a flag for requesting
# global initialization of OpenSSL, instead performing that initialization
# by default
if cc.get_define(
    'LWS_SERVER_OPTION_DO_SSL_GLOBAL_INIT',
    prefix: '#include <libwebsockets.h>',
    dependencies: libwebsockets_dep,
) != ''
    kubernetes_client_config.set(
        'HAVE_LWS_SERVER_OPTION_DO_SSL_GLOBAL_INIT',
        '/**/',
        description: 'Whether LWS_SERVER_OPTION_DO_SSL_GLOBAL_INIT is defined',
    )
endif

# Older versions of libwebsockets do not define special macros for SSL
# connection flags, instead relying on documented integer values
if cc.has_header_symbol(
    'libwebsockets.h',
    'LCCSCF_USE_SSL',
    dependencies: libwebsockets_dep,
)
    kubernetes_client_config.set(
        'HAVE_LCCSCF_USE_SSL',
        '/**/',
        description: 'Whether LCCSCF_USE_SSL is defined',
    )
endif

# Older versions of libwebsockets do not define a dummy callback which
# must be invoked after the main event callback is invoked; the main event
# callback must instead manually return zero
if cc.has_function(
    'lws_callback_http_dummy',
    prefix: '#include <libwebsockets.h>',
    dependencies: libwebsockets_dep,
)
    kubernetes_client_config.set(
        'HAVE_LWS_CALLBACK_HTTP_DUMMY',
        '/**/',
        description: 'Whether lws_callback_http_dummy() is defined',
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

## libguac_terminal
if not is_variable('terminal_dep')
    error('terminal_dep not found. Please build libguac_terminal first.')
endif

# ----------------------------------------------------------------
# Shared Library
# ----------------------------------------------------------------
kubernetes_client_config_h = configure_file(
    output: 'config.h',
    configuration: kubernetes_client_config,
)

kubernetes_client_deps = [
    thread_dep,
    libssl_dep,
    libwebsockets_dep,
    common_dep,
    libguac_dep,
    terminal_dep,
]

kubernetes_client_inc = include_directories('.')

kubernetes_client_src = [
    'argv.c',
    'client.c',
    'clipboard.c',
    'input.c',
    'io.c',
    'pipe.c',
    'settings.c',
    'ssl.c',
    'kubernetes.c',
    'url.c',
    'user.c',
]

kubernetes_client_lib = shared_library(
    'guac_client_kubernetes',
    kubernetes_client_src + [kubernetes_client_config_h],
    dependencies: kubernetes_client_deps,
    c_args: ['-Werror', '-Wall', '-pedantic'],
    link_args: ['-Wl,--no-undefined'],
    install: true,
)


kubernetes_client_dep = declare_dependency(
    include_directories: kubernetes_client_inc,
    link_with: kubernetes_client_lib,
)


# ----------------------------------------------------------------
# Unit tests
# ----------------------------------------------------------------

# CUnit
cunit_dep = dependency('cunit', required: true)

test_kubernetes_client_src = ['tests/url/append.c', 'tests/url/escape.c']

test_kubernetes_client_inc = include_directories('tests')

# Generate test runner using the `generate-test-runner.pl` script
test_kubernetes_client_runner = custom_target(
    'test_kubernetes_client_runner',
    input: test_kubernetes_client_src,
    output: '_generated_runner.c',
    command: [
        meson.project_source_root() / 'util/generate-test-runner.pl',
        '@INPUT@',
    ],
    capture: true,
)

test_kubernetes_client_runner_exe = executable(
    'test_kubernetes_client',
    [test_kubernetes_client_runner] + test_kubernetes_client_src,
    include_directories: test_kubernetes_client_inc,
    dependencies: [cunit_dep, kubernetes_client_dep],
    c_args: ['-Werror', '-Wall', '-pedantic'],
)


test(
    'test_kubernetes_client',
    test_kubernetes_client_runner_exe,
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
