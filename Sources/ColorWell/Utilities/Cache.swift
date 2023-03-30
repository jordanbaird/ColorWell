//
// Cache.swift
// ColorWell
//

// MARK: - CacheContext

/// A private context used to store the value of a cache.
private class CacheContext<Value, ID: Equatable, Constructor> {
    /// The value stored by the context.
    var cachedValue: Value

    /// The identifier associated with the context.
    var id: ID

    /// The constructor function associated with the context.
    var constructor: Constructor

    /// Creates a context with the given value, identifier, and constructor.
    init(cachedValue: Value, id: ID, constructor: Constructor) {
        self.cachedValue = cachedValue
        self.id = id
        self.constructor = constructor
    }
}

// MARK: - Cache

/// A type that caches a value alongside an equatable identifier
/// that can be used to determine whether the value has changed.
struct Cache<Value, ID: Equatable> {
    /// The cache's context.
    private let context: Context

    /// The value stored by the cache.
    var cachedValue: Value {
        context.cachedValue
    }

    /// Creates a cache with the given value and identifier.
    init(_ cachedValue: Value, id: ID) {
        context = Context(cachedValue, id: id)
    }

    /// Compares the cache's stored identifier with the specified
    /// identifier, and, if the two values are different, updates
    /// the cached value using the cache's constructor.
    func recache(id: ID) {
        guard context.id != id else {
            return
        }
        context.id = id
        context.cachedValue = context.constructor(id)
    }

    /// Updates the constructor that is stored with this cache.
    func updateConstructor(_ constructor: @escaping (ID) -> Value) {
        context.constructor = constructor
    }
}

// MARK: Cache Context
extension Cache {
    /// The context for the `Cache` type.
    private class Context: CacheContext<Value, ID, (ID) -> Value> {
        /// Creates a context with the given value and identifier.
        init(_ cachedValue: Value, id: ID) {
            super.init(
                cachedValue: cachedValue,
                id: id,
                constructor: { _ in cachedValue }
            )
        }
    }
}

// MARK: - OptionalCache

/// A type that caches an optional value, and is able
/// to be recached based on whether its value is `nil`.
struct OptionalCache<Wrapped> {
    /// The cache's context.
    private let context: Context

    /// The value stored by the cache.
    var cachedValue: Wrapped? {
        context.cachedValue
    }

    /// Creates a cache with the given value.
    init(_ cachedValue: Wrapped? = nil) {
        context = Context(cachedValue)
    }

    /// Updates the the cached value using the cache's constructor.
    func recache() {
        if cachedValue == nil {
            context.cachedValue = context.constructor()
        }
    }

    /// Sets the cached value to `nil`.
    func clear() {
        context.cachedValue = nil
    }

    /// Updates the constructor that is stored with this cache.
    func updateConstructor(_ constructor: @escaping () -> Wrapped?) {
        context.constructor = constructor
    }
}

// MARK: OptionalCache Context
extension OptionalCache {
    /// The context for the `OptionalCache` type.
    private class Context: CacheContext<Wrapped?, Bool, () -> Wrapped?> {
        /// Creates a context with the given value.
        init(_ cachedValue: Wrapped?) {
            super.init(
                cachedValue: cachedValue,
                id: true,
                constructor: { cachedValue }
            )
        }
    }
}
