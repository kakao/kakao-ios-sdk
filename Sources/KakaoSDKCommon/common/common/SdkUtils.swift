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
public class SdkUtils {
    static public func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
        guard let returnValue = object as? T else {
            throw SdkError(reason: .CastingFailed)
        }
        return returnValue
    }
    
    static public func toJsonString<T: Encodable>(_ value: T) -> String? {
        if let jsonData = try? SdkJSONEncoder.custom.encode(value) {
            return String(data:jsonData, encoding: .utf8)
        }
        else {
            return nil
        }
    }
    
    static public func toJsonObject(_ data: Data) -> [String:Any]? {
        return (try? JSONSerialization.jsonObject(with: data, options:[])) as? [String : Any]
    }
    

    static public func makeUrlStringWithParameters(_ url:String, parameters:[String:Any]?) -> String? {
        guard var components = URLComponents(string:url) else { return nil }
        components.queryItems = parameters?.urlQueryItems
        return components.url?.absoluteString
    }
    
    static public func makeUrlWithParameters(_ url:String, parameters:[String:Any]?) -> URL? {
        guard let finalStringUrl = makeUrlStringWithParameters(url, parameters:parameters) else { return nil }
        return URL(string:finalStringUrl)
    }
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension SdkUtils {
    ///launchMethod 추가 익스텐션
    static public func makeUrlWithParameters(url:String, parameters:[String:Any]?, launchMethod:LaunchMethod? = nil) -> URL? {
        if let launchMethod = launchMethod, launchMethod == .UniversalLink {
            if let customSchemeUrl = makeUrlWithParameters(url, parameters: parameters) {
                let customSchemeStringUrl = "\(customSchemeUrl.absoluteString)"
                let escapedStringUrl = customSchemeStringUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                
                let universalLinkStringUrl = "\(Urls.compose(.UniversalLink, path:Paths.universalLink))/\(escapedStringUrl ?? "")"
                return URL(string: universalLinkStringUrl)
            }
            else { return nil }
        }
        else {
            return makeUrlWithParameters(url, parameters: parameters)
        }
    }
}
