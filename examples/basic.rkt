#!/usr/bin/env racket
#lang racket/base

(void #<<EOF
// Basic sokol example in C
#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_log.h"
#include "sokol_glue.h"

static struct {
    sg_pipeline pip;
    sg_bindings bind;
    sg_pass_action pass_action;
} state;

static void init(void) {
    sg_setup(&(sg_desc){
        .environment = sglue_environment(),
        .logger.func = slog_func,
    });
    
    // set clear color to a nice blue
    state.pass_action = (sg_pass_action) {
        .colors[0] = { .load_action=SG_LOADACTION_CLEAR, .clear_value={0.1f, 0.3f, 0.5f, 1.0f} }
    };
}

void frame(void) {
    sg_begin_pass(&(sg_pass){ .action = state.pass_action, .swapchain = sglue_swapchain() });
    sg_end_pass();
    sg_commit();
}

void cleanup(void) {
    sg_shutdown();
}

sapp_desc sokol_main(int argc, char* argv[]) {
    return (sapp_desc){
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = 800,
        .height = 600,
        .window_title = "Basic Sokol Window",
        .icon.sokol_default = true,
        .logger.func = slog_func,
    };
}
EOF
)

(module+ main
  (require sokol/generated/app
           sokol/generated/gfx
           sokol/generated/log
           sokol/generated/glue)
  
  (define state
    (make-hash))
  
  (define (init)
    (sg-setup 
     (make-sg-desc
      #:environment (sglue-environment)
      #:logger.func slog-func))
    
    ;; set clear color to a nice blue
    (hash-set! state 'pass-action 
               (make-sg-pass-action
                #:colors.0.load-action SG-LOADACTION-CLEAR
                #:colors.0.clear-value (vector 0.1 0.3 0.5 1.0))))
  
  (define (frame)
    (sg-begin-pass 
     (make-sg-pass 
      #:action (hash-ref state 'pass-action)
      #:swapchain (sglue-swapchain)))
    (sg-end-pass)
    (sg-commit))
  
  (define (cleanup)
    (sg-shutdown))
  
  (define app-desc
    (make-sapp-desc
     #:init-cb init
     #:frame-cb frame
     #:cleanup-cb cleanup
     #:width 800
     #:height 600
     #:window-title "Basic Sokol Window"
     #:icon.sokol-default #t
     #:logger.func slog-func))
  
  (sapp-run app-desc))
