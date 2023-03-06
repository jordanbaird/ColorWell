//
// Storage.swift
// ColorWell
//

import Foundation

// MARK: - Storage

/// A type that interfaces with a collection of value-storing contexts.
struct Storage {

    // MARK: Properties

    private let lifetime: AnyObject

    private let accessors: (
        get: () -> [StorageKey: Any],
        set: ([StorageKey: Any]) -> Void
    )

    private var contexts: [StorageKey: Any] {
        get {
            accessors.get()
        }
        nonmutating set {
            accessors.set(newValue)
        }
    }

    // MARK: Initializers

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
        self.accessors = (lifetime.getPointee, lifetime.setPointee)
    }

    // MARK: Private Methods

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

    // MARK: Internal Methods

    /// Accesses the value of the given type for the specified object.
    func value<Object: AnyObject, Value>(
        ofType valueType: Value.Type = Value.self,
        forObject object: Object
    ) -> Value? {
        context(Object.self, valueType)?.value(forObject: object)
    }

    /// Accesses the value of the given type for the specified object, storing
    /// and returning the specified default value if no value is currently stored.
    func value<Object: AnyObject, Value>(
        ofType valueType: Value.Type = Value.self,
        forObject object: Object,
        default defaultValue: @autoclosure () -> Value
    ) -> Value {
        guard let value = value(ofType: valueType, forObject: object) else {
            let value = defaultValue()
            set(value, forObject: object)
            return value
        }
        return value
    }

    /// Assigns a value to the specified object.
    func set<Object: AnyObject, Value>(_ value: Value?, forObject object: Object) {
        if let context = context(Object.self, Value.self) {
            context.set(value, forObject: object)
        } else {
            let context = StorageContext<Object, Value>()
            context.set(value, forObject: object)
            setContext(context, Object.self, Value.self)
        }
    }

    /// Removes the value of the given type for the specified object.
    func removeValue<Object: AnyObject, Value>(ofType valueType: Value.Type, forObject object: Object) {
        if let context = context(Object.self, valueType) {
            context.removeValue(forObject: object)
        }
    }
}

// MARK: - StorageKey

extension Storage {
    /// A key created from the `Object` and `Value` types of a storage
    /// context, enabling efficient lookup based on the type of value
    /// being retrieved, and the type of object that is retrieving it.
    private struct StorageKey: Hashable {
        let objectKey: UInt64
        let valueKey: UInt64

        init<Object: AnyObject, Value>(_ objectType: Object.Type, _ valueType: Value.Type) {
            objectKey = UInt64(UInt(bitPattern: ObjectIdentifier(objectType)))
            valueKey = UInt64(UInt(bitPattern: ObjectIdentifier(valueType)))
        }
    }
}

// MARK: - StorageContext

extension Storage {
    /// A context that uses object association to store external values.
    private class StorageContext<Object: AnyObject, Value> {
        private var key: UnsafeRawPointer {
            UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        }

        func value(forObject object: Object) -> Value? {
            objc_getAssociatedObject(object, key) as? Value
        }

        func set(_ value: Value?, forObject object: Object) {
            objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        func removeValue(forObject object: Object) {
            set(nil, forObject: object)
        }
    }
}
