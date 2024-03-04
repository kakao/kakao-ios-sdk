
//  Copyright 2023 Kakao Corp.
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
import AuthenticationServices

import KakaoSDKCommon
import KakaoSDKAuth

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension UserApi {
    public func _requestShippingAddress(continuePath: String,
                                addressId: Int64? = nil,
                                completion: @escaping (Int64?, Error?) -> Void) {
        AuthApi.shared.refreshToken { _, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            AuthApi.shared.agt { [weak self] (agt, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                if let agt = agt {
                    self?._requestShippingAddressWithAuthenticateSession(agt: agt,
                                                                         continueUrl: Urls.compose(.Apps, path: continuePath),
                                                                         addressId: addressId,
                                                                         completion: completion)
                } else {
                    completion(nil, SdkError())
                }
            }
        }
    }
    
    func _requestShippingAddressWithAuthenticateSession(agt: String,
                                 continueUrl: String,
                                 addressId: Int64? = nil,
                                 completion: @escaping (Int64?, Error?) -> Void) {
        let authenticationSessionCompletionHandler: (URL?, Error?) -> Void = { (callbackUrl, error) in
            guard let callbackUrl = callbackUrl else {
                if let error = error as? ASWebAuthenticationSessionError {
                    if error.code == .canceledLogin {
                        completion(nil, SdkError(reason: .Cancelled, message: "Shipping Address has been canceled by user."))
                    } else {
                        completion(nil, SdkError(reason: .Unknown, message: "An error occurred on shipping address."))
                    }
                } else {
                    completion(nil, SdkError(reason: .Unknown, message: "An unknown Shipping Address error occurred."))
                }
                
                return
            }
            
            SdkLog.d(callbackUrl)
            let appsResult = callbackUrl.appsResult()
            
            if let error = appsResult.error {
                completion(nil, error)
                return
            } else {
                if let result = appsResult.result?["address_id"] as? String,
                   let addressId = Int64(result)  {
                    completion(addressId, nil)
                    return
                }
                
                completion(nil, SdkError(reason: .IllegalState))
                return
            }
        }
        
        let kpidtParameters = _makeParametersForKpidt(agt: agt, addressId:addressId, continueUrl: continueUrl)        
        if let kpidtUrlString = SdkUtils.makeUrlStringWithParameters(Urls.compose(.Apps, path: Paths.kpidt), parameters: kpidtParameters),
           let url = URL(string: kpidtUrlString) {
            SdkLog.d(kpidtUrlString)
            let authenticateSession = ASWebAuthenticationSession(url: url,
                                                                 callbackURLScheme: (try! KakaoSDK.shared.scheme()),
                                                                 completionHandler: authenticationSessionCompletionHandler)
            authenticateSession.presentationContextProvider = self.presentationContextProvider as? ASWebAuthenticationPresentationContextProviding
            authenticateSession.prefersEphemeralWebBrowserSession = true
            
            self.authenticateSession = authenticateSession
            self.authenticateSession?.start()
        }
    }
    
    func _makeParametersForKpidt(agt: String, addressId: Int64? = nil, continueUrl: String) -> [String:Any] {
        var continueParameters = SdkUtils.makeParametersForApps(returnUrl: "\(try! KakaoSDK.shared.scheme())://address")        
        continueParameters["enable_back_button"] = false
        if let addressId = addressId {
            continueParameters["address_id"] = addressId
        }
        
        var  parameters: [String: Any] = [:]
        parameters["app_key"] = try! KakaoSDK.shared.appKey()
        parameters["agt"] = agt
        parameters["continue"] = SdkUtils.makeUrlStringWithParameters(continueUrl, parameters: continueParameters)
        
        return parameters
    }
}
