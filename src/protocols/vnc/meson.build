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

vnc_client_config = configuration_data()
vnc_client_config.merge_from(config)

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
    vnc_client_config.set(
        'HAVE_CAIRO_FORMAT_STRIDE_FOR_WIDTH',
        '/**/',
        description: 'Whether cairo_format_stride_for_width() is defined',
    )
endif

## libvncclient
libvncclient_dep = dependency('libvncclient', required: true)

# Check if libvncserver was built against libgcrypt
if cc.get_define(
    'LIBVNCSERVER_WITH_CLIENT_GCRYPT',
    prefix: '#include <rfb/rfbconfig.h>',
    dependencies: libvncclient_dep,
) != ''
    vnc_client_config.set(
        'LIBVNCSERVER_WITH_CLIENT_GCRYPT',
        '/**/',
        description: 'Whether libvncserver was built with GCrypt support.',
    )
    if not cc.has_header('gcrypt.h')
        error(
            'libvncserver appears to be built against libgcrypt, but the libgcrypt headers could not be found.',
        )
    endif
endif

# VNC feature support checks using arrays for better maintainability
vnc_member_features = [
    {
        'members' : ['destHost', 'destPort'],
        'enable_var' : 'enable_vnc_repeater',
        'config_name' : 'ENABLE_VNC_REPEATER',
        'description' : 'Whether support for VNC repeaters is enabled.',
    },
    {
        'members' : ['LockWriteToTLS', 'UnlockWriteToTLS'],
        'enable_var' : 'enable_vnc_tls_locking',
        'config_name' : 'ENABLE_VNC_TLS_LOCKING',
        'description' : 'Whether support for TLS locking within VNC is enabled.',
    },
    {
        'members' : ['GetCredential'],
        'enable_var' : 'enable_vnc_generic_credentials',
        'config_name' : 'ENABLE_VNC_GENERIC_CREDENTIALS',
        'description' : 'Whether support for generic VNC credentials is available.',
    },
    {
        'members' : ['requestedResize'],
        'enable_var' : 'enable_vnc_requested_resize',
        'config_name' : 'LIBVNC_CLIENT_HAS_REQUESTED_RESIZE',
        'description' : 'Whether rfbClient contains the requestedResize member.',
    },
]

foreach feature : vnc_member_features
    feature_available = cc.has_members(
        'rfbClient',
        feature['members'],
        prefix: '#include <rfb/rfbclient.h>',
        dependencies: libvncclient_dep,
    )

    # Set the enable variable dynamically
    set_variable(feature['enable_var'], feature_available)

    if feature_available
        vnc_client_config.set(
            feature['config_name'],
            '/**/',
            description: feature['description'],
        )
    endif
endforeach

# Listening support within libVNCServer (function check, not member check)
have_vnc_listen = cc.has_function(
    'listenForIncomingConnections',
    prefix: '#include <rfb/rfbclient.h>',
    dependencies: libvncclient_dep,
)

if have_vnc_listen
    vnc_client_config.set(
        'ENABLE_VNC_LISTEN',
        '/**/',
        description: 'Whether support for listen-mode VNC connections is enabled.',
    )
endif

# VNC resize support (requires both type and member checks)
have_vnc_rfb_set_desktop_size_msg = cc.has_type(
    'rfbSetDesktopSizeMsg',
    prefix: '#include <rfb/rfbproto.h>',
    dependencies: libvncclient_dep,
)
have_rfb_client_screen = cc.has_members(
    'rfbClient',
    'screen',
    prefix: '#include <rfb/rfbclient.h>',
    dependencies: libvncclient_dep,
)

if have_vnc_rfb_set_desktop_size_msg and have_rfb_client_screen
    vnc_client_config.set(
        'LIBVNC_HAS_RESIZE_SUPPORT',
        '/**/',
        description: 'Whether VNC client will support sending desktop size messages.',
    )
else
    warning(
        '''
The libvncclient library lacks support for either the rfbSetDesktopSizeMsg
message or for extended screen support. Resizing of remote displays will be disabled.
        ''',
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

## libguac_common_ssh (optional)
if get_option('ssh').enabled() and not is_variable('common_ssh_dep')
    error('common_ssh_dep not found. Please build libguac_common_ssh first.')
endif

if get_option('ssh').enabled()
    vnc_client_config.set(
        'ENABLE_COMMON_SSH',
        '/**/',
        description: 'Whether libguac_common_ssh is available for SSH/SFTP support.',
    )
endif

## libguac_pulse (optional)
if get_option('pulse').enabled() and not is_variable('pulse_dep')
    error('pulse_dep not found. Please build libguac_pulse first.')
endif

if get_option('pulse').enabled()
    vnc_client_config.set(
        'ENABLE_PULSE',
        '/**/',
        description: 'Whether PulseAudio support is enabled.',
    )
endif

# ----------------------------------------------------------------
# Shared Library
# ----------------------------------------------------------------
vnc_client_config_h = configure_file(
    output: 'config.h',
    configuration: vnc_client_config,
)

vnc_client_deps = [cairo_dep, libvncclient_dep, libguac_dep, common_dep]

vnc_client_inc = include_directories('.')

vnc_client_src = [
    'argv.c',
    'auth.c',
    'client.c',
    'clipboard.c',
    'cursor.c',
    'display.c',
    'input.c',
    'log.c',
    'settings.c',
    'user.c',
    'vnc.c',
]

# Optional SFTP support
if get_option('ssh').enabled()
    vnc_client_src += ['sftp.c']
    vnc_client_deps += [common_ssh_dep]
endif

# Optional PulseAudio support
if get_option('pulse').enabled()
    vnc_client_deps += [pulse_dep]
endif

vnc_client_lib = shared_library(
    'guac_client_vnc',
    vnc_client_src + [vnc_client_config_h],
    dependencies: vnc_client_deps,
    c_args: ['-Werror', '-Wall', '-pedantic'],
    link_args: ['-Wl,--no-undefined'],
    install: true,
)


vnc_client_dep = declare_dependency(
    include_directories: vnc_client_inc,
    link_with: vnc_client_lib,
)
