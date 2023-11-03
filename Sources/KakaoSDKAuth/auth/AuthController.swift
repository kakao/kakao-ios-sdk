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
import SafariServices
import AuthenticationServices
import KakaoSDKCommon

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
@available(iOSApplicationExtension, unavailable)
let AUTH_CONTROLLER = AuthController.shared

/// 동의 화면 요청 시 추가 상호작용을 요청할 때 사용
public enum Prompt : String {
    
    /// 기존 사용자 인증 여부와 상관없이 사용자에게 카카오계정 로그인 화면을 출력하여 다시 사용자 인증을 수행하고자 할 때 사용
    case Login = "login"
    
    /// 인증 로그인을 요청할 때 사용
    case Cert = "cert"
    
    /// 사용자가 카카오계정 신규 가입 후 로그인하도록 할 때 사용
    case Create = "create"
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    case UnifyDaum = "unify_daum"
    
    /// 카카오계정 간편 로그인을 요청할 때 사용
    case SelectAccount = "select_account"
}

@available(iOS 13.0, *)
@available(iOSApplicationExtension, unavailable)
class DefaultPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.sdkKeyWindow() ?? ASPresentationAnchor()
    }
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
@available(iOSApplicationExtension, unavailable)
public class AuthController {
    
    // MARK: Fields
    
    /// 간편하게 API를 호출할 수 있도록 제공되는 공용 싱글톤 객체입니다.
    public static let shared = AuthController()
   
    public var presentationContextProvider: Any?
    
    public var authenticationSession : ASWebAuthenticationSession?
    
    public var authorizeWithTalkCompletionHandler : ((URL) -> Void)?

    static public func isValidRedirectUri(_ redirectUri:URL) -> Bool {
        return redirectUri.absoluteString.hasPrefix(KakaoSDK.shared.redirectUri())
    }
    
    //PKCE Spec
    public var codeVerifier : String?
    
    //내부 디폴트브라우져용 time delay
    public static let delayForAuthenticationSession : Double = 0.4
    
    public init() {
        AUTH_API.checkMigrationAndInitSession()
        
        resetCodeVerifier()
        
        if #available(iOS 13.0, *) {
            self.presentationContextProvider = DefaultPresentationContextProvider()
        }
        else {
            self.presentationContextProvider = nil
        }
    }
    
    public func resetCodeVerifier() {
        self.codeVerifier = nil
    }
    
    // MARK: Login with KakaoTalk
    public func _authorizeWithTalk(launchMethod: LaunchMethod? = nil,
                                  prompts: [Prompt]? = nil,
                                  state: String? = nil,
                                  channelPublicIds: [String]? = nil,
                                  serviceTerms: [String]? = nil,
                                  nonce: String? = nil,
                                  completion: @escaping (OAuthToken?, Error?) -> Void) {
        
        AUTH_CONTROLLER.authorizeWithTalkCompletionHandler = { (callbackUrl) in
            let parseResult = callbackUrl.oauthResult()
            if let code = parseResult.code {
                AuthApi.shared.token(code: code, codeVerifier: self.codeVerifier) { (token, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    else {
                        if let token = token {
                            completion(token, nil)
                            return
                        }
                    }
                }
            }
            else {
                let error = parseResult.error ?? SdkError(reason: .Unknown, message: "Failed to parse redirect URI.")
                SdkLog.e("Failed to parse redirect URI.")
                completion(nil, error)
                return
            }
        }
        
        let parameters = self.makeParametersForTalk(prompts:prompts,
                                                    state:state,
                                                    channelPublicIds: channelPublicIds,
                                                    serviceTerms: serviceTerms,
                                                    nonce:nonce,
                                                    launchMethod:launchMethod)

        guard let url = SdkUtils.makeUrlWithParameters(url:Urls.compose(.TalkAuth, path:Paths.authTalk),
                                                       parameters: parameters,
                                                       launchMethod: launchMethod) else {
            SdkLog.e("Bad Parameter - make URL error")
            completion(nil, SdkError(reason: .BadParameter))
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { (result) in
            if (result) {
                SdkLog.i("카카오톡 실행: \(url.absoluteString)")
            }
            else {
                //유니버셜링크 방식일때 톡이 설치되어 있지만 톡을 실행하지 못하는 현상 대응
                if launchMethod == .UniversalLink {
                    self._retryOpen(withLaunchMethod:.CustomScheme, parameters: parameters, completion: completion)
                }
                else {
                    SdkLog.e("카카오톡 실행 실패")
                    completion(nil, SdkError(reason: .NotSupported))
                    return
                }
            }
        }
    }
    
    func _retryOpen(withLaunchMethod:LaunchMethod, parameters:[String:Any], completion: @escaping (OAuthToken?, Error?) -> Void) {
        var modifiedParameters = [String:Any]()
        
        for (key, value) in parameters {
            if key == "deep_link_method" {
                modifiedParameters[key] = "\(value),\(withLaunchMethod.rawValue)"
            }    
            else {
                modifiedParameters[key] = value
            }
        }

        guard let url = SdkUtils.makeUrlWithParameters(url:Urls.compose(.TalkAuth, path:Paths.authTalk),
                                                       parameters: modifiedParameters,
                                                       launchMethod: withLaunchMethod) else {
            SdkLog.e("(\(withLaunchMethod) retry) Bad Parameter - make URL error")
            completion(nil, SdkError(reason: .BadParameter, message:"(\(withLaunchMethod) retry) Bad Parameter - make URL error"))
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { (result) in
            if (result) {
                SdkLog.i("(\(withLaunchMethod) retry) 카카오톡 실행: \(url.absoluteString)")
            }
            else {
                SdkLog.e("(\(withLaunchMethod) retry) 카카오톡 실행 실패 \n url:\(url.absoluteString)")
               completion(nil, SdkError(reason: .NotSupported, message: "(\(withLaunchMethod) retry) KakaoTalk launch failed."))
               return
            }
        }
    }
    
    /// **카카오톡 간편로그인** 등 외부로부터 리다이렉트 된 코드요청 결과를 처리합니다.
    /// AppDelegate의 openURL 메소드 내에 다음과 같이 구현해야 합니다.
    ///
    /// ```
    /// func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    ///     if (AuthController.isKakaoTalkLoginUrl(url)) {
    ///         if AuthController.handleOpenUrl(url: url, options: options) {
    ///             return true
    ///         }
    ///     }
    ///     // 서비스의 나머지 URL 핸들링 처리
    /// }
    /// ```
    public static func handleOpenUrl(url:URL,  options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthController.isValidRedirectUri(url)) {
            if let authorizeWithTalkCompletionHandler = AUTH_CONTROLLER.authorizeWithTalkCompletionHandler {
                authorizeWithTalkCompletionHandler(url)
            }
        }
        return false
    }
    
    public func _authorizeByAgtWithAuthenticationSession(scopes:[String],
                                                         state: String? = nil,
                                                         nonce: String? = nil,
                                                         completion: @escaping (OAuthToken?, Error?) -> Void) {
        
        AuthApi.shared.agt { [weak self] (agtToken, error) in
            guard let strongSelf = self else {
                completion(nil, SdkError()) //내부에러
                return
            }
            
            if let error = error {
                completion(nil, error)
                return
            }
            else {
                strongSelf._authorizeWithAuthenticationSession(state:state, agtToken: agtToken, scopes: scopes, nonce:nonce) { (oauthToken, error) in
                    if let topVC = UIApplication.getMostTopViewController() {
                        let topVCName = "\(type(of: topVC))"
                        SdkLog.d("top vc: \(topVCName)")
                        
                        if topVCName == "SFAuthenticationViewController" {
                            DispatchQueue.main.asyncAfter(deadline: .now() + AuthController.delayForAuthenticationSession) {
                                if let topVC1 = UIApplication.getMostTopViewController() {
                                    let topVCName1 = "\(type(of: topVC1))"
                                    SdkLog.d("top vc: \(topVCName1)")
                                }
                                completion(oauthToken, error)
                            }
                        }
                        else {
                            SdkLog.d("top vc: \(topVCName)")
                            completion(oauthToken, error)
                        }
                    }
                }
            }
        }
    }
    
    public func _authorizeWithAuthenticationSession(prompts: [Prompt]? = nil,
                                                    state: String? = nil,
                                                    agtToken: String? = nil,
                                                    scopes:[String]? = nil,
                                                    channelPublicIds: [String]? = nil,
                                                    serviceTerms: [String]? = nil,
                                                    loginHint: String? = nil,
                                                    accountParameters: [String:String]? = nil,
                                                    nonce: String? = nil,
                                                    accountsSkipIntro: Bool? = nil,
                                                    accountsTalkLoginVisible: Bool? = nil,
                                                    completion: @escaping (OAuthToken?, Error?) -> Void) {
        
        let authenticationSessionCompletionHandler : (URL?, Error?) -> Void = {
            [weak self] (callbackUrl:URL?, error:Error?) in
            
            guard let callbackUrl = callbackUrl else {
                if let error = error as? ASWebAuthenticationSessionError {
                    if error.code == ASWebAuthenticationSessionError.canceledLogin {
                        SdkLog.e("The authentication session has been canceled by user.")
                        completion(nil, SdkError(reason: .Cancelled, message: "The authentication session has been canceled by user."))
                        return
                    }
                    else {
                        SdkLog.e("An error occurred on executing authentication session.\n reason: \(error)")
                        completion(nil, SdkError(reason: .Unknown, message: "An error occurred on executing authentication session."))
                        return
                    }
                }
                else {
                    SdkLog.e("An unknown authentication session error occurred.")
                    completion(nil, SdkError(reason: .Unknown, message: "An unknown authentication session error occurred."))
                    return
                }
            }
            
            SdkLog.d("callback url: \(callbackUrl)")
            
            let parseResult = callbackUrl.oauthResult()
            if let code = parseResult.code {
                SdkLog.i("code:\n \(String(describing: code))\n\n" )
                
                AuthApi.shared.token(code: code, codeVerifier: self?.codeVerifier) { (token, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    else {
                        if let token = token {
                            completion(token, nil)
                            return
                        }
                    }
                }
            }
            else {
                let error = parseResult.error ?? SdkError(reason: .Unknown, message: "Failed to parse redirect URI.")
                SdkLog.e("redirect URI error: \(error)")
                completion(nil, error)
                return
            }
        }
        
        let parameters = self.makeParameters(prompts: prompts,
                                             state: state,
                                             agtToken: agtToken,
                                             scopes: scopes,
                                             channelPublicIds: channelPublicIds,
                                             serviceTerms: serviceTerms,
                                             loginHint: loginHint,
                                             nonce: nonce,
                                             accountsSkipIntro: accountsSkipIntro,
                                             accountsTalkLoginVisible: accountsTalkLoginVisible)
        
        var url: URL? = SdkUtils.makeUrlWithParameters(Urls.compose(.Kauth, path:Paths.authAuthorize), parameters:parameters)
        
        if let accountParameters = accountParameters, !accountParameters.isEmpty {
            var _parameters = [String:Any]()
            for (key, value) in accountParameters {
                _parameters[key] = value
            }
            _parameters["continue"] = url?.absoluteString
            url = SdkUtils.makeUrlWithParameters(Urls.compose(.Auth, path:Paths.kakaoAccountsLogin), parameters:_parameters)
        }
        
        if let url = url {
            SdkLog.d("\n===================================================================================================")
            SdkLog.i("request: \n url:\(url)\n")
            
            let authenticationSession = ASWebAuthenticationSession(url: url,
                                                                   callbackURLScheme: (try! KakaoSDK.shared.scheme()),
                                                                   completionHandler:authenticationSessionCompletionHandler)
            
            authenticationSession.presentationContextProvider = AUTH_CONTROLLER.presentationContextProvider as? ASWebAuthenticationPresentationContextProviding
            if agtToken != nil {
                authenticationSession.prefersEphemeralWebBrowserSession = true
            }            
            AUTH_CONTROLLER.authenticationSession = authenticationSession
            AUTH_CONTROLLER.authenticationSession?.start()
        }
    }
}

@available(iOSApplicationExtension, unavailable)
extension AuthController {
    //Rx 공통 Helper
    
    public func makeParametersForTalk(prompts: [Prompt]? = nil,
                                      state: String? = nil,
                                      channelPublicIds: [String]? = nil,
                                      serviceTerms: [String]? = nil,
                                      nonce: String? = nil,
                                      settleId: String? = nil,
                                      kauthTxId: String? = nil,
                                      launchMethod: LaunchMethod? = nil) -> [String:Any] {
        self.resetCodeVerifier()
        
        var parameters = [String:Any]()
        parameters["client_id"] = try! KakaoSDK.shared.appKey()
        parameters["redirect_uri"] = KakaoSDK.shared.redirectUri()
        parameters["response_type"] = Constants.responseType
        parameters["headers"] = ["KA": Constants.kaHeader].toJsonString()
        
        if let launchMethod = launchMethod {
            parameters["deep_link_method"] = launchMethod.rawValue
        }
        
        var extraParameters = [String: Any]()
        
        if let prompts = prompts {
            let promptsValues : [String]? = prompts.map { $0.rawValue }
            if let prompt = promptsValues?.joined(separator: ",") {
                extraParameters["prompt"] = prompt
            }
        }
        if let state = state {
            extraParameters["state"] = state
        }
        if let channelPublicIds = channelPublicIds?.joined(separator: ",") {
            extraParameters["channel_public_id"] = channelPublicIds
        }
        if let serviceTerms = serviceTerms?.joined(separator: ",")  {
            extraParameters["service_terms"] = serviceTerms
        }
        if let nonce = nonce {
            extraParameters["nonce"] = nonce
        }
        if let settleId = settleId {
            extraParameters["settle_id"] = settleId
        }
        if let kauthTxId = kauthTxId {
            extraParameters["kauth_tx_id"] = kauthTxId
        }
        if let approvalType = KakaoSDK.shared.approvalType().type {
            extraParameters["approval_type"] = approvalType
        }
        
        self.codeVerifier = SdkCrypto.shared.generateCodeVerifier()
        
        if let codeVerifier = self.codeVerifier {
            SdkLog.d("code_verifier: \(codeVerifier)")
            if let codeChallenge = SdkCrypto.shared.sha256(string:codeVerifier) {
                extraParameters["code_challenge"] = SdkCrypto.shared.base64url(data:codeChallenge)
                SdkLog.d("code_challenge: \(SdkCrypto.shared.base64url(data:codeChallenge))")
                extraParameters["code_challenge_method"] = "S256"
            }
        }
        
        if !extraParameters.isEmpty {
            parameters["params"] = extraParameters.toJsonString()
        }
        
        return parameters
    }
    
    
    public func makeParameters(prompts : [Prompt]? = nil,
                               state: String? = nil,
                               agtToken: String? = nil,
                               scopes:[String]? = nil,
                               channelPublicIds: [String]? = nil,
                               serviceTerms: [String]? = nil,
                               loginHint: String? = nil,
                               nonce: String? = nil,
                               accountsSkipIntro: Bool? = nil,
                               accountsTalkLoginVisible: Bool? = nil,
                               settleId: String? = nil,
                               kauthTxId: String? = nil) -> [String:Any] {
        self.resetCodeVerifier()
        
        var parameters = [String:Any]()
        parameters["client_id"] = try! KakaoSDK.shared.appKey()
        parameters["redirect_uri"] = KakaoSDK.shared.redirectUri()
        parameters["response_type"] = Constants.responseType
        parameters["ka"] = Constants.kaHeader
        
        if let approvalType = KakaoSDK.shared.approvalType().type {
            parameters["approval_type"] = approvalType
        }
        
        if let agt = agtToken {
            parameters["agt"] = agt
            
            if let scopes = scopes {
                parameters["scope"] = scopes.joined(separator:" ")
            }
        }
        
        if let prompts = prompts {
            let promptsValues : [String]? = prompts.map { $0.rawValue }
            if let prompt = promptsValues?.joined(separator: ",") {
                parameters["prompt"] = prompt
            }
        }
        
        if let state = state {
            parameters["state"] = state
        }
        
        if let channelPublicIds = channelPublicIds?.joined(separator: ",") {
            parameters["channel_public_id"] = channelPublicIds
        }
        
        if let serviceTerms = serviceTerms?.joined(separator: ",")  {
            parameters["service_terms"] = serviceTerms
        }
        
        if let loginHint = loginHint {
            parameters["login_hint"] = loginHint
        }
        
        if let nonce = nonce {
            parameters["nonce"] = nonce
        }
        
        if let accountsSkipIntro = accountsSkipIntro {
            parameters["accounts_skip_intro"] = accountsSkipIntro
        }
        
        if let accountsTalkLoginVisible = accountsTalkLoginVisible {
            parameters["accounts_talk_login_visible"] = accountsTalkLoginVisible
        }
        
        if let settleId = settleId {
            parameters["settle_id"] = settleId
        }
        
        if let kauthTxId = kauthTxId {
            parameters["kauth_tx_id"] = kauthTxId
        }
        
        self.codeVerifier = SdkCrypto.shared.generateCodeVerifier()
        if let codeVerifier = self.codeVerifier {
            SdkLog.d("code_verifier: \(codeVerifier)")
            if let codeChallenge = SdkCrypto.shared.sha256(string:codeVerifier) {
                parameters["code_challenge"] = SdkCrypto.shared.base64url(data:codeChallenge)
                SdkLog.d("code_challenge: \(SdkCrypto.shared.base64url(data:codeChallenge))")
                parameters["code_challenge_method"] = "S256"
            }
        }
        
        return parameters
    }
}

// MARK: Cert Login
@available(iOSApplicationExtension, unavailable)
extension AuthController {

    public func _certAuthorizeWithTalk(launchMethod: LaunchMethod? = nil,
                                       prompts: [Prompt]? = nil,
                                       channelPublicIds: [String]? = nil,
                                       serviceTerms: [String]? = nil,
                                       nonce: String? = nil,
                                       kauthTxId: String? = nil,
                                       completion: @escaping (CertTokenInfo?, Error?) -> Void) {
        
        AUTH_CONTROLLER.authorizeWithTalkCompletionHandler = { (callbackUrl) in
            let parseResult = callbackUrl.oauthResult()
            if let code = parseResult.code {
                AuthApi.shared.certToken(code: code, codeVerifier: self.codeVerifier) { (certTokenInfo, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    else {
                        completion(certTokenInfo, nil)
                        return
                    }
                }
            }
            else {
                let error = parseResult.error ?? SdkError(reason: .Unknown, message: "Failed to parse redirect URI.")
                SdkLog.e("Failed to parse redirect URI.")
                completion(nil, error)
                return
            }
        }
        
        var certPrompts: [Prompt] = [.Cert]
        if let prompts = prompts {
            certPrompts = prompts + certPrompts
        }
                   
        let parameters = self.makeParametersForTalk(prompts:certPrompts,
                                                    channelPublicIds: channelPublicIds,
                                                    serviceTerms: serviceTerms,
                                                    nonce: nonce,
                                                    kauthTxId: kauthTxId)
        
        guard let url = SdkUtils.makeUrlWithParameters(url:Urls.compose(.TalkAuth, path:Paths.authTalk),
                                                       parameters: parameters,
                                                       launchMethod: launchMethod) else {
            SdkLog.e("Bad Parameter.")
            completion(nil, SdkError(reason: .BadParameter))
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { (result) in
            if (result) {
                SdkLog.d("카카오톡 실행: \(url.absoluteString)")
            }
            else {
                SdkLog.e("카카오톡 실행 취소")
                completion(nil, SdkError(reason: .Cancelled, message: "The KakaoTalk authentication has been canceled by user."))
                return
            }
        }
    }
    
    public func _certAuthorizeWithAuthenticationSession(prompts: [Prompt]? = nil,
                                                        agtToken: String? = nil,
                                                        scopes:[String]? = nil,
                                                        channelPublicIds: [String]? = nil,
                                                        serviceTerms: [String]? = nil,
                                                        loginHint: String? = nil,
                                                        nonce: String? = nil,
                                                        kauthTxId: String? = nil,
                                                        completion: @escaping (CertTokenInfo?, Error?) -> Void) {
        
        let authenticationSessionCompletionHandler : (URL?, Error?) -> Void = {
            [weak self] (callbackUrl:URL?, error:Error?) in
            
            guard let callbackUrl = callbackUrl else {
                if let error = error as? ASWebAuthenticationSessionError {
                    if error.code == ASWebAuthenticationSessionError.canceledLogin {
                        SdkLog.e("The authentication session has been canceled by user.")
                        completion(nil, SdkError(reason: .Cancelled, message: "The authentication session has been canceled by user."))
                        return
                    } else {
                        SdkLog.e("An error occurred on executing authentication session.\n reason: \(error)")
                        completion(nil, SdkError(reason: .Unknown, message: "An error occurred on executing authentication session."))
                        return
                    }
                }
                else {
                    SdkLog.e("An unknown authentication session error occurred.")
                    completion(nil, SdkError(reason: .Unknown, message: "An unknown authentication session error occurred."))
                    return
                }
            }
            
            SdkLog.d("callback url: \(callbackUrl)")
            
            let parseResult = callbackUrl.oauthResult()
            if let code = parseResult.code {
                SdkLog.i("code:\n \(String(describing: code))\n\n" )
                
                AuthApi.shared.certToken(code: code, codeVerifier: self?.codeVerifier) { (certTokenInfo, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    else {
                        completion(certTokenInfo, nil)
                        return
                    }
                }
            }
            else {
                let error = parseResult.error ?? SdkError(reason: .Unknown, message: "Failed to parse redirect URI.")
                SdkLog.e("redirect URI error: \(error)")
                completion(nil, error)
                return
            }
        }
        
        var certPrompts: [Prompt] = [.Cert]        
        if let prompts = prompts {
            certPrompts = prompts + certPrompts
        }
        
        let parameters = self.makeParameters(prompts: certPrompts,                                             
                                             agtToken: agtToken,
                                             scopes: scopes,
                                             channelPublicIds: channelPublicIds,
                                             serviceTerms: serviceTerms,
                                             loginHint: loginHint,
                                             nonce: nonce,
                                             kauthTxId: kauthTxId)
        
        if let url = SdkUtils.makeUrlWithParameters(Urls.compose(.Kauth, path:Paths.authAuthorize), parameters:parameters) {
            SdkLog.d("\n===================================================================================================")
            SdkLog.d("request: \n url:\(url)\n parameters: \(parameters) \n")
            
            
            let authenticationSession = ASWebAuthenticationSession(url: url,
                                                                   callbackURLScheme: (try! KakaoSDK.shared.scheme()),
                                                                   completionHandler:authenticationSessionCompletionHandler)
            
            authenticationSession.presentationContextProvider = AUTH_CONTROLLER.presentationContextProvider as? ASWebAuthenticationPresentationContextProviding
            if agtToken != nil {
                authenticationSession.prefersEphemeralWebBrowserSession = true
            }
            AUTH_CONTROLLER.authenticationSession = authenticationSession
            AUTH_CONTROLLER.authenticationSession?.start()
        }
    }
}
