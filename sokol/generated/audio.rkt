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

; Enum: saudio_log_item
; No explicit value for SAUDIO-LOGITEM-OK
; No explicit value for SAUDIO-LOGITEM-MALLOC-FAILED
; No explicit value for SAUDIO-LOGITEM-ALSA-SND-PCM-OPEN-FAILED
; No explicit value for SAUDIO-LOGITEM-ALSA-FLOAT-SAMPLES-NOT-SUPPORTED
; No explicit value for SAUDIO-LOGITEM-ALSA-REQUESTED-BUFFER-SIZE-NOT-SUPPORTED
; No explicit value for SAUDIO-LOGITEM-ALSA-REQUESTED-CHANNEL-COUNT-NOT-SUPPORTED
; No explicit value for SAUDIO-LOGITEM-ALSA-SND-PCM-HW-PARAMS-SET-RATE-NEAR-FAILED
; No explicit value for SAUDIO-LOGITEM-ALSA-SND-PCM-HW-PARAMS-FAILED
; No explicit value for SAUDIO-LOGITEM-ALSA-PTHREAD-CREATE-FAILED
; No explicit value for SAUDIO-LOGITEM-WASAPI-CREATE-EVENT-FAILED
; No explicit value for SAUDIO-LOGITEM-WASAPI-CREATE-DEVICE-ENUMERATOR-FAILED
; No explicit value for SAUDIO-LOGITEM-WASAPI-GET-DEFAULT-AUDIO-ENDPOINT-FAILED
; No explicit value for SAUDIO-LOGITEM-WASAPI-DEVICE-ACTIVATE-FAILED
; No explicit value for SAUDIO-LOGITEM-WASAPI-AUDIO-CLIENT-INITIALIZE-FAILED
; No explicit value for SAUDIO-LOGITEM-WASAPI-AUDIO-CLIENT-GET-BUFFER-SIZE-FAILED
; No explicit value for SAUDIO-LOGITEM-WASAPI-AUDIO-CLIENT-GET-SERVICE-FAILED
; No explicit value for SAUDIO-LOGITEM-WASAPI-AUDIO-CLIENT-SET-EVENT-HANDLE-FAILED
; No explicit value for SAUDIO-LOGITEM-WASAPI-CREATE-THREAD-FAILED
; No explicit value for SAUDIO-LOGITEM-AAUDIO-STREAMBUILDER-OPEN-STREAM-FAILED
; No explicit value for SAUDIO-LOGITEM-AAUDIO-PTHREAD-CREATE-FAILED
; No explicit value for SAUDIO-LOGITEM-AAUDIO-RESTARTING-STREAM-AFTER-ERROR
; No explicit value for SAUDIO-LOGITEM-USING-AAUDIO-BACKEND
; No explicit value for SAUDIO-LOGITEM-AAUDIO-CREATE-STREAMBUILDER-FAILED
; No explicit value for SAUDIO-LOGITEM-COREAUDIO-NEW-OUTPUT-FAILED
; No explicit value for SAUDIO-LOGITEM-COREAUDIO-ALLOCATE-BUFFER-FAILED
; No explicit value for SAUDIO-LOGITEM-COREAUDIO-START-FAILED
; No explicit value for SAUDIO-LOGITEM-BACKEND-BUFFER-SIZE-ISNT-MULTIPLE-OF-PACKET-SIZE
#|     saudio_logger

    Used in saudio_desc to provide a custom logging and error reporting
    callback to sokol-audio. |#
(define _logger
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['func _fpointer]
   ['user_data _pointer]
  ))

#|     saudio_allocator

    Used in saudio_desc to provide custom memory-alloc and -free functions
    to sokol_audio.h. If memory management should be overridden, both the
    alloc_fn and free_fn function must be provided (e.g. it's not valid to
    override one function but not the other). |#
(define _allocator
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['alloc_fn _fpointer]
   ['free_fn _fpointer]
   ['user_data _pointer]
  ))

(define _desc
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['sample_rate _int]
   ['num_channels _int]
   ['buffer_frames _int]
   ['packet_frames _int]
   ['num_packets _int]
   ['stream_cb _fpointer]
   ['stream_userdata_cb _fpointer]
   ['user_data _pointer]
   ['allocator _allocator]
   ['logger _logger]
  ))

#|  setup sokol-audio |#
(define-sokol setup
  (_fun _unknown_const saudio_desc * -> _void))

#|  shutdown sokol-audio |#
(define-sokol shutdown
  (_fun  -> _void))

#|  true after setup if audio backend was successfully initialized |#
(define-sokol isvalid
  (_fun  -> _bool))

#|  return the saudio_desc.user_data pointer |#
(define-sokol userdata
  (_fun  -> _pointer))

#|  return a copy of the original saudio_desc struct |#
(define-sokol query-desc
  (_fun  -> _desc))

#|  actual sample rate |#
(define-sokol sample-rate
  (_fun  -> _int))

#|  return actual backend buffer size in number of frames |#
(define-sokol buffer-frames
  (_fun  -> _int))

#|  actual number of channels |#
(define-sokol channels
  (_fun  -> _int))

#|  return true if audio context is currently suspended (only in WebAudio backend, all other backends return false) |#
(define-sokol suspended
  (_fun  -> _bool))

#|  get current number of frames to fill packet queue |#
(define-sokol expect
  (_fun  -> _int))

#|  push sample frames from main thread, returns number of frames actually pushed |#
(define-sokol push
  (_fun _unknown_const float * _int -> _int))

