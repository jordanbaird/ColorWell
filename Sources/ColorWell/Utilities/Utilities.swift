//
// Utilities.swift
// ColorWell
//

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
