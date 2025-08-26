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

guacd_config = configuration_data()
guacd_config.merge_from(config)

# ----------------------------------------------------------------
# Dependencies
# ----------------------------------------------------------------

## threads
thread_dep = dependency('threads', required: true)

# Check for pthread_setattr_default_np (GNU extension)
pthread_setattr_default_np_check = '''
    #define _GNU_SOURCE
    #include <pthread.h>

    int main() {
        pthread_attr_t attr;
        pthread_attr_init(&attr);
        pthread_setattr_default_np(&attr);
        pthread_attr_destroy(&attr);
        return 0;
    }
'''

if cc.links(
  pthread_setattr_default_np_check,
  dependencies: thread_dep,
  name: 'pthread_setattr_default_np check',
)
  guacd_config.set(
    'HAVE_DECL_PTHREAD_SETATTR_DEFAULT_NP',
    1,
    description: 'Define to 1 if you have the declaration of `pthread_setattr_default_np`, and to 0 if you don\'t.',
  )
endif

## libssl
libssl_dep = dependency('openssl', required: get_option('ssl'))

if libssl_dep.found() and cc.has_header(
  'openssl/ssl.h',
  dependencies: libssl_dep,
)
  guacd_config.set(
    'ENABLE_SSL',
    '/**/',
    description: 'Whether SSL-related support is enabled',
  )

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
    guacd_config.set(
      'OPENSSL_REQUIRES_THREADING_CALLBACKS',
      '/**/',
      description: 'Whether OpenSSL requires explicit threading callbacks for threadsafety',
    )
  endif
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
# Executable
# ----------------------------------------------------------------
guacd_config_h = configure_file(output: 'config.h', configuration: guacd_config)

guacd_src = [
  'conf-args.c',
  'conf-file.c',
  'conf-parse.c',
  'connection.c',
  'daemon.c',
  'log.c',
  'move-fd.c',
  'proc.c',
  'proc-map.c',
]

guacd_deps = [thread_dep, libssl_dep, common_dep, libguac_dep]

guacd = executable(
  'guacd',
  guacd_src + [guacd_config_h],
  dependencies: guacd_deps,
  c_args: ['-Werror', '-Wall', '-pedantic'],
  install: true,
  install_dir: get_option('sbindir'),
)

# ----------------------------------------------------------------
# Man pages
# ----------------------------------------------------------------
guacd_man8 = configure_file(
  input: 'man/guacd.8.in',
  output: 'guacd.8',
  configuration: guacd_config,
)

guacd_conf_man5 = configure_file(
  input: 'man/guacd.conf.5.in',
  output: 'guacd.conf.5',
  configuration: guacd_config,
)

install_man([guacd_man8, guacd_conf_man5])

# ----------------------------------------------------------------
# Init script and systemd service file generation and installation
# ----------------------------------------------------------------

# Get build options
init_dir = get_option('init_dir')
systemd_dir = get_option('systemd_dir')
systemd_user = get_option('systemd_user')

# Init script generation and installation (equivalent to autotools ENABLE_INIT)
if init_dir != ''
  # Generate init script by substituting @sbindir@ with actual sbindir
  guacd_init_script = configure_file(
    input: 'init.d/guacd.in',
    output: 'init.d-guacd',
    configuration: {'sbindir': get_option('prefix') / get_option('sbindir')},
  )

  # Install the generated init script with correct name and permissions
  install_data(
    guacd_init_script,
    install_dir: init_dir,
    rename: 'guacd',
    install_mode: 'rwxr-xr-x',  # chmod +x equivalent
  )
endif

# Systemd service generation and installation (equivalent to autotools ENABLE_SYSTEMD)
if systemd_dir != ''
  # Generate systemd service by substituting @sbindir@ and @systemduser@
  guacd_systemd_service = configure_file(
    input: 'systemd/guacd.service.in',
    output: 'guacd.service',
    configuration: {
      'sbindir': get_option('prefix') / get_option('sbindir'),
      'systemduser': systemd_user,
    },
    install: true,
    install_dir: systemd_dir,
  )
endif
