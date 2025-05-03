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

; Enum: sfetch_log_item_t
; No explicit value for SFETCH-LOGITEM-OK
; No explicit value for SFETCH-LOGITEM-MALLOC-FAILED
; No explicit value for SFETCH-LOGITEM-FILE-PATH-UTF8-DECODING-FAILED
; No explicit value for SFETCH-LOGITEM-SEND-QUEUE-FULL
; No explicit value for SFETCH-LOGITEM-REQUEST-CHANNEL-INDEX-TOO-BIG
; No explicit value for SFETCH-LOGITEM-REQUEST-PATH-IS-NULL
; No explicit value for SFETCH-LOGITEM-REQUEST-PATH-TOO-LONG
; No explicit value for SFETCH-LOGITEM-REQUEST-CALLBACK-MISSING
; No explicit value for SFETCH-LOGITEM-REQUEST-CHUNK-SIZE-GREATER-BUFFER-SIZE
; No explicit value for SFETCH-LOGITEM-REQUEST-USERDATA-PTR-IS-SET-BUT-USERDATA-SIZE-IS-NULL
; No explicit value for SFETCH-LOGITEM-REQUEST-USERDATA-PTR-IS-NULL-BUT-USERDATA-SIZE-IS-NOT
; No explicit value for SFETCH-LOGITEM-REQUEST-USERDATA-SIZE-TOO-BIG
; No explicit value for SFETCH-LOGITEM-CLAMPING-NUM-CHANNELS-TO-MAX-CHANNELS
; No explicit value for SFETCH-LOGITEM-REQUEST-POOL-EXHAUSTED
#|     sfetch_logger_t

    Used in sfetch_desc_t to provide a custom logging and error reporting
    callback to sokol-fetch. |#
(define _logger-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['func _fpointer]
   ['user_data _pointer]
  ))

#|     sfetch_range_t

    A pointer-size pair struct to pass memory ranges into and out of sokol-fetch.
    When initialized from a value type (array or struct) you can use the
    SFETCH_RANGE() helper macro to build an sfetch_range_t struct. |#
(define _range-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['ptr _pointer]
   ['size _size]
  ))

#|     sfetch_allocator_t

    Used in sfetch_desc_t to provide custom memory-alloc and -free functions
    to sokol_fetch.h. If memory management should be overridden, both the
    alloc and free function must be provided (e.g. it's not valid to
    override one function but not the other). |#
(define _allocator-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['alloc_fn _fpointer]
   ['free_fn _fpointer]
   ['user_data _pointer]
  ))

#|  configuration values for sfetch_setup() |#
(define _desc-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['max_requests _uint32]
   ['num_channels _uint32]
   ['num_lanes _uint32]
   ['allocator _allocator_t]
   ['logger _logger_t]
  ))

#|  a request handle to identify an active fetch request, returned by sfetch_send() |#
(define _handle-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['id _uint32]
  ))

#|  error codes |#
; Enum: sfetch_error_t
; No explicit value for SFETCH-ERROR-NO-ERROR
; No explicit value for SFETCH-ERROR-FILE-NOT-FOUND
; No explicit value for SFETCH-ERROR-NO-BUFFER
; No explicit value for SFETCH-ERROR-BUFFER-TOO-SMALL
; No explicit value for SFETCH-ERROR-UNEXPECTED-EOF
; No explicit value for SFETCH-ERROR-INVALID-HTTP-STATUS
; No explicit value for SFETCH-ERROR-CANCELLED
; No explicit value for SFETCH-ERROR-JS-OTHER
#|  the response struct passed to the response callback |#
(define _response-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['handle _handle_t]
   ['dispatched _bool]
   ['fetched _bool]
   ['paused _bool]
   ['finished _bool]
   ['failed _bool]
   ['cancelled _bool]
   ['error_code _int]
   ['channel _uint32]
   ['lane _uint32]
   ['path _string/utf-8]
   ['user_data _pointer]
   ['data_offset _uint32]
   ['data _range_t]
   ['buffer _range_t]
  ))

#|  request parameters passed to sfetch_send() |#
(define _request-t
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['channel _uint32]
   ['path _string/utf-8]
   ['callback _fpointer]
   ['chunk_size _uint32]
   ['buffer _range_t]
   ['user_data _range_t]
  ))

#|  setup sokol-fetch (can be called on multiple threads) |#
(define-sokol setup
  (_fun _unknown_const sfetch_desc_t * -> _void))

#|  discard a sokol-fetch context |#
(define-sokol shutdown
  (_fun  -> _void))

#|  return true if sokol-fetch has been setup |#
(define-sokol valid
  (_fun  -> _bool))

#|  get the desc struct that was passed to sfetch_setup() |#
(define-sokol desc
  (_fun  -> _desc_t))

#|  return the max userdata size in number of bytes (SFETCH_MAX_USERDATA_UINT64 * sizeof(uint64_t)) |#
(define-sokol max-userdata-bytes
  (_fun  -> _int))

#|  return the value of the SFETCH_MAX_PATH implementation config value |#
(define-sokol max-path
  (_fun  -> _int))

#|  send a fetch-request, get handle to request back |#
(define-sokol send
  (_fun _unknown_const sfetch_request_t * -> _handle_t))

#|  return true if a handle is valid *and* the request is alive |#
(define-sokol handle-valid
  (_fun _handle_t -> _bool))

#|  do per-frame work, moves requests into and out of IO threads, and invokes response-callbacks |#
(define-sokol dowork
  (_fun  -> _void))

#|  bind a data buffer to a request (request must not currently have a buffer bound, must be called from response callback |#
(define-sokol bind-buffer
  (_fun _handle_t _range_t -> _void))

#|  clear the 'buffer binding' of a request, returns previous buffer pointer (can be 0), must be called from response callback |#
(define-sokol unbind-buffer
  (_fun _handle_t -> _pointer))

#|  cancel a request that's in flight (will call response callback with .cancelled + .finished) |#
(define-sokol cancel
  (_fun _handle_t -> _void))

#|  pause a request (will call response callback each frame with .paused) |#
(define-sokol pause
  (_fun _handle_t -> _void))

#|  continue a paused request |#
(define-sokol continue
  (_fun _handle_t -> _void))

