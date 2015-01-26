#!/usr/bin/xcrun swift

import Darwin

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
let pointer = COpaquePointer("/usr/lib/libc.dylib", "random")
println(pointer.description)
