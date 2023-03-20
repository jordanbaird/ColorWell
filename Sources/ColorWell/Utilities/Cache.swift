//
// Cache.swift
// ColorWell
//

/// A type that caches a value alongside an equatable identifier
/// that can be used to determine whether the value has changed.
class Cache<Value, ID: Equatable> {
    /// The value held by the cache.
    private(set) var cachedValue: Value

    /// An equatable identifier that can be used to determine
    /// whether the cache's value has changed.
    private(set) var id: ID

    /// The cache's constructor.
    private(set) var constructor: (ID) -> Value

    /// Creates a cache with the given value, identifier, and constructor.
    init(_ cachedValue: Value, id: ID, constructor: ((ID) -> Value)? = nil) {
        self.cachedValue = cachedValue
        self.id = id
        self.constructor = constructor ?? { _ in cachedValue }
    }

    /// Updates the constructor that is stored with this cache.
    func updateConstructor(_ constructor: @escaping (ID) -> Value) {
        self.constructor = constructor
    }

    /// Compares the cache's stored identifier with the specified
    /// identifier, and, if the two values are different, updates
    /// the cached value using the cache's constructor.
    func recache(id: ID) {
        guard self.id != id else {
            return
        }
        self.id = id
        self.cachedValue = constructor(id)
    }
}

/// A property wrapper for a cached value.
@propertyWrapper
struct Cached<Value, ID: Equatable> {
    /// The underlying cache of this instance.
    let projectedValue: Cache<Value, ID>

    /// The cached value of this instance.
    var wrappedValue: Value {
        projectedValue.cachedValue
    }

    /// Creates an instance that wraps a cache for the specified
    /// value and identifier.
    init(wrappedValue: Value, id: ID) {
        projectedValue = Cache(wrappedValue, id: id)
    }
}
