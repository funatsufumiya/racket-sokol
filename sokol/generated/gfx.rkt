#lang racket/base

(require ffi/unsafe
         ffi/unsafe/define
         racket/file)

(provide (all-defined-out))

; Load the sokol library
(define sokol-lib
  (ffi-lib "libsokol" '("1" "")
           #:fail (lambda () 
                    (error 'sokol "Could not load sokol library"))))

(define-ffi-definer define-sokol sokol-lib)

#|     Resource id typedefs:

    sg_buffer:      vertex- and index-buffers
    sg_image:       images used as textures and render-pass attachments
    sg_sampler      sampler objects describing how a texture is sampled in a shader
    sg_shader:      vertex- and fragment-shaders and shader interface information
    sg_pipeline:    associated shader and vertex-layouts, and render states
    sg_attachments: a baked collection of render pass attachment images

    Instead of pointers, resource creation functions return a 32-bit
    handle which uniquely identifies the resource object.

    The 32-bit resource id is split into a 16-bit pool index in the lower bits,
    and a 16-bit 'generation counter' in the upper bits. The index allows fast
    pool lookups, and combined with the generation-counter it allows to detect
    'dangling accesses' (trying to use an object which no longer exists, and
    its pool slot has been reused for a new object)

    The resource ids are wrapped into a strongly-typed struct so that
    trying to pass an incompatible resource id is a compile error. |#
(define _buffer
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['id _uint32]
  ))

(define _image
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['id _uint32]
  ))

(define _sampler
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['id _uint32]
  ))

(define _shader
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['id _uint32]
  ))

(define _pipeline
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['id _uint32]
  ))

(define _attachments
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['id _uint32]
  ))

#|     sg_range is a pointer-size-pair struct used to pass memory blobs into
    sokol-gfx. When initialized from a value type (array or struct), you can
    use the SG_RANGE() macro to build an sg_range struct. For functions which
    take either a sg_range pointer, or a (C++) sg_range reference, use the
    SG_RANGE_REF macro as a solution which compiles both in C and C++. |#
(define _range
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['ptr _pointer]
   ['size _size]
  ))

#|  various compile-time constants in the public API |#
(define SG-INVALID-ID 0)
(define SG-NUM-INFLIGHT-FRAMES 2)
(define SG-MAX-COLOR-ATTACHMENTS 4)
(define SG-MAX-UNIFORMBLOCK-MEMBERS 16)
(define SG-MAX-VERTEX-ATTRIBUTES 16)
(define SG-MAX-MIPMAPS 16)
(define SG-MAX-TEXTUREARRAY-LAYERS 128)
(define SG-MAX-UNIFORMBLOCK-BINDSLOTS 8)
(define SG-MAX-VERTEXBUFFER-BINDSLOTS 8)
(define SG-MAX-IMAGE-BINDSLOTS 16)
(define SG-MAX-SAMPLER-BINDSLOTS 16)
(define SG-MAX-STORAGEBUFFER-BINDSLOTS 8)
(define SG-MAX-IMAGE-SAMPLER-PAIRS 16)

#|     sg_color

    An RGBA color value. |#
(define _color
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['r _float]
   ['g _float]
   ['b _float]
   ['a _float]
  ))

#|     sg_backend

    The active 3D-API backend, use the function sg_query_backend()
    to get the currently active backend. |#
; Enum: sg_backend
; No explicit value for SG-BACKEND-GLCORE
; No explicit value for SG-BACKEND-GLES3
; No explicit value for SG-BACKEND-D3D11
; No explicit value for SG-BACKEND-METAL-IOS
; No explicit value for SG-BACKEND-METAL-MACOS
; No explicit value for SG-BACKEND-METAL-SIMULATOR
; No explicit value for SG-BACKEND-WGPU
; No explicit value for SG-BACKEND-DUMMY
#|     sg_pixel_format

    sokol_gfx.h basically uses the same pixel formats as WebGPU, since these
    are supported on most newer GPUs.

    A pixelformat name consist of three parts:

        - components (R, RG, RGB or RGBA)
        - bit width per component (8, 16 or 32)
        - component data type:
            - unsigned normalized (no postfix)
            - signed normalized (SN postfix)
            - unsigned integer (UI postfix)
            - signed integer (SI postfix)
            - float (F postfix)

    Not all pixel formats can be used for everything, call sg_query_pixelformat()
    to inspect the capabilities of a given pixelformat. The function returns
    an sg_pixelformat_info struct with the following members:

        - sample: the pixelformat can be sampled as texture at least with
                  nearest filtering
        - filter: the pixelformat can be sampled as texture with linear
                  filtering
        - render: the pixelformat can be used as render-pass attachment
        - blend:  blending is supported when used as render-pass attachment
        - msaa:   multisample-antialiasing is supported when used
                  as render-pass attachment
        - depth:  the pixelformat can be used for depth-stencil attachments
        - compressed: this is a block-compressed format
        - bytes_per_pixel: the numbers of bytes in a pixel (0 for compressed formats)

    The default pixel format for texture images is SG_PIXELFORMAT_RGBA8.

    The default pixel format for render target images is platform-dependent
    and taken from the sg_environment struct passed into sg_setup(). Typically
    the default formats are:

        - for the Metal, D3D11 and WebGPU backends: SG_PIXELFORMAT_BGRA8
        - for GL backends: SG_PIXELFORMAT_RGBA8 |#
; Enum: sg_pixel_format
; No explicit value for -SG-PIXELFORMAT-DEFAULT
; No explicit value for SG-PIXELFORMAT-NONE
; No explicit value for SG-PIXELFORMAT-R8
; No explicit value for SG-PIXELFORMAT-R8SN
; No explicit value for SG-PIXELFORMAT-R8UI
; No explicit value for SG-PIXELFORMAT-R8SI
; No explicit value for SG-PIXELFORMAT-R16
; No explicit value for SG-PIXELFORMAT-R16SN
; No explicit value for SG-PIXELFORMAT-R16UI
; No explicit value for SG-PIXELFORMAT-R16SI
; No explicit value for SG-PIXELFORMAT-R16F
; No explicit value for SG-PIXELFORMAT-RG8
; No explicit value for SG-PIXELFORMAT-RG8SN
; No explicit value for SG-PIXELFORMAT-RG8UI
; No explicit value for SG-PIXELFORMAT-RG8SI
; No explicit value for SG-PIXELFORMAT-R32UI
; No explicit value for SG-PIXELFORMAT-R32SI
; No explicit value for SG-PIXELFORMAT-R32F
; No explicit value for SG-PIXELFORMAT-RG16
; No explicit value for SG-PIXELFORMAT-RG16SN
; No explicit value for SG-PIXELFORMAT-RG16UI
; No explicit value for SG-PIXELFORMAT-RG16SI
; No explicit value for SG-PIXELFORMAT-RG16F
; No explicit value for SG-PIXELFORMAT-RGBA8
; No explicit value for SG-PIXELFORMAT-SRGB8A8
; No explicit value for SG-PIXELFORMAT-RGBA8SN
; No explicit value for SG-PIXELFORMAT-RGBA8UI
; No explicit value for SG-PIXELFORMAT-RGBA8SI
; No explicit value for SG-PIXELFORMAT-BGRA8
; No explicit value for SG-PIXELFORMAT-RGB10A2
; No explicit value for SG-PIXELFORMAT-RG11B10F
; No explicit value for SG-PIXELFORMAT-RGB9E5
; No explicit value for SG-PIXELFORMAT-RG32UI
; No explicit value for SG-PIXELFORMAT-RG32SI
; No explicit value for SG-PIXELFORMAT-RG32F
; No explicit value for SG-PIXELFORMAT-RGBA16
; No explicit value for SG-PIXELFORMAT-RGBA16SN
; No explicit value for SG-PIXELFORMAT-RGBA16UI
; No explicit value for SG-PIXELFORMAT-RGBA16SI
; No explicit value for SG-PIXELFORMAT-RGBA16F
; No explicit value for SG-PIXELFORMAT-RGBA32UI
; No explicit value for SG-PIXELFORMAT-RGBA32SI
; No explicit value for SG-PIXELFORMAT-RGBA32F
; No explicit value for SG-PIXELFORMAT-DEPTH
; No explicit value for SG-PIXELFORMAT-DEPTH-STENCIL
; No explicit value for SG-PIXELFORMAT-BC1-RGBA
; No explicit value for SG-PIXELFORMAT-BC2-RGBA
; No explicit value for SG-PIXELFORMAT-BC3-RGBA
; No explicit value for SG-PIXELFORMAT-BC3-SRGBA
; No explicit value for SG-PIXELFORMAT-BC4-R
; No explicit value for SG-PIXELFORMAT-BC4-RSN
; No explicit value for SG-PIXELFORMAT-BC5-RG
; No explicit value for SG-PIXELFORMAT-BC5-RGSN
; No explicit value for SG-PIXELFORMAT-BC6H-RGBF
; No explicit value for SG-PIXELFORMAT-BC6H-RGBUF
; No explicit value for SG-PIXELFORMAT-BC7-RGBA
; No explicit value for SG-PIXELFORMAT-BC7-SRGBA
; No explicit value for SG-PIXELFORMAT-ETC2-RGB8
; No explicit value for SG-PIXELFORMAT-ETC2-SRGB8
; No explicit value for SG-PIXELFORMAT-ETC2-RGB8A1
; No explicit value for SG-PIXELFORMAT-ETC2-RGBA8
; No explicit value for SG-PIXELFORMAT-ETC2-SRGB8A8
; No explicit value for SG-PIXELFORMAT-EAC-R11
; No explicit value for SG-PIXELFORMAT-EAC-R11SN
; No explicit value for SG-PIXELFORMAT-EAC-RG11
; No explicit value for SG-PIXELFORMAT-EAC-RG11SN
; No explicit value for SG-PIXELFORMAT-ASTC-4x4-RGBA
; No explicit value for SG-PIXELFORMAT-ASTC-4x4-SRGBA
; No explicit value for -SG-PIXELFORMAT-NUM
(define -SG-PIXELFORMAT-FORCE-U32 2147483647)
#|     Runtime information about a pixel format, returned by sg_query_pixelformat(). |#
(define _pixelformat-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['sample _bool]
   ['filter _bool]
   ['render _bool]
   ['blend _bool]
   ['msaa _bool]
   ['depth _bool]
   ['compressed _bool]
   ['bytes_per_pixel _int]
  ))

#|     Runtime information about available optional features, returned by sg_query_features() |#
(define _features
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['origin_top_left _bool]
   ['image_clamp_to_border _bool]
   ['mrt_independent_blend_state _bool]
   ['mrt_independent_write_mask _bool]
   ['compute _bool]
   ['msaa_image_bindings _bool]
  ))

#|     Runtime information about resource limits, returned by sg_query_limit() |#
(define _limits
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['max_image_size_2d _int]
   ['max_image_size_cube _int]
   ['max_image_size_3d _int]
   ['max_image_size_array _int]
   ['max_image_array_layers _int]
   ['max_vertex_attrs _int]
   ['gl_max_vertex_uniform_components _int]
   ['gl_max_combined_texture_image_units _int]
  ))

#|     sg_resource_state

    The current state of a resource in its resource pool.
    Resources start in the INITIAL state, which means the
    pool slot is unoccupied and can be allocated. When a resource is
    created, first an id is allocated, and the resource pool slot
    is set to state ALLOC. After allocation, the resource is
    initialized, which may result in the VALID or FAILED state. The
    reason why allocation and initialization are separate is because
    some resource types (e.g. buffers and images) might be asynchronously
    initialized by the user application. If a resource which is not
    in the VALID state is attempted to be used for rendering, rendering
    operations will silently be dropped.

    The special INVALID state is returned in sg_query_xxx_state() if no
    resource object exists for the provided resource id. |#
; Enum: sg_resource_state
; No explicit value for SG-RESOURCESTATE-INITIAL
; No explicit value for SG-RESOURCESTATE-ALLOC
; No explicit value for SG-RESOURCESTATE-VALID
; No explicit value for SG-RESOURCESTATE-FAILED
; No explicit value for SG-RESOURCESTATE-INVALID
(define -SG-RESOURCESTATE-FORCE-U32 2147483647)
#|     sg_usage

    A resource usage hint describing the update strategy of
    buffers and images. This is used in the sg_buffer_desc.usage
    and sg_image_desc.usage members when creating buffers
    and images:

    SG_USAGE_IMMUTABLE:     the resource will never be updated with
                            new (CPU-side) data, instead the content of the
                            resource must be provided on creation
    SG_USAGE_DYNAMIC:       the resource will be updated infrequently
                            with new data (this could range from "once
                            after creation", to "quite often but not
                            every frame")
    SG_USAGE_STREAM:        the resource will be updated each frame
                            with new content

    The rendering backends use this hint to prevent that the
    CPU needs to wait for the GPU when attempting to update
    a resource that might be currently accessed by the GPU.

    Resource content is updated with the functions sg_update_buffer() or
    sg_append_buffer() for buffer objects, and sg_update_image() for image
    objects. For the sg_update_*() functions, only one update is allowed per
    frame and resource object, while sg_append_buffer() can be called
    multiple times per frame on the same buffer. The application must update
    all data required for rendering (this means that the update data can be
    smaller than the resource size, if only a part of the overall resource
    size is used for rendering, you only need to make sure that the data that
    *is* used is valid).

    The default usage is SG_USAGE_IMMUTABLE. |#
; Enum: sg_usage
; No explicit value for -SG-USAGE-DEFAULT
; No explicit value for SG-USAGE-IMMUTABLE
; No explicit value for SG-USAGE-DYNAMIC
; No explicit value for SG-USAGE-STREAM
; No explicit value for -SG-USAGE-NUM
(define -SG-USAGE-FORCE-U32 2147483647)
#|     sg_buffer_type

    Indicates whether a buffer will be bound as vertex-,
    index- or storage-buffer.

    Used in the sg_buffer_desc.type member when creating a buffer.

    The default value is SG_BUFFERTYPE_VERTEXBUFFER. |#
; Enum: sg_buffer_type
; No explicit value for -SG-BUFFERTYPE-DEFAULT
; No explicit value for SG-BUFFERTYPE-VERTEXBUFFER
; No explicit value for SG-BUFFERTYPE-INDEXBUFFER
; No explicit value for SG-BUFFERTYPE-STORAGEBUFFER
; No explicit value for -SG-BUFFERTYPE-NUM
(define -SG-BUFFERTYPE-FORCE-U32 2147483647)
#|     sg_index_type

    Indicates whether indexed rendering (fetching vertex-indices from an
    index buffer) is used, and if yes, the index data type (16- or 32-bits).

    This is used in the sg_pipeline_desc.index_type member when creating a
    pipeline object.

    The default index type is SG_INDEXTYPE_NONE. |#
; Enum: sg_index_type
; No explicit value for -SG-INDEXTYPE-DEFAULT
; No explicit value for SG-INDEXTYPE-NONE
; No explicit value for SG-INDEXTYPE-UINT16
; No explicit value for SG-INDEXTYPE-UINT32
; No explicit value for -SG-INDEXTYPE-NUM
(define -SG-INDEXTYPE-FORCE-U32 2147483647)
#|     sg_image_type

    Indicates the basic type of an image object (2D-texture, cubemap,
    3D-texture or 2D-array-texture). Used in the sg_image_desc.type member when
    creating an image, and in sg_shader_image_desc to describe a sampled texture
    in the shader (both must match and will be checked in the validation layer
    when calling sg_apply_bindings).

    The default image type when creating an image is SG_IMAGETYPE_2D. |#
; Enum: sg_image_type
; No explicit value for -SG-IMAGETYPE-DEFAULT
; No explicit value for SG-IMAGETYPE-2D
; No explicit value for SG-IMAGETYPE-CUBE
; No explicit value for SG-IMAGETYPE-3D
; No explicit value for SG-IMAGETYPE-ARRAY
; No explicit value for -SG-IMAGETYPE-NUM
(define -SG-IMAGETYPE-FORCE-U32 2147483647)
#|     sg_image_sample_type

    The basic data type of a texture sample as expected by a shader.
    Must be provided in sg_shader_image and used by the validation
    layer in sg_apply_bindings() to check if the provided image object
    is compatible with what the shader expects. Apart from the sokol-gfx
    validation layer, WebGPU is the only backend API which actually requires
    matching texture and sampler type to be provided upfront for validation
    (other 3D APIs treat texture/sampler type mismatches as undefined behaviour).

    NOTE that the following texture pixel formats require the use
    of SG_IMAGESAMPLETYPE_UNFILTERABLE_FLOAT, combined with a sampler
    of type SG_SAMPLERTYPE_NONFILTERING:

    - SG_PIXELFORMAT_R32F
    - SG_PIXELFORMAT_RG32F
    - SG_PIXELFORMAT_RGBA32F

    (when using sokol-shdc, also check out the meta tags `@image_sample_type`
    and `@sampler_type`) |#
; Enum: sg_image_sample_type
; No explicit value for -SG-IMAGESAMPLETYPE-DEFAULT
; No explicit value for SG-IMAGESAMPLETYPE-FLOAT
; No explicit value for SG-IMAGESAMPLETYPE-DEPTH
; No explicit value for SG-IMAGESAMPLETYPE-SINT
; No explicit value for SG-IMAGESAMPLETYPE-UINT
; No explicit value for SG-IMAGESAMPLETYPE-UNFILTERABLE-FLOAT
; No explicit value for -SG-IMAGESAMPLETYPE-NUM
(define -SG-IMAGESAMPLETYPE-FORCE-U32 2147483647)
#|     sg_sampler_type

    The basic type of a texture sampler (sampling vs comparison) as
    defined in a shader. Must be provided in sg_shader_sampler_desc.

    sg_image_sample_type and sg_sampler_type for a texture/sampler
    pair must be compatible with each other, specifically only
    the following pairs are allowed:

    - SG_IMAGESAMPLETYPE_FLOAT => (SG_SAMPLERTYPE_FILTERING or SG_SAMPLERTYPE_NONFILTERING)
    - SG_IMAGESAMPLETYPE_UNFILTERABLE_FLOAT => SG_SAMPLERTYPE_NONFILTERING
    - SG_IMAGESAMPLETYPE_SINT => SG_SAMPLERTYPE_NONFILTERING
    - SG_IMAGESAMPLETYPE_UINT => SG_SAMPLERTYPE_NONFILTERING
    - SG_IMAGESAMPLETYPE_DEPTH => SG_SAMPLERTYPE_COMPARISON |#
; Enum: sg_sampler_type
; No explicit value for -SG-SAMPLERTYPE-DEFAULT
; No explicit value for SG-SAMPLERTYPE-FILTERING
; No explicit value for SG-SAMPLERTYPE-NONFILTERING
; No explicit value for SG-SAMPLERTYPE-COMPARISON
; No explicit value for -SG-SAMPLERTYPE-NUM
; No explicit value for -SG-SAMPLERTYPE-FORCE-U32
#|     sg_cube_face

    The cubemap faces. Use these as indices in the sg_image_desc.content
    array. |#
; Enum: sg_cube_face
; No explicit value for SG-CUBEFACE-POS-X
; No explicit value for SG-CUBEFACE-NEG-X
; No explicit value for SG-CUBEFACE-POS-Y
; No explicit value for SG-CUBEFACE-NEG-Y
; No explicit value for SG-CUBEFACE-POS-Z
; No explicit value for SG-CUBEFACE-NEG-Z
; No explicit value for SG-CUBEFACE-NUM
(define -SG-CUBEFACE-FORCE-U32 2147483647)
#|     sg_primitive_type

    This is the common subset of 3D primitive types supported across all 3D
    APIs. This is used in the sg_pipeline_desc.primitive_type member when
    creating a pipeline object.

    The default primitive type is SG_PRIMITIVETYPE_TRIANGLES. |#
; Enum: sg_primitive_type
; No explicit value for -SG-PRIMITIVETYPE-DEFAULT
; No explicit value for SG-PRIMITIVETYPE-POINTS
; No explicit value for SG-PRIMITIVETYPE-LINES
; No explicit value for SG-PRIMITIVETYPE-LINE-STRIP
; No explicit value for SG-PRIMITIVETYPE-TRIANGLES
; No explicit value for SG-PRIMITIVETYPE-TRIANGLE-STRIP
; No explicit value for -SG-PRIMITIVETYPE-NUM
(define -SG-PRIMITIVETYPE-FORCE-U32 2147483647)
#|     sg_filter

    The filtering mode when sampling a texture image. This is
    used in the sg_sampler_desc.min_filter, sg_sampler_desc.mag_filter
    and sg_sampler_desc.mipmap_filter members when creating a sampler object.

    For the default is SG_FILTER_NEAREST. |#
; Enum: sg_filter
; No explicit value for -SG-FILTER-DEFAULT
; No explicit value for SG-FILTER-NEAREST
; No explicit value for SG-FILTER-LINEAR
; No explicit value for -SG-FILTER-NUM
(define -SG-FILTER-FORCE-U32 2147483647)
#|     sg_wrap

    The texture coordinates wrapping mode when sampling a texture
    image. This is used in the sg_image_desc.wrap_u, .wrap_v
    and .wrap_w members when creating an image.

    The default wrap mode is SG_WRAP_REPEAT.

    NOTE: SG_WRAP_CLAMP_TO_BORDER is not supported on all backends
    and platforms. To check for support, call sg_query_features()
    and check the "clamp_to_border" boolean in the returned
    sg_features struct.

    Platforms which don't support SG_WRAP_CLAMP_TO_BORDER will silently fall back
    to SG_WRAP_CLAMP_TO_EDGE without a validation error. |#
; Enum: sg_wrap
; No explicit value for -SG-WRAP-DEFAULT
; No explicit value for SG-WRAP-REPEAT
; No explicit value for SG-WRAP-CLAMP-TO-EDGE
; No explicit value for SG-WRAP-CLAMP-TO-BORDER
; No explicit value for SG-WRAP-MIRRORED-REPEAT
; No explicit value for -SG-WRAP-NUM
(define -SG-WRAP-FORCE-U32 2147483647)
#|     sg_border_color

    The border color to use when sampling a texture, and the UV wrap
    mode is SG_WRAP_CLAMP_TO_BORDER.

    The default border color is SG_BORDERCOLOR_OPAQUE_BLACK |#
; Enum: sg_border_color
; No explicit value for -SG-BORDERCOLOR-DEFAULT
; No explicit value for SG-BORDERCOLOR-TRANSPARENT-BLACK
; No explicit value for SG-BORDERCOLOR-OPAQUE-BLACK
; No explicit value for SG-BORDERCOLOR-OPAQUE-WHITE
; No explicit value for -SG-BORDERCOLOR-NUM
(define -SG-BORDERCOLOR-FORCE-U32 2147483647)
#|     sg_vertex_format

    The data type of a vertex component. This is used to describe
    the layout of input vertex data when creating a pipeline object.

    NOTE that specific mapping rules exist from the CPU-side vertex
    formats to the vertex attribute base type in the vertex shader code
    (see doc header section 'ON VERTEX FORMATS'). |#
; Enum: sg_vertex_format
; No explicit value for SG-VERTEXFORMAT-INVALID
; No explicit value for SG-VERTEXFORMAT-FLOAT
; No explicit value for SG-VERTEXFORMAT-FLOAT2
; No explicit value for SG-VERTEXFORMAT-FLOAT3
; No explicit value for SG-VERTEXFORMAT-FLOAT4
; No explicit value for SG-VERTEXFORMAT-INT
; No explicit value for SG-VERTEXFORMAT-INT2
; No explicit value for SG-VERTEXFORMAT-INT3
; No explicit value for SG-VERTEXFORMAT-INT4
; No explicit value for SG-VERTEXFORMAT-UINT
; No explicit value for SG-VERTEXFORMAT-UINT2
; No explicit value for SG-VERTEXFORMAT-UINT3
; No explicit value for SG-VERTEXFORMAT-UINT4
; No explicit value for SG-VERTEXFORMAT-BYTE4
; No explicit value for SG-VERTEXFORMAT-BYTE4N
; No explicit value for SG-VERTEXFORMAT-UBYTE4
; No explicit value for SG-VERTEXFORMAT-UBYTE4N
; No explicit value for SG-VERTEXFORMAT-SHORT2
; No explicit value for SG-VERTEXFORMAT-SHORT2N
; No explicit value for SG-VERTEXFORMAT-USHORT2
; No explicit value for SG-VERTEXFORMAT-USHORT2N
; No explicit value for SG-VERTEXFORMAT-SHORT4
; No explicit value for SG-VERTEXFORMAT-SHORT4N
; No explicit value for SG-VERTEXFORMAT-USHORT4
; No explicit value for SG-VERTEXFORMAT-USHORT4N
; No explicit value for SG-VERTEXFORMAT-UINT10-N2
; No explicit value for SG-VERTEXFORMAT-HALF2
; No explicit value for SG-VERTEXFORMAT-HALF4
; No explicit value for -SG-VERTEXFORMAT-NUM
(define -SG-VERTEXFORMAT-FORCE-U32 2147483647)
#|     sg_vertex_step

    Defines whether the input pointer of a vertex input stream is advanced
    'per vertex' or 'per instance'. The default step-func is
    SG_VERTEXSTEP_PER_VERTEX. SG_VERTEXSTEP_PER_INSTANCE is used with
    instanced-rendering.

    The vertex-step is part of the vertex-layout definition
    when creating pipeline objects. |#
; Enum: sg_vertex_step
; No explicit value for -SG-VERTEXSTEP-DEFAULT
; No explicit value for SG-VERTEXSTEP-PER-VERTEX
; No explicit value for SG-VERTEXSTEP-PER-INSTANCE
; No explicit value for -SG-VERTEXSTEP-NUM
(define -SG-VERTEXSTEP-FORCE-U32 2147483647)
#|     sg_uniform_type

    The data type of a uniform block member. This is used to
    describe the internal layout of uniform blocks when creating
    a shader object. This is only required for the GL backend, all
    other backends will ignore the interior layout of uniform blocks. |#
; Enum: sg_uniform_type
; No explicit value for SG-UNIFORMTYPE-INVALID
; No explicit value for SG-UNIFORMTYPE-FLOAT
; No explicit value for SG-UNIFORMTYPE-FLOAT2
; No explicit value for SG-UNIFORMTYPE-FLOAT3
; No explicit value for SG-UNIFORMTYPE-FLOAT4
; No explicit value for SG-UNIFORMTYPE-INT
; No explicit value for SG-UNIFORMTYPE-INT2
; No explicit value for SG-UNIFORMTYPE-INT3
; No explicit value for SG-UNIFORMTYPE-INT4
; No explicit value for SG-UNIFORMTYPE-MAT4
; No explicit value for -SG-UNIFORMTYPE-NUM
(define -SG-UNIFORMTYPE-FORCE-U32 2147483647)
#|     sg_uniform_layout

    A hint for the interior memory layout of uniform blocks. This is
    only relevant for the GL backend where the internal layout
    of uniform blocks must be known to sokol-gfx. For all other backends the
    internal memory layout of uniform blocks doesn't matter, sokol-gfx
    will just pass uniform data as an opaque memory blob to the
    3D backend.

    SG_UNIFORMLAYOUT_NATIVE (default)
        Native layout means that a 'backend-native' memory layout
        is used. For the GL backend this means that uniforms
        are packed tightly in memory (e.g. there are no padding
        bytes).

    SG_UNIFORMLAYOUT_STD140
        The memory layout is a subset of std140. Arrays are only
        allowed for the FLOAT4, INT4 and MAT4. Alignment is as
        is as follows:

            FLOAT, INT:         4 byte alignment
            FLOAT2, INT2:       8 byte alignment
            FLOAT3, INT3:       16 byte alignment(!)
            FLOAT4, INT4:       16 byte alignment
            MAT4:               16 byte alignment
            FLOAT4[], INT4[]:   16 byte alignment

        The overall size of the uniform block must be a multiple
        of 16.

    For more information search for 'UNIFORM DATA LAYOUT' in the documentation block
    at the start of the header. |#
; Enum: sg_uniform_layout
; No explicit value for -SG-UNIFORMLAYOUT-DEFAULT
; No explicit value for SG-UNIFORMLAYOUT-NATIVE
; No explicit value for SG-UNIFORMLAYOUT-STD140
; No explicit value for -SG-UNIFORMLAYOUT-NUM
(define -SG-UNIFORMLAYOUT-FORCE-U32 2147483647)
#|     sg_cull_mode

    The face-culling mode, this is used in the
    sg_pipeline_desc.cull_mode member when creating a
    pipeline object.

    The default cull mode is SG_CULLMODE_NONE |#
; Enum: sg_cull_mode
; No explicit value for -SG-CULLMODE-DEFAULT
; No explicit value for SG-CULLMODE-NONE
; No explicit value for SG-CULLMODE-FRONT
; No explicit value for SG-CULLMODE-BACK
; No explicit value for -SG-CULLMODE-NUM
(define -SG-CULLMODE-FORCE-U32 2147483647)
#|     sg_face_winding

    The vertex-winding rule that determines a front-facing primitive. This
    is used in the member sg_pipeline_desc.face_winding
    when creating a pipeline object.

    The default winding is SG_FACEWINDING_CW (clockwise) |#
; Enum: sg_face_winding
; No explicit value for -SG-FACEWINDING-DEFAULT
; No explicit value for SG-FACEWINDING-CCW
; No explicit value for SG-FACEWINDING-CW
; No explicit value for -SG-FACEWINDING-NUM
(define -SG-FACEWINDING-FORCE-U32 2147483647)
#|     sg_compare_func

    The compare-function for configuring depth- and stencil-ref tests
    in pipeline objects, and for texture samplers which perform a comparison
    instead of regular sampling operation.

    Used in the following structs:

    sg_pipeline_desc
        .depth
            .compare
        .stencil
            .front.compare
            .back.compare

    sg_sampler_desc
        .compare

    The default compare func for depth- and stencil-tests is
    SG_COMPAREFUNC_ALWAYS.

    The default compare func for samplers is SG_COMPAREFUNC_NEVER. |#
; Enum: sg_compare_func
; No explicit value for -SG-COMPAREFUNC-DEFAULT
; No explicit value for SG-COMPAREFUNC-NEVER
; No explicit value for SG-COMPAREFUNC-LESS
; No explicit value for SG-COMPAREFUNC-EQUAL
; No explicit value for SG-COMPAREFUNC-LESS-EQUAL
; No explicit value for SG-COMPAREFUNC-GREATER
; No explicit value for SG-COMPAREFUNC-NOT-EQUAL
; No explicit value for SG-COMPAREFUNC-GREATER-EQUAL
; No explicit value for SG-COMPAREFUNC-ALWAYS
; No explicit value for -SG-COMPAREFUNC-NUM
(define -SG-COMPAREFUNC-FORCE-U32 2147483647)
#|     sg_stencil_op

    The operation performed on a currently stored stencil-value when a
    comparison test passes or fails. This is used when creating a pipeline
    object in the following sg_pipeline_desc struct items:

    sg_pipeline_desc
        .stencil
            .front
                .fail_op
                .depth_fail_op
                .pass_op
            .back
                .fail_op
                .depth_fail_op
                .pass_op

    The default value is SG_STENCILOP_KEEP. |#
; Enum: sg_stencil_op
; No explicit value for -SG-STENCILOP-DEFAULT
; No explicit value for SG-STENCILOP-KEEP
; No explicit value for SG-STENCILOP-ZERO
; No explicit value for SG-STENCILOP-REPLACE
; No explicit value for SG-STENCILOP-INCR-CLAMP
; No explicit value for SG-STENCILOP-DECR-CLAMP
; No explicit value for SG-STENCILOP-INVERT
; No explicit value for SG-STENCILOP-INCR-WRAP
; No explicit value for SG-STENCILOP-DECR-WRAP
; No explicit value for -SG-STENCILOP-NUM
(define -SG-STENCILOP-FORCE-U32 2147483647)
#|     sg_blend_factor

    The source and destination factors in blending operations.
    This is used in the following members when creating a pipeline object:

    sg_pipeline_desc
        .colors[i]
            .blend
                .src_factor_rgb
                .dst_factor_rgb
                .src_factor_alpha
                .dst_factor_alpha

    The default value is SG_BLENDFACTOR_ONE for source
    factors, and for the destination SG_BLENDFACTOR_ZERO if the associated
    blend-op is ADD, SUBTRACT or REVERSE_SUBTRACT or SG_BLENDFACTOR_ONE
    if the associated blend-op is MIN or MAX. |#
; Enum: sg_blend_factor
; No explicit value for -SG-BLENDFACTOR-DEFAULT
; No explicit value for SG-BLENDFACTOR-ZERO
; No explicit value for SG-BLENDFACTOR-ONE
; No explicit value for SG-BLENDFACTOR-SRC-COLOR
; No explicit value for SG-BLENDFACTOR-ONE-MINUS-SRC-COLOR
; No explicit value for SG-BLENDFACTOR-SRC-ALPHA
; No explicit value for SG-BLENDFACTOR-ONE-MINUS-SRC-ALPHA
; No explicit value for SG-BLENDFACTOR-DST-COLOR
; No explicit value for SG-BLENDFACTOR-ONE-MINUS-DST-COLOR
; No explicit value for SG-BLENDFACTOR-DST-ALPHA
; No explicit value for SG-BLENDFACTOR-ONE-MINUS-DST-ALPHA
; No explicit value for SG-BLENDFACTOR-SRC-ALPHA-SATURATED
; No explicit value for SG-BLENDFACTOR-BLEND-COLOR
; No explicit value for SG-BLENDFACTOR-ONE-MINUS-BLEND-COLOR
; No explicit value for SG-BLENDFACTOR-BLEND-ALPHA
; No explicit value for SG-BLENDFACTOR-ONE-MINUS-BLEND-ALPHA
; No explicit value for -SG-BLENDFACTOR-NUM
(define -SG-BLENDFACTOR-FORCE-U32 2147483647)
#|     sg_blend_op

    Describes how the source and destination values are combined in the
    fragment blending operation. It is used in the following struct items
    when creating a pipeline object:

    sg_pipeline_desc
        .colors[i]
            .blend
                .op_rgb
                .op_alpha

    The default value is SG_BLENDOP_ADD. |#
; Enum: sg_blend_op
; No explicit value for -SG-BLENDOP-DEFAULT
; No explicit value for SG-BLENDOP-ADD
; No explicit value for SG-BLENDOP-SUBTRACT
; No explicit value for SG-BLENDOP-REVERSE-SUBTRACT
; No explicit value for SG-BLENDOP-MIN
; No explicit value for SG-BLENDOP-MAX
; No explicit value for -SG-BLENDOP-NUM
(define -SG-BLENDOP-FORCE-U32 2147483647)
#|     sg_color_mask

    Selects the active color channels when writing a fragment color to the
    framebuffer. This is used in the members
    sg_pipeline_desc.colors[i].write_mask when creating a pipeline object.

    The default colormask is SG_COLORMASK_RGBA (write all colors channels)

    NOTE: since the color mask value 0 is reserved for the default value
    (SG_COLORMASK_RGBA), use SG_COLORMASK_NONE if all color channels
    should be disabled. |#
; Enum: sg_color_mask
(define -SG-COLORMASK-DEFAULT 0)
(define SG-COLORMASK-NONE 16)
(define SG-COLORMASK-R 1)
(define SG-COLORMASK-G 2)
(define SG-COLORMASK-RG 3)
(define SG-COLORMASK-B 4)
(define SG-COLORMASK-RB 5)
(define SG-COLORMASK-GB 6)
(define SG-COLORMASK-RGB 7)
(define SG-COLORMASK-A 8)
(define SG-COLORMASK-RA 9)
(define SG-COLORMASK-GA 10)
(define SG-COLORMASK-RGA 11)
(define SG-COLORMASK-BA 12)
(define SG-COLORMASK-RBA 13)
(define SG-COLORMASK-GBA 14)
(define SG-COLORMASK-RGBA 15)
(define -SG-COLORMASK-FORCE-U32 2147483647)
#|     sg_load_action

    Defines the load action that should be performed at the start of a render pass:

    SG_LOADACTION_CLEAR:        clear the render target
    SG_LOADACTION_LOAD:         load the previous content of the render target
    SG_LOADACTION_DONTCARE:     leave the render target in an undefined state

    This is used in the sg_pass_action structure.

    The default load action for all pass attachments is SG_LOADACTION_CLEAR,
    with the values rgba = { 0.5f, 0.5f, 0.5f, 1.0f }, depth=1.0f and stencil=0.

    If you want to override the default behaviour, it is important to not
    only set the clear color, but the 'action' field as well (as long as this
    is _SG_LOADACTION_DEFAULT, the value fields will be ignored). |#
; Enum: sg_load_action
; No explicit value for -SG-LOADACTION-DEFAULT
; No explicit value for SG-LOADACTION-CLEAR
; No explicit value for SG-LOADACTION-LOAD
; No explicit value for SG-LOADACTION-DONTCARE
(define -SG-LOADACTION-FORCE-U32 2147483647)
#|     sg_store_action

    Defines the store action that should be performed at the end of a render pass:

    SG_STOREACTION_STORE:       store the rendered content to the color attachment image
    SG_STOREACTION_DONTCARE:    allows the GPU to discard the rendered content |#
; Enum: sg_store_action
; No explicit value for -SG-STOREACTION-DEFAULT
; No explicit value for SG-STOREACTION-STORE
; No explicit value for SG-STOREACTION-DONTCARE
(define -SG-STOREACTION-FORCE-U32 2147483647)
#|     sg_pass_action

    The sg_pass_action struct defines the actions to be performed
    at the start and end of a render pass.

    - at the start of the pass: whether the render attachments should be cleared,
      loaded with their previous content, or start in an undefined state
    - for clear operations: the clear value (color, depth, or stencil values)
    - at the end of the pass: whether the rendering result should be
      stored back into the render attachment or discarded |#
(define _color-attachment-action
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['load_action _int]
   ['store_action _int]
   ['clear_value _color]
  ))

(define _depth-attachment-action
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['load_action _int]
   ['store_action _int]
   ['clear_value _float]
  ))

(define _stencil-attachment-action
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['load_action _int]
   ['store_action _int]
   ['clear_value _uint8]
  ))

(define _pass-action
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['colors (_array _color_attachment_action 4)]
   ['depth _depth_attachment_action]
   ['stencil _stencil_attachment_action]
  ))

#|     sg_swapchain

    Used in sg_begin_pass() to provide details about an external swapchain
    (pixel formats, sample count and backend-API specific render surface objects).

    The following information must be provided:

    - the width and height of the swapchain surfaces in number of pixels,
    - the pixel format of the render- and optional msaa-resolve-surface
    - the pixel format of the optional depth- or depth-stencil-surface
    - the MSAA sample count for the render and depth-stencil surface

    If the pixel formats and MSAA sample counts are left zero-initialized,
    their defaults are taken from the sg_environment struct provided in the
    sg_setup() call.

    The width and height *must* be > 0.

    Additionally the following backend API specific objects must be passed in
    as 'type erased' void pointers:

    GL:
        - on all GL backends, a GL framebuffer object must be provided. This
          can be zero for the default framebuffer.

    D3D11:
        - an ID3D11RenderTargetView for the rendering surface, without
          MSAA rendering this surface will also be displayed
        - an optional ID3D11DepthStencilView for the depth- or depth/stencil
          buffer surface
        - when MSAA rendering is used, another ID3D11RenderTargetView
          which serves as MSAA resolve target and will be displayed

    WebGPU (same as D3D11, except different types)
        - a WGPUTextureView for the rendering surface, without
          MSAA rendering this surface will also be displayed
        - an optional WGPUTextureView for the depth- or depth/stencil
          buffer surface
        - when MSAA rendering is used, another WGPUTextureView
          which serves as MSAA resolve target and will be displayed

    Metal (NOTE that the roles of provided surfaces is slightly different
    than on D3D11 or WebGPU in case of MSAA vs non-MSAA rendering):

        - A current CAMetalDrawable (NOT an MTLDrawable!) which will be presented.
          This will either be rendered to directly (if no MSAA is used), or serve
          as MSAA-resolve target.
        - an optional MTLTexture for the depth- or depth-stencil buffer
        - an optional multisampled MTLTexture which serves as intermediate
          rendering surface which will then be resolved into the
          CAMetalDrawable.

    NOTE that for Metal you must use an ObjC __bridge cast to
    properly tunnel the ObjC object id through a C void*, e.g.:

        swapchain.metal.current_drawable = (__bridge const void*) [mtkView currentDrawable];

    On all other backends you shouldn't need to mess with the reference count.

    It's a good practice to write a helper function which returns an initialized
    sg_swapchain structs, which can then be plugged directly into
    sg_pass.swapchain. Look at the function sglue_swapchain() in the sokol_glue.h
    as an example. |#
(define _metal-swapchain
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['current_drawable _pointer]
   ['depth_stencil_texture _pointer]
   ['msaa_color_texture _pointer]
  ))

(define _d3d11-swapchain
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['render_view _pointer]
   ['resolve_view _pointer]
   ['depth_stencil_view _pointer]
  ))

(define _wgpu-swapchain
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['render_view _pointer]
   ['resolve_view _pointer]
   ['depth_stencil_view _pointer]
  ))

(define _gl-swapchain
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['framebuffer _uint32]
  ))

(define _swapchain
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['width _int]
   ['height _int]
   ['sample_count _int]
   ['color_format _int]
   ['depth_format _int]
   ['metal _metal_swapchain]
   ['d3d11 _d3d11_swapchain]
   ['wgpu _wgpu_swapchain]
   ['gl _gl_swapchain]
  ))

#|     sg_pass

    The sg_pass structure is passed as argument into the sg_begin_pass()
    function.

    For a swapchain render pass, provide an sg_pass_action and sg_swapchain
    struct (for instance via the sglue_swapchain() helper function from
    sokol_glue.h):

        sg_begin_pass(&(sg_pass){
            .action = { ... },
            .swapchain = sglue_swapchain(),
        });

    For an offscreen render pass, provide an sg_pass_action struct and
    an sg_attachments handle:

        sg_begin_pass(&(sg_pass){
            .action = { ... },
            .attachments = attachments,
        });

    You can also omit the .action object to get default pass action behaviour
    (clear to color=grey, depth=1 and stencil=0).

    For a compute pass, just set the sg_pass.compute boolean to true:

        sg_begin_pass(&(sg_pass){ .compute = true }); |#
(define _pass
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['_start_canary _uint32]
   ['compute _bool]
   ['action _pass_action]
   ['attachments _attachments]
   ['swapchain _swapchain]
   ['label _string/utf-8]
   ['_end_canary _uint32]
  ))

#|     sg_bindings

    The sg_bindings structure defines the buffers, images and
    samplers resource bindings for the next draw call.

    To update the resource bindings, call sg_apply_bindings() with
    a pointer to a populated sg_bindings struct. Note that
    sg_apply_bindings() must be called after sg_apply_pipeline()
    and that bindings are not preserved across sg_apply_pipeline()
    calls, even when the new pipeline uses the same 'bindings layout'.

    A resource binding struct contains:

    - 1..N vertex buffers
    - 0..N vertex buffer offsets
    - 0..1 index buffers
    - 0..1 index buffer offsets
    - 0..N images
    - 0..N samplers
    - 0..N storage buffers

    Where 'N' is defined in the following constants:

    - SG_MAX_VERTEXBUFFER_BINDSLOTS
    - SG_MAX_IMAGE_BINDLOTS
    - SG_MAX_SAMPLER_BINDSLOTS
    - SG_MAX_STORAGEBUFFER_BINDGLOTS

    Note that inside compute passes vertex- and index-buffer-bindings are
    disallowed.

    When using sokol-shdc for shader authoring, the `layout(binding=N)`
    annotation in the shader code directly maps to the slot index for that
    resource type in the bindings struct, for instance the following vertex-
    and fragment-shader interface for sokol-shdc:

        @vs vs
        layout(binding=0) uniform vs_params { ... };
        layout(binding=0) readonly buffer ssbo { ... };
        layout(binding=0) uniform texture2D vs_tex;
        layout(binding=0) uniform sampler vs_smp;
        ...
        @end

        @fs fs
        layout(binding=1) uniform fs_params { ... };
        layout(binding=1) uniform texture2D fs_tex;
        layout(binding=1) uniform sampler fs_smp;
        ...
        @end

    ...would map to the following sg_bindings struct:

        const sg_bindings bnd = {
            .vertex_buffers[0] = ...,
            .images[0] = vs_tex,
            .images[1] = fs_tex,
            .samplers[0] = vs_smp,
            .samplers[1] = fs_smp,
            .storage_buffers[0] = ssbo,
        };

    ...alternatively you can use code-generated slot indices:

        const sg_bindings bnd = {
            .vertex_buffers[0] = ...,
            .images[IMG_vs_tex] = vs_tex,
            .images[IMG_fs_tex] = fs_tex,
            .samplers[SMP_vs_smp] = vs_smp,
            .samplers[SMP_fs_smp] = fs_smp,
            .storage_buffers[SBUF_ssbo] = ssbo,
        };

    Resource bindslots for a specific shader/pipeline may have gaps, and an
    sg_bindings struct may have populated bind slots which are not used by a
    specific shader. This allows to use the same sg_bindings struct across
    different shader variants.

    When not using sokol-shdc, the bindslot indices in the sg_bindings
    struct need to match the per-resource reflection info slot indices
    in the sg_shader_desc struct (for details about that see the
    sg_shader_desc struct documentation).

    The optional buffer offsets can be used to put different unrelated
    chunks of vertex- and/or index-data into the same buffer objects. |#
(define _bindings
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['_start_canary _uint32]
   ['vertex_buffers (_array _buffer 8)]
   ['vertex_buffer_offsets (_array _int 8)]
   ['index_buffer _buffer]
   ['index_buffer_offset _int]
   ['images (_array _image 16)]
   ['samplers (_array _sampler 16)]
   ['storage_buffers (_array _buffer 8)]
   ['_end_canary _uint32]
  ))

#|     sg_buffer_desc

    Creation parameters for sg_buffer objects, used in the
    sg_make_buffer() call.

    The default configuration is:

    .size:      0       (*must* be >0 for buffers without data)
    .type:      SG_BUFFERTYPE_VERTEXBUFFER
    .usage:     SG_USAGE_IMMUTABLE
    .data.ptr   0       (*must* be valid for immutable buffers)
    .data.size  0       (*must* be > 0 for immutable buffers)
    .label      0       (optional string label)

    For immutable buffers which are initialized with initial data,
    keep the .size item zero-initialized, and set the size together with the
    pointer to the initial data in the .data item.

    For immutable or mutable buffers without initial data, keep the .data item
    zero-initialized, and set the buffer size in the .size item instead.

    NOTE: Immutable buffers without initial data are guaranteed to be
    zero-initialized. For mutable (dynamic or streaming) buffers, the
    initial content is undefined.

    You can also set both size values, but currently both size values must
    be identical (this may change in the future when the dynamic resource
    management may become more flexible).

    ADVANCED TOPIC: Injecting native 3D-API buffers:

    The following struct members allow to inject your own GL, Metal
    or D3D11 buffers into sokol_gfx:

    .gl_buffers[SG_NUM_INFLIGHT_FRAMES]
    .mtl_buffers[SG_NUM_INFLIGHT_FRAMES]
    .d3d11_buffer

    You must still provide all other struct items except the .data item, and
    these must match the creation parameters of the native buffers you
    provide. For SG_USAGE_IMMUTABLE, only provide a single native 3D-API
    buffer, otherwise you need to provide SG_NUM_INFLIGHT_FRAMES buffers
    (only for GL and Metal, not D3D11). Providing multiple buffers for GL and
    Metal is necessary because sokol_gfx will rotate through them when
    calling sg_update_buffer() to prevent lock-stalls.

    Note that it is expected that immutable injected buffer have already been
    initialized with content, and the .content member must be 0!

    Also you need to call sg_reset_state_cache() after calling native 3D-API
    functions, and before calling any sokol_gfx function. |#
(define _buffer-desc
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['_start_canary _uint32]
   ['size _size]
   ['type _int]
   ['usage _int]
   ['data _range]
   ['label _string/utf-8]
   ['gl_buffers (_array _uint32 2)]
   ['mtl_buffers (_array _pointer 2)]
   ['d3d11_buffer _pointer]
   ['wgpu_buffer _pointer]
   ['_end_canary _uint32]
  ))

#|     sg_image_data

    Defines the content of an image through a 2D array of sg_range structs.
    The first array dimension is the cubemap face, and the second array
    dimension the mipmap level. |#
(define _image-data
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['subimage (_array (_array _range 16) 6)]
  ))

#|     sg_image_desc

    Creation parameters for sg_image objects, used in the sg_make_image() call.

    The default configuration is:

    .type:              SG_IMAGETYPE_2D
    .render_target:     false
    .width              0 (must be set to >0)
    .height             0 (must be set to >0)
    .num_slices         1 (3D textures: depth; array textures: number of layers)
    .num_mipmaps:       1
    .usage:             SG_USAGE_IMMUTABLE
    .pixel_format:      SG_PIXELFORMAT_RGBA8 for textures, or sg_desc.environment.defaults.color_format for render targets
    .sample_count:      1 for textures, or sg_desc.environment.defaults.sample_count for render targets
    .data               an sg_image_data struct to define the initial content
    .label              0 (optional string label for trace hooks)

    Q: Why is the default sample_count for render targets identical with the
    "default sample count" from sg_desc.environment.defaults.sample_count?

    A: So that it matches the default sample count in pipeline objects. Even
    though it is a bit strange/confusing that offscreen render targets by default
    get the same sample count as 'default swapchains', but it's better that
    an offscreen render target created with default parameters matches
    a pipeline object created with default parameters.

    NOTE:

    Images with usage SG_USAGE_IMMUTABLE must be fully initialized by
    providing a valid .data member which points to initialization data.

    ADVANCED TOPIC: Injecting native 3D-API textures:

    The following struct members allow to inject your own GL, Metal or D3D11
    textures into sokol_gfx:

    .gl_textures[SG_NUM_INFLIGHT_FRAMES]
    .mtl_textures[SG_NUM_INFLIGHT_FRAMES]
    .d3d11_texture
    .d3d11_shader_resource_view
    .wgpu_texture
    .wgpu_texture_view

    For GL, you can also specify the texture target or leave it empty to use
    the default texture target for the image type (GL_TEXTURE_2D for
    SG_IMAGETYPE_2D etc)

    For D3D11 and WebGPU, either only provide a texture, or both a texture and
    shader-resource-view / texture-view object. If you want to use access the
    injected texture in a shader you *must* provide a shader-resource-view.

    The same rules apply as for injecting native buffers (see sg_buffer_desc
    documentation for more details). |#
(define _image-desc
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['_start_canary _uint32]
   ['type _int]
   ['render_target _bool]
   ['width _int]
   ['height _int]
   ['num_slices _int]
   ['num_mipmaps _int]
   ['usage _int]
   ['pixel_format _int]
   ['sample_count _int]
   ['data _image_data]
   ['label _string/utf-8]
   ['gl_textures (_array _uint32 2)]
   ['gl_texture_target _uint32]
   ['mtl_textures (_array _pointer 2)]
   ['d3d11_texture _pointer]
   ['d3d11_shader_resource_view _pointer]
   ['wgpu_texture _pointer]
   ['wgpu_texture_view _pointer]
   ['_end_canary _uint32]
  ))

#|     sg_sampler_desc

    Creation parameters for sg_sampler objects, used in the sg_make_sampler() call

    .min_filter:        SG_FILTER_NEAREST
    .mag_filter:        SG_FILTER_NEAREST
    .mipmap_filter      SG_FILTER_NEAREST
    .wrap_u:            SG_WRAP_REPEAT
    .wrap_v:            SG_WRAP_REPEAT
    .wrap_w:            SG_WRAP_REPEAT (only SG_IMAGETYPE_3D)
    .min_lod            0.0f
    .max_lod            FLT_MAX
    .border_color       SG_BORDERCOLOR_OPAQUE_BLACK
    .compare            SG_COMPAREFUNC_NEVER
    .max_anisotropy     1 (must be 1..16) |#
(define _sampler-desc
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['_start_canary _uint32]
   ['min_filter _int]
   ['mag_filter _int]
   ['mipmap_filter _int]
   ['wrap_u _int]
   ['wrap_v _int]
   ['wrap_w _int]
   ['min_lod _float]
   ['max_lod _float]
   ['border_color _int]
   ['compare _int]
   ['max_anisotropy _uint32]
   ['label _string/utf-8]
   ['gl_sampler _uint32]
   ['mtl_sampler _pointer]
   ['d3d11_sampler _pointer]
   ['wgpu_sampler _pointer]
   ['_end_canary _uint32]
  ))

#|     sg_shader_desc

    Used as parameter of sg_make_shader() to create a shader object which
    communicates shader source or bytecode and shader interface
    reflection information to sokol-gfx.

    If you use sokol-shdc you can ignore the following information since
    the sg_shader_desc struct will be code generated.

    Otherwise you need to provide the following information to the
    sg_make_shader() call:

    - a vertex- and fragment-shader function:
        - the shader source or bytecode
        - an optional entry point name
        - for D3D11: an optional compile target when source code is provided
          (the defaults are "vs_4_0" and "ps_4_0")

    - ...or alternatively, a compute function:
        - the shader source or bytecode
        - an optional entry point name
        - for D3D11: an optional compile target when source code is provided
          (the default is "cs_5_0")

    - vertex attributes required by some backends (not for compute shaders):
        - the vertex attribute base type (undefined, float, signed int, unsigned int),
          this information is only used in the validation layer to check that the
          pipeline object vertex formats are compatible with the input vertex attribute
          type used in the vertex shader. NOTE that the default base type
          'undefined' skips the validation layer check.
        - for the GL backend: optional vertex attribute names used for name lookup
        - for the D3D11 backend: semantic names and indices

    - only for compute shaders on the Metal backend:
        - the workgroup size aka 'threads per thread-group'

          In other 3D APIs this is declared in the shader code:
            - GLSL: `layout(local_size_x=x, local_size_y=y, local_size_y=z) in;`
            - HLSL: `[numthreads(x, y, z)]`
            - WGSL: `@workgroup_size(x, y, z)`
          ...but in Metal the workgroup size is declared on the CPU side

    - reflection information for each uniform block used by the shader:
        - the shader stage the uniform block appears in (SG_SHADERSTAGE_*)
        - the size in bytes of the uniform block
        - backend-specific bindslots:
            - HLSL: the constant buffer register `register(b0..7)`
            - MSL: the buffer attribute `[[buffer(0..7)]]`
            - WGSL: the binding in `@group(0) @binding(0..15)`
        - GLSL only: a description of the uniform block interior
            - the memory layout standard (SG_UNIFORMLAYOUT_*)
            - for each member in the uniform block:
                - the member type (SG_UNIFORM_*)
                - if the member is an array, the array count
                - the member name

    - reflection information for each texture used by the shader:
        - the shader stage the texture appears in (SG_SHADERSTAGE_*)
        - the image type (SG_IMAGETYPE_*)
        - the image-sample type (SG_IMAGESAMPLETYPE_*)
        - whether the texture is multisampled
        - backend specific bindslots:
            - HLSL: the texture register `register(t0..23)`
            - MSL: the texture attribute `[[texture(0..15)]]`
            - WGSL: the binding in `@group(1) @binding(0..127)`

    - reflection information for each sampler used by the shader:
        - the shader stage the sampler appears in (SG_SHADERSTAGE_*)
        - the sampler type (SG_SAMPLERTYPE_*)
        - backend specific bindslots:
            - HLSL: the sampler register `register(s0..15)`
            - MSL: the sampler attribute `[[sampler(0..15)]]`
            - WGSL: the binding in `@group(0) @binding(0..127)`

    - reflection information for each storage buffer used by the shader:
        - the shader stage the storage buffer appears in (SG_SHADERSTAGE_*)
        - whether the storage buffer is readonly (currently this must
          always be true)
        - backend specific bindslots:
            - HLSL:
                - for readonly storage buffer bindings: `register(t0..23)`
                - for read/write storage buffer bindings: `register(u0..7)`
            - MSL: the buffer attribute `[[buffer(8..15)]]`
            - WGSL: the binding in `@group(1) @binding(0..127)`
            - GL: the binding in `layout(binding=0..7)`

    - reflection information for each combined image-sampler object
      used by the shader:
        - the shader stage (SG_SHADERSTAGE_*)
        - the texture's array index in the sg_shader_desc.images[] array
        - the sampler's array index in the sg_shader_desc.samplers[] array
        - GLSL only: the name of the combined image-sampler object

    The number and order of items in the sg_shader_desc.attrs[]
    array corresponds to the items in sg_pipeline_desc.layout.attrs.

        - sg_shader_desc.attrs[N] => sg_pipeline_desc.layout.attrs[N]

    NOTE that vertex attribute indices currently cannot have gaps.

    The items index in the sg_shader_desc.uniform_blocks[] array corresponds
    to the ub_slot arg in sg_apply_uniforms():

        - sg_shader_desc.uniform_blocks[N] => sg_apply_uniforms(N, ...)

    The items in the shader_desc images, samplers and storage_buffers
    arrays correspond to the same array items in the sg_bindings struct:

        - sg_shader_desc.images[N] => sg_bindings.images[N]
        - sg_shader_desc.samplers[N] => sg_bindings.samplers[N]
        - sg_shader_desc.storage_buffers[N] => sg_bindings.storage_buffers[N]

    For all GL backends, shader source-code must be provided. For D3D11 and Metal,
    either shader source-code or byte-code can be provided.

    NOTE that the uniform block, image, sampler and storage_buffer arrays
    can have gaps. This allows to use the same sg_bindings struct for
    different related shader variants.

    For D3D11, if source code is provided, the d3dcompiler_47.dll will be loaded
    on demand. If this fails, shader creation will fail. When compiling HLSL
    source code, you can provide an optional target string via
    sg_shader_stage_desc.d3d11_target, the default target is "vs_4_0" for the
    vertex shader stage and "ps_4_0" for the pixel shader stage. |#
; Enum: sg_shader_stage
; No explicit value for SG-SHADERSTAGE-NONE
; No explicit value for SG-SHADERSTAGE-VERTEX
; No explicit value for SG-SHADERSTAGE-FRAGMENT
; No explicit value for SG-SHADERSTAGE-COMPUTE
(define -SG-SHADERSTAGE-FORCE-U32 2147483647)
(define _shader-function
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['source _string/utf-8]
   ['bytecode _range]
   ['entry _string/utf-8]
   ['d3d11_target _string/utf-8]
  ))

; Enum: sg_shader_attr_base_type
; No explicit value for SG-SHADERATTRBASETYPE-UNDEFINED
; No explicit value for SG-SHADERATTRBASETYPE-FLOAT
; No explicit value for SG-SHADERATTRBASETYPE-SINT
; No explicit value for SG-SHADERATTRBASETYPE-UINT
(define -SG-SHADERATTRBASETYPE-FORCE-U32 2147483647)
(define _shader-vertex-attr
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['base_type _int]
   ['glsl_name _string/utf-8]
   ['hlsl_sem_name _string/utf-8]
   ['hlsl_sem_index _uint8]
  ))

(define _glsl-shader-uniform
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['type _int]
   ['array_count _uint16]
   ['glsl_name _string/utf-8]
  ))

(define _shader-uniform-block
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['stage _int]
   ['size _uint32]
   ['hlsl_register_b_n _uint8]
   ['msl_buffer_n _uint8]
   ['wgsl_group0_binding_n _uint8]
   ['layout _int]
   ['glsl_uniforms (_array _glsl_shader_uniform 16)]
  ))

(define _shader-image
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['stage _int]
   ['image_type _int]
   ['sample_type _int]
   ['multisampled _bool]
   ['hlsl_register_t_n _uint8]
   ['msl_texture_n _uint8]
   ['wgsl_group1_binding_n _uint8]
  ))

(define _shader-sampler
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['stage _int]
   ['sampler_type _int]
   ['hlsl_register_s_n _uint8]
   ['msl_sampler_n _uint8]
   ['wgsl_group1_binding_n _uint8]
  ))

(define _shader-storage-buffer
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['stage _int]
   ['readonly _bool]
   ['hlsl_register_t_n _uint8]
   ['hlsl_register_u_n _uint8]
   ['msl_buffer_n _uint8]
   ['wgsl_group1_binding_n _uint8]
   ['glsl_binding_n _uint8]
  ))

(define _shader-image-sampler-pair
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['stage _int]
   ['image_slot _uint8]
   ['sampler_slot _uint8]
   ['glsl_name _string/utf-8]
  ))

(define _mtl-shader-threads-per-threadgroup
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['x _int]
   ['y _int]
   ['z _int]
  ))

(define _shader-desc
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['_start_canary _uint32]
   ['vertex_func _shader_function]
   ['fragment_func _shader_function]
   ['compute_func _shader_function]
   ['attrs (_array _shader_vertex_attr 16)]
   ['uniform_blocks (_array _shader_uniform_block 8)]
   ['storage_buffers (_array _shader_storage_buffer 8)]
   ['images (_array _shader_image 16)]
   ['samplers (_array _shader_sampler 16)]
   ['image_sampler_pairs (_array _shader_image_sampler_pair 16)]
   ['mtl_threads_per_threadgroup _mtl_shader_threads_per_threadgroup]
   ['label _string/utf-8]
   ['_end_canary _uint32]
  ))

#|     sg_pipeline_desc

    The sg_pipeline_desc struct defines all creation parameters for an
    sg_pipeline object, used as argument to the sg_make_pipeline() function:

    Pipeline objects come in two flavours:

    - render pipelines for use in render passes
    - compute pipelines for use in compute passes

    A compute pipeline only requires a compute shader object but no
    'render state', while a render pipeline requires a vertex/fragment shader
    object and additional render state declarations:

    - the vertex layout for all input vertex buffers
    - a shader object
    - the 3D primitive type (points, lines, triangles, ...)
    - the index type (none, 16- or 32-bit)
    - all the fixed-function-pipeline state (depth-, stencil-, blend-state, etc...)

    If the vertex data has no gaps between vertex components, you can omit
    the .layout.buffers[].stride and layout.attrs[].offset items (leave them
    default-initialized to 0), sokol-gfx will then compute the offsets and
    strides from the vertex component formats (.layout.attrs[].format).
    Please note that ALL vertex attribute offsets must be 0 in order for the
    automatic offset computation to kick in.

    The default configuration is as follows:

    .compute:               false (must be set to true for a compute pipeline)
    .shader:                0 (must be initialized with a valid sg_shader id!)
    .layout:
        .buffers[]:         vertex buffer layouts
            .stride:        0 (if no stride is given it will be computed)
            .step_func      SG_VERTEXSTEP_PER_VERTEX
            .step_rate      1
        .attrs[]:           vertex attribute declarations
            .buffer_index   0 the vertex buffer bind slot
            .offset         0 (offsets can be omitted if the vertex layout has no gaps)
            .format         SG_VERTEXFORMAT_INVALID (must be initialized!)
    .depth:
        .pixel_format:      sg_desc.context.depth_format
        .compare:           SG_COMPAREFUNC_ALWAYS
        .write_enabled:     false
        .bias:              0.0f
        .bias_slope_scale:  0.0f
        .bias_clamp:        0.0f
    .stencil:
        .enabled:           false
        .front/back:
            .compare:       SG_COMPAREFUNC_ALWAYS
            .fail_op:       SG_STENCILOP_KEEP
            .depth_fail_op: SG_STENCILOP_KEEP
            .pass_op:       SG_STENCILOP_KEEP
        .read_mask:         0
        .write_mask:        0
        .ref:               0
    .color_count            1
    .colors[0..color_count]
        .pixel_format       sg_desc.context.color_format
        .write_mask:        SG_COLORMASK_RGBA
        .blend:
            .enabled:           false
            .src_factor_rgb:    SG_BLENDFACTOR_ONE
            .dst_factor_rgb:    SG_BLENDFACTOR_ZERO
            .op_rgb:            SG_BLENDOP_ADD
            .src_factor_alpha:  SG_BLENDFACTOR_ONE
            .dst_factor_alpha:  SG_BLENDFACTOR_ZERO
            .op_alpha:          SG_BLENDOP_ADD
    .primitive_type:            SG_PRIMITIVETYPE_TRIANGLES
    .index_type:                SG_INDEXTYPE_NONE
    .cull_mode:                 SG_CULLMODE_NONE
    .face_winding:              SG_FACEWINDING_CW
    .sample_count:              sg_desc.context.sample_count
    .blend_color:               (sg_color) { 0.0f, 0.0f, 0.0f, 0.0f }
    .alpha_to_coverage_enabled: false
    .label  0       (optional string label for trace hooks) |#
(define _vertex-buffer-layout-state
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['stride _int]
   ['step_func _int]
   ['step_rate _int]
  ))

(define _vertex-attr-state
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['buffer_index _int]
   ['offset _int]
   ['format _int]
  ))

(define _vertex-layout-state
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['buffers (_array _vertex_buffer_layout_state 8)]
   ['attrs (_array _vertex_attr_state 16)]
  ))

(define _stencil-face-state
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['compare _int]
   ['fail_op _int]
   ['depth_fail_op _int]
   ['pass_op _int]
  ))

(define _stencil-state
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['enabled _bool]
   ['front _stencil_face_state]
   ['back _stencil_face_state]
   ['read_mask _uint8]
   ['write_mask _uint8]
   ['ref _uint8]
  ))

(define _depth-state
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['pixel_format _int]
   ['compare _int]
   ['write_enabled _bool]
   ['bias _float]
   ['bias_slope_scale _float]
   ['bias_clamp _float]
  ))

(define _blend-state
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['enabled _bool]
   ['src_factor_rgb _int]
   ['dst_factor_rgb _int]
   ['op_rgb _int]
   ['src_factor_alpha _int]
   ['dst_factor_alpha _int]
   ['op_alpha _int]
  ))

(define _color-target-state
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['pixel_format _int]
   ['write_mask _int]
   ['blend _blend_state]
  ))

(define _pipeline-desc
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['_start_canary _uint32]
   ['compute _bool]
   ['shader _shader]
   ['layout _vertex_layout_state]
   ['depth _depth_state]
   ['stencil _stencil_state]
   ['color_count _int]
   ['colors (_array _color_target_state 4)]
   ['primitive_type _int]
   ['index_type _int]
   ['cull_mode _int]
   ['face_winding _int]
   ['sample_count _int]
   ['blend_color _color]
   ['alpha_to_coverage_enabled _bool]
   ['label _string/utf-8]
   ['_end_canary _uint32]
  ))

#|     sg_attachments_desc

    Creation parameters for an sg_attachments object, used as argument to the
    sg_make_attachments() function.

    An attachments object bundles 0..4 color attachments, 0..4 msaa-resolve
    attachments, and none or one depth-stencil attachmente for use
    in a render pass. At least one color attachment or one depth-stencil
    attachment must be provided (no color attachment and a depth-stencil
    attachment is useful for a depth-only render pass).

    Each attachment definition consists of an image object, and two additional indices
    describing which subimage the pass will render into: one mipmap index, and if the image
    is a cubemap, array-texture or 3D-texture, the face-index, array-layer or
    depth-slice.

    All attachments must have the same width and height.

    All color attachments and the depth-stencil attachment must have the
    same sample count.

    If a resolve attachment is set, an MSAA-resolve operation from the
    associated color attachment image into the resolve attachment image will take
    place in the sg_end_pass() function. In this case, the color attachment
    must have a (sample_count>1), and the resolve attachment a
    (sample_count==1). The resolve attachment also must have the same pixel
    format as the color attachment.

    NOTE that MSAA depth-stencil attachments cannot be msaa-resolved! |#
(define _attachment-desc
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['image _image]
   ['mip_level _int]
   ['slice _int]
  ))

(define _attachments-desc
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['_start_canary _uint32]
   ['colors (_array _attachment_desc 4)]
   ['resolves (_array _attachment_desc 4)]
   ['depth_stencil _attachment_desc]
   ['label _string/utf-8]
   ['_end_canary _uint32]
  ))

#|     sg_trace_hooks

    Installable callback functions to keep track of the sokol-gfx calls,
    this is useful for debugging, or keeping track of resource creation
    and destruction.

    Trace hooks are installed with sg_install_trace_hooks(), this returns
    another sg_trace_hooks struct with the previous set of
    trace hook function pointers. These should be invoked by the
    new trace hooks to form a proper call chain. |#
(define _trace-hooks
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['user_data _pointer]
   ['reset_state_cache _fpointer]
   ['make_buffer _fpointer]
   ['make_image _fpointer]
   ['make_sampler _fpointer]
   ['make_shader _fpointer]
   ['make_pipeline _fpointer]
   ['make_attachments _fpointer]
   ['destroy_buffer _fpointer]
   ['destroy_image _fpointer]
   ['destroy_sampler _fpointer]
   ['destroy_shader _fpointer]
   ['destroy_pipeline _fpointer]
   ['destroy_attachments _fpointer]
   ['update_buffer _fpointer]
   ['update_image _fpointer]
   ['append_buffer _fpointer]
   ['begin_pass _fpointer]
   ['apply_viewport _fpointer]
   ['apply_scissor_rect _fpointer]
   ['apply_pipeline _fpointer]
   ['apply_bindings _fpointer]
   ['apply_uniforms _fpointer]
   ['draw _fpointer]
   ['dispatch _fpointer]
   ['end_pass _fpointer]
   ['commit _fpointer]
   ['alloc_buffer _fpointer]
   ['alloc_image _fpointer]
   ['alloc_sampler _fpointer]
   ['alloc_shader _fpointer]
   ['alloc_pipeline _fpointer]
   ['alloc_attachments _fpointer]
   ['dealloc_buffer _fpointer]
   ['dealloc_image _fpointer]
   ['dealloc_sampler _fpointer]
   ['dealloc_shader _fpointer]
   ['dealloc_pipeline _fpointer]
   ['dealloc_attachments _fpointer]
   ['init_buffer _fpointer]
   ['init_image _fpointer]
   ['init_sampler _fpointer]
   ['init_shader _fpointer]
   ['init_pipeline _fpointer]
   ['init_attachments _fpointer]
   ['uninit_buffer _fpointer]
   ['uninit_image _fpointer]
   ['uninit_sampler _fpointer]
   ['uninit_shader _fpointer]
   ['uninit_pipeline _fpointer]
   ['uninit_attachments _fpointer]
   ['fail_buffer _fpointer]
   ['fail_image _fpointer]
   ['fail_sampler _fpointer]
   ['fail_shader _fpointer]
   ['fail_pipeline _fpointer]
   ['fail_attachments _fpointer]
   ['push_debug_group _fpointer]
   ['pop_debug_group _fpointer]
  ))

#|     sg_buffer_info
    sg_image_info
    sg_sampler_info
    sg_shader_info
    sg_pipeline_info
    sg_attachments_info

    These structs contain various internal resource attributes which
    might be useful for debug-inspection. Please don't rely on the
    actual content of those structs too much, as they are quite closely
    tied to sokol_gfx.h internals and may change more frequently than
    the other public API elements.

    The *_info structs are used as the return values of the following functions:

    sg_query_buffer_info()
    sg_query_image_info()
    sg_query_sampler_info()
    sg_query_shader_info()
    sg_query_pipeline_info()
    sg_query_attachments_info() |#
(define _slot-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['state _int]
   ['res_id _uint32]
  ))

(define _buffer-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['slot _slot_info]
   ['update_frame_index _uint32]
   ['append_frame_index _uint32]
   ['append_pos _int]
   ['append_overflow _bool]
   ['num_slots _int]
   ['active_slot _int]
  ))

(define _image-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['slot _slot_info]
   ['upd_frame_index _uint32]
   ['num_slots _int]
   ['active_slot _int]
  ))

(define _sampler-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['slot _slot_info]
  ))

(define _shader-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['slot _slot_info]
  ))

(define _pipeline-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['slot _slot_info]
  ))

(define _attachments-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['slot _slot_info]
  ))

#|     sg_frame_stats

    Allows to track generic and backend-specific stats about a
    render frame. Obtained by calling sg_query_frame_stats(). The returned
    struct contains information about the *previous* frame. |#
(define _frame-stats-gl
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['num_bind_buffer _uint32]
   ['num_active_texture _uint32]
   ['num_bind_texture _uint32]
   ['num_bind_sampler _uint32]
   ['num_use_program _uint32]
   ['num_render_state _uint32]
   ['num_vertex_attrib_pointer _uint32]
   ['num_vertex_attrib_divisor _uint32]
   ['num_enable_vertex_attrib_array _uint32]
   ['num_disable_vertex_attrib_array _uint32]
   ['num_uniform _uint32]
   ['num_memory_barriers _uint32]
  ))

(define _frame-stats-d3d11-pass
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['num_om_set_render_targets _uint32]
   ['num_clear_render_target_view _uint32]
   ['num_clear_depth_stencil_view _uint32]
   ['num_resolve_subresource _uint32]
  ))

(define _frame-stats-d3d11-pipeline
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['num_rs_set_state _uint32]
   ['num_om_set_depth_stencil_state _uint32]
   ['num_om_set_blend_state _uint32]
   ['num_ia_set_primitive_topology _uint32]
   ['num_ia_set_input_layout _uint32]
   ['num_vs_set_shader _uint32]
   ['num_vs_set_constant_buffers _uint32]
   ['num_ps_set_shader _uint32]
   ['num_ps_set_constant_buffers _uint32]
   ['num_cs_set_shader _uint32]
   ['num_cs_set_constant_buffers _uint32]
  ))

(define _frame-stats-d3d11-bindings
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['num_ia_set_vertex_buffers _uint32]
   ['num_ia_set_index_buffer _uint32]
   ['num_vs_set_shader_resources _uint32]
   ['num_vs_set_samplers _uint32]
   ['num_ps_set_shader_resources _uint32]
   ['num_ps_set_samplers _uint32]
   ['num_cs_set_shader_resources _uint32]
   ['num_cs_set_samplers _uint32]
   ['num_cs_set_unordered_access_views _uint32]
  ))

(define _frame-stats-d3d11-uniforms
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['num_update_subresource _uint32]
  ))

(define _frame-stats-d3d11-draw
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['num_draw_indexed_instanced _uint32]
   ['num_draw_indexed _uint32]
   ['num_draw_instanced _uint32]
   ['num_draw _uint32]
  ))

(define _frame-stats-d3d11
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['pass _frame_stats_d3d11_pass]
   ['pipeline _frame_stats_d3d11_pipeline]
   ['bindings _frame_stats_d3d11_bindings]
   ['uniforms _frame_stats_d3d11_uniforms]
   ['draw _frame_stats_d3d11_draw]
   ['num_map _uint32]
   ['num_unmap _uint32]
  ))

(define _frame-stats-metal-idpool
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['num_added _uint32]
   ['num_released _uint32]
   ['num_garbage_collected _uint32]
  ))

(define _frame-stats-metal-pipeline
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['num_set_blend_color _uint32]
   ['num_set_cull_mode _uint32]
   ['num_set_front_facing_winding _uint32]
   ['num_set_stencil_reference_value _uint32]
   ['num_set_depth_bias _uint32]
   ['num_set_render_pipeline_state _uint32]
   ['num_set_depth_stencil_state _uint32]
  ))

(define _frame-stats-metal-bindings
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['num_set_vertex_buffer _uint32]
   ['num_set_vertex_texture _uint32]
   ['num_set_vertex_sampler_state _uint32]
   ['num_set_fragment_buffer _uint32]
   ['num_set_fragment_texture _uint32]
   ['num_set_fragment_sampler_state _uint32]
   ['num_set_compute_buffer _uint32]
   ['num_set_compute_texture _uint32]
   ['num_set_compute_sampler_state _uint32]
  ))

(define _frame-stats-metal-uniforms
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['num_set_vertex_buffer_offset _uint32]
   ['num_set_fragment_buffer_offset _uint32]
   ['num_set_compute_buffer_offset _uint32]
  ))

(define _frame-stats-metal
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['idpool _frame_stats_metal_idpool]
   ['pipeline _frame_stats_metal_pipeline]
   ['bindings _frame_stats_metal_bindings]
   ['uniforms _frame_stats_metal_uniforms]
  ))

(define _frame-stats-wgpu-uniforms
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['num_set_bindgroup _uint32]
   ['size_write_buffer _uint32]
  ))

(define _frame-stats-wgpu-bindings
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['num_set_vertex_buffer _uint32]
   ['num_skip_redundant_vertex_buffer _uint32]
   ['num_set_index_buffer _uint32]
   ['num_skip_redundant_index_buffer _uint32]
   ['num_create_bindgroup _uint32]
   ['num_discard_bindgroup _uint32]
   ['num_set_bindgroup _uint32]
   ['num_skip_redundant_bindgroup _uint32]
   ['num_bindgroup_cache_hits _uint32]
   ['num_bindgroup_cache_misses _uint32]
   ['num_bindgroup_cache_collisions _uint32]
   ['num_bindgroup_cache_invalidates _uint32]
   ['num_bindgroup_cache_hash_vs_key_mismatch _uint32]
  ))

(define _frame-stats-wgpu
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['uniforms _frame_stats_wgpu_uniforms]
   ['bindings _frame_stats_wgpu_bindings]
  ))

(define _frame-stats
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['frame_index _uint32]
   ['num_passes _uint32]
   ['num_apply_viewport _uint32]
   ['num_apply_scissor_rect _uint32]
   ['num_apply_pipeline _uint32]
   ['num_apply_bindings _uint32]
   ['num_apply_uniforms _uint32]
   ['num_draw _uint32]
   ['num_dispatch _uint32]
   ['num_update_buffer _uint32]
   ['num_append_buffer _uint32]
   ['num_update_image _uint32]
   ['size_apply_uniforms _uint32]
   ['size_update_buffer _uint32]
   ['size_append_buffer _uint32]
   ['size_update_image _uint32]
   ['gl _frame_stats_gl]
   ['d3d11 _frame_stats_d3d11]
   ['metal _frame_stats_metal]
   ['wgpu _frame_stats_wgpu]
  ))

; Enum: sg_log_item
; No explicit value for SG-LOGITEM-OK
; No explicit value for SG-LOGITEM-MALLOC-FAILED
; No explicit value for SG-LOGITEM-GL-TEXTURE-FORMAT-NOT-SUPPORTED
; No explicit value for SG-LOGITEM-GL-3D-TEXTURES-NOT-SUPPORTED
; No explicit value for SG-LOGITEM-GL-ARRAY-TEXTURES-NOT-SUPPORTED
; No explicit value for SG-LOGITEM-GL-STORAGEBUFFER-GLSL-BINDING-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-GL-SHADER-COMPILATION-FAILED
; No explicit value for SG-LOGITEM-GL-SHADER-LINKING-FAILED
; No explicit value for SG-LOGITEM-GL-VERTEX-ATTRIBUTE-NOT-FOUND-IN-SHADER
; No explicit value for SG-LOGITEM-GL-UNIFORMBLOCK-NAME-NOT-FOUND-IN-SHADER
; No explicit value for SG-LOGITEM-GL-IMAGE-SAMPLER-NAME-NOT-FOUND-IN-SHADER
; No explicit value for SG-LOGITEM-GL-FRAMEBUFFER-STATUS-UNDEFINED
; No explicit value for SG-LOGITEM-GL-FRAMEBUFFER-STATUS-INCOMPLETE-ATTACHMENT
; No explicit value for SG-LOGITEM-GL-FRAMEBUFFER-STATUS-INCOMPLETE-MISSING-ATTACHMENT
; No explicit value for SG-LOGITEM-GL-FRAMEBUFFER-STATUS-UNSUPPORTED
; No explicit value for SG-LOGITEM-GL-FRAMEBUFFER-STATUS-INCOMPLETE-MULTISAMPLE
; No explicit value for SG-LOGITEM-GL-FRAMEBUFFER-STATUS-UNKNOWN
; No explicit value for SG-LOGITEM-D3D11-CREATE-BUFFER-FAILED
; No explicit value for SG-LOGITEM-D3D11-CREATE-BUFFER-SRV-FAILED
; No explicit value for SG-LOGITEM-D3D11-CREATE-BUFFER-UAV-FAILED
; No explicit value for SG-LOGITEM-D3D11-CREATE-DEPTH-TEXTURE-UNSUPPORTED-PIXEL-FORMAT
; No explicit value for SG-LOGITEM-D3D11-CREATE-DEPTH-TEXTURE-FAILED
; No explicit value for SG-LOGITEM-D3D11-CREATE-2D-TEXTURE-UNSUPPORTED-PIXEL-FORMAT
; No explicit value for SG-LOGITEM-D3D11-CREATE-2D-TEXTURE-FAILED
; No explicit value for SG-LOGITEM-D3D11-CREATE-2D-SRV-FAILED
; No explicit value for SG-LOGITEM-D3D11-CREATE-3D-TEXTURE-UNSUPPORTED-PIXEL-FORMAT
; No explicit value for SG-LOGITEM-D3D11-CREATE-3D-TEXTURE-FAILED
; No explicit value for SG-LOGITEM-D3D11-CREATE-3D-SRV-FAILED
; No explicit value for SG-LOGITEM-D3D11-CREATE-MSAA-TEXTURE-FAILED
; No explicit value for SG-LOGITEM-D3D11-CREATE-SAMPLER-STATE-FAILED
; No explicit value for SG-LOGITEM-D3D11-UNIFORMBLOCK-HLSL-REGISTER-B-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-D3D11-STORAGEBUFFER-HLSL-REGISTER-T-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-D3D11-STORAGEBUFFER-HLSL-REGISTER-U-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-D3D11-IMAGE-HLSL-REGISTER-T-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-D3D11-SAMPLER-HLSL-REGISTER-S-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-D3D11-LOAD-D3DCOMPILER-47-DLL-FAILED
; No explicit value for SG-LOGITEM-D3D11-SHADER-COMPILATION-FAILED
; No explicit value for SG-LOGITEM-D3D11-SHADER-COMPILATION-OUTPUT
; No explicit value for SG-LOGITEM-D3D11-CREATE-CONSTANT-BUFFER-FAILED
; No explicit value for SG-LOGITEM-D3D11-CREATE-INPUT-LAYOUT-FAILED
; No explicit value for SG-LOGITEM-D3D11-CREATE-RASTERIZER-STATE-FAILED
; No explicit value for SG-LOGITEM-D3D11-CREATE-DEPTH-STENCIL-STATE-FAILED
; No explicit value for SG-LOGITEM-D3D11-CREATE-BLEND-STATE-FAILED
; No explicit value for SG-LOGITEM-D3D11-CREATE-RTV-FAILED
; No explicit value for SG-LOGITEM-D3D11-CREATE-DSV-FAILED
; No explicit value for SG-LOGITEM-D3D11-MAP-FOR-UPDATE-BUFFER-FAILED
; No explicit value for SG-LOGITEM-D3D11-MAP-FOR-APPEND-BUFFER-FAILED
; No explicit value for SG-LOGITEM-D3D11-MAP-FOR-UPDATE-IMAGE-FAILED
; No explicit value for SG-LOGITEM-METAL-CREATE-BUFFER-FAILED
; No explicit value for SG-LOGITEM-METAL-TEXTURE-FORMAT-NOT-SUPPORTED
; No explicit value for SG-LOGITEM-METAL-CREATE-TEXTURE-FAILED
; No explicit value for SG-LOGITEM-METAL-CREATE-SAMPLER-FAILED
; No explicit value for SG-LOGITEM-METAL-SHADER-COMPILATION-FAILED
; No explicit value for SG-LOGITEM-METAL-SHADER-CREATION-FAILED
; No explicit value for SG-LOGITEM-METAL-SHADER-COMPILATION-OUTPUT
; No explicit value for SG-LOGITEM-METAL-SHADER-ENTRY-NOT-FOUND
; No explicit value for SG-LOGITEM-METAL-UNIFORMBLOCK-MSL-BUFFER-SLOT-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-METAL-STORAGEBUFFER-MSL-BUFFER-SLOT-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-METAL-IMAGE-MSL-TEXTURE-SLOT-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-METAL-SAMPLER-MSL-SAMPLER-SLOT-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-METAL-CREATE-CPS-FAILED
; No explicit value for SG-LOGITEM-METAL-CREATE-CPS-OUTPUT
; No explicit value for SG-LOGITEM-METAL-CREATE-RPS-FAILED
; No explicit value for SG-LOGITEM-METAL-CREATE-RPS-OUTPUT
; No explicit value for SG-LOGITEM-METAL-CREATE-DSS-FAILED
; No explicit value for SG-LOGITEM-WGPU-BINDGROUPS-POOL-EXHAUSTED
; No explicit value for SG-LOGITEM-WGPU-BINDGROUPSCACHE-SIZE-GREATER-ONE
; No explicit value for SG-LOGITEM-WGPU-BINDGROUPSCACHE-SIZE-POW2
; No explicit value for SG-LOGITEM-WGPU-CREATEBINDGROUP-FAILED
; No explicit value for SG-LOGITEM-WGPU-CREATE-BUFFER-FAILED
; No explicit value for SG-LOGITEM-WGPU-CREATE-TEXTURE-FAILED
; No explicit value for SG-LOGITEM-WGPU-CREATE-TEXTURE-VIEW-FAILED
; No explicit value for SG-LOGITEM-WGPU-CREATE-SAMPLER-FAILED
; No explicit value for SG-LOGITEM-WGPU-CREATE-SHADER-MODULE-FAILED
; No explicit value for SG-LOGITEM-WGPU-SHADER-CREATE-BINDGROUP-LAYOUT-FAILED
; No explicit value for SG-LOGITEM-WGPU-UNIFORMBLOCK-WGSL-GROUP0-BINDING-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-WGPU-STORAGEBUFFER-WGSL-GROUP1-BINDING-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-WGPU-IMAGE-WGSL-GROUP1-BINDING-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-WGPU-SAMPLER-WGSL-GROUP1-BINDING-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-WGPU-CREATE-PIPELINE-LAYOUT-FAILED
; No explicit value for SG-LOGITEM-WGPU-CREATE-RENDER-PIPELINE-FAILED
; No explicit value for SG-LOGITEM-WGPU-CREATE-COMPUTE-PIPELINE-FAILED
; No explicit value for SG-LOGITEM-WGPU-ATTACHMENTS-CREATE-TEXTURE-VIEW-FAILED
; No explicit value for SG-LOGITEM-IDENTICAL-COMMIT-LISTENER
; No explicit value for SG-LOGITEM-COMMIT-LISTENER-ARRAY-FULL
; No explicit value for SG-LOGITEM-TRACE-HOOKS-NOT-ENABLED
; No explicit value for SG-LOGITEM-DEALLOC-BUFFER-INVALID-STATE
; No explicit value for SG-LOGITEM-DEALLOC-IMAGE-INVALID-STATE
; No explicit value for SG-LOGITEM-DEALLOC-SAMPLER-INVALID-STATE
; No explicit value for SG-LOGITEM-DEALLOC-SHADER-INVALID-STATE
; No explicit value for SG-LOGITEM-DEALLOC-PIPELINE-INVALID-STATE
; No explicit value for SG-LOGITEM-DEALLOC-ATTACHMENTS-INVALID-STATE
; No explicit value for SG-LOGITEM-INIT-BUFFER-INVALID-STATE
; No explicit value for SG-LOGITEM-INIT-IMAGE-INVALID-STATE
; No explicit value for SG-LOGITEM-INIT-SAMPLER-INVALID-STATE
; No explicit value for SG-LOGITEM-INIT-SHADER-INVALID-STATE
; No explicit value for SG-LOGITEM-INIT-PIPELINE-INVALID-STATE
; No explicit value for SG-LOGITEM-INIT-ATTACHMENTS-INVALID-STATE
; No explicit value for SG-LOGITEM-UNINIT-BUFFER-INVALID-STATE
; No explicit value for SG-LOGITEM-UNINIT-IMAGE-INVALID-STATE
; No explicit value for SG-LOGITEM-UNINIT-SAMPLER-INVALID-STATE
; No explicit value for SG-LOGITEM-UNINIT-SHADER-INVALID-STATE
; No explicit value for SG-LOGITEM-UNINIT-PIPELINE-INVALID-STATE
; No explicit value for SG-LOGITEM-UNINIT-ATTACHMENTS-INVALID-STATE
; No explicit value for SG-LOGITEM-FAIL-BUFFER-INVALID-STATE
; No explicit value for SG-LOGITEM-FAIL-IMAGE-INVALID-STATE
; No explicit value for SG-LOGITEM-FAIL-SAMPLER-INVALID-STATE
; No explicit value for SG-LOGITEM-FAIL-SHADER-INVALID-STATE
; No explicit value for SG-LOGITEM-FAIL-PIPELINE-INVALID-STATE
; No explicit value for SG-LOGITEM-FAIL-ATTACHMENTS-INVALID-STATE
; No explicit value for SG-LOGITEM-BUFFER-POOL-EXHAUSTED
; No explicit value for SG-LOGITEM-IMAGE-POOL-EXHAUSTED
; No explicit value for SG-LOGITEM-SAMPLER-POOL-EXHAUSTED
; No explicit value for SG-LOGITEM-SHADER-POOL-EXHAUSTED
; No explicit value for SG-LOGITEM-PIPELINE-POOL-EXHAUSTED
; No explicit value for SG-LOGITEM-PASS-POOL-EXHAUSTED
; No explicit value for SG-LOGITEM-BEGINPASS-ATTACHMENT-INVALID
; No explicit value for SG-LOGITEM-APPLY-BINDINGS-STORAGE-BUFFER-TRACKER-EXHAUSTED
; No explicit value for SG-LOGITEM-DRAW-WITHOUT-BINDINGS
; No explicit value for SG-LOGITEM-VALIDATE-BUFFERDESC-CANARY
; No explicit value for SG-LOGITEM-VALIDATE-BUFFERDESC-EXPECT-NONZERO-SIZE
; No explicit value for SG-LOGITEM-VALIDATE-BUFFERDESC-EXPECT-MATCHING-DATA-SIZE
; No explicit value for SG-LOGITEM-VALIDATE-BUFFERDESC-EXPECT-ZERO-DATA-SIZE
; No explicit value for SG-LOGITEM-VALIDATE-BUFFERDESC-EXPECT-NO-DATA
; No explicit value for SG-LOGITEM-VALIDATE-BUFFERDESC-STORAGEBUFFER-SUPPORTED
; No explicit value for SG-LOGITEM-VALIDATE-BUFFERDESC-STORAGEBUFFER-SIZE-MULTIPLE-4
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDATA-NODATA
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDATA-DATA-SIZE
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDESC-CANARY
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDESC-WIDTH
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDESC-HEIGHT
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDESC-RT-PIXELFORMAT
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDESC-NONRT-PIXELFORMAT
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDESC-MSAA-BUT-NO-RT
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDESC-NO-MSAA-RT-SUPPORT
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDESC-MSAA-NUM-MIPMAPS
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDESC-MSAA-3D-IMAGE
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDESC-MSAA-CUBE-IMAGE
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDESC-DEPTH-3D-IMAGE
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDESC-RT-IMMUTABLE
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDESC-RT-NO-DATA
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDESC-INJECTED-NO-DATA
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDESC-DYNAMIC-NO-DATA
; No explicit value for SG-LOGITEM-VALIDATE-IMAGEDESC-COMPRESSED-IMMUTABLE
; No explicit value for SG-LOGITEM-VALIDATE-SAMPLERDESC-CANARY
; No explicit value for SG-LOGITEM-VALIDATE-SAMPLERDESC-ANISTROPIC-REQUIRES-LINEAR-FILTERING
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-CANARY
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-VERTEX-SOURCE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-FRAGMENT-SOURCE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-COMPUTE-SOURCE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-VERTEX-SOURCE-OR-BYTECODE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-FRAGMENT-SOURCE-OR-BYTECODE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-COMPUTE-SOURCE-OR-BYTECODE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-INVALID-SHADER-COMBO
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-NO-BYTECODE-SIZE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-METAL-THREADS-PER-THREADGROUP
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-UNIFORMBLOCK-NO-CONT-MEMBERS
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-UNIFORMBLOCK-SIZE-IS-ZERO
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-UNIFORMBLOCK-METAL-BUFFER-SLOT-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-UNIFORMBLOCK-METAL-BUFFER-SLOT-COLLISION
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-UNIFORMBLOCK-HLSL-REGISTER-B-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-UNIFORMBLOCK-HLSL-REGISTER-B-COLLISION
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-UNIFORMBLOCK-WGSL-GROUP0-BINDING-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-UNIFORMBLOCK-WGSL-GROUP0-BINDING-COLLISION
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-UNIFORMBLOCK-NO-MEMBERS
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-UNIFORMBLOCK-UNIFORM-GLSL-NAME
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-UNIFORMBLOCK-SIZE-MISMATCH
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-UNIFORMBLOCK-ARRAY-COUNT
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-UNIFORMBLOCK-STD140-ARRAY-TYPE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-STORAGEBUFFER-METAL-BUFFER-SLOT-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-STORAGEBUFFER-METAL-BUFFER-SLOT-COLLISION
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-STORAGEBUFFER-HLSL-REGISTER-T-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-STORAGEBUFFER-HLSL-REGISTER-T-COLLISION
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-STORAGEBUFFER-HLSL-REGISTER-U-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-STORAGEBUFFER-HLSL-REGISTER-U-COLLISION
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-STORAGEBUFFER-GLSL-BINDING-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-STORAGEBUFFER-GLSL-BINDING-COLLISION
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-STORAGEBUFFER-WGSL-GROUP1-BINDING-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-STORAGEBUFFER-WGSL-GROUP1-BINDING-COLLISION
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-IMAGE-METAL-TEXTURE-SLOT-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-IMAGE-METAL-TEXTURE-SLOT-COLLISION
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-IMAGE-HLSL-REGISTER-T-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-IMAGE-HLSL-REGISTER-T-COLLISION
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-IMAGE-WGSL-GROUP1-BINDING-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-IMAGE-WGSL-GROUP1-BINDING-COLLISION
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-SAMPLER-METAL-SAMPLER-SLOT-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-SAMPLER-METAL-SAMPLER-SLOT-COLLISION
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-SAMPLER-HLSL-REGISTER-S-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-SAMPLER-HLSL-REGISTER-S-COLLISION
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-SAMPLER-WGSL-GROUP1-BINDING-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-SAMPLER-WGSL-GROUP1-BINDING-COLLISION
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-IMAGE-SAMPLER-PAIR-IMAGE-SLOT-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-IMAGE-SAMPLER-PAIR-SAMPLER-SLOT-OUT-OF-RANGE
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-IMAGE-SAMPLER-PAIR-IMAGE-STAGE-MISMATCH
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-IMAGE-SAMPLER-PAIR-SAMPLER-STAGE-MISMATCH
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-IMAGE-SAMPLER-PAIR-GLSL-NAME
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-NONFILTERING-SAMPLER-REQUIRED
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-COMPARISON-SAMPLER-REQUIRED
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-IMAGE-NOT-REFERENCED-BY-IMAGE-SAMPLER-PAIRS
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-SAMPLER-NOT-REFERENCED-BY-IMAGE-SAMPLER-PAIRS
; No explicit value for SG-LOGITEM-VALIDATE-SHADERDESC-ATTR-STRING-TOO-LONG
; No explicit value for SG-LOGITEM-VALIDATE-PIPELINEDESC-CANARY
; No explicit value for SG-LOGITEM-VALIDATE-PIPELINEDESC-SHADER
; No explicit value for SG-LOGITEM-VALIDATE-PIPELINEDESC-COMPUTE-SHADER-EXPECTED
; No explicit value for SG-LOGITEM-VALIDATE-PIPELINEDESC-NO-COMPUTE-SHADER-EXPECTED
; No explicit value for SG-LOGITEM-VALIDATE-PIPELINEDESC-NO-CONT-ATTRS
; No explicit value for SG-LOGITEM-VALIDATE-PIPELINEDESC-ATTR-BASETYPE-MISMATCH
; No explicit value for SG-LOGITEM-VALIDATE-PIPELINEDESC-LAYOUT-STRIDE4
; No explicit value for SG-LOGITEM-VALIDATE-PIPELINEDESC-ATTR-SEMANTICS
; No explicit value for SG-LOGITEM-VALIDATE-PIPELINEDESC-SHADER-READONLY-STORAGEBUFFERS
; No explicit value for SG-LOGITEM-VALIDATE-PIPELINEDESC-BLENDOP-MINMAX-REQUIRES-BLENDFACTOR-ONE
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-CANARY
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-NO-ATTACHMENTS
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-NO-CONT-COLOR-ATTS
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-IMAGE
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-MIPLEVEL
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-FACE
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-LAYER
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-SLICE
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-IMAGE-NO-RT
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-COLOR-INV-PIXELFORMAT
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-DEPTH-INV-PIXELFORMAT
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-IMAGE-SIZES
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-IMAGE-SAMPLE-COUNTS
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-RESOLVE-COLOR-IMAGE-MSAA
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-RESOLVE-IMAGE
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-RESOLVE-SAMPLE-COUNT
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-RESOLVE-MIPLEVEL
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-RESOLVE-FACE
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-RESOLVE-LAYER
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-RESOLVE-SLICE
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-RESOLVE-IMAGE-NO-RT
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-RESOLVE-IMAGE-SIZES
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-RESOLVE-IMAGE-FORMAT
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-DEPTH-IMAGE
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-DEPTH-MIPLEVEL
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-DEPTH-FACE
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-DEPTH-LAYER
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-DEPTH-SLICE
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-DEPTH-IMAGE-NO-RT
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-DEPTH-IMAGE-SIZES
; No explicit value for SG-LOGITEM-VALIDATE-ATTACHMENTSDESC-DEPTH-IMAGE-SAMPLE-COUNT
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-CANARY
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-EXPECT-NO-ATTACHMENTS
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-ATTACHMENTS-EXISTS
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-ATTACHMENTS-VALID
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-COLOR-ATTACHMENT-IMAGE
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-RESOLVE-ATTACHMENT-IMAGE
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-DEPTHSTENCIL-ATTACHMENT-IMAGE
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-EXPECT-WIDTH
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-EXPECT-WIDTH-NOTSET
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-EXPECT-HEIGHT
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-EXPECT-HEIGHT-NOTSET
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-EXPECT-SAMPLECOUNT
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-EXPECT-SAMPLECOUNT-NOTSET
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-EXPECT-COLORFORMAT
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-EXPECT-COLORFORMAT-NOTSET
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-EXPECT-DEPTHFORMAT-NOTSET
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-METAL-EXPECT-CURRENTDRAWABLE
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-METAL-EXPECT-CURRENTDRAWABLE-NOTSET
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-METAL-EXPECT-DEPTHSTENCILTEXTURE
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-METAL-EXPECT-DEPTHSTENCILTEXTURE-NOTSET
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-METAL-EXPECT-MSAACOLORTEXTURE
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-METAL-EXPECT-MSAACOLORTEXTURE-NOTSET
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-D3D11-EXPECT-RENDERVIEW
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-D3D11-EXPECT-RENDERVIEW-NOTSET
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-D3D11-EXPECT-RESOLVEVIEW
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-D3D11-EXPECT-RESOLVEVIEW-NOTSET
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-D3D11-EXPECT-DEPTHSTENCILVIEW
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-D3D11-EXPECT-DEPTHSTENCILVIEW-NOTSET
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-WGPU-EXPECT-RENDERVIEW
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-WGPU-EXPECT-RENDERVIEW-NOTSET
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-WGPU-EXPECT-RESOLVEVIEW
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-WGPU-EXPECT-RESOLVEVIEW-NOTSET
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-WGPU-EXPECT-DEPTHSTENCILVIEW
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-WGPU-EXPECT-DEPTHSTENCILVIEW-NOTSET
; No explicit value for SG-LOGITEM-VALIDATE-BEGINPASS-SWAPCHAIN-GL-EXPECT-FRAMEBUFFER-NOTSET
; No explicit value for SG-LOGITEM-VALIDATE-AVP-RENDERPASS-EXPECTED
; No explicit value for SG-LOGITEM-VALIDATE-ASR-RENDERPASS-EXPECTED
; No explicit value for SG-LOGITEM-VALIDATE-APIP-PIPELINE-VALID-ID
; No explicit value for SG-LOGITEM-VALIDATE-APIP-PIPELINE-EXISTS
; No explicit value for SG-LOGITEM-VALIDATE-APIP-PIPELINE-VALID
; No explicit value for SG-LOGITEM-VALIDATE-APIP-PASS-EXPECTED
; No explicit value for SG-LOGITEM-VALIDATE-APIP-SHADER-EXISTS
; No explicit value for SG-LOGITEM-VALIDATE-APIP-SHADER-VALID
; No explicit value for SG-LOGITEM-VALIDATE-APIP-COMPUTEPASS-EXPECTED
; No explicit value for SG-LOGITEM-VALIDATE-APIP-RENDERPASS-EXPECTED
; No explicit value for SG-LOGITEM-VALIDATE-APIP-CURPASS-ATTACHMENTS-EXISTS
; No explicit value for SG-LOGITEM-VALIDATE-APIP-CURPASS-ATTACHMENTS-VALID
; No explicit value for SG-LOGITEM-VALIDATE-APIP-ATT-COUNT
; No explicit value for SG-LOGITEM-VALIDATE-APIP-COLOR-FORMAT
; No explicit value for SG-LOGITEM-VALIDATE-APIP-DEPTH-FORMAT
; No explicit value for SG-LOGITEM-VALIDATE-APIP-SAMPLE-COUNT
; No explicit value for SG-LOGITEM-VALIDATE-ABND-PASS-EXPECTED
; No explicit value for SG-LOGITEM-VALIDATE-ABND-EMPTY-BINDINGS
; No explicit value for SG-LOGITEM-VALIDATE-ABND-PIPELINE
; No explicit value for SG-LOGITEM-VALIDATE-ABND-PIPELINE-EXISTS
; No explicit value for SG-LOGITEM-VALIDATE-ABND-PIPELINE-VALID
; No explicit value for SG-LOGITEM-VALIDATE-ABND-COMPUTE-EXPECTED-NO-VBS
; No explicit value for SG-LOGITEM-VALIDATE-ABND-COMPUTE-EXPECTED-NO-IB
; No explicit value for SG-LOGITEM-VALIDATE-ABND-EXPECTED-VB
; No explicit value for SG-LOGITEM-VALIDATE-ABND-VB-EXISTS
; No explicit value for SG-LOGITEM-VALIDATE-ABND-VB-TYPE
; No explicit value for SG-LOGITEM-VALIDATE-ABND-VB-OVERFLOW
; No explicit value for SG-LOGITEM-VALIDATE-ABND-NO-IB
; No explicit value for SG-LOGITEM-VALIDATE-ABND-IB
; No explicit value for SG-LOGITEM-VALIDATE-ABND-IB-EXISTS
; No explicit value for SG-LOGITEM-VALIDATE-ABND-IB-TYPE
; No explicit value for SG-LOGITEM-VALIDATE-ABND-IB-OVERFLOW
; No explicit value for SG-LOGITEM-VALIDATE-ABND-EXPECTED-IMAGE-BINDING
; No explicit value for SG-LOGITEM-VALIDATE-ABND-IMG-EXISTS
; No explicit value for SG-LOGITEM-VALIDATE-ABND-IMAGE-TYPE-MISMATCH
; No explicit value for SG-LOGITEM-VALIDATE-ABND-EXPECTED-MULTISAMPLED-IMAGE
; No explicit value for SG-LOGITEM-VALIDATE-ABND-IMAGE-MSAA
; No explicit value for SG-LOGITEM-VALIDATE-ABND-EXPECTED-FILTERABLE-IMAGE
; No explicit value for SG-LOGITEM-VALIDATE-ABND-EXPECTED-DEPTH-IMAGE
; No explicit value for SG-LOGITEM-VALIDATE-ABND-EXPECTED-SAMPLER-BINDING
; No explicit value for SG-LOGITEM-VALIDATE-ABND-UNEXPECTED-SAMPLER-COMPARE-NEVER
; No explicit value for SG-LOGITEM-VALIDATE-ABND-EXPECTED-SAMPLER-COMPARE-NEVER
; No explicit value for SG-LOGITEM-VALIDATE-ABND-EXPECTED-NONFILTERING-SAMPLER
; No explicit value for SG-LOGITEM-VALIDATE-ABND-SMP-EXISTS
; No explicit value for SG-LOGITEM-VALIDATE-ABND-EXPECTED-STORAGEBUFFER-BINDING
; No explicit value for SG-LOGITEM-VALIDATE-ABND-STORAGEBUFFER-EXISTS
; No explicit value for SG-LOGITEM-VALIDATE-ABND-STORAGEBUFFER-BINDING-BUFFERTYPE
; No explicit value for SG-LOGITEM-VALIDATE-ABND-STORAGEBUFFER-READWRITE-IMMUTABLE
; No explicit value for SG-LOGITEM-VALIDATE-AU-PASS-EXPECTED
; No explicit value for SG-LOGITEM-VALIDATE-AU-NO-PIPELINE
; No explicit value for SG-LOGITEM-VALIDATE-AU-NO-UNIFORMBLOCK-AT-SLOT
; No explicit value for SG-LOGITEM-VALIDATE-AU-SIZE
; No explicit value for SG-LOGITEM-VALIDATE-DRAW-RENDERPASS-EXPECTED
; No explicit value for SG-LOGITEM-VALIDATE-DRAW-BASEELEMENT
; No explicit value for SG-LOGITEM-VALIDATE-DRAW-NUMELEMENTS
; No explicit value for SG-LOGITEM-VALIDATE-DRAW-NUMINSTANCES
; No explicit value for SG-LOGITEM-VALIDATE-DRAW-REQUIRED-BINDINGS-OR-UNIFORMS-MISSING
; No explicit value for SG-LOGITEM-VALIDATE-DISPATCH-COMPUTEPASS-EXPECTED
; No explicit value for SG-LOGITEM-VALIDATE-DISPATCH-NUMGROUPSX
; No explicit value for SG-LOGITEM-VALIDATE-DISPATCH-NUMGROUPSY
; No explicit value for SG-LOGITEM-VALIDATE-DISPATCH-NUMGROUPSZ
; No explicit value for SG-LOGITEM-VALIDATE-DISPATCH-REQUIRED-BINDINGS-OR-UNIFORMS-MISSING
; No explicit value for SG-LOGITEM-VALIDATE-UPDATEBUF-USAGE
; No explicit value for SG-LOGITEM-VALIDATE-UPDATEBUF-SIZE
; No explicit value for SG-LOGITEM-VALIDATE-UPDATEBUF-ONCE
; No explicit value for SG-LOGITEM-VALIDATE-UPDATEBUF-APPEND
; No explicit value for SG-LOGITEM-VALIDATE-APPENDBUF-USAGE
; No explicit value for SG-LOGITEM-VALIDATE-APPENDBUF-SIZE
; No explicit value for SG-LOGITEM-VALIDATE-APPENDBUF-UPDATE
; No explicit value for SG-LOGITEM-VALIDATE-UPDIMG-USAGE
; No explicit value for SG-LOGITEM-VALIDATE-UPDIMG-ONCE
; No explicit value for SG-LOGITEM-VALIDATION-FAILED
#|     sg_desc

    The sg_desc struct contains configuration values for sokol_gfx,
    it is used as parameter to the sg_setup() call.

    The default configuration is:

    .buffer_pool_size               128
    .image_pool_size                128
    .sampler_pool_size              64
    .shader_pool_size               32
    .pipeline_pool_size             64
    .attachments_pool_size          16
    .uniform_buffer_size            4 MB (4*1024*1024)
    .max_dispatch_calls_per_pass    1024
    .max_commit_listeners           1024
    .disable_validation             false
    .mtl_force_managed_storage_mode false
    .wgpu_disable_bindgroups_cache  false
    .wgpu_bindgroups_cache_size     1024

    .allocator.alloc_fn     0 (in this case, malloc() will be called)
    .allocator.free_fn      0 (in this case, free() will be called)
    .allocator.user_data    0

    .environment.defaults.color_format: default value depends on selected backend:
        all GL backends:    SG_PIXELFORMAT_RGBA8
        Metal and D3D11:    SG_PIXELFORMAT_BGRA8
        WebGPU:             *no default* (must be queried from WebGPU swapchain object)
    .environment.defaults.depth_format: SG_PIXELFORMAT_DEPTH_STENCIL
    .environment.defaults.sample_count: 1

    Metal specific:
        (NOTE: All Objective-C object references are transferred through
        a bridged cast (__bridge const void*) to sokol_gfx, which will use an
        unretained bridged cast (__bridge id<xxx>) to retrieve the Objective-C
        references back. Since the bridge cast is unretained, the caller
        must hold a strong reference to the Objective-C object until sg_setup()
        returns.

        .mtl_force_managed_storage_mode
            when enabled, Metal buffers and texture resources are created in managed storage
            mode, otherwise sokol-gfx will decide whether to create buffers and
            textures in managed or shared storage mode (this is mainly a debugging option)
        .mtl_use_command_buffer_with_retained_references
            when true, the sokol-gfx Metal backend will use Metal command buffers which
            bump the reference count of resource objects as long as they are inflight,
            this is slower than the default command-buffer-with-unretained-references
            method, this may be a workaround when confronted with lifetime validation
            errors from the Metal validation layer until a proper fix has been implemented
        .environment.metal.device
            a pointer to the MTLDevice object

    D3D11 specific:
        .environment.d3d11.device
            a pointer to the ID3D11Device object, this must have been created
            before sg_setup() is called
        .environment.d3d11.device_context
            a pointer to the ID3D11DeviceContext object
        .d3d11_shader_debugging
            set this to true to compile shaders which are provided as HLSL source
            code with debug information and without optimization, this allows
            shader debugging in tools like RenderDoc, to output source code
            instead of byte code from sokol-shdc, omit the `--binary` cmdline
            option

    WebGPU specific:
        .wgpu_disable_bindgroups_cache
            When this is true, the WebGPU backend will create and immediately
            release a BindGroup object in the sg_apply_bindings() call, only
            use this for debugging purposes.
        .wgpu_bindgroups_cache_size
            The size of the bindgroups cache for re-using BindGroup objects
            between sg_apply_bindings() calls. The smaller the cache size,
            the more likely are cache slot collisions which will cause
            a BindGroups object to be destroyed and a new one created.
            Use the information returned by sg_query_stats() to check
            if this is a frequent occurrence, and increase the cache size as
            needed (the default is 1024).
            NOTE: wgpu_bindgroups_cache_size must be a power-of-2 number!
        .environment.wgpu.device
            a WGPUDevice handle

    When using sokol_gfx.h and sokol_app.h together, consider using the
    helper function sglue_environment() in the sokol_glue.h header to
    initialize the sg_desc.environment nested struct. sglue_environment() returns
    a completely initialized sg_environment struct with information
    provided by sokol_app.h. |#
(define _environment-defaults
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['color_format _int]
   ['depth_format _int]
   ['sample_count _int]
  ))

(define _metal-environment
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['device _pointer]
  ))

(define _d3d11-environment
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['device _pointer]
   ['device_context _pointer]
  ))

(define _wgpu-environment
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['device _pointer]
  ))

(define _environment
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['defaults _environment_defaults]
   ['metal _metal_environment]
   ['d3d11 _d3d11_environment]
   ['wgpu _wgpu_environment]
  ))

#|     sg_commit_listener

    Used with function sg_add_commit_listener() to add a callback
    which will be called in sg_commit(). This is useful for libraries
    building on top of sokol-gfx to be notified about when a frame
    ends (instead of having to guess, or add a manual 'new-frame'
    function. |#
(define _commit-listener
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['func _fpointer]
   ['user_data _pointer]
  ))

#|     sg_allocator

    Used in sg_desc to provide custom memory-alloc and -free functions
    to sokol_gfx.h. If memory management should be overridden, both the
    alloc_fn and free_fn function must be provided (e.g. it's not valid to
    override one function but not the other). |#
(define _allocator
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['alloc_fn _fpointer]
   ['free_fn _fpointer]
   ['user_data _pointer]
  ))

#|     sg_logger

    Used in sg_desc to provide a logging function. Please be aware
    that without logging function, sokol-gfx will be completely
    silent, e.g. it will not report errors, warnings and
    validation layer messages. For maximum error verbosity,
    compile in debug mode (e.g. NDEBUG *not* defined) and provide a
    compatible logger function in the sg_setup() call
    (for instance the standard logging function from sokol_log.h). |#
(define _logger
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['func _fpointer]
   ['user_data _pointer]
  ))

(define _desc
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['_start_canary _uint32]
   ['buffer_pool_size _int]
   ['image_pool_size _int]
   ['sampler_pool_size _int]
   ['shader_pool_size _int]
   ['pipeline_pool_size _int]
   ['attachments_pool_size _int]
   ['uniform_buffer_size _int]
   ['max_dispatch_calls_per_pass _int]
   ['max_commit_listeners _int]
   ['disable_validation _bool]
   ['d3d11_shader_debugging _bool]
   ['mtl_force_managed_storage_mode _bool]
   ['mtl_use_command_buffer_with_retained_references _bool]
   ['wgpu_disable_bindgroups_cache _bool]
   ['wgpu_bindgroups_cache_size _int]
   ['allocator _allocator]
   ['logger _logger]
   ['environment _environment]
   ['_end_canary _uint32]
  ))

#|  setup and misc functions |#
(define-sokol setup
  (_fun _unknown_const sg_desc * -> _void))

(define-sokol shutdown
  (_fun  -> _void))

(define-sokol isvalid
  (_fun  -> _bool))

(define-sokol reset-state-cache
  (_fun  -> _void))

(define-sokol install-trace-hooks
  (_fun _unknown_const sg_trace_hooks * -> _trace_hooks))

(define-sokol push-debug-group
  (_fun _string/utf-8 -> _void))

(define-sokol pop-debug-group
  (_fun  -> _void))

(define-sokol add-commit-listener
  (_fun _commit_listener -> _bool))

(define-sokol remove-commit-listener
  (_fun _commit_listener -> _bool))

#|  resource creation, destruction and updating |#
(define-sokol make-buffer
  (_fun _unknown_const sg_buffer_desc * -> _buffer))

(define-sokol make-image
  (_fun _unknown_const sg_image_desc * -> _image))

(define-sokol make-sampler
  (_fun _unknown_const sg_sampler_desc * -> _sampler))

(define-sokol make-shader
  (_fun _unknown_const sg_shader_desc * -> _shader))

(define-sokol make-pipeline
  (_fun _unknown_const sg_pipeline_desc * -> _pipeline))

(define-sokol make-attachments
  (_fun _unknown_const sg_attachments_desc * -> _attachments))

(define-sokol destroy-buffer
  (_fun _buffer -> _void))

(define-sokol destroy-image
  (_fun _image -> _void))

(define-sokol destroy-sampler
  (_fun _sampler -> _void))

(define-sokol destroy-shader
  (_fun _shader -> _void))

(define-sokol destroy-pipeline
  (_fun _pipeline -> _void))

(define-sokol destroy-attachments
  (_fun _attachments -> _void))

(define-sokol update-buffer
  (_fun _buffer _unknown_const sg_range * -> _void))

(define-sokol update-image
  (_fun _image _unknown_const sg_image_data * -> _void))

(define-sokol append-buffer
  (_fun _buffer _unknown_const sg_range * -> _int))

(define-sokol query-buffer-overflow
  (_fun _buffer -> _bool))

(define-sokol query-buffer-will-overflow
  (_fun _buffer _size -> _bool))

#|  render and compute functions |#
(define-sokol begin-pass
  (_fun _unknown_const sg_pass * -> _void))

(define-sokol apply-viewport
  (_fun _int _int _int _int _bool -> _void))

(define-sokol apply-viewportf
  (_fun _float _float _float _float _bool -> _void))

(define-sokol apply-scissor-rect
  (_fun _int _int _int _int _bool -> _void))

(define-sokol apply-scissor-rectf
  (_fun _float _float _float _float _bool -> _void))

(define-sokol apply-pipeline
  (_fun _pipeline -> _void))

(define-sokol apply-bindings
  (_fun _unknown_const sg_bindings * -> _void))

(define-sokol apply-uniforms
  (_fun _int _unknown_const sg_range * -> _void))

(define-sokol draw
  (_fun _int _int _int -> _void))

(define-sokol dispatch
  (_fun _int _int _int -> _void))

(define-sokol end-pass
  (_fun  -> _void))

(define-sokol commit
  (_fun  -> _void))

#|  getting information |#
(define-sokol query-desc
  (_fun  -> _desc))

(define-sokol query-backend
  (_fun  -> _int))

(define-sokol query-features
  (_fun  -> _features))

(define-sokol query-limits
  (_fun  -> _limits))

(define-sokol query-pixelformat
  (_fun _int -> _pixelformat_info))

(define-sokol query-row-pitch
  (_fun _int _int _int -> _int))

(define-sokol query-surface-pitch
  (_fun _int _int _int _int -> _int))

#|  get current state of a resource (INITIAL, ALLOC, VALID, FAILED, INVALID) |#
(define-sokol query-buffer-state
  (_fun _buffer -> _int))

(define-sokol query-image-state
  (_fun _image -> _int))

(define-sokol query-sampler-state
  (_fun _sampler -> _int))

(define-sokol query-shader-state
  (_fun _shader -> _int))

(define-sokol query-pipeline-state
  (_fun _pipeline -> _int))

(define-sokol query-attachments-state
  (_fun _attachments -> _int))

#|  get runtime information about a resource |#
(define-sokol query-buffer-info
  (_fun _buffer -> _buffer_info))

(define-sokol query-image-info
  (_fun _image -> _image_info))

(define-sokol query-sampler-info
  (_fun _sampler -> _sampler_info))

(define-sokol query-shader-info
  (_fun _shader -> _shader_info))

(define-sokol query-pipeline-info
  (_fun _pipeline -> _pipeline_info))

(define-sokol query-attachments-info
  (_fun _attachments -> _attachments_info))

#|  get desc structs matching a specific resource (NOTE that not all creation attributes may be provided) |#
(define-sokol query-buffer-desc
  (_fun _buffer -> _buffer_desc))

(define-sokol query-image-desc
  (_fun _image -> _image_desc))

(define-sokol query-sampler-desc
  (_fun _sampler -> _sampler_desc))

(define-sokol query-shader-desc
  (_fun _shader -> _shader_desc))

(define-sokol query-pipeline-desc
  (_fun _pipeline -> _pipeline_desc))

(define-sokol query-attachments-desc
  (_fun _attachments -> _attachments_desc))

#|  get resource creation desc struct with their default values replaced |#
(define-sokol query-buffer-defaults
  (_fun _unknown_const sg_buffer_desc * -> _buffer_desc))

(define-sokol query-image-defaults
  (_fun _unknown_const sg_image_desc * -> _image_desc))

(define-sokol query-sampler-defaults
  (_fun _unknown_const sg_sampler_desc * -> _sampler_desc))

(define-sokol query-shader-defaults
  (_fun _unknown_const sg_shader_desc * -> _shader_desc))

(define-sokol query-pipeline-defaults
  (_fun _unknown_const sg_pipeline_desc * -> _pipeline_desc))

(define-sokol query-attachments-defaults
  (_fun _unknown_const sg_attachments_desc * -> _attachments_desc))

#|  assorted query functions |#
(define-sokol query-buffer-size
  (_fun _buffer -> _size))

(define-sokol query-buffer-type
  (_fun _buffer -> _int))

(define-sokol query-buffer-usage
  (_fun _buffer -> _int))

(define-sokol query-image-type
  (_fun _image -> _int))

(define-sokol query-image-width
  (_fun _image -> _int))

(define-sokol query-image-height
  (_fun _image -> _int))

(define-sokol query-image-num-slices
  (_fun _image -> _int))

(define-sokol query-image-num-mipmaps
  (_fun _image -> _int))

(define-sokol query-image-pixelformat
  (_fun _image -> _int))

(define-sokol query-image-usage
  (_fun _image -> _int))

(define-sokol query-image-sample-count
  (_fun _image -> _int))

#|  separate resource allocation and initialization (for async setup) |#
(define-sokol alloc-buffer
  (_fun  -> _buffer))

(define-sokol alloc-image
  (_fun  -> _image))

(define-sokol alloc-sampler
  (_fun  -> _sampler))

(define-sokol alloc-shader
  (_fun  -> _shader))

(define-sokol alloc-pipeline
  (_fun  -> _pipeline))

(define-sokol alloc-attachments
  (_fun  -> _attachments))

(define-sokol dealloc-buffer
  (_fun _buffer -> _void))

(define-sokol dealloc-image
  (_fun _image -> _void))

(define-sokol dealloc-sampler
  (_fun _sampler -> _void))

(define-sokol dealloc-shader
  (_fun _shader -> _void))

(define-sokol dealloc-pipeline
  (_fun _pipeline -> _void))

(define-sokol dealloc-attachments
  (_fun _attachments -> _void))

(define-sokol init-buffer
  (_fun _buffer _unknown_const sg_buffer_desc * -> _void))

(define-sokol init-image
  (_fun _image _unknown_const sg_image_desc * -> _void))

(define-sokol init-sampler
  (_fun _sampler _unknown_const sg_sampler_desc * -> _void))

(define-sokol init-shader
  (_fun _shader _unknown_const sg_shader_desc * -> _void))

(define-sokol init-pipeline
  (_fun _pipeline _unknown_const sg_pipeline_desc * -> _void))

(define-sokol init-attachments
  (_fun _attachments _unknown_const sg_attachments_desc * -> _void))

(define-sokol uninit-buffer
  (_fun _buffer -> _void))

(define-sokol uninit-image
  (_fun _image -> _void))

(define-sokol uninit-sampler
  (_fun _sampler -> _void))

(define-sokol uninit-shader
  (_fun _shader -> _void))

(define-sokol uninit-pipeline
  (_fun _pipeline -> _void))

(define-sokol uninit-attachments
  (_fun _attachments -> _void))

(define-sokol fail-buffer
  (_fun _buffer -> _void))

(define-sokol fail-image
  (_fun _image -> _void))

(define-sokol fail-sampler
  (_fun _sampler -> _void))

(define-sokol fail-shader
  (_fun _shader -> _void))

(define-sokol fail-pipeline
  (_fun _pipeline -> _void))

(define-sokol fail-attachments
  (_fun _attachments -> _void))

#|  frame stats |#
(define-sokol enable-frame-stats
  (_fun  -> _void))

(define-sokol disable-frame-stats
  (_fun  -> _void))

(define-sokol frame-stats-enabled
  (_fun  -> _bool))

(define-sokol query-frame-stats
  (_fun  -> _frame_stats))

#|  Backend-specific structs and functions, these may come in handy for mixing
   sokol-gfx rendering with 'native backend' rendering functions.

   This group of functions will be expanded as needed. |#
(define _d3d11-buffer-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['buf _pointer]
  ))

(define _d3d11-image-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['tex2d _pointer]
   ['tex3d _pointer]
   ['res _pointer]
   ['srv _pointer]
  ))

(define _d3d11-sampler-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['smp _pointer]
  ))

(define _d3d11-shader-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['cbufs (_array _pointer 8)]
   ['vs _pointer]
   ['fs _pointer]
  ))

(define _d3d11-pipeline-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['il _pointer]
   ['rs _pointer]
   ['dss _pointer]
   ['bs _pointer]
  ))

(define _d3d11-attachments-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['color_rtv (_array _pointer 4)]
   ['resolve_rtv (_array _pointer 4)]
   ['dsv _pointer]
  ))

(define _mtl-buffer-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['buf (_array _pointer 2)]
   ['active_slot _int]
  ))

(define _mtl-image-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['tex (_array _pointer 2)]
   ['active_slot _int]
  ))

(define _mtl-sampler-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['smp _pointer]
  ))

(define _mtl-shader-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['vertex_lib _pointer]
   ['fragment_lib _pointer]
   ['vertex_func _pointer]
   ['fragment_func _pointer]
  ))

(define _mtl-pipeline-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['rps _pointer]
   ['dss _pointer]
  ))

(define _wgpu-buffer-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['buf _pointer]
  ))

(define _wgpu-image-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['tex _pointer]
   ['view _pointer]
  ))

(define _wgpu-sampler-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['smp _pointer]
  ))

(define _wgpu-shader-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['vs_mod _pointer]
   ['fs_mod _pointer]
   ['bgl _pointer]
  ))

(define _wgpu-pipeline-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['render_pipeline _pointer]
   ['compute_pipeline _pointer]
  ))

(define _wgpu-attachments-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['color_view (_array _pointer 4)]
   ['resolve_view (_array _pointer 4)]
   ['ds_view _pointer]
  ))

(define _gl-buffer-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['buf (_array _uint32 2)]
   ['active_slot _int]
  ))

(define _gl-image-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['tex (_array _uint32 2)]
   ['tex_target _uint32]
   ['msaa_render_buffer _uint32]
   ['active_slot _int]
  ))

(define _gl-sampler-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['smp _uint32]
  ))

(define _gl-shader-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['prog _uint32]
  ))

(define _gl-attachments-info
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['framebuffer _uint32]
   ['msaa_resolve_framebuffer (_array _uint32 4)]
  ))

#|  D3D11: return ID3D11Device |#
(define-sokol d3d11-device
  (_fun  -> _pointer))

#|  D3D11: return ID3D11DeviceContext |#
(define-sokol d3d11-device-context
  (_fun  -> _pointer))

#|  D3D11: get internal buffer resource objects |#
(define-sokol d3d11-query-buffer-info
  (_fun _buffer -> _d3d11_buffer_info))

#|  D3D11: get internal image resource objects |#
(define-sokol d3d11-query-image-info
  (_fun _image -> _d3d11_image_info))

#|  D3D11: get internal sampler resource objects |#
(define-sokol d3d11-query-sampler-info
  (_fun _sampler -> _d3d11_sampler_info))

#|  D3D11: get internal shader resource objects |#
(define-sokol d3d11-query-shader-info
  (_fun _shader -> _d3d11_shader_info))

#|  D3D11: get internal pipeline resource objects |#
(define-sokol d3d11-query-pipeline-info
  (_fun _pipeline -> _d3d11_pipeline_info))

#|  D3D11: get internal pass resource objects |#
(define-sokol d3d11-query-attachments-info
  (_fun _attachments -> _d3d11_attachments_info))

#|  Metal: return __bridge-casted MTLDevice |#
(define-sokol mtl-device
  (_fun  -> _pointer))

#|  Metal: return __bridge-casted MTLRenderCommandEncoder when inside render pass (otherwise zero) |#
(define-sokol mtl-render-command-encoder
  (_fun  -> _pointer))

#|  Metal: return __bridge-casted MTLComputeCommandEncoder when inside compute pass (otherwise zero) |#
(define-sokol mtl-compute-command-encoder
  (_fun  -> _pointer))

#|  Metal: get internal __bridge-casted buffer resource objects |#
(define-sokol mtl-query-buffer-info
  (_fun _buffer -> _mtl_buffer_info))

#|  Metal: get internal __bridge-casted image resource objects |#
(define-sokol mtl-query-image-info
  (_fun _image -> _mtl_image_info))

#|  Metal: get internal __bridge-casted sampler resource objects |#
(define-sokol mtl-query-sampler-info
  (_fun _sampler -> _mtl_sampler_info))

#|  Metal: get internal __bridge-casted shader resource objects |#
(define-sokol mtl-query-shader-info
  (_fun _shader -> _mtl_shader_info))

#|  Metal: get internal __bridge-casted pipeline resource objects |#
(define-sokol mtl-query-pipeline-info
  (_fun _pipeline -> _mtl_pipeline_info))

#|  WebGPU: return WGPUDevice object |#
(define-sokol wgpu-device
  (_fun  -> _pointer))

#|  WebGPU: return WGPUQueue object |#
(define-sokol wgpu-queue
  (_fun  -> _pointer))

#|  WebGPU: return this frame's WGPUCommandEncoder |#
(define-sokol wgpu-command-encoder
  (_fun  -> _pointer))

#|  WebGPU: return WGPURenderPassEncoder of current pass (returns 0 when outside pass or in a compute pass) |#
(define-sokol wgpu-render-pass-encoder
  (_fun  -> _pointer))

#|  WebGPU: return WGPUComputePassEncoder of current pass (returns 0 when outside pass or in a render pass) |#
(define-sokol wgpu-compute-pass-encoder
  (_fun  -> _pointer))

#|  WebGPU: get internal buffer resource objects |#
(define-sokol wgpu-query-buffer-info
  (_fun _buffer -> _wgpu_buffer_info))

#|  WebGPU: get internal image resource objects |#
(define-sokol wgpu-query-image-info
  (_fun _image -> _wgpu_image_info))

#|  WebGPU: get internal sampler resource objects |#
(define-sokol wgpu-query-sampler-info
  (_fun _sampler -> _wgpu_sampler_info))

#|  WebGPU: get internal shader resource objects |#
(define-sokol wgpu-query-shader-info
  (_fun _shader -> _wgpu_shader_info))

#|  WebGPU: get internal pipeline resource objects |#
(define-sokol wgpu-query-pipeline-info
  (_fun _pipeline -> _wgpu_pipeline_info))

#|  WebGPU: get internal pass resource objects |#
(define-sokol wgpu-query-attachments-info
  (_fun _attachments -> _wgpu_attachments_info))

#|  GL: get internal buffer resource objects |#
(define-sokol gl-query-buffer-info
  (_fun _buffer -> _gl_buffer_info))

#|  GL: get internal image resource objects |#
(define-sokol gl-query-image-info
  (_fun _image -> _gl_image_info))

#|  GL: get internal sampler resource objects |#
(define-sokol gl-query-sampler-info
  (_fun _sampler -> _gl_sampler_info))

#|  GL: get internal shader resource objects |#
(define-sokol gl-query-shader-info
  (_fun _shader -> _gl_shader_info))

#|  GL: get internal pass resource objects |#
(define-sokol gl-query-attachments-info
  (_fun _attachments -> _gl_attachments_info))

