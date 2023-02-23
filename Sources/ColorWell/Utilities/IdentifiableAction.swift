//
// IdentifiableAction.swift
// ColorWell
//

import Foundation

/// An identifiable, hashable wrapper for an executable closure.
internal struct IdentifiableAction<Value> {
    /// A unique identifier for this action.
    let id: UUID

    private let body: (Value) -> Void

    /// Creates an action with the given identifier and closure.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for this action.
    ///   - body: A closure to store for later execution.
    init(id: UUID, body: @escaping (Value) -> Void) {
        self.id = id
        self.body = body
    }

    /// Creates an action from a closure.
    ///
    /// This initializer automatically creates the action's identifier.
    ///
    /// - Parameter body: A closure to store for later execution.
    init(body: @escaping (Value) -> Void) {
        self.init(id: UUID(), body: body)
    }

    /// Invokes the closure that is stored by this instance, passing the
    /// given value as an argument.
    ///
    /// - Parameter value: The value to pass into the action's closure.
    func execute(_ value: Value) {
        body(value)
    }

    /// Invokes the closure that is stored by this instance, passing the
    /// given value as an argument.
    ///
    /// Inclusion of this method enables `IdentifiableAction` instances to
    /// be called as if they were functions.
    ///
    /// ```swift
    /// let action = IdentifiableAction { (s: String) -> Void in
    ///     print(s)
    /// }
    ///
    /// action("Hello!") // Prints "Hello!"
    /// ```
    ///
    /// - Parameter value: The value to pass into the action's closure.
    func callAsFunction(_ value: Value) {
        execute(value)
    }
}

// MARK: where Value == Void
extension IdentifiableAction where Value == Void {
    /// Creates an action with the given identifier and closure.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for this action.
    ///   - body: A closure to store for later execution.
    init(id: UUID, body: @escaping () -> Void) {
        self.init(id: id, body: { _ in body() })
    }

    /// Creates an action from a closure.
    ///
    /// This initializer automatically creates the action's identifier.
    ///
    /// - Parameter body: A closure to store for later execution.
    init(body: @escaping () -> Void) {
        self.init(body: { _ in body() })
    }

    /// Invokes the closure that is stored by this instance.
    func execute() {
        body(())
    }

    /// Invokes the closure that is stored by this instance.
    ///
    /// Inclusion of this method enables `IdentifiableAction` instances to
    /// be called as if they were functions.
    ///
    /// ```swift
    /// let action = IdentifiableAction {
    ///     print("Hello!")
    /// }
    ///
    /// action() // Prints "Hello!"
    /// ```
    func callAsFunction() {
        execute()
    }
}

// MARK: Equatable
extension IdentifiableAction: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: Hashable
extension IdentifiableAction: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
