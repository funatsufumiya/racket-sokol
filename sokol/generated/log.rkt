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

#|     Plug this function into the 'logger.func' struct item when initializing any of the sokol
    headers. For instance for sokol_audio.h it would look like this:

    saudio_setup(&(saudio_desc){
        .logger = {
            .func = slog_func
        }
    }); |#
(define-sokol func
  (_fun _string/utf-8 _uint32 _uint32 _string/utf-8 _uint32 _string/utf-8 _pointer -> _void))

