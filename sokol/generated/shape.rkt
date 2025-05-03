#lang racket/base

(require ffi/unsafe
         ffi/unsafe/define
         racket/file)

(require "../../sokol/generated/gfx.rkt")

(provide (all-defined-out))

; Load the sokol library
(define sokol-lib
  (ffi-lib "libsokol" '("1" "")
           #:fail (lambda () 
                    (error 'sokol "Could not load sokol library"))))

(define-ffi-definer define-sokol sokol-lib)

#|     sshape_range is a pointer-size-pair struct used to pass memory
    blobs into sokol-shape. When initialized from a value type
    (array or struct), use the SSHAPE_RANGE() macro to build
    an sshape_range struct. |#
(define _range
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['ptr _pointer]
   ['size _size]
  ))

#|  a 4x4 matrix wrapper struct |#
(define _mat4-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['m (_array (_array _float 4) 4)]
  ))

#|  vertex layout of the generated geometry |#
(define _vertex-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['x _float]
   ['y _float]
   ['z _float]
   ['normal _uint32]
   ['u _uint16]
   ['v _uint16]
   ['color _uint32]
  ))

#|  a range of draw-elements (sg_draw(int base_element, int num_element, ...)) |#
(define _element-range-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['base_element _int]
   ['num_elements _int]
  ))

#|  number of elements and byte size of build actions |#
(define _sizes-item-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['num _uint32]
   ['size _uint32]
  ))

(define _sizes-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['vertices _sizes_item_t]
   ['indices _sizes_item_t]
  ))

#|  in/out struct to keep track of mesh-build state |#
(define _buffer-item-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['buffer _range]
   ['data_size _size]
   ['shape_offset _size]
  ))

(define _buffer-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['valid _bool]
   ['vertices _buffer_item_t]
   ['indices _buffer_item_t]
  ))

#|  creation parameters for the different shape types |#
(define _plane-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['width _float]
   ['depth _float]
   ['tiles _uint16]
   ['color _uint32]
   ['random_colors _bool]
   ['merge _bool]
   ['transform _mat4_t]
  ))

(define _box-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['width _float]
   ['height _float]
   ['depth _float]
   ['tiles _uint16]
   ['color _uint32]
   ['random_colors _bool]
   ['merge _bool]
   ['transform _mat4_t]
  ))

(define _sphere-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['radius _float]
   ['slices _uint16]
   ['stacks _uint16]
   ['color _uint32]
   ['random_colors _bool]
   ['merge _bool]
   ['transform _mat4_t]
  ))

(define _cylinder-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['radius _float]
   ['height _float]
   ['slices _uint16]
   ['stacks _uint16]
   ['color _uint32]
   ['random_colors _bool]
   ['merge _bool]
   ['transform _mat4_t]
  ))

(define _torus-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['radius _float]
   ['ring_radius _float]
   ['sides _uint16]
   ['rings _uint16]
   ['color _uint32]
   ['random_colors _bool]
   ['merge _bool]
   ['transform _mat4_t]
  ))

#|  shape builder functions |#
(define-sokol build-plane
  (_fun _unknown_const sshape_buffer_t * _unknown_const sshape_plane_t * -> _buffer_t))

(define-sokol build-box
  (_fun _unknown_const sshape_buffer_t * _unknown_const sshape_box_t * -> _buffer_t))

(define-sokol build-sphere
  (_fun _unknown_const sshape_buffer_t * _unknown_const sshape_sphere_t * -> _buffer_t))

(define-sokol build-cylinder
  (_fun _unknown_const sshape_buffer_t * _unknown_const sshape_cylinder_t * -> _buffer_t))

(define-sokol build-torus
  (_fun _unknown_const sshape_buffer_t * _unknown_const sshape_torus_t * -> _buffer_t))

#|  query required vertex- and index-buffer sizes in bytes |#
(define-sokol plane-sizes
  (_fun _uint32 -> _sizes_t))

(define-sokol box-sizes
  (_fun _uint32 -> _sizes_t))

(define-sokol sphere-sizes
  (_fun _uint32 _uint32 -> _sizes_t))

(define-sokol cylinder-sizes
  (_fun _uint32 _uint32 -> _sizes_t))

(define-sokol torus-sizes
  (_fun _uint32 _uint32 -> _sizes_t))

#|  extract sokol-gfx desc structs and primitive ranges from build state |#
(define-sokol element-range
  (_fun _unknown_const sshape_buffer_t * -> _element_range_t))

(define-sokol vertex-buffer-desc
  (_fun _unknown_const sshape_buffer_t * -> _sg_buffer_desc))

(define-sokol index-buffer-desc
  (_fun _unknown_const sshape_buffer_t * -> _sg_buffer_desc))

(define-sokol vertex-buffer-layout-state
  (_fun  -> _sg_vertex_buffer_layout_state))

(define-sokol position-vertex-attr-state
  (_fun  -> _sg_vertex_attr_state))

(define-sokol normal-vertex-attr-state
  (_fun  -> _sg_vertex_attr_state))

(define-sokol texcoord-vertex-attr-state
  (_fun  -> _sg_vertex_attr_state))

(define-sokol color-vertex-attr-state
  (_fun  -> _sg_vertex_attr_state))

#|  helper functions to build packed color value from floats or bytes |#
(define-sokol color-4f
  (_fun _float _float _float _float -> _uint32))

(define-sokol color-3f
  (_fun _float _float _float -> _uint32))

(define-sokol color-4b
  (_fun _uint8 _uint8 _uint8 _uint8 -> _uint32))

(define-sokol color-3b
  (_fun _uint8 _uint8 _uint8 -> _uint32))

#|  adapter function for filling matrix struct from generic float[16] array |#
(define-sokol mat4
  (_fun _unknown_const float * -> _mat4_t))

(define-sokol mat4-transpose
  (_fun _unknown_const float * -> _mat4_t))

