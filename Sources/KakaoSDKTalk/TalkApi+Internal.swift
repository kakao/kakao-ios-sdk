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
import UIKit

import AuthenticationServices

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension TalkApi {
    public func _followChannelWithAuthenticationSession(channelPublicId:String,
                                                             agtToken: String? = nil,
                                                             completion: @escaping (FollowChannelResult?, Error?) -> Void) {
        
        let authenticationSessionCompletionHandler : (URL?, Error?) -> Void = {(callbackUrl:URL?, error:Error?) in
            
            guard let callbackUrl = callbackUrl else {
                if let error = error as? ASWebAuthenticationSessionError {
                    if error.code == ASWebAuthenticationSessionError.canceledLogin {
                        SdkLog.e("Following channel has been canceled by user.")
                        completion(nil, SdkError(reason: .Cancelled, message: "Following channel has been canceled by user."))
                        return
                    }
                    else {
                        SdkLog.e("An error occurred on following channel.\n reason: \(error)")
                        completion(nil, SdkError(reason: .Unknown, message: "An error occurred on following channel."))
                        return
                    }
                }
                else {
                    SdkLog.e("An unknown following channel error occurred.")
                    completion(nil, SdkError(reason: .Unknown, message: "An unknown following channel error occurred."))
                    return
                }
            }
            
            SdkLog.d("callback url: \(callbackUrl)")
            
            let parseResult = callbackUrl.appsResult()
            SdkLog.d("parse result: \(parseResult)")
            if let error = parseResult.error {
                completion(nil, error)
                return
            }
            else {
                if let result = parseResult.result, let followChannelResult = try? SdkJSONDecoder.custom.decode(FollowChannelResult.self, from: JSONSerialization.data(withJSONObject: result, options: [])) {
                    completion(followChannelResult, nil)
                    return
                }
                else {
                    completion(nil, SdkError(reason: .IllegalState))
                    return
                }
            }
        }
        
        let parameters = _makeParametersForFollowChannel(agtToken: agtToken, channelPublicId:channelPublicId)
        let url: URL? = SdkUtils.makeUrlWithParameters(Urls.compose(.Apps, path:Paths.followChannel), parameters:parameters)

        if let url = url {
            SdkLog.d("\n===================================================================================================")
            SdkLog.i("request: \n url:\(url)\n")
            
            let authenticationSession = ASWebAuthenticationSession(url: url,
                                                                   callbackURLScheme: (try! KakaoSDK.shared.scheme()),
                                                                   completionHandler:authenticationSessionCompletionHandler)
            
            authenticationSession.presentationContextProvider = self.presentationContextProvider as? ASWebAuthenticationPresentationContextProviding
            if agtToken != nil {
                authenticationSession.prefersEphemeralWebBrowserSession = true
            }
            self.authenticationSession = authenticationSession
            self.authenticationSession?.start()
        }
    }
    
    public func _makeParametersForFollowChannel(agtToken: String? = nil, channelPublicId: String) -> [String:Any] {
        var parameters = SdkUtils.makeParametersForApps(returnUrl: "\(try! KakaoSDK.shared.scheme())://channel")
        
        if let agt = agtToken {
            parameters["agt"] = agt
        }
        parameters["channel_public_id"] = channelPublicId
        return parameters
    }
}
