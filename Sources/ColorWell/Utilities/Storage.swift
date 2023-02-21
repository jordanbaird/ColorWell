//===----------------------------------------------------------------------===//
//
// Storage.swift
//
//===----------------------------------------------------------------------===//

import Foundation

// MARK: - Storage

/// A type that uses object association to store external values.
internal class Storage<Object: AnyObject, Value> {
    private let policy: AssociationPolicy

    private var key: UnsafeMutableRawPointer {
        Unmanaged.passUnretained(self).toOpaque()
    }

    /// Creates a storage object that stores external values using
    /// the specified association policy.
    init(policy: AssociationPolicy = .retainNonatomic) {
        self.policy = policy
    }

    /// Accesses the associated value for the specified object.
    func value(forObject object: Object) -> Value? {
        objc_getAssociatedObject(object, key) as? Value
    }

    /// Assigns an associated value to the specified object.
    func set(_ value: Value?, forObject object: Object) {
        objc_setAssociatedObject(object, key, value, policy.objcValue)
    }

    /// Removes the associated value for the specified object.
    func removeValue(forObject object: Object) {
        set(nil, forObject: object)
    }
}

// MARK: - AssociationPolicy

/// Available policies to use for object association.
internal enum AssociationPolicy {
    /// A weak reference to the associated object.
    case assign

    /// The associated object is copied atomically.
    case copy

    /// The associated object is copied nonatomically.
    case copyNonatomic

    /// A strong reference to the associated object that is made atomically.
    case retain

    /// A strong reference to the associated object that is made nonatomically.
    case retainNonatomic

    fileprivate var objcValue: objc_AssociationPolicy {
        switch self {
        case .assign:
            return .OBJC_ASSOCIATION_ASSIGN
        case .copy:
            return .OBJC_ASSOCIATION_COPY
        case .copyNonatomic:
            return .OBJC_ASSOCIATION_COPY_NONATOMIC
        case .retain:
            return .OBJC_ASSOCIATION_RETAIN
        case .retainNonatomic:
            return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        }
    }
}
