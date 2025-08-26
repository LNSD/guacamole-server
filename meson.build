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

project(
  'guacamole-server',
  'c',
  version: '1.6.0',
  meson_version: '>=1.1',
  license: 'Apache-2.0',
  default_options: ['c_std=c99'],
)

# Source characteristics
add_project_arguments('-D_GNU_SOURCE=1', language: 'c')
add_project_arguments('-D_XOPEN_SOURCE=700', language: 'c')
add_project_arguments('-D__BSD_VISIBLE=1', language: 'c')

# ----------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------
config = configuration_data()
config.set_quoted(
  'VERSION',
  meson.project_version(),
  description: 'Version number of package',
)

# Package metadata
config.set_quoted('PACKAGE', 'guacamole-server', description: 'Name of package')
config.set_quoted(
  'PACKAGE_NAME',
  'guacamole-server',
  description: 'Define to the full name of this package.',
)
config.set_quoted(
  'PACKAGE_STRING',
  'guacamole-server ' + meson.project_version(),
  description: 'Define to the full name and version of this package.',
)
config.set_quoted(
  'PACKAGE_TARNAME',
  'guacamole-server',
  description: 'Define to the one symbol short name of this package.',
)
config.set_quoted(
  'PACKAGE_URL',
  '',
  description: 'Define to the home page for this package.',
)
config.set_quoted(
  'PACKAGE_VERSION',
  meson.project_version(),
  description: 'Define to the version of this package.',
)
config.set_quoted(
  'PACKAGE_BUGREPORT',
  '',
  description: 'Define to the address where bug reports for this package should be sent.',
)

# Guacd config file
guac_conf_file = get_option('guacd_conf')
if guac_conf_file == ''
  error('A valid guacd config file path must be specified')
endif

config.set_quoted(
  'GUACD_CONF_FILE',
  guac_conf_file,
  description: 'The full path to the guacd config file',
)

# ----------------------------------------------------------------
# Project modules
# ----------------------------------------------------------------

# libguac-core (exmperimental Rust core library)
if get_option('rust').enabled()
  subdir('src/core')
endif

# libguac
subdir('src/libguac')

# common (built when guacd or any protocol is enabled)
if get_option('guacd').enabled() or get_option('kubernetes').enabled() or \
  get_option('rdp').enabled() or get_option('ssh').enabled() or \
  get_option('telnet').enabled() or get_option('vnc').enabled()
  subdir('src/common')
endif

# common-ssh (built when SSH is enabled, used by SSH, RDP, and VNC protocols)
if get_option('ssh').enabled()
  subdir('src/common-ssh')
endif

# terminal emulator (built when needed by SSH, Telnet, Kubernetes, etc.)
if get_option('kubernetes').enabled() or get_option('ssh').enabled() or \
  get_option('telnet').enabled()
  subdir('src/terminal')
endif

# pulse
if get_option('pulse').enabled()
  subdir('src/pulse')
endif


## Protocols

# protocols/kubernetes
if get_option('kubernetes').enabled()
  subdir('src/protocols/kubernetes')
endif

# protocols/rdp
if get_option('rdp').enabled()
  subdir('src/protocols/rdp')
endif

# protocols/ssh
if get_option('ssh').enabled()
  subdir('src/protocols/ssh')
endif

# protocols/telnet
if get_option('telnet').enabled()
  subdir('src/protocols/telnet')
endif

# protocols/vnc
if get_option('vnc').enabled()
  subdir('src/protocols/vnc')
endif


## Binaries

# guacd
if get_option('guacd').enabled()
  subdir('src/guacd')
endif

# guacenc
if get_option('guacenc').enabled()
  subdir('src/guacenc')
endif

# guaclog
if get_option('guaclog').enabled()
  subdir('src/guaclog')
endif

