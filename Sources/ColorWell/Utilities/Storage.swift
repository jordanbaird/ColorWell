//
// Storage.swift
// ColorWell
//

import ObjectiveC

/// A context that uses object association to store external values
/// using the Objective-C runtime.
///
/// The object associations managed by instances of this type maintain
/// strong references to their objects, and are made non-atomically.
class Storage<Value> {
    private var key: UnsafeRawPointer {
        UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
    }

    /// Accesses the value associated with the specified object.
    func value<Object: AnyObject>(forObject object: Object) -> Value? {
        objc_getAssociatedObject(object, key) as? Value
    }

    /// Accesses the value associated with the specified object, storing
    /// and returning the given default if no value is currently stored.
    func value<Object: AnyObject>(
        forObject object: Object,
        default defaultValue: @autoclosure () -> Value
    ) -> Value {
        guard let value = value(forObject: object) else {
            let value = defaultValue()
            set(value, forObject: object)
            return value
        }
        return value
    }

    /// Associates a value with the specified object.
    func set<Object: AnyObject>(_ value: Value?, forObject object: Object) {
        objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    /// Removes the value associated with the specified object.
    func removeValue<Object: AnyObject>(forObject object: Object) {
        set(nil, forObject: object)
    }

    /// Invokes the given closure with a mutable version of the value that
    /// is associated with the specified object, falling back to the given
    /// default if no value is currently associated.
    ///
    /// A new association with the mutated value will replace the existing
    /// association.
    func withMutableValue<Object: AnyObject, Result>(
        forObject object: Object,
        default defaultValue: @autoclosure () -> Value,
        body: (inout Value) throws -> Result
    ) rethrows -> Result {
        var value = value(forObject: object) ?? defaultValue()
        defer {
            set(value, forObject: object)
        }
        return try body(&value)
    }
}
