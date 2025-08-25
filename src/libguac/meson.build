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

libguac_config = configuration_data()
libguac_config.merge_from(config)

# ----------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------

if cc.has_function('clock_gettime')
    libguac_config.set(
        'HAVE_CLOCK_GETTIME',
        '/**/',
        description: 'Whether clock_gettime() is defined',
    )
endif

if cc.has_function('nanosleep')
    libguac_config.set(
        'HAVE_NANOSLEEP',
        '/**/',
        description: 'Whether nanosleep() is defined',
    )
endif

if cc.has_function('poll')
    libguac_config.set(
        'HAVE_POLL',
        '/**/',
        description: 'Whether poll() is defined',
    )
endif

if cc.has_function('sched_getaffinity')
    libguac_config.set(
        'HAVE_SCHED_GETAFFINITY',
        '/**/',
        description: 'Whether sched_getaffinity() is defined',
    )
endif

# String function checks
if cc.has_header_symbol('string.h', 'strlcpy')
    libguac_config.set(
        'HAVE_STRLCPY',
        '/**/',
        description: 'Whether strlcpy() is defined',
    )
endif

if cc.has_header_symbol('string.h', 'strnstr')
    libguac_config.set(
        'HAVE_STRNSTR',
        '/**/',
        description: 'Whether strnstr() is defined',
    )
endif

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
    libguac_config.set(
        'HAVE_CAIRO_FORMAT_STRIDE_FOR_WIDTH',
        '/**/',
        description: 'Whether cairo_format_stride_for_width() is defined',
    )
endif

## libjpeg
libjpeg_dep = dependency('libjpeg', 'jpeg', required: true)

## libpng (required)
libpng_dep = dependency('libpng', 'png', required: true)

if cc.check_header('pngstruct.h', dependencies: libpng_dep)
    libguac_config.set(
        'HAVE_PNGSTRUCT_H',
        '/**/',
        description: 'The <pngstruct.h> header file is available',
    )
endif

if cc.has_function(
    'png_get_io_ptr',
    prefix: '#include <png.h>',
    dependencies: libpng_dep,
)
    libguac_config.set(
        'HAVE_PNG_GET_IO_PTR',
        '/**/',
        description: 'The `png_get_io_ptr` function is defined',
    )
endif

## libdl
libdl_dep = cc.find_library('dl', required: true)

## librt
librt_dep = cc.find_library('rt', required: true)

## threads
thread_dep = dependency('threads', required: true)

libguac_config.set(
    'HAVE_LIBPTHREAD',
    '/**/',
    description: 'Whether libpthread was found',
)


## libuuid
libuuid_dep = dependency('uuid', 'ossp-uuid', required: true)

# Determine if we are compiling against libuuid or ossp-uuid
libuuid_has_ossp_uuid_header = cc.has_header(
    'ossp/uuid.h',
    dependencies: libuuid_dep,
)

# Validate uuid_make declaration
libuuid_has_uuid_make_fn = cc.has_header_symbol(
    libuuid_has_ossp_uuid_header ? 'ossp/uuid.h' : 'uuid.h',
    'uuid_make',
    dependencies: libuuid_dep,
)

if not libuuid_has_ossp_uuid_header and not libuuid_has_uuid_make_fn
    libguac_config.set(
        'HAVE_LIBUUID',
        '/**/',
        description: 'Whether libuuid is available',
    )
endif

if libuuid_has_ossp_uuid_header
    # Determines if the ossp/uuid.h header is available else use uuid.h
    libguac_config.set(
        'HAVE_OSSP_UUID_H',
        '/**/',
        description: 'OSSP uuid.h header available',
    )
endif

## libssl (optional)
libssl_dep = dependency('openssl', required: get_option('ssl'))

if libssl_dep.found()
    libguac_config.set(
        'ENABLE_SSL',
        '/**/',
        description: 'Whether SSL-related support is enabled',
    )
endif

## libwebp (optional)
libwebp_dep = dependency('libwebp', required: get_option('webp'))

libwebp_has_encode_header = cc.has_header(
    'webp/encode.h',
    dependencies: libwebp_dep,
    required: get_option('webp'),
)

if get_option('webp').enabled() or (get_option('webp').auto() and libwebp_dep.found()) and libwebp_has_encode_header
    libguac_config.set(
        'ENABLE_WEBP',
        '/**/',
        description: 'Whether WebP support is enabled',
    )
endif

## libwinsock (Windows only)
libwinsock_dep = cc.find_library(
    'wsock32',
    required: host_machine.system() == 'windows',
)

if libwinsock_dep.found()
    libguac_config.set(
        'ENABLE_WINSOCK',
        '/**/',
        description: 'Whether Windows Socket API support is enabled',
    )
endif


# ----------------------------------------------------------------
# Shared Library
# ----------------------------------------------------------------
libguac_config_h = configure_file(
    output: 'config.h',
    configuration: libguac_config,
)

libguac_deps = [
    cairo_dep,
    libdl_dep,
    libjpeg_dep,
    libpng_dep,
    thread_dep,
    librt_dep,
    libssl_dep,
    libuuid_dep,
    libwebp_dep,
    libwinsock_dep,
]

libguac_inc = include_directories('.')

libguac_headers = [
    'guacamole/argv.h',
    'guacamole/argv-constants.h',
    'guacamole/argv-fntypes.h',
    'guacamole/assert.h',
    'guacamole/audio.h',
    'guacamole/audio-fntypes.h',
    'guacamole/audio-types.h',
    'guacamole/client.h',
    'guacamole/client-constants.h',
    'guacamole/client-fntypes.h',
    'guacamole/client-types.h',
    'guacamole/display.h',
    'guacamole/display-constants.h',
    'guacamole/display-types.h',
    'guacamole/error.h',
    'guacamole/error-types.h',
    'guacamole/fifo.h',
    'guacamole/fifo-constants.h',
    'guacamole/fifo-types.h',
    'guacamole/fips.h',
    'guacamole/flag.h',
    'guacamole/flag-types.h',
    'guacamole/hash.h',
    'guacamole/layer.h',
    'guacamole/layer-types.h',
    'guacamole/mem.h',
    'guacamole/object.h',
    'guacamole/object-types.h',
    'guacamole/parser-constants.h',
    'guacamole/parser.h',
    'guacamole/parser-types.h',
    'guacamole/plugin-constants.h',
    'guacamole/plugin.h',
    'guacamole/pool.h',
    'guacamole/pool-types.h',
    'guacamole/protocol.h',
    'guacamole/protocol-constants.h',
    'guacamole/protocol-types.h',
    'guacamole/recording.h',
    'guacamole/rect.h',
    'guacamole/rect-types.h',
    'guacamole/rwlock.h',
    'guacamole/socket.h',
    'guacamole/socket-constants.h',
    'guacamole/socket-fntypes.h',
    'guacamole/socket-types.h',
    'guacamole/stream.h',
    'guacamole/stream-types.h',
    'guacamole/string.h',
    'guacamole/tcp.h',
    'guacamole/timestamp.h',
    'guacamole/timestamp-types.h',
    'guacamole/unicode.h',
    'guacamole/user.h',
    'guacamole/user-constants.h',
    'guacamole/user-fntypes.h',
    'guacamole/user-types.h',
    'guacamole/wol.h',
    'guacamole/wol-constants.h',
]

libguac_src = [
    'argv.c',
    'audio.c',
    'client.c',
    'display.c',
    'display-builtin-cursors.c',
    'display-cursor.c',
    'display-flush.c',
    'display-layer.c',
    'display-layer-list.c',
    'display-plan.c',
    'display-plan-combine.c',
    'display-plan-rect.c',
    'display-plan-search.c',
    'display-render-thread.c',
    'display-worker.c',
    'encode-jpeg.c',
    'encode-png.c',
    'error.c',
    'fifo.c',
    'fips.c',
    'flag.c',
    'hash.c',
    'id.c',
    'mem.c',
    'rwlock.c',
    'palette.c',
    'parser.c',
    'pool.c',
    'protocol.c',
    'raw_encoder.c',
    'recording.c',
    'rect.c',
    'socket.c',
    'socket-broadcast.c',
    'socket-fd.c',
    'socket-nest.c',
    'socket-tee.c',
    'string.c',
    'tcp.c',
    'timestamp.c',
    'unicode.c',
    'user.c',
    'user-handlers.c',
    'user-handshake.c',
    'wait-fd.c',
    'wol.c',
]


# Compile WebP support if available
if libwebp_dep.found() and libwebp_has_encode_header
    libguac_src += ['encode-webp.c']
    # Note: encode-webp.h is a private header, not installed
endif

# SSL support
if libssl_dep.found()
    libguac_src += ['socket-ssl.c']
    libguac_headers += ['guacamole/socket-ssl.h']
endif

# Winsock support
if libwinsock_dep.found()
    libguac_src += ['socket-wsa.c']
    libguac_headers += ['guacamole/socket-wsa.h']
endif

libguac_lib = shared_library(
    'guac',
    libguac_src + [libguac_config_h],
    dependencies: libguac_deps,
    c_args: ['-Werror', '-Wall', '-pedantic'],
    link_args: ['-Wl,--no-undefined'],
    install: true,
)

# Public headers
install_headers(libguac_headers, subdir: 'libguac')

# Private headers
install_headers(['guacamole/private/mem.h'], subdir: 'libguac/private')


libguac_dep = declare_dependency(
    include_directories: libguac_inc,
    link_with: libguac_lib,
)

# ----------------------------------------------------------------
# Unit tests
# ----------------------------------------------------------------

# CUnit
cunit_dep = dependency('cunit', required: true)

# Test dependencies
test_libguac_deps = [cunit_dep, libguac_dep]

# Test source files
test_libguac_src = [
    'tests/client/buffer_pool.c',
    'tests/client/layer_pool.c',
    'tests/fifo/fifo.c',
    'tests/flag/flag.c',
    'tests/id/generate.c',
    'tests/mem/alloc.c',
    'tests/mem/ckd_add.c',
    'tests/mem/ckd_add_or_die.c',
    'tests/mem/ckd_mul.c',
    'tests/mem/ckd_mul_or_die.c',
    'tests/mem/ckd_sub.c',
    'tests/mem/ckd_sub_or_die.c',
    'tests/mem/free.c',
    'tests/mem/realloc.c',
    'tests/mem/realloc_or_die.c',
    'tests/mem/zalloc.c',
    'tests/parser/append.c',
    'tests/parser/read.c',
    'tests/pool/next_free.c',
    'tests/protocol/base64_decode.c',
    'tests/protocol/guac_protocol_version.c',
    'tests/rect/align.c',
    'tests/rect/constrain.c',
    'tests/rect/extend.c',
    'tests/rect/init.c',
    'tests/rect/intersects.c',
    'tests/socket/fd_send_instruction.c',
    'tests/socket/nested_send_instruction.c',
    'tests/string/strdup.c',
    'tests/string/strlcat.c',
    'tests/string/strlcpy.c',
    'tests/string/strljoin.c',
    'tests/string/strnstr.c',
    'tests/unicode/charsize.c',
    'tests/unicode/read.c',
    'tests/unicode/strlen.c',
    'tests/unicode/write.c',
]

test_libguac_inc = include_directories('tests')

# Generate test runner using the `generate-test-runner.pl` script
test_libguac_runner = custom_target(
    'test_libguac_runner',
    input: test_libguac_src,
    output: '_generated_runner.c',
    command: [
        meson.project_source_root() / 'util/generate-test-runner.pl',
        '@INPUT@',
    ],
    capture: true,
)

test_libguac_runner_exe = executable(
    'test_libguac',
    [test_libguac_runner] + test_libguac_src + [libguac_config_h],
    include_directories: test_libguac_inc,
    dependencies: test_libguac_deps,
    c_args: ['-Werror', '-Wall', '-pedantic'],
)


test(
    'test_libguac',
    test_libguac_runner_exe,
    protocol: 'tap',
    env: environment(
        {
            # By default, MALLOC_PERTURB_ is set to a random value between 1..255. This helps find
            # memory leaks on configurations using glibc. Disable this behavior for tests.
            # See: https://mesonbuild.com/Unit-tests.html#malloc_perturb_
            'MALLOC_PERTURB_' : '0',
        },
    ),
)
