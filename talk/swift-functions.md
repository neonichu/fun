# Swift fun(ctions)

## dotSwift 2015

### Boris Bügling - @NeoNacho

![20%, original, inline](images/contentful.png)

![](images/taylor-swift.jpg)

---

# What is a function?

```swift
func add(a: Int, b: Int) -> Int {
    return a + b 
}

let f = add

f(1, 2)
// $R0: Int = 3

println(f)
// (Function)
```

![](images/swift-bg.jpg)

---

# Name mangling

```
$ xcrun swiftc func.swift 
$ nm -g func
0000000100000f10 T __TF4func3addFTSiSi_Si
[...]
$ xcrun swift-demangle __TF4func3addFTSiSi_Si
_TF4func3addFTSiSi_Si ---> func.add (Swift.Int, Swift.Int) -> Swift.Int
```

![](images/swift-bg.jpg)

---

# Memory layout

- 8 bytes => Pointer to `_TPA__TTRXFo_dSidSi_dSi_XFo_iTSiSi__iSi_`
- 8 bytes => Pointer to struct

```
_TPA__TTRXFo_dSidSi_dSi_XFo_iTSiSi__iSi_ ---> 
partial apply forwarder for reabstraction thunk helper 
[...]
```

![](images/swift-bg.jpg)

---

# Memory layout

- 16 bytes => Swift object
- 8 bytes => Pointer to `_TF6memory3addFTSiSi_Si`

__Function pointer__ 🎉

![](images/swift-bg.jpg)

---

```swift
struct f_trampoline {
    var trampoline_ptr: COpaquePointer
    var function_obj_ptr: UnsafeMutablePointer<function_obj>
}

struct function_obj {
    var some_ptr_0: COpaquePointer
    var some_ptr_1: COpaquePointer
    var function_ptr: COpaquePointer
}
```

![](images/swift-bg.jpg)

---

```swift
import Darwin

@asmname("floor") func my_floor(dbl: Double) -> Double
println(my_floor(6.7))

let handle = dlopen(nil, RTLD_NOW)
let pointer = COpaquePointer(dlsym(handle, "ceil"))

typealias FunctionType = (Double) -> Double
```

![](images/swift-bg.jpg)

---

```swift
struct f_trampoline { [...] }
struct function_obj { [...] }

let orig = unsafeBitCast(my_floor, f_trampoline.self)
let new = f_trampoline(prototype: orig, new_fp: pointer)
let my_ceil = unsafeBitCast(new, FunctionType.self)
println(my_ceil(6.7))
```

![](images/swift-bg.jpg)

---

```
$ xcrun swift -Onone hook.swift 
6.0
7.0
```

![](images/swift-bg.jpg)

---

```c
void executeFunction(void(*f)(void)) {
    f();
}
```

```swift
@asmname("executeFunction") func 
executeFunction(fp: CFunctionPointer<()->()>)
```

![](images/swift-bg.jpg)

---

```swift
func greeting() {
    println("Hello from Swift")
}

let t = unsafeBitCast(greeting, f_trampoline.self)
let fp = CFunctionPointer<()->()>
	(t.function_obj_ptr.memory.function_ptr)
executeFunction(fp)
```

```
Hello from Swift
Program ended with exit code: 0
```

![](images/swift-bg.jpg)

---

# Thank you!

### <https://github.com/neonichu/fun>

![left](images/thanks.gif)
