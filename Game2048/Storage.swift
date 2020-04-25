//
//  Storage.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 26.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation

@propertyWrapper
struct UserDefault<T: PropertyListValue> {
  let key: Key

  var wrappedValue: T? {
    get { UserDefaults.standard.value(forKey: key.rawValue) as? T }
    set { UserDefaults.standard.set(newValue, forKey: key.rawValue) }
  }
}

struct Key: RawRepresentable {
  let rawValue: String
}

extension Key: ExpressibleByStringLiteral {
  init(stringLiteral: String) {
    self.rawValue = stringLiteral
  }
}

extension Key {
  static let deviceId: Key = "deviceId"
}

struct Storage {
  @UserDefault(key: .deviceId)
  var deviceId: String?
}

// The marker protocol
protocol PropertyListValue {}

extension Data: PropertyListValue {}
extension String: PropertyListValue {}
extension Date: PropertyListValue {}
extension Bool: PropertyListValue {}
extension Int: PropertyListValue {}
extension Double: PropertyListValue {}
extension Float: PropertyListValue {}

// Every element must be a property-list type
extension Array: PropertyListValue where Element: PropertyListValue {}
extension Dictionary: PropertyListValue where Key == String, Value: PropertyListValue {}
