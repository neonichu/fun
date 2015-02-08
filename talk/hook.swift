#!/usr/bin/xcrun swift -Onone

import Darwin

@asmname("floor") func my_floor(dbl: Double) -> Double
println(my_floor(6.7))

let handle = dlopen(nil, RTLD_NOW)
let pointer = COpaquePointer(dlsym(handle, "ceil"))

typealias FunctionType = (Double) -> Double

struct f_trampoline {
    private var trampoline_ptr: COpaquePointer
    var function_obj_ptr: UnsafeMutablePointer<function_obj>

    init(prototype: f_trampoline, new_fp: COpaquePointer) {
        trampoline_ptr = prototype.trampoline_ptr

        function_obj_ptr = UnsafeMutablePointer<function_obj>.alloc(1)
        let fobj = function_obj(prototype: prototype.function_obj_ptr.memory, new_fp: new_fp)
        function_obj_ptr.initialize(fobj)
    }
}

struct function_obj {
    private var some_ptr_0: COpaquePointer
    private var some_ptr_1: COpaquePointer
    var function_ptr: COpaquePointer

    init(prototype: function_obj, new_fp: COpaquePointer) {
        some_ptr_0 = prototype.some_ptr_0
        some_ptr_1 = prototype.some_ptr_1
        function_ptr = new_fp
    }
}

let orig = unsafeBitCast(my_floor, f_trampoline.self)
let new_ = f_trampoline(prototype: orig, new_fp: pointer)
let my_ceil = unsafeBitCast(new_, FunctionType.self)
println(my_ceil(6.7))
