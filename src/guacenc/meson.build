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

guacenc_config = configuration_data()
guacenc_config.merge_from(config)

# ----------------------------------------------------------------
# Dependencies
# ----------------------------------------------------------------

## libavcodec
libavcodec_dep = dependency('libavcodec', required: true)

## libavformat
libavformat_dep = dependency('libavformat', required: true)

## libavutil
libavutil_dep = dependency('libavutil', required: true)

## libswscale
libswscale_dep = dependency('libswscale', required: true)

## cairo
cairo_dep = dependency('cairo', required: true)

if cc.has_function(
  'cairo_format_stride_for_width',
  prefix: '#include <cairo/cairo.h>',
  dependencies: cairo_dep,
)
  guacenc_config.set(
    'HAVE_CAIRO_FORMAT_STRIDE_FOR_WIDTH',
    '/**/',
    description: 'Whether cairo_format_stride_for_width() is defined',
  )
endif

## libjpeg
libjpeg_dep = dependency('libjpeg', 'jpeg', required: true)

## libpng
libpng_dep = dependency('libpng', 'png', required: true)

if cc.check_header('pngstruct.h', dependencies: libpng_dep)
  guacenc_config.set(
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
  guacenc_config.set(
    'HAVE_PNG_GET_IO_PTR',
    '/**/',
    description: 'The `png_get_io_ptr` function is defined',
  )
endif

## libwebp (optional)
libwebp_dep = dependency('libwebp', required: get_option('webp'))

libwebp_has_decode_header = cc.has_header(
  'webp/decode.h',
  dependencies: libwebp_dep,
  required: get_option('webp'),
)

if libwebp_dep.found() and libwebp_has_decode_header
  guacenc_config.set(
    'ENABLE_WEBP',
    '/**/',
    description: 'Whether WebP support is enabled',
  )
endif

## libguac
if not is_variable('libguac_dep')
  error('libguac_dep not found. Please build libguac first.')
endif

# ----------------------------------------------------------------
# Executable
# ----------------------------------------------------------------
guacenc_config_h = configure_file(
  output: 'config.h',
  configuration: guacenc_config,
)

guacenc_deps = [
  libavcodec_dep,
  libavformat_dep,
  libavutil_dep,
  cairo_dep,
  libjpeg_dep,
  libpng_dep,
  libswscale_dep,
  libwebp_dep,
  libguac_dep,
]

guacenc_src = [
  'buffer.c',
  'cursor.c',
  'display.c',
  'display-buffers.c',
  'display-image-streams.c',
  'display-flatten.c',
  'display-layers.c',
  'display-sync.c',
  'encode.c',
  'ffmpeg-compat.c',
  'guacenc.c',
  'image-stream.c',
  'instructions.c',
  'instruction-blob.c',
  'instruction-cfill.c',
  'instruction-copy.c',
  'instruction-cursor.c',
  'instruction-dispose.c',
  'instruction-end.c',
  'instruction-img.c',
  'instruction-mouse.c',
  'instruction-move.c',
  'instruction-rect.c',
  'instruction-shade.c',
  'instruction-size.c',
  'instruction-sync.c',
  'instruction-transfer.c',
  'jpeg.c',
  'layer.c',
  'log.c',
  'parse.c',
  'png.c',
  'video.c',
]

# Compile WebP support if available
if libwebp_dep.found() and libwebp_has_decode_header
  guacenc_src += ['webp.c']
endif


guacenc = executable(
  'guacenc',
  guacenc_src + [guacenc_config_h],
  dependencies: guacenc_deps,
  c_args: ['-Werror', '-Wall', '-pedantic'],
  install: true,
)

# ----------------------------------------------------------------
# Man pages
# ----------------------------------------------------------------
guacenc_man1 = configure_file(
  input: 'man/guacenc.1.in',
  output: 'guacenc.1',
  configuration: guacenc_config,
)

install_man([guacenc_man1])
