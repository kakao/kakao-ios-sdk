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
import UIKit

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
public class Constants {
    static public let responseType = "code"
    
    static public let kaHeader : String = generateKaHeader()
    static func generateKaHeader() -> String {
    
        let sdkVersion = KakaoSDK.shared.sdkVersion()

        let sdkType = KakaoSDK.shared.sdkType().rawValue
        
        let osVersion = UIDevice.current.systemVersion
        
        var langCode = Locale.current.languageCode
        if (Locale.preferredLanguages.count > 0) {
            if let preferredLanguage = Locale.preferredLanguages.first {                
                if let languageCode = Locale.components(fromIdentifier:preferredLanguage)[NSLocale.Key.languageCode.rawValue] {
                    langCode = languageCode
                }
            }
        }
        let countryCode = Locale.current.regionCode
        
        let lang = "\(langCode ?? "")-\(countryCode ?? "")"
        let resX = "\(Int(UIScreen.main.bounds.width))"
        let resY = "\(Int(UIScreen.main.bounds.height))"
        let device = UIDevice.current.model.replacingOccurrences(of: " ", with: "_")
        let appBundleId = Bundle.main.bundleIdentifier
        let appVersion = self.appVersion()
        let customIdentifier = KakaoSDK.shared.sdkIdentifier()?.customIdentifier
        
        let ka = "sdk/\(sdkVersion) sdk_type/\(sdkType) os/ios-\(osVersion) lang/\(lang) res/\(resX)x\(resY) device/\(device) origin/\(appBundleId ?? "") app_ver/\(appVersion ?? "")"
        
        return customIdentifier != nil ? "\(ka) \(customIdentifier!)":ka
    }
    
    static public func appVersion() -> String? {
        var appVersion = Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String
        if appVersion == nil {
            appVersion = Bundle.main.object(forInfoDictionaryKey:(kCFBundleVersionKey as String)) as? String
        }
        appVersion = appVersion?.replacingOccurrences(of: " ", with: "_")
        return appVersion
    }
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
public enum SdkType : String {
    case Swift = "swift"
    case RxSwift = "rx_swift"
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
public class ApprovalType {
    public static let shared = ApprovalType()
    public var type : String?
    
    public init() {
        self.type = nil
    }
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
public enum ApiType {
    case KApi
    case KAuth
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
public class SdkIdentifier {
    public let customIdentifier : String?
    
    public init(_ customIdentifier : String? = nil) {
        self.customIdentifier = customIdentifier
    }
}

/// 톡 간편로그인 호출 방식
public enum LaunchMethod: String {
    
    /// 커스텀 스킴
    case CustomScheme = "uri_scheme"
    
    /// 유니버셜 링크
    case UniversalLink = "universal_link"
}
