//
// Storage.swift
// ColorWell
//

import Foundation

// MARK: - Storage

/// A type that interfaces with a collection of value-storing contexts.
struct Storage {
    /// An object that manages the lifetime of the instance's
    /// stored contexts.
    private let lifetime: AnyObject

    /// A closure that returns the instance's stored contexts.
    private let getContexts: () -> [StorageKey: Any]

    /// A closure that updates the instance's stored contexts.
    private let setContexts: ([StorageKey: Any]) -> Void

    /// The instance's stored contexts.
    private var contexts: [StorageKey: Any] {
        get {
            getContexts()
        }
        nonmutating set {
            setContexts(newValue)
        }
    }

    /// Creates a storage instance.
    init() {
        class Lifetime<T> {
            let pointer: UnsafeMutablePointer<T>

            init(value: T) {
                pointer = .allocate(capacity: 1)
                pointer.initialize(to: value)
            }

            func getPointee() -> T {
                pointer.pointee
            }

            func setPointee(_ newValue: T) {
                pointer.pointee = newValue
            }

            deinit {
                pointer.deinitialize(count: 1)
                pointer.deallocate()
            }
        }

        let lifetime = Lifetime<[StorageKey: Any]>(value: [:])
        self.lifetime = lifetime
        self.getContexts = lifetime.getPointee
        self.setContexts = lifetime.setPointee
    }

    /// Returns the storage context for the given object and value types.
    private func context<Object: AnyObject, Value>(
        _ objectType: Object.Type,
        _ valueType: Value.Type
    ) -> StorageContext<Object, Value>? {
        contexts[StorageKey(objectType, valueType)] as? StorageContext<Object, Value>
    }

    /// Sets the storage context for the given object and value types.
    private func setContext<Object: AnyObject, Value>(
        _ context: StorageContext<Object, Value>?,
        _ objectType: Object.Type,
        _ valueType: Value.Type
    ) {
        contexts[StorageKey(objectType, valueType)] = context
    }

    /// Accesses the associated value for the specified object.
    func value<Object: AnyObject, Value>(
        ofType valueType: Value.Type = Value.self,
        forObject object: Object
    ) -> Value? {
        context(Object.self, valueType)?.value(forObject: object)
    }

    /// Accesses the associated value for the specified object, storing and
    /// returning the specified default value if no value is currently stored.
    func value<Object: AnyObject, Value>(
        ofType valueType: Value.Type = Value.self,
        forObject object: Object,
        default defaultValue: @autoclosure () -> Value
    ) -> Value {
        if let value = value(ofType: valueType, forObject: object) {
            return value
        } else {
            let value = defaultValue()
            set(value, forObject: object)
            return value
        }
    }

    /// Assigns an associated value to the specified object.
    func set<Object: AnyObject, Value>(_ value: Value?, forObject object: Object) {
        if let context = context(Object.self, Value.self) {
            context.set(value, forObject: object)
        } else {
            let context = StorageContext<Object, Value>()
            context.set(value, forObject: object)
            setContext(context, Object.self, Value.self)
        }
    }

    /// Removes the associated value for the specified object.
    func removeValue<Object: AnyObject, Value>(ofType valueType: Value.Type, forObject object: Object) {
        if let context = context(Object.self, valueType) {
            context.removeValue(forObject: object)
        }
    }
}

// MARK: - StorageKey

extension Storage {
    /// A key that contains information about the object and
    /// value types of a storage context.
    private struct StorageKey: Hashable {
        /// An integer created based on the bit pattern of a storage
        /// context's object type.
        let objectID: UInt64

        /// An integer created based on the bit pattern of a storage
        /// context's value type.
        let valueID: UInt64

        /// Creates a storage key for the given object and value types.
        init<Object: AnyObject, Value>(_: Object.Type, _: Value.Type) {
            objectID = UInt64(UInt(bitPattern: ObjectIdentifier(Object.self)))
            valueID = UInt64(UInt(bitPattern: ObjectIdentifier(Value.self)))
        }
    }
}

// MARK: - StorageContext

extension Storage {
    /// A type that uses object association to store external values.
    private class StorageContext<Object: AnyObject, Value> {
        /// A pointer that this storage context uses as a key to create
        /// and access object associations.
        private var key: UnsafeMutableRawPointer {
            Unmanaged.passUnretained(self).toOpaque()
        }

        /// Creates a storage context.
        init() { }

        /// Accesses the associated value for the specified object.
        func value(forObject object: Object) -> Value? {
            objc_getAssociatedObject(object, key) as? Value
        }

        /// Assigns an associated value to the specified object.
        func set(_ value: Value?, forObject object: Object) {
            objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        /// Removes the associated value for the specified object.
        func removeValue(forObject object: Object) {
            set(nil, forObject: object)
        }
    }
}
