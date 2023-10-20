//          
//    MIT License
//
//    Copyright (c) 2019 levantAJ
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Foundation

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension KeyedDecodingContainer {
    public func decode(_ type: [Any].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [Any] {
        var values = try nestedUnkeyedContainer(forKey: key)
        return try values.decode(type)
    }

    public func decode(_ type: [String: Any].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [String: Any] {
        let values = try nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
        return try values.decode(type)
    }

    public func decodeIfPresent(_ type: [Any].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [Any]? {
        guard contains(key),
            try decodeNil(forKey: key) == false else { return nil }
        return try decode(type, forKey: key)
    }

    public func decodeIfPresent(_ type: [String: Any].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [String: Any]? {
        guard contains(key),
            try decodeNil(forKey: key) == false else { return nil }
        return try decode(type, forKey: key)
    }
}

private extension KeyedDecodingContainer {
    func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        var dictionary: [String: Any] = [:]
        for key in allKeys {
            if try decodeNil(forKey: key) {
                dictionary[key.stringValue] = NSNull()
            } else if let bool = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = bool
            } else if let string = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = string
            } else if let int = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = int
            } else if let double = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = double
            } else if let dict = try? decode([String: Any].self, forKey: key) {
                dictionary[key.stringValue] = dict
            } else if let array = try? decode([Any].self, forKey: key) {
                dictionary[key.stringValue] = array
            }
        }
        return dictionary
    }
}

private extension UnkeyedDecodingContainer {
    mutating func decode(_ type: [Any].Type) throws -> [Any] {
        var elements: [Any] = []
        while !isAtEnd {
            if try decodeNil() {
                elements.append(NSNull())
            } else if let int = try? decode(Int.self) {
                elements.append(int)
            } else if let bool = try? decode(Bool.self) {
                elements.append(bool)
            } else if let double = try? decode(Double.self) {
                elements.append(double)
            } else if let string = try? decode(String.self) {
                elements.append(string)
            } else if let values = try? nestedContainer(keyedBy: AnyCodingKey.self),
                let element = try? values.decode([String: Any].self) {
                elements.append(element)
            } else if var values = try? nestedUnkeyedContainer(),
                let element = try? values.decode([Any].self) {
                elements.append(element)
            }
        }
        return elements
    }
}
