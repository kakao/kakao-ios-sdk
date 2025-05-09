//  Copyright 2019 Kakao Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension Dictionary {
    public var queryParameters: String? {
        if self.isEmpty { return nil }
        var parts: [String] = []
        for (key, value) in self {
            let key = String(describing: key)
            let value = String(describing: value)
            
            let part = String(format: "%@=%@",
                              key.addingPercentEncoding(withAllowedCharacters: CharacterSet.fixedUrlQueryAllowed()) ?? key,
                              value.addingPercentEncoding(withAllowedCharacters: CharacterSet.fixedUrlQueryAllowed()) ?? value)
            if part == "=" { continue }
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension CharacterSet {
    public static func fixedUrlQueryAllowed() -> CharacterSet {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
    }
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension Dictionary where Key == String, Value == Any? {
    public func filterNil() -> [String:Any]? {
        let filteredNil = self.filter({ $0.value != nil }).mapValues({ $0! })
        return (!filteredNil.isEmpty) ? filteredNil : nil
    }
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension Dictionary where Key == String, Value: Any {
    public func toJsonString() -> String? {
        if let data = try? JSONSerialization.data(withJSONObject: self, options:[]) {
            return String(data:data, encoding: .utf8)
        }
        else {
            return nil
        }
    }
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
public extension Dictionary {
    mutating func merge(_ dictionary: [Key: Value]) {
        for (key, value) in dictionary {
            self[key] = value
        }
    }
}

