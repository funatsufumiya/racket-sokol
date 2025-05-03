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

; Enum: sgl_log_item_t
; No explicit value for SGL-LOGITEM-OK
; No explicit value for SGL-LOGITEM-MALLOC-FAILED
; No explicit value for SGL-LOGITEM-MAKE-PIPELINE-FAILED
; No explicit value for SGL-LOGITEM-PIPELINE-POOL-EXHAUSTED
; No explicit value for SGL-LOGITEM-ADD-COMMIT-LISTENER-FAILED
; No explicit value for SGL-LOGITEM-CONTEXT-POOL-EXHAUSTED
; No explicit value for SGL-LOGITEM-CANNOT-DESTROY-DEFAULT-CONTEXT
#|     sgl_logger_t

    Used in sgl_desc_t to provide a custom logging and error reporting
    callback to sokol-gl. |#
(define _logger-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['func _fpointer]
   ['user_data _pointer]
  ))

#|  sokol_gl pipeline handle (created with sgl_make_pipeline()) |#
(define _pipeline
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['id _uint32]
  ))

#|  a context handle (created with sgl_make_context()) |#
(define _context
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['id _uint32]
  ))

#|     sgl_error_t

    Errors are reset each frame after calling sgl_draw(),
    get the last error code with sgl_error() |#
(define _error-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['any _bool]
   ['vertices_full _bool]
   ['uniforms_full _bool]
   ['commands_full _bool]
   ['stack_overflow _bool]
   ['stack_underflow _bool]
   ['no_context _bool]
  ))

#|     sgl_context_desc_t

    Describes the initialization parameters of a rendering context.
    Creating additional contexts is useful if you want to render
    in separate sokol-gfx passes. |#
(define _context-desc-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['max_vertices _int]
   ['max_commands _int]
   ['color_format _int]
   ['depth_format _int]
   ['sample_count _int]
  ))

#|     sgl_allocator_t

    Used in sgl_desc_t to provide custom memory-alloc and -free functions
    to sokol_gl.h. If memory management should be overridden, both the
    alloc and free function must be provided (e.g. it's not valid to
    override one function but not the other). |#
(define _allocator-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['alloc_fn _fpointer]
   ['free_fn _fpointer]
   ['user_data _pointer]
  ))

(define _desc-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['max_vertices _int]
   ['max_commands _int]
   ['context_pool_size _int]
   ['pipeline_pool_size _int]
   ['color_format _int]
   ['depth_format _int]
   ['sample_count _int]
   ['face_winding _int]
   ['allocator _allocator_t]
   ['logger _logger_t]
  ))

#|  setup/shutdown/misc |#
(define-sokol setup
  (_fun _unknown_const sgl_desc_t * -> _void))

(define-sokol shutdown
  (_fun  -> _void))

(define-sokol rad
  (_fun _float -> _float))

(define-sokol deg
  (_fun _float -> _float))

(define-sokol error
  (_fun  -> _error_t))

(define-sokol context-error
  (_fun _context -> _error_t))

#|  context functions |#
(define-sokol make-context
  (_fun _unknown_const sgl_context_desc_t * -> _context))

(define-sokol destroy-context
  (_fun _context -> _void))

(define-sokol set-context
  (_fun _context -> _void))

(define-sokol get-context
  (_fun  -> _context))

(define-sokol default-context
  (_fun  -> _context))

#|  get information about recorded vertices and commands in current context |#
(define-sokol num-vertices
  (_fun  -> _int))

(define-sokol num-commands
  (_fun  -> _int))

#|  draw recorded commands (call inside a sokol-gfx render pass) |#
(define-sokol draw
  (_fun  -> _void))

(define-sokol context-draw
  (_fun _context -> _void))

(define-sokol draw-layer
  (_fun _int -> _void))

(define-sokol context-draw-layer
  (_fun _context _int -> _void))

#|  create and destroy pipeline objects |#
(define-sokol make-pipeline
  (_fun _unknown_const sg_pipeline_desc * -> _pipeline))

(define-sokol context-make-pipeline
  (_fun _context _unknown_const sg_pipeline_desc * -> _pipeline))

(define-sokol destroy-pipeline
  (_fun _pipeline -> _void))

#|  render state functions |#
(define-sokol defaults
  (_fun  -> _void))

(define-sokol viewport
  (_fun _int _int _int _int _bool -> _void))

(define-sokol viewportf
  (_fun _float _float _float _float _bool -> _void))

(define-sokol scissor-rect
  (_fun _int _int _int _int _bool -> _void))

(define-sokol scissor-rectf
  (_fun _float _float _float _float _bool -> _void))

(define-sokol enable-texture
  (_fun  -> _void))

(define-sokol disable-texture
  (_fun  -> _void))

(define-sokol texture
  (_fun _sg_image _sg_sampler -> _void))

(define-sokol layer
  (_fun _int -> _void))

#|  pipeline stack functions |#
(define-sokol load-default-pipeline
  (_fun  -> _void))

(define-sokol load-pipeline
  (_fun _pipeline -> _void))

(define-sokol push-pipeline
  (_fun  -> _void))

(define-sokol pop-pipeline
  (_fun  -> _void))

#|  matrix stack functions |#
(define-sokol matrix-mode-modelview
  (_fun  -> _void))

(define-sokol matrix-mode-projection
  (_fun  -> _void))

(define-sokol matrix-mode-texture
  (_fun  -> _void))

(define-sokol load-identity
  (_fun  -> _void))

(define-sokol load-matrix
  (_fun _unknown_const float * -> _void))

(define-sokol load-transpose-matrix
  (_fun _unknown_const float * -> _void))

(define-sokol mult-matrix
  (_fun _unknown_const float * -> _void))

(define-sokol mult-transpose-matrix
  (_fun _unknown_const float * -> _void))

(define-sokol rotate
  (_fun _float _float _float _float -> _void))

(define-sokol scale
  (_fun _float _float _float -> _void))

(define-sokol translate
  (_fun _float _float _float -> _void))

(define-sokol frustum
  (_fun _float _float _float _float _float _float -> _void))

(define-sokol ortho
  (_fun _float _float _float _float _float _float -> _void))

(define-sokol perspective
  (_fun _float _float _float _float -> _void))

(define-sokol lookat
  (_fun _float _float _float _float _float _float _float _float _float -> _void))

(define-sokol push-matrix
  (_fun  -> _void))

(define-sokol pop-matrix
  (_fun  -> _void))

#|  these functions only set the internal 'current texcoord / color / point size' (valid inside or outside begin/end) |#
(define-sokol t2f
  (_fun _float _float -> _void))

(define-sokol c3f
  (_fun _float _float _float -> _void))

(define-sokol c4f
  (_fun _float _float _float _float -> _void))

(define-sokol c3b
  (_fun _uint8 _uint8 _uint8 -> _void))

(define-sokol c4b
  (_fun _uint8 _uint8 _uint8 _uint8 -> _void))

(define-sokol c1i
  (_fun _uint32 -> _void))

(define-sokol point-size
  (_fun _float -> _void))

#|  define primitives, each begin/end is one draw command |#
(define-sokol begin-points
  (_fun  -> _void))

(define-sokol begin-lines
  (_fun  -> _void))

(define-sokol begin-line-strip
  (_fun  -> _void))

(define-sokol begin-triangles
  (_fun  -> _void))

(define-sokol begin-triangle-strip
  (_fun  -> _void))

(define-sokol begin-quads
  (_fun  -> _void))

(define-sokol v2f
  (_fun _float _float -> _void))

(define-sokol v3f
  (_fun _float _float _float -> _void))

(define-sokol v2f-t2f
  (_fun _float _float _float _float -> _void))

(define-sokol v3f-t2f
  (_fun _float _float _float _float _float -> _void))

(define-sokol v2f-c3f
  (_fun _float _float _float _float _float -> _void))

(define-sokol v2f-c3b
  (_fun _float _float _uint8 _uint8 _uint8 -> _void))

(define-sokol v2f-c4f
  (_fun _float _float _float _float _float _float -> _void))

(define-sokol v2f-c4b
  (_fun _float _float _uint8 _uint8 _uint8 _uint8 -> _void))

(define-sokol v2f-c1i
  (_fun _float _float _uint32 -> _void))

(define-sokol v3f-c3f
  (_fun _float _float _float _float _float _float -> _void))

(define-sokol v3f-c3b
  (_fun _float _float _float _uint8 _uint8 _uint8 -> _void))

(define-sokol v3f-c4f
  (_fun _float _float _float _float _float _float _float -> _void))

(define-sokol v3f-c4b
  (_fun _float _float _float _uint8 _uint8 _uint8 _uint8 -> _void))

(define-sokol v3f-c1i
  (_fun _float _float _float _uint32 -> _void))

(define-sokol v2f-t2f-c3f
  (_fun _float _float _float _float _float _float _float -> _void))

(define-sokol v2f-t2f-c3b
  (_fun _float _float _float _float _uint8 _uint8 _uint8 -> _void))

(define-sokol v2f-t2f-c4f
  (_fun _float _float _float _float _float _float _float _float -> _void))

(define-sokol v2f-t2f-c4b
  (_fun _float _float _float _float _uint8 _uint8 _uint8 _uint8 -> _void))

(define-sokol v2f-t2f-c1i
  (_fun _float _float _float _float _uint32 -> _void))

(define-sokol v3f-t2f-c3f
  (_fun _float _float _float _float _float _float _float _float -> _void))

(define-sokol v3f-t2f-c3b
  (_fun _float _float _float _float _float _uint8 _uint8 _uint8 -> _void))

(define-sokol v3f-t2f-c4f
  (_fun _float _float _float _float _float _float _float _float _float -> _void))

(define-sokol v3f-t2f-c4b
  (_fun _float _float _float _float _float _uint8 _uint8 _uint8 _uint8 -> _void))

(define-sokol v3f-t2f-c1i
  (_fun _float _float _float _float _float _uint32 -> _void))

(define-sokol end
  (_fun  -> _void))

