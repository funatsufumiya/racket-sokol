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

(define-sokol setup
  (_fun  -> _void))

(define-sokol now
  (_fun  -> _uint64))

(define-sokol diff
  (_fun _uint64 _uint64 -> _uint64))

(define-sokol since
  (_fun _uint64 -> _uint64))

(define-sokol laptime
  (_fun _unknown_uint64_t * -> _uint64))

(define-sokol round-to-common-refresh-rate
  (_fun _uint64 -> _uint64))

(define-sokol sec
  (_fun _uint64 -> _double))

(define-sokol ms
  (_fun _uint64 -> _double))

(define-sokol us
  (_fun _uint64 -> _double))

(define-sokol ns
  (_fun _uint64 -> _double))

