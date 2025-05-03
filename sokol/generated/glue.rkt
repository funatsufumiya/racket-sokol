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

(define-sokol environment
  (_fun  -> _sg_environment))

(define-sokol swapchain
  (_fun  -> _sg_swapchain))

