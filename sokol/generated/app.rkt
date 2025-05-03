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

#|  misc constants |#
(define SAPP-MAX-TOUCHPOINTS 8)
(define SAPP-MAX-MOUSEBUTTONS 3)
(define SAPP-MAX-KEYCODES 512)
(define SAPP-MAX-ICONIMAGES 8)

#|     sapp_event_type

    The type of event that's passed to the event handler callback
    in the sapp_event.type field. These are not just "traditional"
    input events, but also notify the application about state changes
    or other user-invoked actions. |#
; Enum: sapp_event_type
; No explicit value for SAPP-EVENTTYPE-INVALID
; No explicit value for SAPP-EVENTTYPE-KEY-DOWN
; No explicit value for SAPP-EVENTTYPE-KEY-UP
; No explicit value for SAPP-EVENTTYPE-CHAR
; No explicit value for SAPP-EVENTTYPE-MOUSE-DOWN
; No explicit value for SAPP-EVENTTYPE-MOUSE-UP
; No explicit value for SAPP-EVENTTYPE-MOUSE-SCROLL
; No explicit value for SAPP-EVENTTYPE-MOUSE-MOVE
; No explicit value for SAPP-EVENTTYPE-MOUSE-ENTER
; No explicit value for SAPP-EVENTTYPE-MOUSE-LEAVE
; No explicit value for SAPP-EVENTTYPE-TOUCHES-BEGAN
; No explicit value for SAPP-EVENTTYPE-TOUCHES-MOVED
; No explicit value for SAPP-EVENTTYPE-TOUCHES-ENDED
; No explicit value for SAPP-EVENTTYPE-TOUCHES-CANCELLED
; No explicit value for SAPP-EVENTTYPE-RESIZED
; No explicit value for SAPP-EVENTTYPE-ICONIFIED
; No explicit value for SAPP-EVENTTYPE-RESTORED
; No explicit value for SAPP-EVENTTYPE-FOCUSED
; No explicit value for SAPP-EVENTTYPE-UNFOCUSED
; No explicit value for SAPP-EVENTTYPE-SUSPENDED
; No explicit value for SAPP-EVENTTYPE-RESUMED
; No explicit value for SAPP-EVENTTYPE-QUIT-REQUESTED
; No explicit value for SAPP-EVENTTYPE-CLIPBOARD-PASTED
; No explicit value for SAPP-EVENTTYPE-FILES-DROPPED
; No explicit value for -SAPP-EVENTTYPE-NUM
(define -SAPP-EVENTTYPE-FORCE-U32 2147483647)
#|     sapp_keycode

    The 'virtual keycode' of a KEY_DOWN or KEY_UP event in the
    struct field sapp_event.key_code.

    Note that the keycode values are identical with GLFW. |#
; Enum: sapp_keycode
(define SAPP-KEYCODE-INVALID 0)
(define SAPP-KEYCODE-SPACE 32)
(define SAPP-KEYCODE-APOSTROPHE 39)
(define SAPP-KEYCODE-COMMA 44)
(define SAPP-KEYCODE-MINUS 45)
(define SAPP-KEYCODE-PERIOD 46)
(define SAPP-KEYCODE-SLASH 47)
(define SAPP-KEYCODE-0 48)
(define SAPP-KEYCODE-1 49)
(define SAPP-KEYCODE-2 50)
(define SAPP-KEYCODE-3 51)
(define SAPP-KEYCODE-4 52)
(define SAPP-KEYCODE-5 53)
(define SAPP-KEYCODE-6 54)
(define SAPP-KEYCODE-7 55)
(define SAPP-KEYCODE-8 56)
(define SAPP-KEYCODE-9 57)
(define SAPP-KEYCODE-SEMICOLON 59)
(define SAPP-KEYCODE-EQUAL 61)
(define SAPP-KEYCODE-A 65)
(define SAPP-KEYCODE-B 66)
(define SAPP-KEYCODE-C 67)
(define SAPP-KEYCODE-D 68)
(define SAPP-KEYCODE-E 69)
(define SAPP-KEYCODE-F 70)
(define SAPP-KEYCODE-G 71)
(define SAPP-KEYCODE-H 72)
(define SAPP-KEYCODE-I 73)
(define SAPP-KEYCODE-J 74)
(define SAPP-KEYCODE-K 75)
(define SAPP-KEYCODE-L 76)
(define SAPP-KEYCODE-M 77)
(define SAPP-KEYCODE-N 78)
(define SAPP-KEYCODE-O 79)
(define SAPP-KEYCODE-P 80)
(define SAPP-KEYCODE-Q 81)
(define SAPP-KEYCODE-R 82)
(define SAPP-KEYCODE-S 83)
(define SAPP-KEYCODE-T 84)
(define SAPP-KEYCODE-U 85)
(define SAPP-KEYCODE-V 86)
(define SAPP-KEYCODE-W 87)
(define SAPP-KEYCODE-X 88)
(define SAPP-KEYCODE-Y 89)
(define SAPP-KEYCODE-Z 90)
(define SAPP-KEYCODE-LEFT-BRACKET 91)
(define SAPP-KEYCODE-BACKSLASH 92)
(define SAPP-KEYCODE-RIGHT-BRACKET 93)
(define SAPP-KEYCODE-GRAVE-ACCENT 96)
(define SAPP-KEYCODE-WORLD-1 161)
(define SAPP-KEYCODE-WORLD-2 162)
(define SAPP-KEYCODE-ESCAPE 256)
(define SAPP-KEYCODE-ENTER 257)
(define SAPP-KEYCODE-TAB 258)
(define SAPP-KEYCODE-BACKSPACE 259)
(define SAPP-KEYCODE-INSERT 260)
(define SAPP-KEYCODE-DELETE 261)
(define SAPP-KEYCODE-RIGHT 262)
(define SAPP-KEYCODE-LEFT 263)
(define SAPP-KEYCODE-DOWN 264)
(define SAPP-KEYCODE-UP 265)
(define SAPP-KEYCODE-PAGE-UP 266)
(define SAPP-KEYCODE-PAGE-DOWN 267)
(define SAPP-KEYCODE-HOME 268)
(define SAPP-KEYCODE-END 269)
(define SAPP-KEYCODE-CAPS-LOCK 280)
(define SAPP-KEYCODE-SCROLL-LOCK 281)
(define SAPP-KEYCODE-NUM-LOCK 282)
(define SAPP-KEYCODE-PRINT-SCREEN 283)
(define SAPP-KEYCODE-PAUSE 284)
(define SAPP-KEYCODE-F1 290)
(define SAPP-KEYCODE-F2 291)
(define SAPP-KEYCODE-F3 292)
(define SAPP-KEYCODE-F4 293)
(define SAPP-KEYCODE-F5 294)
(define SAPP-KEYCODE-F6 295)
(define SAPP-KEYCODE-F7 296)
(define SAPP-KEYCODE-F8 297)
(define SAPP-KEYCODE-F9 298)
(define SAPP-KEYCODE-F10 299)
(define SAPP-KEYCODE-F11 300)
(define SAPP-KEYCODE-F12 301)
(define SAPP-KEYCODE-F13 302)
(define SAPP-KEYCODE-F14 303)
(define SAPP-KEYCODE-F15 304)
(define SAPP-KEYCODE-F16 305)
(define SAPP-KEYCODE-F17 306)
(define SAPP-KEYCODE-F18 307)
(define SAPP-KEYCODE-F19 308)
(define SAPP-KEYCODE-F20 309)
(define SAPP-KEYCODE-F21 310)
(define SAPP-KEYCODE-F22 311)
(define SAPP-KEYCODE-F23 312)
(define SAPP-KEYCODE-F24 313)
(define SAPP-KEYCODE-F25 314)
(define SAPP-KEYCODE-KP-0 320)
(define SAPP-KEYCODE-KP-1 321)
(define SAPP-KEYCODE-KP-2 322)
(define SAPP-KEYCODE-KP-3 323)
(define SAPP-KEYCODE-KP-4 324)
(define SAPP-KEYCODE-KP-5 325)
(define SAPP-KEYCODE-KP-6 326)
(define SAPP-KEYCODE-KP-7 327)
(define SAPP-KEYCODE-KP-8 328)
(define SAPP-KEYCODE-KP-9 329)
(define SAPP-KEYCODE-KP-DECIMAL 330)
(define SAPP-KEYCODE-KP-DIVIDE 331)
(define SAPP-KEYCODE-KP-MULTIPLY 332)
(define SAPP-KEYCODE-KP-SUBTRACT 333)
(define SAPP-KEYCODE-KP-ADD 334)
(define SAPP-KEYCODE-KP-ENTER 335)
(define SAPP-KEYCODE-KP-EQUAL 336)
(define SAPP-KEYCODE-LEFT-SHIFT 340)
(define SAPP-KEYCODE-LEFT-CONTROL 341)
(define SAPP-KEYCODE-LEFT-ALT 342)
(define SAPP-KEYCODE-LEFT-SUPER 343)
(define SAPP-KEYCODE-RIGHT-SHIFT 344)
(define SAPP-KEYCODE-RIGHT-CONTROL 345)
(define SAPP-KEYCODE-RIGHT-ALT 346)
(define SAPP-KEYCODE-RIGHT-SUPER 347)
(define SAPP-KEYCODE-MENU 348)
#|     Android specific 'tool type' enum for touch events. This lets the
    application check what type of input device was used for
    touch events.

    NOTE: the values must remain in sync with the corresponding
    Android SDK type, so don't change those.

    See https://developer.android.com/reference/android/view/MotionEvent#TOOL_TYPE_UNKNOWN |#
; Enum: sapp_android_tooltype
(define SAPP-ANDROIDTOOLTYPE-UNKNOWN 0)
(define SAPP-ANDROIDTOOLTYPE-FINGER 1)
(define SAPP-ANDROIDTOOLTYPE-STYLUS 2)
(define SAPP-ANDROIDTOOLTYPE-MOUSE 3)
#|     sapp_touchpoint

    Describes a single touchpoint in a multitouch event (TOUCHES_BEGAN,
    TOUCHES_MOVED, TOUCHES_ENDED).

    Touch points are stored in the nested array sapp_event.touches[],
    and the number of touches is stored in sapp_event.num_touches. |#
(define _touchpoint
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['identifier _uintptr]
   ['pos_x _float]
   ['pos_y _float]
   ['android_tooltype _int]
   ['changed _bool]
  ))

#|     sapp_mousebutton

    The currently pressed mouse button in the events MOUSE_DOWN
    and MOUSE_UP, stored in the struct field sapp_event.mouse_button. |#
; Enum: sapp_mousebutton
(define SAPP-MOUSEBUTTON-LEFT 0)
(define SAPP-MOUSEBUTTON-RIGHT 1)
(define SAPP-MOUSEBUTTON-MIDDLE 2)
(define SAPP-MOUSEBUTTON-INVALID 256)
#|     These are currently pressed modifier keys (and mouse buttons) which are
    passed in the event struct field sapp_event.modifiers. |#
(define SAPP-MODIFIER-SHIFT 1)
(define SAPP-MODIFIER-CTRL 2)
(define SAPP-MODIFIER-ALT 4)
(define SAPP-MODIFIER-SUPER 8)
(define SAPP-MODIFIER-LMB 256)
(define SAPP-MODIFIER-RMB 512)
(define SAPP-MODIFIER-MMB 1024)

#|     sapp_event

    This is an all-in-one event struct passed to the event handler
    user callback function. Note that it depends on the event
    type what struct fields actually contain useful values, so you
    should first check the event type before reading other struct
    fields. |#
(define _event
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['frame_count _uint64]
   ['type _int]
   ['key_code _int]
   ['char_code _uint32]
   ['key_repeat _bool]
   ['modifiers _uint32]
   ['mouse_button _int]
   ['mouse_x _float]
   ['mouse_y _float]
   ['mouse_dx _float]
   ['mouse_dy _float]
   ['scroll_x _float]
   ['scroll_y _float]
   ['num_touches _int]
   ['touches (_array _touchpoint 8)]
   ['window_width _int]
   ['window_height _int]
   ['framebuffer_width _int]
   ['framebuffer_height _int]
  ))

#|     sg_range

    A general pointer/size-pair struct and constructor macros for passing binary blobs
    into sokol_app.h. |#
(define _range
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['ptr _pointer]
   ['size _size]
  ))

#|     sapp_image_desc

    This is used to describe image data to sokol_app.h (at first, window
    icons, later maybe cursor images).

    Note that the actual image pixel format depends on the use case:

    - window icon pixels are RGBA8 |#
(define _image-desc
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['width _int]
   ['height _int]
   ['pixels _range]
  ))

#|     sapp_icon_desc

    An icon description structure for use in sapp_desc.icon and
    sapp_set_icon().

    When setting a custom image, the application can provide a number of
    candidates differing in size, and sokol_app.h will pick the image(s)
    closest to the size expected by the platform's window system.

    To set sokol-app's default icon, set .sokol_default to true.

    Otherwise provide candidate images of different sizes in the
    images[] array.

    If both the sokol_default flag is set to true, any image candidates
    will be ignored and the sokol_app.h default icon will be set. |#
(define _icon-desc
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['sokol_default _bool]
   ['images (_array _image_desc 8)]
  ))

#|     sapp_allocator

    Used in sapp_desc to provide custom memory-alloc and -free functions
    to sokol_app.h. If memory management should be overridden, both the
    alloc_fn and free_fn function must be provided (e.g. it's not valid to
    override one function but not the other). |#
(define _allocator
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['alloc_fn _fpointer]
   ['free_fn _fpointer]
   ['user_data _pointer]
  ))

; Enum: sapp_log_item
; No explicit value for SAPP-LOGITEM-OK
; No explicit value for SAPP-LOGITEM-MALLOC-FAILED
; No explicit value for SAPP-LOGITEM-MACOS-INVALID-NSOPENGL-PROFILE
; No explicit value for SAPP-LOGITEM-WIN32-LOAD-OPENGL32-DLL-FAILED
; No explicit value for SAPP-LOGITEM-WIN32-CREATE-HELPER-WINDOW-FAILED
; No explicit value for SAPP-LOGITEM-WIN32-HELPER-WINDOW-GETDC-FAILED
; No explicit value for SAPP-LOGITEM-WIN32-DUMMY-CONTEXT-SET-PIXELFORMAT-FAILED
; No explicit value for SAPP-LOGITEM-WIN32-CREATE-DUMMY-CONTEXT-FAILED
; No explicit value for SAPP-LOGITEM-WIN32-DUMMY-CONTEXT-MAKE-CURRENT-FAILED
; No explicit value for SAPP-LOGITEM-WIN32-GET-PIXELFORMAT-ATTRIB-FAILED
; No explicit value for SAPP-LOGITEM-WIN32-WGL-FIND-PIXELFORMAT-FAILED
; No explicit value for SAPP-LOGITEM-WIN32-WGL-DESCRIBE-PIXELFORMAT-FAILED
; No explicit value for SAPP-LOGITEM-WIN32-WGL-SET-PIXELFORMAT-FAILED
; No explicit value for SAPP-LOGITEM-WIN32-WGL-ARB-CREATE-CONTEXT-REQUIRED
; No explicit value for SAPP-LOGITEM-WIN32-WGL-ARB-CREATE-CONTEXT-PROFILE-REQUIRED
; No explicit value for SAPP-LOGITEM-WIN32-WGL-OPENGL-VERSION-NOT-SUPPORTED
; No explicit value for SAPP-LOGITEM-WIN32-WGL-OPENGL-PROFILE-NOT-SUPPORTED
; No explicit value for SAPP-LOGITEM-WIN32-WGL-INCOMPATIBLE-DEVICE-CONTEXT
; No explicit value for SAPP-LOGITEM-WIN32-WGL-CREATE-CONTEXT-ATTRIBS-FAILED-OTHER
; No explicit value for SAPP-LOGITEM-WIN32-D3D11-CREATE-DEVICE-AND-SWAPCHAIN-WITH-DEBUG-FAILED
; No explicit value for SAPP-LOGITEM-WIN32-D3D11-GET-IDXGIFACTORY-FAILED
; No explicit value for SAPP-LOGITEM-WIN32-D3D11-GET-IDXGIADAPTER-FAILED
; No explicit value for SAPP-LOGITEM-WIN32-D3D11-QUERY-INTERFACE-IDXGIDEVICE1-FAILED
; No explicit value for SAPP-LOGITEM-WIN32-REGISTER-RAW-INPUT-DEVICES-FAILED-MOUSE-LOCK
; No explicit value for SAPP-LOGITEM-WIN32-REGISTER-RAW-INPUT-DEVICES-FAILED-MOUSE-UNLOCK
; No explicit value for SAPP-LOGITEM-WIN32-GET-RAW-INPUT-DATA-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-GLX-LOAD-LIBGL-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-GLX-LOAD-ENTRY-POINTS-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-GLX-EXTENSION-NOT-FOUND
; No explicit value for SAPP-LOGITEM-LINUX-GLX-QUERY-VERSION-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-GLX-VERSION-TOO-LOW
; No explicit value for SAPP-LOGITEM-LINUX-GLX-NO-GLXFBCONFIGS
; No explicit value for SAPP-LOGITEM-LINUX-GLX-NO-SUITABLE-GLXFBCONFIG
; No explicit value for SAPP-LOGITEM-LINUX-GLX-GET-VISUAL-FROM-FBCONFIG-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-GLX-REQUIRED-EXTENSIONS-MISSING
; No explicit value for SAPP-LOGITEM-LINUX-GLX-CREATE-CONTEXT-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-GLX-CREATE-WINDOW-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-X11-CREATE-WINDOW-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-EGL-BIND-OPENGL-API-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-EGL-BIND-OPENGL-ES-API-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-EGL-GET-DISPLAY-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-EGL-INITIALIZE-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-EGL-NO-CONFIGS
; No explicit value for SAPP-LOGITEM-LINUX-EGL-NO-NATIVE-VISUAL
; No explicit value for SAPP-LOGITEM-LINUX-EGL-GET-VISUAL-INFO-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-EGL-CREATE-WINDOW-SURFACE-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-EGL-CREATE-CONTEXT-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-EGL-MAKE-CURRENT-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-X11-OPEN-DISPLAY-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-X11-QUERY-SYSTEM-DPI-FAILED
; No explicit value for SAPP-LOGITEM-LINUX-X11-DROPPED-FILE-URI-WRONG-SCHEME
; No explicit value for SAPP-LOGITEM-LINUX-X11-FAILED-TO-BECOME-OWNER-OF-CLIPBOARD
; No explicit value for SAPP-LOGITEM-ANDROID-UNSUPPORTED-INPUT-EVENT-INPUT-CB
; No explicit value for SAPP-LOGITEM-ANDROID-UNSUPPORTED-INPUT-EVENT-MAIN-CB
; No explicit value for SAPP-LOGITEM-ANDROID-READ-MSG-FAILED
; No explicit value for SAPP-LOGITEM-ANDROID-WRITE-MSG-FAILED
; No explicit value for SAPP-LOGITEM-ANDROID-MSG-CREATE
; No explicit value for SAPP-LOGITEM-ANDROID-MSG-RESUME
; No explicit value for SAPP-LOGITEM-ANDROID-MSG-PAUSE
; No explicit value for SAPP-LOGITEM-ANDROID-MSG-FOCUS
; No explicit value for SAPP-LOGITEM-ANDROID-MSG-NO-FOCUS
; No explicit value for SAPP-LOGITEM-ANDROID-MSG-SET-NATIVE-WINDOW
; No explicit value for SAPP-LOGITEM-ANDROID-MSG-SET-INPUT-QUEUE
; No explicit value for SAPP-LOGITEM-ANDROID-MSG-DESTROY
; No explicit value for SAPP-LOGITEM-ANDROID-UNKNOWN-MSG
; No explicit value for SAPP-LOGITEM-ANDROID-LOOP-THREAD-STARTED
; No explicit value for SAPP-LOGITEM-ANDROID-LOOP-THREAD-DONE
; No explicit value for SAPP-LOGITEM-ANDROID-NATIVE-ACTIVITY-ONSTART
; No explicit value for SAPP-LOGITEM-ANDROID-NATIVE-ACTIVITY-ONRESUME
; No explicit value for SAPP-LOGITEM-ANDROID-NATIVE-ACTIVITY-ONSAVEINSTANCESTATE
; No explicit value for SAPP-LOGITEM-ANDROID-NATIVE-ACTIVITY-ONWINDOWFOCUSCHANGED
; No explicit value for SAPP-LOGITEM-ANDROID-NATIVE-ACTIVITY-ONPAUSE
; No explicit value for SAPP-LOGITEM-ANDROID-NATIVE-ACTIVITY-ONSTOP
; No explicit value for SAPP-LOGITEM-ANDROID-NATIVE-ACTIVITY-ONNATIVEWINDOWCREATED
; No explicit value for SAPP-LOGITEM-ANDROID-NATIVE-ACTIVITY-ONNATIVEWINDOWDESTROYED
; No explicit value for SAPP-LOGITEM-ANDROID-NATIVE-ACTIVITY-ONINPUTQUEUECREATED
; No explicit value for SAPP-LOGITEM-ANDROID-NATIVE-ACTIVITY-ONINPUTQUEUEDESTROYED
; No explicit value for SAPP-LOGITEM-ANDROID-NATIVE-ACTIVITY-ONCONFIGURATIONCHANGED
; No explicit value for SAPP-LOGITEM-ANDROID-NATIVE-ACTIVITY-ONLOWMEMORY
; No explicit value for SAPP-LOGITEM-ANDROID-NATIVE-ACTIVITY-ONDESTROY
; No explicit value for SAPP-LOGITEM-ANDROID-NATIVE-ACTIVITY-DONE
; No explicit value for SAPP-LOGITEM-ANDROID-NATIVE-ACTIVITY-ONCREATE
; No explicit value for SAPP-LOGITEM-ANDROID-CREATE-THREAD-PIPE-FAILED
; No explicit value for SAPP-LOGITEM-ANDROID-NATIVE-ACTIVITY-CREATE-SUCCESS
; No explicit value for SAPP-LOGITEM-WGPU-SWAPCHAIN-CREATE-SURFACE-FAILED
; No explicit value for SAPP-LOGITEM-WGPU-SWAPCHAIN-CREATE-SWAPCHAIN-FAILED
; No explicit value for SAPP-LOGITEM-WGPU-SWAPCHAIN-CREATE-DEPTH-STENCIL-TEXTURE-FAILED
; No explicit value for SAPP-LOGITEM-WGPU-SWAPCHAIN-CREATE-DEPTH-STENCIL-VIEW-FAILED
; No explicit value for SAPP-LOGITEM-WGPU-SWAPCHAIN-CREATE-MSAA-TEXTURE-FAILED
; No explicit value for SAPP-LOGITEM-WGPU-SWAPCHAIN-CREATE-MSAA-VIEW-FAILED
; No explicit value for SAPP-LOGITEM-WGPU-REQUEST-DEVICE-STATUS-ERROR
; No explicit value for SAPP-LOGITEM-WGPU-REQUEST-DEVICE-STATUS-UNKNOWN
; No explicit value for SAPP-LOGITEM-WGPU-REQUEST-ADAPTER-STATUS-UNAVAILABLE
; No explicit value for SAPP-LOGITEM-WGPU-REQUEST-ADAPTER-STATUS-ERROR
; No explicit value for SAPP-LOGITEM-WGPU-REQUEST-ADAPTER-STATUS-UNKNOWN
; No explicit value for SAPP-LOGITEM-WGPU-CREATE-INSTANCE-FAILED
; No explicit value for SAPP-LOGITEM-IMAGE-DATA-SIZE-MISMATCH
; No explicit value for SAPP-LOGITEM-DROPPED-FILE-PATH-TOO-LONG
; No explicit value for SAPP-LOGITEM-CLIPBOARD-STRING-TOO-BIG
#|     sapp_logger

    Used in sapp_desc to provide a logging function. Please be aware that
    without logging function, sokol-app will be completely silent, e.g. it will
    not report errors or warnings. For maximum error verbosity, compile in
    debug mode (e.g. NDEBUG *not* defined) and install a logger (for instance
    the standard logging function from sokol_log.h). |#
(define _logger
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['func _fpointer]
   ['user_data _pointer]
  ))

#|     sokol-app initialization options, used as return value of sokol_main()
    or sapp_run() argument. |#
(define _desc
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['init_cb _fpointer]
   ['frame_cb _fpointer]
   ['cleanup_cb _fpointer]
   ['event_cb _fpointer]
   ['user_data _pointer]
   ['init_userdata_cb _fpointer]
   ['frame_userdata_cb _fpointer]
   ['cleanup_userdata_cb _fpointer]
   ['event_userdata_cb _fpointer]
   ['width _int]
   ['height _int]
   ['sample_count _int]
   ['swap_interval _int]
   ['high_dpi _bool]
   ['fullscreen _bool]
   ['alpha _bool]
   ['window_title _string/utf-8]
   ['enable_clipboard _bool]
   ['clipboard_size _int]
   ['enable_dragndrop _bool]
   ['max_dropped_files _int]
   ['max_dropped_file_path_length _int]
   ['icon _icon_desc]
   ['allocator _allocator]
   ['logger _logger]
   ['gl_major_version _int]
   ['gl_minor_version _int]
   ['win32_console_utf8 _bool]
   ['win32_console_create _bool]
   ['win32_console_attach _bool]
   ['html5_canvas_selector _string/utf-8]
   ['html5_canvas_resize _bool]
   ['html5_preserve_drawing_buffer _bool]
   ['html5_premultiplied_alpha _bool]
   ['html5_ask_leave_site _bool]
   ['html5_update_document_title _bool]
   ['html5_bubble_mouse_events _bool]
   ['html5_bubble_touch_events _bool]
   ['html5_bubble_wheel_events _bool]
   ['html5_bubble_key_events _bool]
   ['html5_bubble_char_events _bool]
   ['html5_use_emsc_set_main_loop _bool]
   ['html5_emsc_set_main_loop_simulate_infinite_loop _bool]
   ['ios_keyboard_resizes_canvas _bool]
  ))

#|  HTML5 specific: request and response structs for
   asynchronously loading dropped-file content. |#
; Enum: sapp_html5_fetch_error
; No explicit value for SAPP-HTML5-FETCH-ERROR-NO-ERROR
; No explicit value for SAPP-HTML5-FETCH-ERROR-BUFFER-TOO-SMALL
; No explicit value for SAPP-HTML5-FETCH-ERROR-OTHER
(define _html5-fetch-response
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['succeeded _bool]
   ['error_code _int]
   ['file_index _int]
   ['data _range]
   ['buffer _range]
   ['user_data _pointer]
  ))

(define _html5-fetch-request
  (_struct
   #:alignment 4  ; Assuming 4-byte alignment, adjust if needed
   ['dropped_file_index _int]
   ['callback _fpointer]
   ['buffer _range]
   ['user_data _pointer]
  ))

#|     sapp_mouse_cursor

    Predefined cursor image definitions, set with sapp_set_mouse_cursor(sapp_mouse_cursor cursor) |#
; Enum: sapp_mouse_cursor
(define SAPP-MOUSECURSOR-DEFAULT 0)
; No explicit value for SAPP-MOUSECURSOR-ARROW
; No explicit value for SAPP-MOUSECURSOR-IBEAM
; No explicit value for SAPP-MOUSECURSOR-CROSSHAIR
; No explicit value for SAPP-MOUSECURSOR-POINTING-HAND
; No explicit value for SAPP-MOUSECURSOR-RESIZE-EW
; No explicit value for SAPP-MOUSECURSOR-RESIZE-NS
; No explicit value for SAPP-MOUSECURSOR-RESIZE-NWSE
; No explicit value for SAPP-MOUSECURSOR-RESIZE-NESW
; No explicit value for SAPP-MOUSECURSOR-RESIZE-ALL
; No explicit value for SAPP-MOUSECURSOR-NOT-ALLOWED
; No explicit value for -SAPP-MOUSECURSOR-NUM
#|  returns true after sokol-app has been initialized |#
(define-sokol isvalid
  (_fun  -> _bool))

#|  returns the current framebuffer width in pixels |#
(define-sokol width
  (_fun  -> _int))

#|  same as sapp_width(), but returns float |#
(define-sokol widthf
  (_fun  -> _float))

#|  returns the current framebuffer height in pixels |#
(define-sokol height
  (_fun  -> _int))

#|  same as sapp_height(), but returns float |#
(define-sokol heightf
  (_fun  -> _float))

#|  get default framebuffer color pixel format |#
(define-sokol color-format
  (_fun  -> _int))

#|  get default framebuffer depth pixel format |#
(define-sokol depth-format
  (_fun  -> _int))

#|  get default framebuffer sample count |#
(define-sokol sample-count
  (_fun  -> _int))

#|  returns true when high_dpi was requested and actually running in a high-dpi scenario |#
(define-sokol high-dpi
  (_fun  -> _bool))

#|  returns the dpi scaling factor (window pixels to framebuffer pixels) |#
(define-sokol dpi-scale
  (_fun  -> _float))

#|  show or hide the mobile device onscreen keyboard |#
(define-sokol show-keyboard
  (_fun _bool -> _void))

#|  return true if the mobile device onscreen keyboard is currently shown |#
(define-sokol keyboard-shown
  (_fun  -> _bool))

#|  query fullscreen mode |#
(define-sokol is-fullscreen
  (_fun  -> _bool))

#|  toggle fullscreen mode |#
(define-sokol toggle-fullscreen
  (_fun  -> _void))

#|  show or hide the mouse cursor |#
(define-sokol show-mouse
  (_fun _bool -> _void))

#|  show or hide the mouse cursor |#
(define-sokol mouse-shown
  (_fun  -> _bool))

#|  enable/disable mouse-pointer-lock mode |#
(define-sokol lock-mouse
  (_fun _bool -> _void))

#|  return true if in mouse-pointer-lock mode (this may toggle a few frames later) |#
(define-sokol mouse-locked
  (_fun  -> _bool))

#|  set mouse cursor type |#
(define-sokol set-mouse-cursor
  (_fun _int -> _void))

#|  get current mouse cursor type |#
(define-sokol get-mouse-cursor
  (_fun  -> _int))

#|  return the userdata pointer optionally provided in sapp_desc |#
(define-sokol userdata
  (_fun  -> _pointer))

#|  return a copy of the sapp_desc structure |#
(define-sokol query-desc
  (_fun  -> _desc))

#|  initiate a "soft quit" (sends SAPP_EVENTTYPE_QUIT_REQUESTED) |#
(define-sokol request-quit
  (_fun  -> _void))

#|  cancel a pending quit (when SAPP_EVENTTYPE_QUIT_REQUESTED has been received) |#
(define-sokol cancel-quit
  (_fun  -> _void))

#|  initiate a "hard quit" (quit application without sending SAPP_EVENTTYPE_QUIT_REQUESTED) |#
(define-sokol quit
  (_fun  -> _void))

#|  call from inside event callback to consume the current event (don't forward to platform) |#
(define-sokol consume-event
  (_fun  -> _void))

#|  get the current frame counter (for comparison with sapp_event.frame_count) |#
(define-sokol frame-count
  (_fun  -> _uint64))

#|  get an averaged/smoothed frame duration in seconds |#
(define-sokol frame-duration
  (_fun  -> _double))

#|  write string into clipboard |#
(define-sokol set-clipboard-string
  (_fun _string/utf-8 -> _void))

#|  read string from clipboard (usually during SAPP_EVENTTYPE_CLIPBOARD_PASTED) |#
(define-sokol get-clipboard-string
  (_fun  -> _string/utf-8))

#|  set the window title (only on desktop platforms) |#
(define-sokol set-window-title
  (_fun _string/utf-8 -> _void))

#|  set the window icon (only on Windows and Linux) |#
(define-sokol set-icon
  (_fun _unknown_const sapp_icon_desc * -> _void))

#|  gets the total number of dropped files (after an SAPP_EVENTTYPE_FILES_DROPPED event) |#
(define-sokol get-num-dropped-files
  (_fun  -> _int))

#|  gets the dropped file paths |#
(define-sokol get-dropped-file-path
  (_fun _int -> _string/utf-8))

#|  special run-function for SOKOL_NO_ENTRY (in standard mode this is an empty stub) |#
(define-sokol run
  (_fun _unknown_const sapp_desc * -> _void))

#|  EGL: get EGLDisplay object |#
(define-sokol egl-get-display
  (_fun  -> _pointer))

#|  EGL: get EGLContext object |#
(define-sokol egl-get-context
  (_fun  -> _pointer))

#|  HTML5: enable or disable the hardwired "Leave Site?" dialog box |#
(define-sokol html5-ask-leave-site
  (_fun _bool -> _void))

#|  HTML5: get byte size of a dropped file |#
(define-sokol html5-get-dropped-file-size
  (_fun _int -> _uint32))

#|  HTML5: asynchronously load the content of a dropped file |#
(define-sokol html5-fetch-dropped-file
  (_fun _unknown_const sapp_html5_fetch_request * -> _void))

#|  Metal: get bridged pointer to Metal device object |#
(define-sokol metal-get-device
  (_fun  -> _pointer))

#|  Metal: get bridged pointer to MTKView's current drawable of type CAMetalDrawable |#
(define-sokol metal-get-current-drawable
  (_fun  -> _pointer))

#|  Metal: get bridged pointer to MTKView's depth-stencil texture of type MTLTexture |#
(define-sokol metal-get-depth-stencil-texture
  (_fun  -> _pointer))

#|  Metal: get bridged pointer to MTKView's msaa-color-texture of type MTLTexture (may be null) |#
(define-sokol metal-get-msaa-color-texture
  (_fun  -> _pointer))

#|  macOS: get bridged pointer to macOS NSWindow |#
(define-sokol macos-get-window
  (_fun  -> _pointer))

#|  iOS: get bridged pointer to iOS UIWindow |#
(define-sokol ios-get-window
  (_fun  -> _pointer))

#|  D3D11: get pointer to ID3D11Device object |#
(define-sokol d3d11-get-device
  (_fun  -> _pointer))

#|  D3D11: get pointer to ID3D11DeviceContext object |#
(define-sokol d3d11-get-device-context
  (_fun  -> _pointer))

#|  D3D11: get pointer to IDXGISwapChain object |#
(define-sokol d3d11-get-swap-chain
  (_fun  -> _pointer))

#|  D3D11: get pointer to ID3D11RenderTargetView object for rendering |#
(define-sokol d3d11-get-render-view
  (_fun  -> _pointer))

#|  D3D11: get pointer ID3D11RenderTargetView object for msaa-resolve (may return null) |#
(define-sokol d3d11-get-resolve-view
  (_fun  -> _pointer))

#|  D3D11: get pointer ID3D11DepthStencilView |#
(define-sokol d3d11-get-depth-stencil-view
  (_fun  -> _pointer))

#|  Win32: get the HWND window handle |#
(define-sokol win32-get-hwnd
  (_fun  -> _pointer))

#|  WebGPU: get WGPUDevice handle |#
(define-sokol wgpu-get-device
  (_fun  -> _pointer))

#|  WebGPU: get swapchain's WGPUTextureView handle for rendering |#
(define-sokol wgpu-get-render-view
  (_fun  -> _pointer))

#|  WebGPU: get swapchain's MSAA-resolve WGPUTextureView (may return null) |#
(define-sokol wgpu-get-resolve-view
  (_fun  -> _pointer))

#|  WebGPU: get swapchain's WGPUTextureView for the depth-stencil surface |#
(define-sokol wgpu-get-depth-stencil-view
  (_fun  -> _pointer))

#|  GL: get framebuffer object |#
(define-sokol gl-get-framebuffer
  (_fun  -> _uint32))

#|  GL: get major version |#
(define-sokol gl-get-major-version
  (_fun  -> _int))

#|  GL: get minor version |#
(define-sokol gl-get-minor-version
  (_fun  -> _int))

#|  GL: return true if the context is GLES |#
(define-sokol gl-is-gles
  (_fun  -> _bool))

#|  X11: get Window |#
(define-sokol x11-get-window
  (_fun  -> _pointer))

#|  X11: get Display |#
(define-sokol x11-get-display
  (_fun  -> _pointer))

#|  Android: get native activity handle |#
(define-sokol android-get-native-activity
  (_fun  -> _pointer))

