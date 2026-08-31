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

@_documentation(visibility: private)
@available(iOSApplicationExtension, unavailable)
public final class AuthRequestRetrier : RequestInterceptor {
    private var requestsToRetry: [(apiRequest: Request, completion: (RetryResult) -> Void)] = []

    private var isRefreshing = false
    
    private let errorLock = NSLock()
    
    private var isShowLog: Bool

    private let retryLimit: Int
    private let maxRetryDelay: Int = 4

    public init(isShowLog: Bool = true, retryLimit: Int = Auth.retryTokenRefreshCount) {
        self.isShowLog = isShowLog
        self.retryLimit = retryLimit
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        errorLock.lock() ; defer { errorLock.unlock() }
        
        var logString = "request retrier:"        

        if let sdkError = API.getSdkError(error: error) {
            if !sdkError.isApiFailed {
                if isShowLog { SdkLog.e("\(logString)\n error:\(error)\n not api error -> pass through\n\n") }
                completion(.doNotRetryWithError(sdkError))
                return
            }

            let apiError = sdkError.getApiError()
            switch(apiError.reason) {
            case .InvalidAccessToken:
                logString = "\(logString)\n reason:\(error)\n token: \(String(describing: AUTH.tokenManager.getToken()))"
                if isShowLog { SdkLog.e("\(logString)\n\n") }

                if apiError.info?.reason != ErrorInfo.RecoveryReason.refresh
                    || request.retryCount >= retryLimit {
                    completion(.doNotRetryWithError(sdkError))
                    return
                }

                if shouldRefreshToken(request) {
//                    SdkLog.d("---------------------------- enqueue completion\n request: \(request) \n\n")
                    if let urlString = request.request?.url?.absoluteString, urlString.hasSuffix(Paths.checkAccessToken) == false {
                        requestsToRetry.append((apiRequest: request, completion: completion))
                    }

                    if !isRefreshing {
                        isRefreshing = true
                        let refreshCompletions: (OAuthToken?, Error?) -> Void = { [unowned self] (token, error) in
                            errorLock.lock(); defer { errorLock.unlock() }
                            if let error = error {
                                //token refresh failure.
                                if isShowLog { SdkLog.e(" refreshToken error: \(error). retry aborted.\n request: \(request) \n\n") }
                                
                                //pending requests all cancel
                                self.requestsToRetry.forEach { (_, completion) in
                                    completion(.doNotRetryWithError(error))
                                }                              }
                            else {
                                //token refresh success.
                                //SdkLog.d(">>>>>>>>>>>>>> refreshToken success\n request: \(request) \n\n")
                                
                                //proceed all pending requests.
                                self.requestsToRetry.forEach { (apiRequest, completion) in
                                    completion(.retryWithDelay(AuthRequestRetrier.calculateDelay(for: apiRequest.retryCount, maxCount: maxRetryDelay)))
                                }
                            }
                            
                            self.requestsToRetry.removeAll() //reset all stored completion
                            self.isRefreshing = false
                        }
                        
                        //SdkLog.d("<<<<<<<<<<<<<< start token refresh\n request: \(String(describing:request))\n\n")
                        if isShowLog {
                            AuthApi.shared.refreshToken(completion: refreshCompletions)
                        } else {
                            AuthApi.shared.refreshToken(loggingEnabled: false, completion: refreshCompletions)
                        }
                    }
                }
                else {                    
                    let sdkError = SdkError(reason: .TokenNotFound)
                    if isShowLog { SdkLog.e(" should not refresh: \(sdkError)  -> pass through \n") }
                    completion(.doNotRetryWithError(sdkError))
                }
            case .InsufficientScope:
                logString = "\(logString)\n reason:\(error)\n token: \(String(describing: AUTH.tokenManager.getToken()))"
                if isShowLog { SdkLog.e("\(logString)\n\n") }
                
                if let requiredScopes = sdkError.getApiError().info?.requiredScopes {
                    DispatchQueue.main.async {
                        AuthController.shared._authorizeByAgtWithAuthenticationSession(scopes: requiredScopes) { (_, error) in
                            if let error = error {
                                completion(.doNotRetryWithError(error))
                            }
                            else {
                                completion(.retry)
                            }
                        }
                    }
                }
                else {
                    if isShowLog { SdkLog.e("\(logString)\n reason:\(sdkError)\n requiredScopes not exist -> pass through \n\n") }
                    completion(.doNotRetryWithError(SdkError(apiFailedMessage:"requiredScopes not exist")))
                }
            case .RequiredAgeVerification:
                if isShowLog { SdkLog.e("\(logString)\n reason:\(sdkError)\n not handled error -> pass through partnerAuthRetrier \n\n") }
                completion(.doNotRetry)
            default:
                if isShowLog { SdkLog.e("\(logString)\n reason:\(sdkError)\n not handled error -> pass through \n\n") }
                completion(.doNotRetryWithError(sdkError))
            }
        }
        else {
            if isShowLog { SdkLog.e("\(logString)\n not handled error -> pass through \n\n") }
            completion(.doNotRetry)
        }
    }
    
    private func shouldRefreshToken(_ request: Request) -> Bool  {
        guard AUTH.tokenManager.getToken()?.refreshToken != nil else {
            if isShowLog { SdkLog.e(" refresh token not exist. retry aborted.\n\n") }
            return false
        }

        return true
    }

    public static func calculateDelay(for retryCount: Int, maxCount: Int) -> Double {
        let count = min(retryCount, maxCount)
        return pow(2, Double(count))
    }
}
