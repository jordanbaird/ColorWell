//
// Utilities.swift
// ColorWell
//

/// Returns the given closure, adding an additional layer
/// of indirection.
internal func makeIndirect<T>(_ closure: () -> T) -> () -> T {
    let value = closure()
    return { value }
}

/// Returns the given autoclosure, adding an additional layer
/// of indirection.
internal func makeIndirect<T>(_ closure: @autoclosure () -> T) -> () -> T {
    makeIndirect(closure)
}
