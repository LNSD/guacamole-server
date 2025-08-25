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

rdp_client_config = configuration_data()
rdp_client_config.merge_from(config)

# ----------------------------------------------------------------
# Dependencies
# ----------------------------------------------------------------

## FreeRDP (libfreerdp2/3, libfreerdp-client2/3, and libwinpr2/3)
freerdp_plugin_dir = ''

# Try FreeRDP 2.x first
freerdp2_dep = dependency('freerdp2', required: false)
freerdp_client2_dep = dependency('freerdp-client2', required: false)
winpr2_dep = dependency('winpr2', required: false)

if freerdp2_dep.found() and freerdp_client2_dep.found() and winpr2_dep.found()
    libfreerdp_dep = freerdp2_dep
    libfreerdp_client_dep = freerdp_client2_dep
    libwinpr_dep = winpr2_dep

    # Get FreeRDP plugin directory
    freerdp_plugin_dir_opt = get_option('freerdp_plugin_dir')
    if freerdp_plugin_dir_opt != ''
        freerdp_plugin_dir = freerdp_plugin_dir_opt
    else
        freerdp_plugin_dir = freerdp2_dep.get_variable(pkgconfig: 'libdir') / 'freerdp2'
    endif
else
    # Try FreeRDP 3.x (if 2.x not found)
    libfreerdp_dep = dependency('freerdp3', required: false)
    libfreerdp_client_dep = dependency('freerdp-client3', required: false)
    libwinpr_dep = dependency('winpr3', required: false)

    # Get FreeRDP plugin directory
    freerdp_plugin_dir_opt = get_option('freerdp_plugin_dir')
    if freerdp_plugin_dir_opt != ''
        freerdp_plugin_dir = freerdp_plugin_dir_opt
    else
        freerdp_plugin_dir = libfreerdp_dep.get_variable(pkgconfig: 'libdir') / 'freerdp3'
    endif
endif

if not libfreerdp_dep.found() or not libfreerdp_client_dep.found() or not libwinpr_dep.found()
    error('FreeRDP (libfreerdp, libfreerdp-client, and libwinpr) not found')
endif

# Check if building against development version (unless allowed)
if not get_option('allow_freerdp_snapshots').enabled()
    # Get FreeRDP version string to check if it's a development version
    freerdp_version_str = cc.get_define(
        'FREERDP_VERSION_FULL',
        prefix: '#include <freerdp/version.h>',
        dependencies: libfreerdp_dep,
    )
    
    # Check if version matches release pattern: x.y.z or x.y.z-rcN
    # Development versions typically contain git commit info or other non-standard formats
    if freerdp_version_str != ''
        freerdp_version_str = freerdp_version_str.strip('"')
        
        # Use grep to match standard release version pattern (same as autotools)
        version_check = run_command(
            'sh', '-c', 'echo "@0@" | grep -E "^[0-9]+\\.[0-9]+\\.[0-9]+(-rc[0-9]+)?$"'.format(freerdp_version_str),
            check: false,
        )
        
        # If grep doesn't match (exit code != 0), it's a development version
        if version_check.returncode() != 0
            error('''
--------------------------------------------
You are building against a development version of FreeRDP (@0@). Non-release
versions of FreeRDP may have differences in behavior that are impossible to
check for at build time. This may result in memory leaks or other strange
behavior.

*** PLEASE USE A RELEASED VERSION OF FREERDP IF POSSIBLE ***

If you are ABSOLUTELY CERTAIN that building against this version of FreeRDP
is OK, rerun configure with -Dallow_freerdp_snapshots=true
--------------------------------------------'''.format(freerdp_version_clean))
        endif
    endif
endif

# Various FreeRDP version compatibility checks -------------------------

# FreeRDP renamed ConvertColor() to FreeRDPConvertColor() during 2.0.0-rc series
# to avoid macOS naming conflicts. Compilation test used since it's a static inline function.
freerdp_convertcolor_check = '''
    #define _GNU_SOURCE
    #define _XOPEN_SOURCE 700
    #include <stdarg.h>
    #include <freerdp/codec/color.h>
    
    int main() {
        UINT32 result = FreeRDPConvertColor(0xFF000000, PIXEL_FORMAT_ARGB32, PIXEL_FORMAT_XRGB32, NULL);
        return 0;
    }
'''

if cc.compiles(
    freerdp_convertcolor_check,
    dependencies: libfreerdp_dep,
    name: 'FreeRDP FreeRDPConvertColor availability check',
)
    rdp_client_config.set(
        'HAVE_FREERDPCONVERTCOLOR',
        '/**/',
        description: 'Whether FreeRDPConvertColor() is defined',
    )
endif

# FreeRDP 2.0.0-rc3 through 2.0.0-rc4 automatically free the wStream
# provided to pVirtualChannelWriteEx(). Use version string matching like autotools.
freerdp_version_str = cc.get_define(
    'FREERDP_VERSION_FULL',
    prefix: '#include <freerdp/version.h>',
    dependencies: libfreerdp_dep,
)

if freerdp_version_str != ''
    freerdp_version_str = freerdp_version_str.strip('"')
    
    # Check for versions 2.0.0-rc3, 2.0.0-rc4, 2.0.0-dev3, or 2.0.0-dev4
    wstream_version_check = run_command(
        'sh', '-c', 'echo "@0@" | grep -E "2\\.0\\.0-(rc|dev)[3-4]"'.format(freerdp_version_str),
        check: false,
    )
    
    if wstream_version_check.returncode() == 0
        rdp_client_config.set(
            'FREERDP_SVC_CORE_FREES_WSTREAM',
            '/**/',
            description: 'Whether pVirtualChannelWriteEx() frees the wStream upon completion',
        )
    endif
endif

# FreeRDP 2.0.0 final and newer requires const for CLIPRDR callbacks
freerdp_cliprdr_check = '''
    #define _GNU_SOURCE
    #define _XOPEN_SOURCE 700
    #include <stdarg.h>
    #include <freerdp/client/cliprdr.h>
    
    UINT test_monitor_ready(CliprdrClientContext* cliprdr,
            const CLIPRDR_MONITOR_READY* monitor_ready) {
        return 0;
    }
    
    int main() {
        CliprdrClientContext context = {
            .MonitorReady = test_monitor_ready
        };
        return (int) context.MonitorReady(NULL, NULL);
    }
'''

if cc.compiles(
    freerdp_cliprdr_check,
    dependencies: [libfreerdp_dep, libfreerdp_client_dep],
    name: 'FreeRDP CLIPRDR const check',
)
    rdp_client_config.set(
        'FREERDP_CLIPRDR_CALLBACKS_REQUIRE_CONST',
        '/**/',
        description: 'Whether FreeRDP CLIPRDR callbacks require const parameters',
    )
endif

# FreeRDP 2.0.0 final and newer requires const for RAIL callbacks
freerdp_rail_check = '''
    #define _GNU_SOURCE
    #define _XOPEN_SOURCE 700
    #include <stdarg.h>
    #include <freerdp/client/rail.h>
    #include <winpr/wtypes.h>
    
    UINT test_server_handshake(RailClientContext* rail,
            const RAIL_HANDSHAKE_ORDER* handshake) {
        return 0;
    }
    
    int main() {
        RailClientContext context = {
            .ServerHandshake = test_server_handshake
        };
        return (int) context.ServerHandshake(NULL, NULL);
    }
'''

if cc.compiles(
    freerdp_rail_check,
    dependencies: [libfreerdp_dep, libfreerdp_client_dep],
    name: 'FreeRDP RAIL const check',
)
    rdp_client_config.set(
        'FREERDP_RAIL_CALLBACKS_REQUIRE_CONST',
        '/**/',
        description: 'Whether FreeRDP RAIL callbacks require const parameters',
    )
endif

# FreeRDP 2.0.0 final introduced VerifyCertificateEx (not present in 2.0.0-rc4 or earlier)
if cc.has_members(
    'struct freerdp',
    'VerifyCertificateEx',
    prefix: '#include <freerdp/freerdp.h>',
    dependencies: libfreerdp_dep,
)
    rdp_client_config.set(
        'HAVE_FREERDP_VERIFYCERTIFICATEEX',
        '/**/',
        description: 'Whether FreeRDP has VerifyCertificateEx member',
    )
endif

# Check for relaxed order checks support (AllowUnanouncedOrdersFromServer)
if cc.has_members(
    'rdpSettings',
    'AllowUnanouncedOrdersFromServer',
    prefix: '#include <freerdp/settings.h>',
    dependencies: libfreerdp_dep,
)
    rdp_client_config.set(
        'HAVE_RDPSETTINGS_ALLOWUNANOUNCEDORDERSFROMSERVER',
        '/**/',
        description: 'Defined if rdpSettings has AllowUnanouncedOrdersFromServer member',
    )
endif

# FreeRDP 3.0.0 introduced FreeRDPReadColor/FreeRDPWriteColor API functions
# (replaces static inline ReadColor/WriteColor from 2.x)
if cc.has_header_symbol(
    'freerdp/codec/color.h',
    'FreeRDPReadColor',
    prefix: '''
        #define _GNU_SOURCE
        #define _XOPEN_SOURCE 700
        #include <stdarg.h>
    ''',
    dependencies: libfreerdp_dep,
)
    rdp_client_config.set(
        'USE_UPDATED_RW_COLOR_FUNCS',
        '/**/',
        description: 'Defined if FreeRDPReadColor() and FreeRDPWriteColor() are available',
    )
endif

# FreeRDP 3.0.0-rc0 introduced settings getter/setter API functions
# (replaces direct struct member access from 2.x)
if cc.has_header_symbol(
    'freerdp/settings.h',
    'freerdp_settings_set_pointer',
    prefix: '''
        #define _GNU_SOURCE
        #define _XOPEN_SOURCE 700
        #include <stdarg.h>
    ''',
    dependencies: libfreerdp_dep,
)
    rdp_client_config.set(
        'HAVE_SETTERS_GETTERS',
        '/**/',
        description: 'Defined if freerdp_settings_set_pointer is available',
    )
endif

# FreeRDP has included context member since 1.0.1 (2013) - this check detects pre-1.0 versions
freerdp_context_check = '''
    #define _GNU_SOURCE
    #define _XOPEN_SOURCE 700
    #include <stdarg.h>
    #include <freerdp/freerdp.h>
    
    int main() {
        freerdp* instance = freerdp_new();
        rdpContext* context = instance->context;
        freerdp_free(instance);
        return 0;
    }
'''

if cc.compiles(
    freerdp_context_check,
    dependencies: libfreerdp_dep,
    name: 'FreeRDP context support check',
)
    rdp_client_config.set(
        'FREERDP_HAS_CONTEXT',
        '/**/',
        description: 'FreeRDP structs have a context',
    )
endif

# FreeRDP 3.0.0-rc0 introduced freerdp_shall_disconnect_context()
# (replaces freerdp_shall_disconnect() from 2.x)
if cc.has_header_symbol(
    'freerdp/freerdp.h',
    'freerdp_shall_disconnect_context',
    prefix: '''
        #define _GNU_SOURCE
        #define _XOPEN_SOURCE 700
        #include <stdarg.h>
    ''',
    dependencies: libfreerdp_dep,
)
    rdp_client_config.set(
        'HAVE_DISCONNECT_CONTEXT',
        '/**/',
        description: 'Defined if freerdp_shall_disconnect_context is available in FreeRDP',
    )
endif

# FreeRDP 2.x requires const rdpPointer* parameter in pointer.Set callback
# (const modifier removed in 3.0.0-rc0)
freerdp_pointer_set_check = '''
    #define _GNU_SOURCE
    #define _XOPEN_SOURCE 700
    #include <stdarg.h>
    #include <freerdp/graphics.h>
    
    BOOL mock_pointer_set(rdpContext* context, const rdpPointer* pointer) {
        return TRUE;
    }
    
    int main() {
        rdpPointer* pointer = (rdpPointer*) malloc(sizeof(rdpPointer));
        pointer->Set = mock_pointer_set;
        free(pointer);
        return 0;
    }
'''

if cc.compiles(
    freerdp_pointer_set_check,
    dependencies: libfreerdp_dep,
    name: 'FreeRDP pointer Set const check',
)
    rdp_client_config.set(
        'RDP_POINTER_SET_REQUIRES_CONST',
        '/**/',
        description: 'Defined if pointer.Set expects a const rdpPointer* parameter',
    )
endif

# FreeRDP 3.0.0-rc0 introduced LoadChannels callback member
# (not present in 2.x, where channels are loaded in PreConnect instead)
freerdp_loadchannels_check = '''
    #define _GNU_SOURCE
    #define _XOPEN_SOURCE 700
    #include <stdarg.h>
    #include <freerdp/freerdp.h>
    
    /* Mock LoadChannels function with the expected signature */
    BOOL load_channels(freerdp* instance) {
        return TRUE;
    }
    
    int main() {
        freerdp* instance = freerdp_new();
        instance->LoadChannels = load_channels;
        freerdp_free(instance);
        return 0;
    }
'''

if cc.compiles(
    freerdp_loadchannels_check,
    dependencies: libfreerdp_dep,
    name: 'FreeRDP instance LoadChannels check',
)
    rdp_client_config.set(
        'RDP_INST_HAS_LOAD_CHANNELS',
        '/**/',
        description: 'Defined if freerdp instance supports LoadChannels',
    )
endif

# FreeRDP 3.0.0-rc0 changed GetPluginData to return const ADDIN_ARGV*
# (returns ADDIN_ARGV* in 2.x)
freerdp_plugin_data_check = '''
    #define _GNU_SOURCE
    #define _XOPEN_SOURCE 700
    #include <stdarg.h>
    #include <freerdp/addin.h>
    #include <freerdp/client/channels.h>
    
    void test(ADDIN_ARGV* args) {
        const ADDIN_ARGV* const_args = freerdp_dynamic_channel_collection_find(NULL, "test");
    }
    
    int main() {
        return 0;
    }
'''

if cc.compiles(
    freerdp_plugin_data_check,
    dependencies: [libfreerdp_dep, libfreerdp_client_dep],
    name: 'FreeRDP plugin data const check',
)
    rdp_client_config.set(
        'PLUGIN_DATA_CONST',
        '/**/',
        description: 'Defined if GetPluginData returns a pointer to a const ADDIN_ARGV',
    )
endif

# Check if CLIPRDR structures include common CLIPRDR_HEADER member
# (some versions have nested 'common' header, others have flattened fields)
freerdp_cliprdr_header_check = '''
    #define _GNU_SOURCE
    #include <freerdp/client/cliprdr.h>
    
    int main() {
        CLIPRDR_FORMAT_LIST list;
        list.common.msgType = 0;
        (void)list;
        return 0;
    }
'''

if cc.compiles(
    freerdp_cliprdr_header_check,
    dependencies: [libfreerdp_dep, libfreerdp_client_dep],
    name: 'FreeRDP CLIPRDR header check',
)
    rdp_client_config.set(
        'HAVE_CLIPRDR_HEADER',
        '/**/',
        description: 'Defined if CLIPRDR structs have a common CLIPRDR_HEADER',
    )
endif

# Set FreeRDP plugin directory
rdp_client_config.set_quoted(
    'FREERDP_PLUGIN_DIR',
    freerdp_plugin_dir,
    description: 'FreeRDP plugin installation directory',
)

## cairo
cairo_dep = dependency('cairo', required: true)

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

## libguac_common_ssh (optional)
if get_option('ssh').enabled() and not is_variable('common_ssh_dep')
    error('common_ssh_dep not found. Please build libguac_common_ssh first.')
endif

if get_option('ssh').enabled()
    rdp_client_config.set(
        'ENABLE_COMMON_SSH',
        '/**/',
        description: 'Whether libguac_common_ssh is available for SSH/SFTP support.',
    )
endif



# ----------------------------------------------------------------
# RDP keymaps generation
# ----------------------------------------------------------------
rdp_keymaps = [
    'keymaps/base.keymap',
    'keymaps/base_altgr.keymap',
    'keymaps/failsafe.keymap',
    'keymaps/cs-cz-qwertz.keymap',
    'keymaps/de_de_qwertz.keymap',
    'keymaps/de_ch_qwertz.keymap',
    'keymaps/en_gb_qwerty.keymap',
    'keymaps/en_us_qwerty.keymap',
    'keymaps/es_es_qwerty.keymap',
    'keymaps/es_latam_qwerty.keymap',
    'keymaps/fr_be_azerty.keymap',
    'keymaps/fr_ca_qwerty.keymap',
    'keymaps/fr_ch_qwertz.keymap',
    'keymaps/fr_fr_azerty.keymap',
    'keymaps/hu_hu_qwertz.keymap',
    'keymaps/it_it_qwerty.keymap',
    'keymaps/ja_jp_qwerty.keymap',
    'keymaps/no_no_qwerty.keymap',
    'keymaps/pl_pl_qwerty.keymap',
    'keymaps/pt_br_qwerty.keymap',
    'keymaps/pt_pt_qwerty.keymap',
    'keymaps/ro_ro_qwerty.keymap',
    'keymaps/sv_se_qwerty.keymap',
    'keymaps/da_dk_qwerty.keymap',
    'keymaps/tr_tr_qwerty.keymap',
]

# Generate keymaps
generated_keymaps = custom_target(
    '_generated_keymaps.c',
    input: ['keymaps/generate.pl'] + rdp_keymaps,
    output: '_generated_keymaps.c',
    command: [find_program('perl'), '@INPUT0@'] + rdp_keymaps,
)

# Generate channel entry wrappers
generated_channel_wrappers = custom_target(
    '_generated_channel_entry_wrappers.c',
    input: ['plugins/channels.h', 'plugins/generate-entry-wrappers.pl'],
    output: '_generated_channel_entry_wrappers.c',
    command: [find_program('perl'), '@INPUT1@', '@INPUT0@'],
)

# ----------------------------------------------------------------
# Main RDP client library
# ----------------------------------------------------------------

rdp_client_config_h = configure_file(
    output: 'config.h',
    configuration: rdp_client_config,
)

rdp_client_deps = [
    libguac_dep,
    common_dep,
    libfreerdp_dep,
    libfreerdp_client_dep,
    libwinpr_dep,
    cairo_dep,
    thread_dep,
]

rdp_client_inc = include_directories('.')

rdp_client_src = [
    'argv.c',
    'beep.c',
    'channels/audio-input/audio-buffer.c',
    'channels/audio-input/audio-input.c',
    'channels/cliprdr.c',
    'channels/common-svc.c',
    'channels/disp.c',
    'channels/pipe-svc.c',
    'channels/rail.c',
    'channels/rdpdr/rdpdr-fs-messages-dir-info.c',
    'channels/rdpdr/rdpdr-fs-messages-file-info.c',
    'channels/rdpdr/rdpdr-fs-messages-vol-info.c',
    'channels/rdpdr/rdpdr-fs-messages.c',
    'channels/rdpdr/rdpdr-fs.c',
    'channels/rdpdr/rdpdr-messages.c',
    'channels/rdpdr/rdpdr-printer.c',
    'channels/rdpdr/rdpdr.c',
    'channels/rdpei.c',
    'channels/rdpgfx.c',
    'channels/rdpsnd/rdpsnd-messages.c',
    'channels/rdpsnd/rdpsnd.c',
    'client.c',
    'color.c',
    'decompose.c',
    'download.c',
    'error.c',
    'fs.c',
    'gdi.c',
    'input.c',
    'input-queue.c',
    'keyboard.c',
    'keymap.c',
    'log.c',
    'ls.c',
    'plugins/channels.c',
    'plugins/ptr-string.c',
    'pointer.c',
    'print-job.c',
    'rdp.c',
    'resolution.c',
    'settings.c',
    'unicode.c',
    'upload.c',
    'user.c',
]

# Optional SFTP support
if get_option('ssh').enabled()
    rdp_client_src += ['sftp.c']
    rdp_client_deps += [common_ssh_dep]
endif

rdp_client_lib = shared_library(
    'guac_client_rdp',
    rdp_client_src + generated_keymaps + generated_channel_wrappers + [
        rdp_client_config_h,
    ],
    dependencies: rdp_client_deps,
    # FreeRDP 3.16.0+ headers generate deprecation warnings and pragma warnings
    # that are incompatible with -Werror. These suppressions are needed for
    # compatibility with newer FreeRDP versions. Same issue affects autotools.
    c_args: ['-Wall', '-Wno-pragma-messages'],
    install: true,
)

# ----------------------------------------------------------------
# FreeRDP Plugins
# ----------------------------------------------------------------

# Common SVC plugin (shared by RDPDR, RDPSND, etc.)
common_svc_client_src = ['plugins/guac-common-svc/guac-common-svc.c']

common_svc_client_deps = [
    libguac_dep,
    libfreerdp_dep,
    libfreerdp_client_dep,
    libwinpr_dep,
]

common_svc_client_lib = shared_library(
    'guac_common_svc_client',
    common_svc_client_src + [rdp_client_config_h],
    include_directories: rdp_client_inc,
    dependencies: common_svc_client_deps,
    # FreeRDP plugins also need warning suppressions for FreeRDP 3.16.0+ headers
    c_args: ['-Wall', '-Wno-pragma-messages'],
    install: true,
    install_dir: freerdp_plugin_dir,
)

# Audio Input plugin
ai_client_src = [
    'channels/audio-input/audio-buffer.c',
    'plugins/guacai/guacai-messages.c',
    'plugins/guacai/guacai.c',
    'plugins/ptr-string.c',
]

ai_client_deps = [
    libguac_dep,
    common_dep,
    libfreerdp_dep,
    libfreerdp_client_dep,
    libwinpr_dep,
    thread_dep,
]

if get_option('ssh').enabled()
    ai_client_deps += [common_ssh_dep]
endif

ai_client_lib = shared_library(
    'guacai_client',
    ai_client_src + [rdp_client_config_h],
    include_directories: rdp_client_inc,
    dependencies: ai_client_deps,
    # FreeRDP plugins also need warning suppressions for FreeRDP 3.16.0+ headers
    c_args: ['-Wall', '-Wno-pragma-messages'],
    install: true,
    install_dir: freerdp_plugin_dir,
)
