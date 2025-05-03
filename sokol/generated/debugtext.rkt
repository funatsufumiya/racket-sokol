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

; Enum: sdtx_log_item_t
; No explicit value for SDTX-LOGITEM-OK
; No explicit value for SDTX-LOGITEM-MALLOC-FAILED
; No explicit value for SDTX-LOGITEM-ADD-COMMIT-LISTENER-FAILED
; No explicit value for SDTX-LOGITEM-COMMAND-BUFFER-FULL
; No explicit value for SDTX-LOGITEM-CONTEXT-POOL-EXHAUSTED
; No explicit value for SDTX-LOGITEM-CANNOT-DESTROY-DEFAULT-CONTEXT
#|     sdtx_logger_t

    Used in sdtx_desc_t to provide a custom logging and error reporting
    callback to sokol-debugtext. |#
(define _logger-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['func _fpointer]
   ['user_data _pointer]
  ))

#|  a rendering context handle |#
(define _context
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['id _uint32]
  ))

#|     sdtx_range is a pointer-size-pair struct used to pass memory
    blobs into sokol-debugtext. When initialized from a value type
    (array or struct), use the SDTX_RANGE() macro to build
    an sdtx_range struct. |#
(define _range
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['ptr _pointer]
   ['size _size]
  ))

(define _font-desc-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['data _range]
   ['first_char _uint8]
   ['last_char _uint8]
  ))

#|     sdtx_context_desc_t

    Describes the initialization parameters of a rendering context. Creating
    additional rendering contexts is useful if you want to render in
    different sokol-gfx rendering passes, or when rendering several layers
    of text. |#
(define _context-desc-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['max_commands _int]
   ['char_buf_size _int]
   ['canvas_width _float]
   ['canvas_height _float]
   ['tab_width _int]
   ['color_format _int]
   ['depth_format _int]
   ['sample_count _int]
  ))

#|     sdtx_allocator_t

    Used in sdtx_desc_t to provide custom memory-alloc and -free functions
    to sokol_debugtext.h. If memory management should be overridden, both the
    alloc_fn and free_fn function must be provided (e.g. it's not valid to
    override one function but not the other). |#
(define _allocator-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['alloc_fn _fpointer]
   ['free_fn _fpointer]
   ['user_data _pointer]
  ))

#|     sdtx_desc_t

    Describes the sokol-debugtext API initialization parameters. Passed
    to the sdtx_setup() function.

    NOTE: to populate the fonts item array with builtin fonts, use any
    of the following functions:

        sdtx_font_kc853()
        sdtx_font_kc854()
        sdtx_font_z1013()
        sdtx_font_cpc()
        sdtx_font_c64()
        sdtx_font_oric() |#
(define _desc-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['context_pool_size _int]
   ['printf_buf_size _int]
   ['fonts (_array _font_desc_t 8)]
   ['ctx _context_desc_t]
   ['allocator _allocator_t]
   ['logger _logger_t]
  ))

#|  initialization/shutdown |#
(define-sokol setup
  (_fun _unknown_const sdtx_desc_t * -> _void))

(define-sokol shutdown
  (_fun  -> _void))

#|  builtin font data (use to populate sdtx_desc.font[]) |#
(define-sokol font-kc853
  (_fun  -> _font_desc_t))

(define-sokol font-kc854
  (_fun  -> _font_desc_t))

(define-sokol font-z1013
  (_fun  -> _font_desc_t))

(define-sokol font-cpc
  (_fun  -> _font_desc_t))

(define-sokol font-c64
  (_fun  -> _font_desc_t))

(define-sokol font-oric
  (_fun  -> _font_desc_t))

#|  context functions |#
(define-sokol make-context
  (_fun _unknown_const sdtx_context_desc_t * -> _context))

(define-sokol destroy-context
  (_fun _context -> _void))

(define-sokol set-context
  (_fun _context -> _void))

(define-sokol get-context
  (_fun  -> _context))

(define-sokol default-context
  (_fun  -> _context))

#|  drawing functions (call inside sokol-gfx render pass) |#
(define-sokol draw
  (_fun  -> _void))

(define-sokol context-draw
  (_fun _context -> _void))

(define-sokol draw-layer
  (_fun _int -> _void))

(define-sokol context-draw-layer
  (_fun _context _int -> _void))

#|  switch render layer |#
(define-sokol layer
  (_fun _int -> _void))

#|  switch to a different font |#
(define-sokol font
  (_fun _int -> _void))

#|  set a new virtual canvas size in screen pixels |#
(define-sokol canvas
  (_fun _float _float -> _void))

#|  set a new origin in character grid coordinates |#
(define-sokol origin
  (_fun _float _float -> _void))

#|  cursor movement functions (relative to origin in character grid coordinates) |#
(define-sokol home
  (_fun  -> _void))

(define-sokol pos
  (_fun _float _float -> _void))

(define-sokol pos-x
  (_fun _float -> _void))

(define-sokol pos-y
  (_fun _float -> _void))

(define-sokol move
  (_fun _float _float -> _void))

(define-sokol move-x
  (_fun _float -> _void))

(define-sokol move-y
  (_fun _float -> _void))

(define-sokol crlf
  (_fun  -> _void))

#|  set the current text color |#
(define-sokol color3b
  (_fun _uint8 _uint8 _uint8 -> _void))

(define-sokol color3f
  (_fun _float _float _float -> _void))

(define-sokol color4b
  (_fun _uint8 _uint8 _uint8 _uint8 -> _void))

(define-sokol color4f
  (_fun _float _float _float _float -> _void))

(define-sokol color1i
  (_fun _uint32 -> _void))

#|  text rendering |#
(define-sokol putc
  (_fun _byte -> _void))

(define-sokol puts
  (_fun _string/utf-8 -> _void))

(define-sokol putr
  (_fun _string/utf-8 _int -> _void))

