import os, argparse
import gen_rkt

# Common header files and their prefixes
tasks = [
    [ 'vendor/sokol/sokol_log.h',            'slog_',     [] ],
    [ 'vendor/sokol/sokol_gfx.h',            'sg_',       [] ],
    [ 'vendor/sokol/sokol_app.h',            'sapp_',     [] ],
    [ 'vendor/sokol/sokol_glue.h',           'sglue_',    ['sg_', 'sapp_'] ],
    [ 'vendor/sokol/sokol_time.h',           'stm_',      [] ],
    [ 'vendor/sokol/sokol_audio.h',          'saudio_',   [] ],
    [ 'vendor/sokol/util/sokol_gl.h',        'sgl_',      ['sg_'] ],
    [ 'vendor/sokol/util/sokol_debugtext.h', 'sdtx_',     ['sg_'] ],
    [ 'vendor/sokol/util/sokol_shape.h',     'sshape_',   ['sg_'] ],
    [ 'vendor/sokol/sokol_fetch.h',          'sfetch_',   [] ],
    [ 'vendor/sokol/util/sokol_imgui.h',     'simgui_',   ['sg_', 'sapp_'] ],
]

if __name__ == '__main__':
    # Ensure we're in the project root directory
    if os.path.basename(os.getcwd()) == 'bindgen':
        os.chdir('..')
    
    # Prepare output directories and create dummy source files
    gen_rkt.prepare()
    
    # Generate Racket bindings for each module
    for task in tasks:
        [c_header_path, main_prefix, dep_prefixes] = task
        gen_rkt.gen(c_header_path, main_prefix, dep_prefixes)

    # Clear intermediate json files
    for task in tasks:
        module_name = gen_rkt.module_names[task[1]]
        json_file = f"{module_name}.json"
        if os.path.exists(json_file):
            os.remove(json_file)
            print(f"  Removed temporary file: {json_file}")
    
    print('=== Racket bindings generation completed')
