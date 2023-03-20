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

    /// Accesses the value for the specified object.
    func value<Object: AnyObject>(forObject object: Object) -> Value? {
        objc_getAssociatedObject(object, key) as? Value
    }

    /// Assigns a value to the specified object.
    func set<Object: AnyObject>(_ value: Value?, forObject object: Object) {
        objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    /// Removes the value for the specified object.
    func removeValue<Object: AnyObject>(forObject object: Object) {
        set(nil, forObject: object)
    }
}
