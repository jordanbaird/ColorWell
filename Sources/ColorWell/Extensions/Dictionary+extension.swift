//===----------------------------------------------------------------------===//
//
// DictionaryExtension.swift
//
//===----------------------------------------------------------------------===//

import Foundation

extension Dictionary where Key == ObjectIdentifier, Value: ExpressibleByArrayLiteral {
  /// Access the value for the given metatype by transforming it into
  /// an object identifier.
  ///
  /// In the event that no value is stored for `type`, an empty value
  /// will be created and returned.
  internal subscript<T>(type: T.Type) -> Value {
    get { self[ObjectIdentifier(type), default: []] }
    set { self[ObjectIdentifier(type)] = newValue }
  }
}
