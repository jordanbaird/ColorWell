//===----------------------------------------------------------------------===//
//
// Utilities.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import Foundation

// MARK: - ComparableID

/// An identifier type that can be compared by order of creation.
///
/// For identifiers `id1` and `id2`, `id1 < id2` if `id1` was created first.
struct ComparableID {
  private static var totalCount = 0

  let root = UUID()
  let count: Int

  init() {
    defer { Self.totalCount += 1 }
    count = Self.totalCount
  }
}

extension ComparableID: Comparable {
  static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.count < rhs.count
  }
}

extension ComparableID: Equatable { }

extension ComparableID: Hashable { }

// MARK: - ChangeHandler

/// An identifiable, hashable wrapper for a change handler
/// that is executed when a color well's color changes.
///
/// This type can be compared by order of creation.
///
/// For handlers `h1` and `h2`, `h1 < h2` if `h1` was created first.
struct ChangeHandler {
  let id: ComparableID
  let handler: (NSColor) -> Void

  init(id: ComparableID, handler: @escaping (NSColor) -> Void) {
    self.id = id
    self.handler = handler
  }

  init(handler: @escaping (NSColor) -> Void) {
    self.init(id: .init(), handler: handler)
  }

  func callAsFunction(_ color: NSColor) {
    handler(color)
  }
}

extension ChangeHandler: Comparable {
  static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.id < rhs.id
  }
}

extension ChangeHandler: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
}

extension ChangeHandler: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

// MARK: - Storage

/// A type that uses object association to store external values.
class Storage<Value> {
  private let policy: AssociationPolicy

  private var key: UnsafeMutableRawPointer {
    Unmanaged.passUnretained(self).toOpaque()
  }

  /// Creates a storage object that stores values of the
  /// given type, using the provided association policy.
  init(
    _ type: Value.Type = Value.self,
    policy: @autoclosure () -> AssociationPolicy = .retain(false)
  ) {
    self.policy = policy()
  }

  /// Accesses the value for the given object.
  subscript<Object: AnyObject>(_ object: Object) -> Value? {
    get { objc_getAssociatedObject(object, key) as? Value }
    set { objc_setAssociatedObject(object, key, newValue, policy.objcValue) }
  }
}

// MARK: - AssociationPolicy

/// A type that specifies the behavior of an object association.
struct AssociationPolicy {
  fileprivate let objcValue: objc_AssociationPolicy

  private init(_ objcValue: objc_AssociationPolicy) {
    self.objcValue = objcValue
  }
}

extension AssociationPolicy {
  /// A weak reference to the associated object.
  static var assign: Self {
    .init(.OBJC_ASSOCIATION_ASSIGN)
  }

  /// The associated object is copied.
  static func copy(_ isAtomic: Bool) -> Self {
    guard isAtomic else {
      return .init(.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    return .init(.OBJC_ASSOCIATION_COPY)
  }

  /// A strong reference to the associated object.
  static func retain(_ isAtomic: Bool) -> Self {
    guard isAtomic else {
      return .init(.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    return .init(.OBJC_ASSOCIATION_RETAIN)
  }
}

#if canImport(SwiftUI)
import SwiftUI

// MARK: - ViewConstructor

@available(macOS 10.15, *)
struct ViewConstructor<Content: View>: View {
  private let content: Content

  var body: some View {
    content
  }

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  init(content: @autoclosure () -> Content) {
    self.init(content: content)
  }

  func with<Modified: View>(@ViewBuilder _ block: (Content) -> Modified) -> ViewConstructor<Modified> {
    .init(content: block(content))
  }

  func erased() -> AnyViewConstructor {
    .init(base: self)
  }
}

// MARK: - AnyViewConstructor

@available(macOS 10.15, *)
struct AnyViewConstructor: View {
  let base: any View

  var body: some View {
    AnyView(base)
  }

  init<Content: View>(base: ViewConstructor<Content>) {
    self.base = base
  }

  init<Content: View>(@ViewBuilder content: () -> Content) {
    self.init(base: .init(content: content))
  }

  init<Content: View>(content: @autoclosure () -> Content) {
    self.init(content: content)
  }
}

// MARK: - CustomCocoaConvertible

internal protocol CustomCocoaConvertible<CocoaType, Converted> {
  associatedtype CocoaType: NSObject
  associatedtype Converted: CustomCocoaConvertible = Self
  static func converted(from source: CocoaType) -> Converted
}

@available(macOS 10.15, *)
extension Color: CustomCocoaConvertible {
  internal static func converted(from source: NSColor) -> Self {
    .init(source)
  }
}

extension CGColor: CustomCocoaConvertible {
  internal static func converted(from source: NSColor) -> CGColor {
    source.cgColor
  }
}

// MARK: - StringProtocol Label

@available(macOS 10.15, *)
extension StringProtocol {
  internal var label: Text {
    .init(self)
  }
}

// MARK: - LocalizedStringKey Label

@available(macOS 10.15, *)
extension LocalizedStringKey {
  internal var label: Text {
    .init(self)
  }
}
#endif