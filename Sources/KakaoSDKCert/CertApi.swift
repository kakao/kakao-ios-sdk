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

/// 카카오 인증서비스를 위한 Api 입니다.
public class CertApi {
    // MARK: Fields
    
    /// 간편하게 API를 호출할 수 있도록 제공되는 공용 싱글톤 객체입니다.
    public static let shared = CertApi()
}


// MARK:  k2100, k2220
extension CertApi {
    /// 앱투앱(App-to-App) 방식 카카오톡 인증 로그인을 실행합니다.
    /// 카카오톡을 실행하고, 카카오톡에 연결된 카카오계정으로 사용자 인증 후 동의 및 전자서명을 거쳐 [CertTokenInfo]을 반환합니다.
    /// - note: launchMethod가 .UniversalLink 일 경우 카카오톡 실행가능 상태체크는 필수가 아닙니다.
    /// - parameters:
    ///   - launchMethod: 카카오톡 간편로그인 앱 전환 방식 선택  { CustomScheme, .UniversalLink(Default) }
    ///   - prompts: 동의 화면 요청 시 추가 상호작용을 요청하고자 할 때 전달, 사용할 수 있는 옵션의 종류는 [Prompt] 참고
    ///   - state: 카카오 로그인 과정 중 동일한 값을 유지하는 임의의 문자열(정해진 형식 없음)
    ///   - nonce: ID 토큰 재생 공격을 방지하기 위해, ID 토큰 검증 시 사용할 임의의 문자열(정해진 형식 없음)
    ///   - settleId: 정산 ID
    public func certLoginWithKakaoTalk(certType: CertType,
                                       txId: String? = nil,
                                       launchMethod: LaunchMethod? = .UniversalLink,
                                       prompts: [Prompt]? = nil,
                                       channelPublicIds: [String]? = nil,
                                       serviceTerms: [String]? = nil,
                                       signData: String? = nil,
                                       nonce: String? = nil,
                                       settleId: String? = nil,
                                       completion: @escaping (CertTokenInfo?, Error?) -> Void) {
        AuthApi.shared.prepare(certType: certType, txId: txId, settleId: settleId, signData: signData) { (kauthTxId, error) in
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
    
    /// 채널 메시지 방식 카카오톡 인증 로그인을 실행합니다.
    /// 기본 브라우저의 카카오계정 쿠키(cookie)로 사용자 인증 후, 카카오계정에 연결된 카카오톡으로 카카오톡 인증 로그인을 요청하는 채널 메시지를 발송합니다.
    /// 카카오톡의 채널 메시지를 통해 동의 및 전자서명을 거쳐 [CertTokenInfo]을 반환합니다.
    /// - parameters:
    ///   - prompts: 동의 화면 요청 시 추가 상호작용을 요청하고자 할 때 전달, 사용할 수 있는 옵션의 종류는 [Prompt] 참고
    ///   - loginHint: 카카오계정 로그인 페이지의 ID에 자동 입력할 이메일 또는 전화번호
    ///   - state: 카카오 로그인 과정 중 동일한 값을 유지하는 임의의 문자열(정해진 형식 없음)
    ///   - nonce: ID 토큰 재생 공격을 방지하기 위해, ID 토큰 검증 시 사용할 임의의 문자열(정해진 형식 없음)
    ///   - settleId: 정산 ID
    public func certLoginWithKakaoAccount(certType: CertType,
                                          txId: String? = nil,
                                          prompts : [Prompt]? = nil,
                                          loginHint: String? = nil,
                                          signData: String? = nil,
                                          nonce: String? = nil,
                                          settleId: String? = nil,
                                          completion: @escaping (CertTokenInfo?, Error?) -> Void) {
        AuthApi.shared.prepare(certType: certType, txId: txId, settleId: settleId, signData: signData) { (kauthTxId, error) in
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

//MARK:  k2220
extension CertApi {
    /// 공개키를 반환합니다. 공개키가 없다면 임시 키 쌍 생성 및 세션 정보 초기화 후 공개키를 반환합니다.
    public func publicKey() -> String? {
        return CertCore.shared.__publicKey()
    }
    
    /// 생성된 임시 키 쌍의 유효성 확인 후 세션 정보를 반환합니다.
    /// ## SeeAlso
    /// - ``sessionInfo``
    public func sessionInfo(txId: String, completion:@escaping (SessionInfo?, Error?) -> Void) {
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
                        CertCore.shared.setSessionInfo(sessionInfo: sessionInfo)
                        completion(sessionInfo, nil)
                        return
                    }
                }
                
                completion(nil, SdkError(apiFailedMessage: "response data is nil"))
            }
        }
    }
    
    /// 유효한 개인키로 서명한 전자서명 값을 반환합니다.
    public func sign(data:String, completion: @escaping (String?, Error?) -> Void) {
        CertCore.shared.__sign(data: data, completion: completion)
    }
    
    /// 세션이 유효한지 확인합니다.
    public func isValidSession() -> Bool {
        return CertCore.shared.__isValidSession()
    }
    
    /// 세션 정보를 반환합니다.
    public func sessionInfo() -> SessionInfo? {
        return CertCore.shared.__sessionInfo()
    }
    
    /// 임시 키 쌍을 삭제합니다. 세션 정보도 함께 삭제됩니다.
    /// ## SeeAlso
    /// - ``sessionInfo``
    public func deleteKeyPair() {
        CertCore.shared.__deleteKeyPair()
    }
}
