//
// Cache.swift
// ColorWell
//

// MARK: - Cache

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

// MARK: - Make Thunk

/// Returns a closure that accepts a single equatable parameter
/// from a closure that has no parameters.
///
/// This conversion is necessary to satisfy type checking rules.
/// The returned closure discards its input and simply calls the
/// zero-parameter closure.
private func makeThunk<Value, ID: Equatable>(_ closure: @escaping () -> Value) -> (ID) -> Value {
    let thunk: (ID) -> Value = { _ in
        closure()
    }
    return thunk
}

// MARK: - OptionalCache

/// A type that caches an optional value, and is able
/// to be recached based on whether its value is `nil`.
class OptionalCache<Value>: Cache<Value?, Bool> {
    /// Creates a cache with the given value and constructor.
    init(_ cachedValue: Value? = nil, constructor: (() -> Value?)? = nil) {
        super.init(cachedValue, id: true, constructor: constructor.map(makeThunk))
    }

    /// Updates the constructor that is stored with this cache.
    func updateConstructor(_ constructor: @escaping () -> Value?) {
        updateConstructor(makeThunk(constructor))
    }

    /// Updates the the cached value using the cache's constructor.
    func recache() {
        recache(id: cachedValue == nil ? !id : id)
    }

    /// Sets the cached value to `nil`.
    func clear() {
        let cachedConstructor = constructor
        updateConstructor { nil }
        defer {
            updateConstructor(cachedConstructor)
        }
        recache(id: !id)
    }
}
