#!/usr/bin/xcrun swift -Onone

import Darwin

private struct function_trampoline {
    private var trampoline_ptr: COpaquePointer
    var function_obj_ptr: UnsafeMutablePointer<function_obj>

    init(prototype: function_trampoline, new_fp: COpaquePointer) {
        trampoline_ptr = prototype.trampoline_ptr

        function_obj_ptr = UnsafeMutablePointer<function_obj>.alloc(1)
        let fobj = function_obj(prototype: prototype.function_obj_ptr.memory, new_fp: new_fp)
        function_obj_ptr.initialize(fobj)
    }
}

private struct function_obj {
    private var some_ptr_0: COpaquePointer
    private var some_ptr_1: COpaquePointer
    var function_ptr: COpaquePointer

    init(prototype: function_obj, new_fp: COpaquePointer) {
        some_ptr_0 = prototype.some_ptr_0
        some_ptr_1 = prototype.some_ptr_1
        function_ptr = new_fp
    }
}

extension COpaquePointer: Printable {
    public var description: String {
        let info = symbolInfo(unsafeBitCast(self, UInt.self))

        if let symInfo = info {
            let lib_name = String.fromCString(symInfo.dli_fname)!
            let func_name = String.fromCString(symInfo.dli_sname)!
            return "Function '\(func_name)' from '\(lib_name)'"
        }

        return debugDescription
    }

    public init(_ library: String, _ symbol: String) {
        let handle = dlopen(library, RTLD_NOW)
        let sym = dlsym(handle, symbol)
        self.init(sym)
    }

    // thx Mike Ash (https://github.com/mikeash/memorydumper)
    private func symbolInfo(address: UInt) -> Dl_info? {
        var info = Dl_info(dli_fname: "", dli_fbase: nil, dli_sname: "", dli_saddr: nil)
        let ptr: UnsafePointer<Void> = unsafeBitCast(address, UnsafePointer<Void>.self)
        let result = dladdr(ptr, &info)
        return (result == 0 ? nil : info)
    }
}

// # Usage
typealias FunctionFromDoubleToDouble = (Double) -> Double

@asmname("floor") func my_floor(dbl: Double) -> Double
println(my_floor(6.7))

let pointer = COpaquePointer("/usr/lib/libc.dylib", "ceil")
println(pointer.description)

private let orig_trampoline = unsafeBitCast(my_floor, function_trampoline.self)
private let new_trampoline = function_trampoline(prototype: orig_trampoline, new_fp: pointer)
let my_ceil = unsafeBitCast(new_trampoline, FunctionFromDoubleToDouble.self)
println(my_ceil(6.7))
