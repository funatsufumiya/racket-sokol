#lang racket/base

(require ffi/unsafe
         ffi/unsafe/define
         racket/file)

(require "../../sokol/generated/gfx.rkt")
(require "../../sokol/generated/app.rkt")

(provide (all-defined-out))

; Load the sokol library
(define sokol-lib
  (ffi-lib "libsokol" '("1" "")
           #:fail (lambda () 
                    (error 'sokol "Could not load sokol library"))))

(define-ffi-definer define-sokol sokol-lib)

; Enum: simgui_log_item_t
; No explicit value for SIMGUI-LOGITEM-OK
; No explicit value for SIMGUI-LOGITEM-MALLOC-FAILED
#|     simgui_allocator_t

    Used in simgui_desc_t to provide custom memory-alloc and -free functions
    to sokol_imgui.h. If memory management should be overridden, both the
    alloc_fn and free_fn function must be provided (e.g. it's not valid to
    override one function but not the other). |#
(define _allocator-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['alloc_fn _fpointer]
   ['free_fn _fpointer]
   ['user_data _pointer]
  ))

#|     simgui_logger

    Used in simgui_desc_t to provide a logging function. Please be aware
    that without logging function, sokol-imgui will be completely
    silent, e.g. it will not report errors, warnings and
    validation layer messages. For maximum error verbosity,
    compile in debug mode (e.g. NDEBUG *not* defined) and install
    a logger (for instance the standard logging function from sokol_log.h). |#
(define _logger-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['func _fpointer]
   ['user_data _pointer]
  ))

(define _desc-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['max_vertices _int]
   ['color_format _int]
   ['depth_format _int]
   ['sample_count _int]
   ['ini_filename _string/utf-8]
   ['no_default_font _bool]
   ['disable_paste_override _bool]
   ['disable_set_mouse_cursor _bool]
   ['disable_windows_resize_from_edges _bool]
   ['write_alpha_channel _bool]
   ['allocator _allocator_t]
   ['logger _logger_t]
  ))

(define _frame-desc-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['width _int]
   ['height _int]
   ['delta_time _double]
   ['dpi_scale _float]
  ))

(define _font-tex-desc-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['min_filter _int]
   ['mag_filter _int]
  ))

(define-sokol setup
  (_fun _unknown_const simgui_desc_t * -> _void))

(define-sokol new-frame
  (_fun _unknown_const simgui_frame_desc_t * -> _void))

(define-sokol render
  (_fun  -> _void))

(define-sokol imtextureid
  (_fun _sg_image -> _uint64))

(define-sokol imtextureid-with-sampler
  (_fun _sg_image _sg_sampler -> _uint64))

(define-sokol image-from-imtextureid
  (_fun _uint64 -> _sg_image))

(define-sokol sampler-from-imtextureid
  (_fun _uint64 -> _sg_sampler))

(define-sokol add-focus-event
  (_fun _bool -> _void))

(define-sokol add-mouse-pos-event
  (_fun _float _float -> _void))

(define-sokol add-touch-pos-event
  (_fun _float _float -> _void))

(define-sokol add-mouse-button-event
  (_fun _int _bool -> _void))

(define-sokol add-mouse-wheel-event
  (_fun _float _float -> _void))

(define-sokol add-key-event
  (_fun _int _bool -> _void))

(define-sokol add-input-character
  (_fun _uint32 -> _void))

(define-sokol add-input-characters-utf8
  (_fun _string/utf-8 -> _void))

(define-sokol add-touch-button-event
  (_fun _int _bool -> _void))

(define-sokol handle-event
  (_fun _unknown_const sapp_event * -> _bool))

(define-sokol map-keycode
  (_fun _int -> _int))

(define-sokol shutdown
  (_fun  -> _void))

(define-sokol create-fonts-texture
  (_fun _unknown_const simgui_font_tex_desc_t * -> _void))

(define-sokol destroy-fonts-texture
  (_fun  -> _void))

