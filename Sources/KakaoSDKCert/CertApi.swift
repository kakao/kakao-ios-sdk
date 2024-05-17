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

import UIKit
import Foundation
import KakaoSDKCommon
import KakaoSDKAuth

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
@_exported import KakaoSDKCertCore

/// 카카오 인증서비스 API 클래스 \
/// Class for the Kakao Certification APIs
public class CertApi {
    // MARK: Fields
    
    /// 카카오 SDK 싱글톤 객체 \
    /// A singleton object for Kakao SDK
    public static let shared = CertApi()
    
    public var certWithTalkCompletionHandler : ((URL) -> Void)?
    private static let delayForHandleOpenUrl : Double = 0.1
}


// MARK:  k2100, k2220
extension CertApi {
    /// 카카오톡으로 인증 로그인 \
    /// Certification Login with Kakao Talk
    /// - parameters:
    ///   - certType: 상품 종류 \
    ///               Product type
    ///   - launchMethod: 카카오 로그인 시 앱 전환 방식 \
    ///                   Method to switch apps for Kakao Login
    ///   - prompts: 동의 화면에 상호작용 추가 요청 프롬프트 \
    ///              Prompt to add an interaction to the consent screen
    ///   - signData: 서명할 데이터 \
    ///               Data to sign
    ///   - nonce: ID 토큰 재생 공격 방지를 위한 검증 값, 임의의 문자열 \
    ///            Random strings to prevent ID token replay attacks
    ///   - settleId: 정산 ID \
    ///               Settlement ID
    ///   - identifyItems: 확인할 서명자 정보 \
    ///                    Signer information to verify
    public func certLoginWithKakaoTalk(certType: CertType,
                                       txId: String? = nil,
                                       launchMethod: LaunchMethod? = .UniversalLink,
                                       prompts: [Prompt]? = nil,
                                       channelPublicIds: [String]? = nil,
                                       serviceTerms: [String]? = nil,
                                       signData: String? = nil,
                                       nonce: String? = nil,
                                       settleId: String? = nil,
                                       identifyItems: [IdentifyItem]? = nil,
                                       completion: @escaping (CertTokenInfo?, Error?) -> Void) {
        AuthApi.shared.prepare(certType: certType, txId: txId, settleId: settleId, signData: signData, identifyItems: identifyItems) { (kauthTxId, error) in
            if let error = error {
                completion(nil, error)
            } else {
                if let kauthTxId = kauthTxId {
                    AuthController.shared._certAuthorizeWithTalk(launchMethod: launchMethod,
                                                                 prompts:prompts,
                                                                 channelPublicIds:channelPublicIds,
                                                                 serviceTerms:serviceTerms,
                                                                 nonce:nonce,
                                                                 kauthTxId: kauthTxId,
                                                                 completion:completion)
                    return
                }
                
                completion(nil, SdkError())
            }
        }
    }
    
    /// 카카오계정으로 인증 로그인 \
    /// Certification Login with Kakao Account
    /// - parameters:
    ///   - certType: 상품 종류 \
    ///               Product type
    ///   - launchMethod: 카카오 로그인 시 앱 전환 방식 \
    ///                   Method to switch apps for Kakao Login
    ///   - prompts: 동의 화면에 상호작용 추가 요청 프롬프트 \
    ///              Prompt to add an interaction to the consent screen
    ///   - loginHint: 카카오계정 로그인 페이지 ID에 자동 입력할 이메일 또는 전화번호, +82 00-0000-0000 형식 \
    ///                Email or phone number in the format +82 00-0000-0000 to fill in the ID field of the Kakao Account login page
    ///   - signData: 서명할 데이터 \
    ///               Data to sign
    ///   - nonce: ID 토큰 재생 공격 방지를 위한 검증 값, 임의의 문자열 \
    ///            Random strings to prevent ID token replay attacks
    ///   - settleId: 정산 ID \
    ///               Settlement ID
    ///   - identifyItems: 확인할 서명자 정보 \
    ///                    Signer information to verify
    public func certLoginWithKakaoAccount(certType: CertType,
                                          txId: String? = nil,
                                          prompts : [Prompt]? = nil,
                                          loginHint: String? = nil,
                                          signData: String? = nil,
                                          nonce: String? = nil,
                                          settleId: String? = nil,
                                          identifyItems: [IdentifyItem]? = nil,
                                          completion: @escaping (CertTokenInfo?, Error?) -> Void) {
        AuthApi.shared.prepare(certType: certType, txId: txId, settleId: settleId, signData: signData, identifyItems: identifyItems) { (kauthTxId, error) in
            if let error = error {
                completion(nil, error)
            } else {
                if let kauthTxId = kauthTxId {
                    AuthController.shared._certAuthorizeWithAuthenticationSession(prompts: prompts,
                                                                                  loginHint: loginHint,
                                                                                  nonce: nonce,
                                                                                  kauthTxId: kauthTxId,
                                                                                  completion:completion)
                    return
                }
                completion(nil, SdkError())
            }
        }
    }
}


//MARK: k2220 && 공통
extension CertApi {
    /// 공개 키 가져오기 \
    /// Retrieve public key
    public func publicKey(certType:CertType) -> String? {
        if (certType == .K2100) { return nil }
        
        return CertCore.shared.__publicKey(CCCertType(rawValue:certType.rawValue)!)
    }
    
    /// 세션 정보 가져오기 \
    /// Retrieve session infomation
    /// - parameters:
    ///   - txId: 전자서명 접수번호 \
    ///           Transaction ID
    /// ## SeeAlso
    /// - ``sessionInfoByAppKey(certType:txId:targetAppKey:completion:)``
    public func sessionInfo(certType: CertType, txId: String, completion:@escaping (SessionInfo?, Error?) -> Void) {
        if (certType != .K2220) {
            completion(nil, SdkError(reason: .BadParameter))
            return
        }
        
        AUTH_API.responseData(.get,
                              Urls.compose(path:Paths.sessionInfo),
                              parameters: ["tx_id": txId].filterNil(),                              
                              apiType: .KApi) { (response, data, error) in
            if let error = error {
                completion(nil, error)
            }
            else {
                if let data = data {
                    if let sessionInfo = try? SdkJSONDecoder.customIso8601Date.decode(SessionInfo.self, from: data) {
                        CertCore.shared.setSessionInfo(sessionInfo, certType:CCCertType(rawValue:certType.rawValue)!)
                        completion(sessionInfo, nil)
                        return
                    }
                }
                
                completion(nil, SdkError(apiFailedMessage: "response data is nil"))
            }
        }
    }
    
    /// 축약서명하기 \
    /// Sign for abbreviated signature
    public func reducedSign(certType:CertType, data:String, completion: @escaping (String?, Error?) -> Void) {
        if (certType == .K2100) {
            completion(nil, SdkError(reason: .BadParameter))
            return
        }
        
        CertCore.shared.__reducedSign(data: data, certType:CCCertType(rawValue:certType.rawValue)!, completion: completion)
    }
    
    /// 세션 유효성 확인하기 \
    /// Validate session
    public func isValidSession(certType:CertType) -> Bool {
        if (certType == .K2100) { return false }
        
        return CertCore.shared.__isValidSession(CCCertType(rawValue:certType.rawValue)!)
    }
    
    /// 세션 정보 가져오기 \
    /// Retrieve session infomation
    public func sessionInfo(certType:CertType) -> SessionInfo? {
        return CertCore.shared.__sessionInfo(CCCertType(rawValue:certType.rawValue)!)
    }
    
    /// 임시 키 쌍 삭제하기 \
    /// Delete key pair
    /// ## SeeAlso
    /// - ``sessionInfo``
    public func deleteKeyPair(certType:CertType) {
        CertCore.shared.__deleteKeyPair(CCCertType(rawValue:certType.rawValue)!)
    }
}

//k3220 전용
extension CertApi {
    /// 카카오톡으로 사용자 서명 가능 여부 확인 \
    /// Checks whether the Request user signature is available
    public static func isKakaoTalkSignAvailable() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string:Urls.compose(.TalkCert, path:""))!)
    }
    
    /// K3220 축약서명의 전자서명용 `returnUrl` 반환 \
    /// Returns `returnUrl` for Electronic signature of K3220 Abbreviated signature
    public static func certReturnUrl() -> String {
        return "\(try! KakaoSDK.shared.scheme())://cert"
    }
    
    /// `returnUrl` 유효성 확인 \
    /// Checks whether `returnUrl` is valid
    public static func isKakaoTalkSignReturnUrl(_ redirectUri:URL) -> Bool {
        return redirectUri.absoluteString.hasPrefix(CertApi.certReturnUrl())
    }
    
    /// K3220 축약서명의 외부로부터 리다이렉트된 요청 처리 \
    /// Handles requests redirected from K3220 Abbreviated signature
    public static func handleOpenUrl(url:URL,  options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (CertApi.isKakaoTalkSignReturnUrl(url)) {
            if let certWithTalkCompletionHandler = CertApi.shared.certWithTalkCompletionHandler {
                DispatchQueue.main.asyncAfter(deadline: .now() + CertApi.delayForHandleOpenUrl) {
                    certWithTalkCompletionHandler(url)
                }
                return true
            }
        }
        return false
    }
    
    /// 세션 정보 가져오기 \
    /// Retrieve session infomation
    /// ## SeeAlso
    /// - ``sessionInfo(certType:txId:completion:)``
    public func sessionInfoByAppKey(certType:CertType,
                                    txId:String,
                                    targetAppKey:String? = nil,
                                    completion:@escaping (SessionInfo?, Error?) -> Void) {
        
        if (certType != .K3220) {
            completion(nil, SdkError(reason: .BadParameter))
            return
        }

        var modifiedHeaders = [String:String]()
        modifiedHeaders["Authorization"] = "KakaoAK \(try! KakaoSDK.shared.appKey())"
        if let targetAppKey = targetAppKey {
            modifiedHeaders["Target-Authorization"] = "KakaoAK \(targetAppKey)"
        }
        
        API.responseData(.get,
                         Urls.compose(path:Paths.sessionInfo),
                         parameters: ["tx_id": txId].filterNil(),
                         headers: modifiedHeaders,
                         sessionType: .Api,
                         apiType: .KApi) { (response, data, error) in
            if let error = error {
                completion(nil, error)
            }
            else {
                if let data = data {
                    if let sessionInfo = try? SdkJSONDecoder.customIso8601Date.decode(SessionInfo.self, from: data) {
                        CertCore.shared.setSessionInfo(sessionInfo, certType: CCCertType(rawValue:certType.rawValue)!)
                        completion(sessionInfo, nil)
                        return
                    }
                }
                
                completion(nil, SdkError(apiFailedMessage: "response data is nil"))
            }
        }
    }
    
    /// 사용자 서명 요청하기 \
    /// Request user signature
    public func signWithKakaoTalk(certType:CertType,
                                  txId:String,
                                  targetAppKey:String? = nil,
                                  completion: @escaping (SignStatusInfo?, Error?) -> Void)
    {
        if (certType != .K3220) {
            completion(nil, SdkError(reason: .BadParameter))
            return
        }
        
        self.certWithTalkCompletionHandler = { [weak self] _ in
            
            self?._checkStatus(txId: txId, targetAppKey: targetAppKey) { signStatusInfo, error in
                if let error = error {
                    completion(nil, error)
                }
                else {
                    completion(signStatusInfo, nil)
                }
            }
        }
        
        var parameters = [String:Any]()
        parameters["tx_id"] = txId
        
        guard let url = SdkUtils.makeUrlWithParameters(url:Urls.compose(.TalkCert, path:Paths.certSignWithoutLogin),
                                                       parameters: parameters) else {
            SdkLog.e("Bad Parameter - make URL error")
            completion(nil, SdkError(reason: .BadParameter))
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { (result) in
            if (result) {
                SdkLog.i("카카오톡 실행: \(url.absoluteString)")
            }
            else {
                SdkLog.e("카카오톡 실행 실패")
                completion(nil, SdkError(reason: .NotSupported))
            }
        }
    }
}

extension CertApi {
#if swift(>=5.8)
@_documentation(visibility: private)
#endif
    //signWithKakaoTalk 내부 리퀘스트 메소드
    private func _checkStatus(txId: String,
                              targetAppKey:String? = nil,
                              completion:@escaping (SignStatusInfo?, Error?) -> Void) {

        var modifiedHeaders = [String:String]()
        modifiedHeaders["Authorization"] = "KakaoAK \(try! KakaoSDK.shared.appKey())"
        if let targetAppKey = targetAppKey {
            modifiedHeaders["Target-Authorization"] = "KakaoAK \(targetAppKey)"
        }
        
        API.responseData(.get,
                         Urls.compose(path:Paths.checkStatus),
                         parameters: ["tx_id": txId].filterNil(),
                         headers: modifiedHeaders,
                         sessionType: .Api,
                         apiType: .KApi) { (response, data, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            else {
                if let data = data {
                    if let signStatusInfo = try? SdkJSONDecoder.customIso8601Date.decode(SignStatusInfo.self, from: data) {
                        completion(signStatusInfo, nil)
                        return
                    }
                }
                
                completion(nil, SdkError(apiFailedMessage: "response data is nil"))
            }
        }
    }
}
