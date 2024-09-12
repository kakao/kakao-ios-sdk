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

/// 주요 설정 및 초기화 클래스 \
/// Class for major settings and initializing
///## SeeAlso
///- [초기화](https://developers.kakao.com/docs/latest/ko/ios/getting-started#init) \
///  [Initialize](https://developers.kakao.com/docs/latest/en/ios/getting-started#init)
final public class KakaoSDK {
    
    // MARK: Fields
    
    //static 라이브러리용 버전.
    private let _version = "2.22.7"
    
    /// 카카오 SDK 싱글톤 객체 \
    /// A singleton object for Kakao SDK
    public static let shared = KakaoSDK()
    
    private var _appKey : String? = nil
    private var _customScheme : String? = nil
    private var _loggingEnable : Bool = false
    
    private var _hosts : Hosts? = nil
    
    private var _approvalType : ApprovalType? = nil
    
    private var _sdkType : SdkType!
    
    private var _sdkIdentifier : SdkIdentifier? = nil
    
    public init() {
        _appKey = nil
        _customScheme = nil
    }
    
    // MARK: Initializers
    
    /// Kakao SDK 초기화 \
    /// Initializes Kakao SDK
    /// - parameters:
    ///   - appKey: 앱 키 \
    ///             App key
    ///   - loggingEnable: Kakao SDK 내부 로그 기능 활성화 여부 \
    ///                    Whether to enable the internal log of the Kakao SDK
    
    public static func initSDK(appKey: String,
                               customScheme: String? = nil,
                               loggingEnable: Bool = false,
                               hosts: Hosts? = nil,
                               approvalType: ApprovalType? = nil,
                               sdkIdentifier: SdkIdentifier? = nil) {
        KakaoSDK.shared.initialize(appKey: appKey,
                                   customScheme:customScheme,
                                   loggingEnable: loggingEnable,
                                   hosts: hosts,
                                   approvalType: approvalType,
                                   sdkIdentifier: sdkIdentifier,
                                   sdkType: .Swift)
    }
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public func initialize(appKey: String,
                           customScheme: String? = nil,
                           loggingEnable: Bool = false,
                           hosts: Hosts? = nil,
                           approvalType: ApprovalType? = nil,
                           sdkIdentifier: SdkIdentifier? = nil,
                           sdkType: SdkType) {
        _appKey = appKey
        _customScheme = customScheme
        _loggingEnable = loggingEnable
        _hosts = hosts
        _approvalType = approvalType
        _sdkIdentifier = sdkIdentifier
        _sdkType = sdkType
        
        SdkLog.shared.clearLog()        
    }
    
    /// Kakao SDK 버전 조회 \
    /// Returns the version of Kakao SDK
    public func sdkVersion() -> String {
        return _version
    }
    
    /// 초기화 시 설정된 로깅 여부 조회 \
    /// Returns whether logging is enabled
    /// ## SeeAlso
    /// - ``SdkLog``
    public func isLoggingEnable() -> Bool {
        return _loggingEnable
    }
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public func hosts() -> Hosts {
        return _hosts != nil ? _hosts! : Hosts.shared
    }
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public func approvalType() -> ApprovalType {
        return _approvalType != nil ? _approvalType! : ApprovalType.shared
    }
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public func sdkType() -> SdkType {
        return _sdkType != nil ? _sdkType : .Swift
    }
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public func scheme() throws -> String {
        guard _appKey != nil else {
            throw SdkError(reason: .MustInitAppKey)
        }
        return _customScheme ?? "kakao\(_appKey!)"
    }
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public func sdkIdentifier() -> SdkIdentifier? {
        return _sdkIdentifier
    }
}

extension KakaoSDK {
    /// 초기화 시 설정된 앱 키 조회 \
    /// Returns the app key used to initialize
    /// - throws: ``ClientFailureReason/MustInitAppKey``: SDK가 초기화되지 않았습니다. 앱키를 가져오기 전에 initSDK를 이용하여 먼저 싱글톤 인스턴스를 초기화해야 합니다.
    public func appKey() throws -> String {
        guard _appKey != nil else {
            throw SdkError(reason: .MustInitAppKey)
        }
        return _appKey!
    }
    
    /// KA 헤더 조회 \
    /// Returns KA header
    public func kaHeader() -> String {
        return Constants.kaHeader
    }
    
    /// 리다이렉트 URI 조회 \
    /// Returns the redirect URI
    public func redirectUri() -> String {
        return "\(try! self.scheme())://oauth"
    }
}
