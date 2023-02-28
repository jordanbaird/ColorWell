//
// Utilities.swift
// ColorWell
//

/// Returns the specified closure, after adding a layer of indirection.
internal func makeIndirect<T>(_ closure: () -> T) -> () -> T {
    let value = closure()
    return { value }
}

/// Returns the specified autoclosure, after adding a layer of indirection.
internal func makeIndirect<T>(_ closure: @autoclosure () -> T) -> () -> T {
    makeIndirect(closure)
}

/// Returns a function with the type `(A) -> C` that passes the
/// result of a function with the type `(A) -> B` into a function
/// with the type `(B) -> C`.
internal func passResult<A, B, C>(of aToB: @escaping (A) -> B, into bToC: @escaping (B) -> C) -> (A) -> C {
    let aToC = { value in
        let result = aToB(value)
        return bToC(result)
    }
    return aToC
}
