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
import KakaoSDKCommon

/// 카카오 로그인 인증서버로 API 요청을 담당하는 클래스입니다.
final public class AuthApi {
    
    /// 간편하게 API를 호출할 수 있도록 제공되는 공용 싱글톤 객체입니다.
    public static let shared = AuthApi()
    
    /// 카카오톡 으로부터 리다이렉트 된 URL 인지 체크합니다.
    public static func isKakaoTalkLoginUrl(_ url:URL) -> Bool {
        if url.absoluteString.hasPrefix(KakaoSDK.shared.redirectUri()) {
            return true
        }
        return false
    }
        
    /// 사용자가 앞서 로그인을 통해 토큰을 발급 받은 상태인지 확인합니다.
    /// 주의: 기존 토큰 존재 여부를 확인하는 기능으로, 사용자가 현재도 로그인 상태임을 보장하지 않습니다.
    public static func hasToken() -> Bool {
        return Auth.shared.tokenManager.getToken() != nil
    }
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    /// 인증코드 요청입니다.
    public func authorizeRequest(parameters:[String:Any]) -> URLRequest? {
        guard let finalUrl = SdkUtils.makeUrlWithParameters(Urls.compose(.Kauth, path:Paths.authAuthorize), parameters:parameters) else { return nil }
        return URLRequest(url: finalUrl)
    }
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    /// 추가 항목 동의 받기 요청시 인증값으로 사용되는 임시토큰 발급 요청입니다. SDK 내부 전용입니다.
    public func agt(completion:@escaping (String?, Error?) -> Void) {
        API.responseData(.post,
                                Urls.compose(.Kauth, path:Paths.authAgt),
                                parameters: ["client_id":try! KakaoSDK.shared.appKey(), "access_token":AUTH.tokenManager.getToken()?.accessToken].filterNil(),
                                sessionType:.Auth,
                                apiType: .KAuth) { (response, data, error) in
                                    if let error = error {
                                        completion(nil, error)
                                        return
                                    }
                                    
                                    if let data = data {
                                        if let json = (try? JSONSerialization.jsonObject(with:data, options:[])) as? [String: Any] {
                                            completion(json["agt"] as? String, nil)
                                            return
                                        }
                                    }
                                    
                                    completion(nil, SdkError())
                                }
    }
    
    /// 사용자 인증코드를 이용하여 신규 토큰 발급을 요청합니다.
    public func token(code: String,
                      codeVerifier: String? = nil,
                      redirectUri: String = KakaoSDK.shared.redirectUri(),
                      completion:@escaping (OAuthToken?, Error?) -> Void) {
        API.responseData(.post,
                                Urls.compose(.Kauth, path:Paths.authToken),
                                parameters: ["grant_type":"authorization_code",
                                             "client_id":try! KakaoSDK.shared.appKey(),
                                             "redirect_uri":redirectUri,
                                             "code":code,
                                             "code_verifier":codeVerifier,
                                             "ios_bundle_id":Bundle.main.bundleIdentifier,
                                             "approval_type":KakaoSDK.shared.approvalType().type].filterNil(),
                                sessionType:.Auth,
                                apiType: .KAuth) { (response, data, error) in
                                    if let error = error {
                                        completion(nil, error)
                                        return
                                    }
                                    
                                    if let data = data {
                                        if let oauthToken = try? SdkJSONDecoder.custom.decode(OAuthToken.self, from: data) {
                                            AUTH.tokenManager.setToken(oauthToken)
                                            completion(oauthToken, nil)
                                            return
                                        }
                                    }
                                    completion(nil, SdkError())
                                }
    }
    
    /// 기존 토큰을 갱신합니다.
    public func refreshToken(token oldToken: OAuthToken? = nil,
                             completion:@escaping (OAuthToken?, Error?) -> Void) {
        API.responseData(.post,
                                Urls.compose(.Kauth, path:Paths.authToken),
                                parameters: ["grant_type":"refresh_token",
                                             "client_id":try! KakaoSDK.shared.appKey(),
                                             "refresh_token":oldToken?.refreshToken ?? AUTH.tokenManager.getToken()?.refreshToken,
                                             "ios_bundle_id":Bundle.main.bundleIdentifier,
                                             "approval_type":KakaoSDK.shared.approvalType().type].filterNil(),
                                sessionType:.Auth,
                                apiType: .KAuth) { (response, data, error) in
                                    if let error = error {
                                        completion(nil, error)
                                        return
                                    }
                                    
                                    if let data = data {
                                        if let newToken = try? SdkJSONDecoder.custom.decode(Token.self, from: data) {

                                            //oauthtoken 객체가 없으면 에러가 나야함.
                                            guard let oldOAuthToken = oldToken ?? AUTH.tokenManager.getToken()
                                            else {
                                                completion(nil, SdkError(reason: .TokenNotFound))
                                                return
                                            }
                                            
                                            var newRefreshToken: String {
                                                if let refreshToken = newToken.refreshToken {
                                                    return refreshToken
                                                }
                                                else {
                                                    return oldOAuthToken.refreshToken
                                                }
                                            }
                                            
                                            var newRefreshTokenExpiresIn : TimeInterval {
                                                if let refreshTokenExpiresIn = newToken.refreshTokenExpiresIn {
                                                    return refreshTokenExpiresIn
                                                }
                                                else {
                                                    return oldOAuthToken.refreshTokenExpiresIn
                                                }
                                            }
                                            
                                            let oauthToken = OAuthToken(accessToken: newToken.accessToken,
                                                                        expiresIn: newToken.expiresIn,
                                                                        tokenType: newToken.tokenType,
                                                                        refreshToken: newRefreshToken,
                                                                        refreshTokenExpiresIn: newRefreshTokenExpiresIn,
                                                                        scope: newToken.scope,
                                                                        scopes: newToken.scopes,
                                                                        idToken: newToken.idToken)
                                            
                                            AUTH.tokenManager.setToken(oauthToken)
                                            completion(oauthToken, nil)
                                            return
                                        }
                                    }
                                    
                                    completion(nil, SdkError())
                                }
        
    }
    
    
    /// 기존 토큰을 갱신합니다.
    @available(*, deprecated, message: "use refreshToken(token:completion:) instead")
    public func refreshAccessToken(refreshToken: String? = nil,
                                   completion:@escaping (OAuthToken?, Error?) -> Void) {
    }
}


extension AuthApi {
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public func certToken(code: String,
                          codeVerifier: String? = nil,
                          redirectUri: String = KakaoSDK.shared.redirectUri(),
                          completion:@escaping (CertTokenInfo?, Error?) -> Void) {
                API.responseData(.post,
                                Urls.compose(.Kauth, path:Paths.authToken),
                                parameters: ["grant_type":"authorization_code",
                                             "client_id":try! KakaoSDK.shared.appKey(),
                                             "redirect_uri":redirectUri,
                                             "code":code,
                                             "code_verifier":codeVerifier,
                                             "ios_bundle_id":Bundle.main.bundleIdentifier,
                                             "approval_type":KakaoSDK.shared.approvalType().type].filterNil(),
                                sessionType:.Auth,
                                apiType: .KAuth) { (response, data, error) in
                                    if let error = error {
                                        completion(nil, error)
                                        return
                                    }
                                    
                                    if let data = data {
                                        if let certOauthToken = try? SdkJSONDecoder.custom.decode(CertOAuthToken.self, from: data) {
                                            let oauthToken = OAuthToken(accessToken: certOauthToken.accessToken,
                                                                        expiresIn: certOauthToken.expiresIn,
                                                                        expiredAt: certOauthToken.expiredAt,
                                                                        tokenType: certOauthToken.tokenType,
                                                                        refreshToken: certOauthToken.refreshToken,
                                                                        refreshTokenExpiresIn: certOauthToken.refreshTokenExpiresIn,
                                                                        refreshTokenExpiredAt: certOauthToken.refreshTokenExpiredAt,
                                                                        scope: certOauthToken.scope,
                                                                        scopes: certOauthToken.scopes,
                                                                        idToken: certOauthToken.idToken)
                                            
                                            if let txId = certOauthToken.txId {
                                                AUTH.tokenManager.setToken(oauthToken)
                                                
                                                let certTokenInfo = CertTokenInfo(token: oauthToken, txId: txId)
                                                completion(certTokenInfo, nil)
                                            }
                                            else {
                                                completion(nil, SdkError(reason: .Unknown, message: "certToken - txId is nil."))
                                            }
                                            return
                                        }
                                        else {
                                            completion(nil, SdkError(reason: .Unknown, message: "certToken - token parsing error."))
                                            return
                                        }
                                    }
                    
                                    completion(nil, SdkError(reason: .Unknown, message: "certToken - data is nil."))
                                }
    }
}

// MARK: for Cert Prepare
extension AuthApi {
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public func prepare(certType: CertType,
                        txId: String? = nil, //certType == .K2220 일때 not null
                        settleId: String? = nil,
                        signData: String? = nil,
                        completion: @escaping (String?, Error?) -> Void) {
        
        if certType == .K2220 {
            guard txId != nil else {
                completion(nil, SdkError(reason: .BadParameter, message: "txId is nil"))
                return
            }
        }
        
        API.responseData(.post,
                         Urls.compose(.Kauth, path: Paths.authPrepare),
                         parameters: [
                            "client_id": try! KakaoSDK.shared.appKey(),
                            "cert_type": certType.rawValue,
                            "tx_id": txId,
                            "settle_id":settleId,
                            "sign_data": signData
                            ].filterNil(),
                         sessionType: .Auth,
                         apiType: .KAuth) { (response, data, error) in
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let data = data {
                if let json = (try? JSONSerialization.jsonObject(with:data, options:[])) as? [String: Any] {
                    completion(json["kauth_tx_id"] as? String, nil)
                    return
                }
                
                completion(nil, SdkError(reason: .Unknown, message: "prepare - token parsing error."))
                return
            }
            
            completion(nil, SdkError(reason: .Unknown, message: "prepare - data is nil."))
        }
    }
}
