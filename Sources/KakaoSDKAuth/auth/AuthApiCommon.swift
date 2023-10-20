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
import Alamofire
import KakaoSDKCommon
import UIKit

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
@available(iOSApplicationExtension, unavailable)
public let AUTH_API = AuthApiCommon.shared

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
@available(iOSApplicationExtension, unavailable)
public class AuthApiCommon {
    
    public static let shared = AuthApiCommon()

    public init() {
        AUTH.checkMigration()  //for token migration
        initSession()
    }
    
    func initSession() {
        let interceptor = Interceptor(adapter: AuthRequestAdapter(), retrier: AuthRequestRetrier())
        let authApiSessionConfiguration : URLSessionConfiguration = URLSessionConfiguration.default
        authApiSessionConfiguration.tlsMinimumSupportedProtocolVersion = .TLSv12
        API.addSession(type: .AuthApi, session: Session(configuration: authApiSessionConfiguration, interceptor: interceptor))
        
        let rxAuthApiSessionConfiguration : URLSessionConfiguration = URLSessionConfiguration.default
        rxAuthApiSessionConfiguration.tlsMinimumSupportedProtocolVersion = .TLSv12
        API.addSession(type: .RxAuthApi, session: Session(configuration: rxAuthApiSessionConfiguration, interceptor: AuthRequestAdapter()))
        
        SdkLog.d(">>>> \(API.sessions)")
    }

    public func responseData(_ HTTPMethod: Alamofire.HTTPMethod,
                             _ url: String,
                             parameters: [String: Any]? = nil,
                             headers: [String: String]? = nil,
                             apiType: ApiType,
                             logging: Bool = true,
                             completion: @escaping (HTTPURLResponse?, Data?, Error?) -> Void) {
        
        API.responseData(HTTPMethod, url, parameters: parameters, headers: headers, sessionType: .AuthApi, apiType: apiType, logging: logging, completion: completion)
    }
    
    public func upload(_ HTTPMethod: Alamofire.HTTPMethod,
                       _ url: String,
                       images: [UIImage?] = [],
                       headers: [String: String]? = nil,
                       apiType: ApiType,
                       completion: @escaping (HTTPURLResponse?, Data?, Error?) -> Void) {
        API.upload(HTTPMethod, url, images:images, headers: headers, apiType: apiType, completion: completion)
    }
    
    func checkMigrationAndInitSession() {
        //nop
    }
}
