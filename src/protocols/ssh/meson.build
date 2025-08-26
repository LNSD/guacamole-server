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

ssh_client_config = configuration_data()
ssh_client_config.merge_from(config)

# ----------------------------------------------------------------
# Dependencies
# ----------------------------------------------------------------

## threads
thread_dep = dependency('threads', required: true)

## libssh2
libssh2_dep = dependency('libssh2', required: true)

# Underlying crypto library usage of libssh2
if cc.has_function('gcry_control', dependencies: libssh2_dep)
  if cc.has_header('gcrypt.h')
    ssh_client_config.set(
      'LIBSSH2_USES_GCRYPT',
      '/**/',
      description: 'Whether libssh2 was built against libgcrypt',
    )
  else
    error('libssh2 requires libgcrypt headers')
  endif
endif

# Check for agent forwarding support within libssh2
#
# NOTE: SSH agent support has been broken since 2015 due to missing ssh_key.h
# See: https://issues.apache.org/jira/browse/GUACAMOLE-1658
# The SSH agent code references removed files (ssh_key.h, ssh_key_sign function)
# that were deleted during the migration to common SSH library (GUAC-1171).
if get_option('ssh_agent').enabled()
  if not cc.has_header_symbol(
    'libssh2.h',
    'libssh2_channel_request_auth_agent',
    dependencies: libssh2_dep,
  )
    error('SSH agent forwarding not supported by libssh2')
  endif

  ssh_client_config.set(
    'ENABLE_SSH_AGENT',
    '/**/',
    description: 'Whether agent forwarding support for SSH is enabled',
  )
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
  ssh_client_config.set(
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

## libguac_common_ssh
if not is_variable('common_ssh_dep')
  error('common_ssh_dep not found. Please build libguac_common_ssh first.')
endif

## libguac_terminal
if not is_variable('terminal_dep')
  error('terminal_dep not found. Please build libguac_terminal first.')
endif

# ----------------------------------------------------------------
# Shared Library
# ----------------------------------------------------------------
ssh_client_config_h = configure_file(
  output: 'config.h',
  configuration: ssh_client_config,
)

ssh_client_deps = [
  thread_dep,
  libssh2_dep,
  libssl_dep,
  common_dep,
  common_ssh_dep,
  libguac_dep,
  terminal_dep,
]

ssh_client_inc = include_directories('.')

ssh_client_src = [
  'argv.c',
  'client.c',
  'clipboard.c',
  'input.c',
  'pipe.c',
  'settings.c',
  'sftp.c',
  'ssh.c',
  'ttymode.c',
  'user.c',
]

# Add agent sources if enabled
if get_option('ssh_agent').enabled()
  ssh_client_src += ['ssh_agent.c']
endif

ssh_client_lib = shared_library(
  'guac_client_ssh',
  ssh_client_src + [ssh_client_config_h],
  dependencies: ssh_client_deps,
  c_args: ['-Werror', '-Wall', '-pedantic'],
  link_args: ['-Wl,--no-undefined'],
  install: true,
)


ssh_client_dep = declare_dependency(
  include_directories: ssh_client_inc,
  link_with: ssh_client_lib,
)
