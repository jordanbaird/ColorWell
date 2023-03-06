//
// Storage.swift
// ColorWell
//

import Foundation

/// A type that uses object association to store external values.
class Storage<Object: AnyObject, Value> {
    /// The association policy that this storage object uses to
    /// create its associations.
    private let policy: objc_AssociationPolicy

    /// A pointer that this storage object uses as a key to create
    /// and access object associations.
    private var key: UnsafeMutableRawPointer {
        Unmanaged.passUnretained(self).toOpaque()
    }

    /// Creates a storage object that stores external values using
    /// the specified association policy.
    init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        self.policy = policy
    }

    /// Accesses the associated value for the specified object.
    func value(forObject object: Object) -> Value? {
        objc_getAssociatedObject(object, key) as? Value
    }

    /// Accesses the associated value for the specified object,
    /// storing and returning the specified default value if no
    /// value is currently stored.
    func value(forObject object: Object, default defaultValue: @autoclosure () -> Value) -> Value {
        if let value = value(forObject: object) {
            return value
        } else {
            let value = defaultValue()
            set(value, forObject: object)
            return value
        }
    }

    /// Assigns an associated value to the specified object.
    func set(_ value: Value?, forObject object: Object) {
        objc_setAssociatedObject(object, key, value, policy)
    }

    /// Removes the associated value for the specified object.
    func removeValue(forObject object: Object) {
        set(nil, forObject: object)
    }
}
