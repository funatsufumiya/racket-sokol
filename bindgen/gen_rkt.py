#-------------------------------------------------------------------------------
#   Generate Racket bindings.
#
#   Racket coding style:
#   - functions are kebab-case
#   - structs are prefixed with _
#   - enums use constants
#-------------------------------------------------------------------------------
import gen_ir
import os, shutil, sys
import textwrap

import gen_util as util

# Module names mapping
module_names = {
    'slog_':    'log',
    'sg_':      'gfx',
    'sapp_':    'app',
    'stm_':     'time',
    'saudio_':  'audio',
    'sgl_':     'gl',
    'sdtx_':    'debugtext',
    'sshape_':  'shape',
    'sglue_':   'glue',
    'sfetch_':  'fetch',
    'simgui_':  'imgui',
}

# Output paths
output_paths = {
    'slog_':    'sokol/generated/log.rkt',
    'sg_':      'sokol/generated/gfx.rkt',
    'sapp_':    'sokol/generated/app.rkt',
    'stm_':     'sokol/generated/time.rkt',
    'saudio_':  'sokol/generated/audio.rkt',
    'sgl_':     'sokol/generated/gl.rkt',
    'sdtx_':    'sokol/generated/debugtext.rkt',
    'sshape_':  'sokol/generated/shape.rkt',
    'sglue_':   'sokol/generated/glue.rkt',
    'sfetch_':  'sokol/generated/fetch.rkt',
    'simgui_':  'sokol/generated/imgui.rkt',
}

# C header paths
c_header_paths = {
    'slog_':    'vendor/sokol/sokol_log.h',
    'sg_':      'vendor/sokol/sokol_gfx.h',
    'sapp_':    'vendor/sokol/sokol_app.h',
    'stm_':     'vendor/sokol/sokol_time.h',
    'saudio_':  'vendor/sokol/sokol_audio.h',
    'sgl_':     'vendor/sokol/util/sokol_gl.h',
    'sdtx_':    'vendor/sokol/util/sokol_debugtext.h',
    'sshape_':  'vendor/sokol/util/sokol_shape.h',
    'sglue_':   'vendor/sokol/sokol_glue.h',
    'sfetch_':  'vendor/sokol/sokol_fetch.h',
    'simgui_':  'vendor/sokol/util/sokol_imgui.h',
}

# Define C source paths that will be created by prepare()
c_source_paths = {
    'slog_':    'sokol-racket/src/c/sokol_log.c',
    'sg_':      'sokol-racket/src/c/sokol_gfx.c',
    'sapp_':    'sokol-racket/src/c/sokol_app.c',
    'stm_':     'sokol-racket/src/c/sokol_time.c',
    'saudio_':  'sokol-racket/src/c/sokol_audio.c',
    'sgl_':     'sokol-racket/src/c/sokol_gl.c',
    'sdtx_':    'sokol-racket/src/c/sokol_debugtext.c',
    'sshape_':  'sokol-racket/src/c/sokol_shape.c',
    'sglue_':   'sokol-racket/src/c/sokol_glue.c',
    'sfetch_':  'sokol-racket/src/c/sokol_fetch.c',
    'simgui_':  'sokol-racket/src/c/sokol_imgui.c',
}

# Functions to ignore
ignores = [
    'sdtx_printf',
    'sdtx_vprintf',
]

# Type overrides
overrides = {
    'context': 'ctx',  # context is a common name in Racket
    'SGL_NO_ERROR': 'SGL_ERROR_NO_ERROR',
}

# C to Racket type mapping
prim_types = {
    'int':          '_int',
    'bool':         '_bool',
    'char':         '_byte',
    'int8_t':       '_sint8',
    'uint8_t':      '_uint8',
    'int16_t':      '_sint16',
    'uint16_t':     '_uint16',
    'int32_t':      '_sint32',
    'uint32_t':     '_uint32',
    'int64_t':      '_sint64',
    'uint64_t':     '_uint64',
    'float':        '_float',
    'double':       '_double',
    'uintptr_t':    '_uintptr',
    'intptr_t':     '_intptr',
    'size_t':       '_size'
}

# Globals
struct_types = []
enum_types = []
enum_items = {}
out_lines = ''

def reset_globals():
    global struct_types
    global enum_types
    global enum_items
    global out_lines
    struct_types = []
    enum_types = []
    enum_items = {}
    out_lines = ''

def l(s):
    global out_lines
    out_lines += s + '\n'

def c(s, indent="", comment="#|"):
    if not s:
        return
    if comment == "#|":
        l(f"{indent}{comment} {s} |#")
    else:
        prefix = f"{indent}{comment}"
        for line in textwrap.dedent(s).splitlines():
            l(f"{prefix} {line}" if line else prefix)

def as_racket_identifier(name, prefix):
    """Convert C snake_case to Racket kebab-case, remove prefix, add module prefix"""
    module_prefix = module_names[prefix] if prefix in module_names else ""
    
    if name.startswith(prefix):
        name = name[len(prefix):]
    
    # Convert to kebab-case
    result = name.replace('_', '-').lower()
    
    # Add module prefix
    if module_prefix:
        return f"{module_prefix}:{result}"
    else:
        return result

def as_racket_type(c_type, prefix):
    """Convert C type to Racket FFI type"""
    if c_type in prim_types:
        return prim_types[c_type]
    elif c_type in struct_types:
        struct_name = c_type
        if struct_name.startswith(prefix):
            struct_name = struct_name[len(prefix):]
        return f"_{as_racket_identifier(struct_name, prefix)}"
    elif c_type in enum_types:
        return "_int"  # Enums are represented as integers in FFI
    elif util.is_void_ptr(c_type):
        return "_pointer"
    elif util.is_const_void_ptr(c_type):
        return "_pointer"
    elif util.is_string_ptr(c_type):
        return "_string/utf-8"
    elif util.is_func_ptr(c_type):
        return "_fpointer"  # Function pointers
    elif "const" in c_type:
        return as_racket_type(c_type.replace("const", "").strip(), prefix)
    else:
        # NOTE: Unknown types are treated as pointers for safety
        print(f"Warning: Unknown type '{c_type}', treating as pointer")
        return "_pointer"

def gen_struct(decl, prefix):
    """Generate Racket FFI struct definition using define-cstruct"""
    struct_name = check_override(decl['name'])
    racket_struct_name = f"_{as_racket_identifier(struct_name, prefix)}"
    exports = [racket_struct_name]
    
    c(decl.get('comment'))
    l(f"(define-cstruct {racket_struct_name}")
    l(f"  (")
    
    for field in decl['fields']:
        field_name = check_override(field['name'])
        field_type = check_override(f'{struct_name}.{field_name}', default=field['type'])
        
        if util.is_1d_array_type(field_type):
            array_type = util.extract_array_type(field_type)
            array_sizes = util.extract_array_sizes(field_type)
            l(f"   [{field_name} (_array {as_racket_type(array_type, prefix)} {array_sizes[0]})]")
        elif util.is_2d_array_type(field_type):
            array_type = util.extract_array_type(field_type)
            array_sizes = util.extract_array_sizes(field_type)
            l(f"   [{field_name} (_array (_array {as_racket_type(array_type, prefix)} {array_sizes[1]}) {array_sizes[0]})]")
        else:
            l(f"   [{field_name} {as_racket_type(field_type, prefix)}]")
    
    l(f"  ))")
    l("")

    return exports

def gen_enum(decl, prefix):
    """Generate Racket constants for enum values"""
    enum_name = check_override(decl['name'])
    exports = []

    # Use default value or 0 as the first value
    next_value = 0
    
    c(decl.get('comment'))
    l(f"; Enum: {enum_name}")
    
    for item in decl['items']:
        item_name = check_override(item['name'])
        if item_name != "FORCE_U32":
            racket_name = as_racket_identifier(item_name, prefix)

            # Use explicit value if provided, otherwise use sequence
            if 'value' in item:
                value = item['value']
                l(f"(define {racket_name} {value})")
                next_value = int(value) + 1  # Increment for next item
            else:
                l(f"(define {racket_name} {next_value})")
                next_value += 1
            
            exports.append(racket_name)

    return exports

def gen_consts(decl, prefix):
    """Generate constants"""
    c(decl.get('comment'))

    exports = []
    
    for item in decl['items']:
        item_name = check_override(item['name'])
        racket_name = as_racket_identifier(item_name, prefix)
        l(f"(define {racket_name} {item['value']})")
        exports.append(racket_name)
    
    l("")

    return exports

def gen_function(decl, prefix):
    """Generate Racket FFI function binding"""
    func_name = decl['name']
    racket_name = as_racket_identifier(func_name, prefix)
    
    c(decl.get('comment'))
    
    # Parse function parameters
    params = []
    for param in decl['params']:
        param_type = param['type']
        params.append(as_racket_type(param_type, prefix))
    
    # Parse return type
    ret_type = decl['type'].split('(')[0].strip()
    if ret_type == "void":
        ret_type = "_void"
    else:
        ret_type = as_racket_type(ret_type, prefix)
    
    # Generate the function definition
    l(f"(define-sokol {racket_name}")
    l(f"  (_fun {' '.join(params)} -> {ret_type}))")
    l("")

    return racket_name

def check_override(name, default=None):
    """Check if a name has an override"""
    if name in overrides:
        return overrides[name]
    elif default is None:
        return name
    else:
        return default

def check_ignore(name):
    """Check if a name should be ignored"""
    return name in ignores

def pre_parse(inp):
    """Pre-parse input to collect all types"""
    global struct_types
    global enum_types
    global enum_items
    
    for decl in inp['decls']:
        kind = decl['kind']
        if kind == 'struct':
            struct_types.append(decl['name'])
        elif kind == 'enum':
            enum_name = decl['name']
            enum_types.append(enum_name)
            enum_items[enum_name] = []
            for item in decl['items']:
                enum_items[enum_name].append(item['name'])

def gen_module_header(inp, dep_prefixes):
    """Generate module header with imports"""
    l("#lang racket/base")
    l("")
    l("(require ffi/unsafe")
    l("         ffi/unsafe/define")
    l("         ffi/unsafe/cvector")  # For array support
    l("         racket/file)")
    
    # Add type definitions
    l("")
    l("; FFI base type definitions")
    l("(define _int _int)")
    l("(define _uint8 _uint8)")
    l("(define _sint8 _sint8)")
    l("(define _uint16 _uint16)")
    l("(define _sint16 _sint16)")
    l("(define _uint32 _uint32)")
    l("(define _sint32 _sint32)")
    l("(define _uint64 _uint64)")
    l("(define _sint64 _sint64)")
    l("(define _float _float)")
    l("(define _double _double)")
    l("(define _bool _bool)")
    l("(define _byte _byte)")
    l("(define _uintptr _uintptr)")
    l("(define _intptr _intptr)")
    l("(define _size _size)")
    
    # Define special types
    l("")
    l("; Special type definitions")
    l("(define _allocator_t _pointer)")
    l("(define _image_desc _pointer)")
    l("(define _unknown_uint64_t _uint64)")
    l("(define _unknown_const _pointer)")
    l("")
    
    # Import dependencies with prefix
    if dep_prefixes:
        l("; Module dependencies")
        for dep_prefix in dep_prefixes:
            if dep_prefix in module_names:
                dep_module = module_names[dep_prefix]
                l(f"(require (prefix-in {dep_module}: \"../../sokol/generated/{dep_module}.rkt\"))")
        l("")
    
    # Library loading
    l("; Load the sokol library")
    l("(define sokol-lib")
    l("  (ffi-lib \"libsokol\" '(\"1\" \"\")")
    l("           #:fail (lambda () ")
    l("                    (error 'sokol \"Could not load sokol library\"))))")
    l("")
    l("(define-ffi-definer define-sokol sokol-lib)")
    l("")


def gen_module(inp, dep_prefixes):
    """Generate the complete module"""
    prefix = inp['prefix']
    module_name = module_names[prefix] if prefix in module_names else "sokol"
    
    # Generate module header
    gen_module_header(inp, dep_prefixes)
    
    # Track exports
    exports = []
    problematic_exports = set()  # Always keep as a set
    
    # Generate declarations
    for decl in inp['decls']:
        if decl['is_dep']:
            continue
            
        kind = decl['kind']
        if kind == 'consts':
            try:
                decl_exports = gen_consts(decl, prefix)
                if decl_exports:
                    exports.extend(decl_exports)
            except Exception as e:
                print(f"  Warning: Error generating constants: {e}")
        elif not check_ignore(decl['name']):
            if kind == 'struct':
                try:
                    decl_exports = gen_struct(decl, prefix)
                    
                    # If this is the problematic pass-action struct in gfx module
                    if prefix == 'sg_' and 'pass_action' in decl['name']:
                        struct_name = f"gfx:pass-action"
                        problematic_exports.add(struct_name)
                        problematic_exports.add(f"make-{struct_name}")
                        problematic_exports.add(f"{struct_name}?")
                        problematic_exports.add(f"set-{struct_name}!")
                        
                        # Add field accessors and setters
                        for field in ["colors", "depth", "stencil"]:
                            problematic_exports.add(f"{struct_name}-{field}")
                            problematic_exports.add(f"set-{struct_name}-{field}!")
                    
                    if decl_exports:
                        exports.extend(decl_exports)
                except Exception as e:
                    print(f"  Warning: Error generating struct {decl['name']}: {e}")
            elif kind == 'enum':
                try:
                    decl_exports = gen_enum(decl, prefix)
                    if decl_exports:
                        exports.extend(decl_exports)
                except Exception as e:
                    print(f"  Warning: Error generating enum {decl['name']}: {e}")
            elif kind == 'func':
                try:
                    func_export = gen_function(decl, prefix)
                    if func_export:
                        exports.append(func_export)
                except Exception as e:
                    print(f"  Warning: Error generating function {decl['name']}: {e}")
    
    # Generate explicit export list
    l("; Explicit export list")
    l("(provide")
    for export in exports:
        if export not in problematic_exports:
            l(f"  {export}")
    l(")")
    
    # For gfx.rkt file specifically, add special handling to avoid duplicates
    if prefix == 'sg_':
        l("")
        l(";; Special handling for gfx module to avoid duplicates")
        l("(provide (except-out (all-defined-out)")
        for item in sorted(problematic_exports):  # Sort for readability
            l(f"                  {item}")
        l("))")


def prepare():
    """Prepare output directories and create dummy C files"""
    print('=== Generating Racket bindings:')
    
    # Create output directories
    for prefix, path in output_paths.items():
        directory = os.path.dirname(path)
        if not os.path.isdir(directory):
            os.makedirs(directory)
    
    # Create necessary directories
    if not os.path.isdir('sokol-racket/src/c'):
        os.makedirs('sokol-racket/src/c')
    if not os.path.isdir('sokol-racket/include'):
        os.makedirs('sokol-racket/include')
    
    # Get absolute path to include directory
    include_dir = os.path.abspath('sokol-racket/include')
    
    # Copy header files to the include directory
    for prefix, header_path in c_header_paths.items():
        if os.path.exists(header_path):
            header_basename = os.path.basename(header_path)
            local_header_path = f'{include_dir}/{header_basename}'
            print(f"  Copying {header_path} to {local_header_path}")
            shutil.copyfile(header_path, local_header_path)
        else:
            print(f"  Warning: Header file not found: {header_path}")
    
    # Create a dependency map based on the dep_prefixes
    dependencies = {
        'sglue_': ['sg_', 'sapp_'],
        'sgl_': ['sg_'],
        'sdtx_': ['sg_'],
        'sshape_': ['sg_'],
        'simgui_': ['sg_', 'sapp_'],
    }
    
    # Create dummy source files with proper include order
    for prefix, src_path in c_source_paths.items():
        with open(src_path, 'w') as f:
            # First include dependencies
            if prefix in dependencies:
                for dep_prefix in dependencies[prefix]:
                    dep_header = os.path.basename(c_header_paths[dep_prefix])
                    f.write(f'#include "{include_dir}/{dep_header}"\n')
            
            # Then include the main header
            header_basename = os.path.basename(c_header_paths[prefix])
            f.write(f'#include "{include_dir}/{header_basename}"\n')

def gen(c_header_path, c_prefix, dep_c_prefixes):
    if not c_prefix in module_names:
        print(f' >> warning: skipping generation for {c_prefix} prefix...')
        return
        
    module_name = module_names[c_prefix]
    output_path = output_paths[c_prefix]
    c_source_path = c_source_paths[c_prefix]
    
    print(f'  {c_header_path} => {output_path}')
    
    reset_globals()
    
    # Generate IR from C header
    ir = gen_ir.gen(c_header_path, c_source_path, module_name, c_prefix, dep_c_prefixes, with_comments=True)
    
    # Generate Racket module
    gen_module(ir, dep_c_prefixes)
    
    # Write output
    with open(output_path, 'w', newline='\n') as f_outp:
        f_outp.write(out_lines)

if __name__ == '__main__':
    if os.path.basename(os.getcwd()) == 'bindgen':
        os.chdir('..')
    
    prepare()
    
    dep_map = {
        'sg_': [],
        'sapp_': ['sg_'],
        'stm_': [],
        'saudio_': [],
        'sgl_': ['sg_'],
        'sdtx_': ['sg_'],
        'sshape_': ['sg_'],
        'sglue_': ['sg_', 'sapp_'],
        'sfetch_': ['sg_'],
        'simgui_': ['sg_'],
        'slog_': [],
    }
    
    for prefix, header_path in c_header_paths.items():
        gen(header_path, prefix, dep_map.get(prefix, []))
    
    print('=== Racket bindings generated successfully')
