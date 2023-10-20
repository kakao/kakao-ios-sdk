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

import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
#if swift(>=5.8)
@_documentation(visibility: private)
#endif
@_exported import KakaoSDKFriendCore

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension PickerApi {
    func updateSharingData() {
        self.updateSharingData(SharingData(kapiHost: KakaoSDK.shared.hosts().kapi,
                                           kaHeader: KakaoSDK.shared.kaHeader(),
                                           appKey: try! KakaoSDK.shared.appKey()))
    }
        
    func refreshAuth(completion:@escaping (Error?) -> Void) {
        if (AuthApi.hasToken()) {
            if shouldRefreshToken() == true {
                AuthApi.shared.refreshToken { _, error in
                    if let error = error {
                        completion(error)
                        return
                    }
                    else {
                        let oauthToken = AUTH.tokenManager.getToken()
                        self.updateAuth(accessToken:oauthToken?.accessToken, expiredAt: oauthToken?.expiredAt)
                        completion(nil)
                    }
                }
            }
            else {
                //토큰 갱신 안해도 된다.
                completion(nil)
            }
        }
        else {
            completion(SdkError(reason: .TokenNotFound))
        }
    }
        
    func assignScopeRequestor() {
        self.scopeRequestor = self
    }    
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension PickerApi {
    /// 반복 실행 Helper
    public func prepareCallPickerApi(completion:@escaping (Error?) -> Void) {
        updateSharingData()
        refreshAuth { [weak self] error in
            if let error = error {
                completion(error)
            }
            else {
                self?.assignScopeRequestor()
                completion(nil)
            }
        }
    }
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension PickerApi : ScopeRequestable {
    public func requestPickerScope(requiredScope:[String], completion:@escaping (Error?) -> Void) {
        UserApi.shared.scopes(scopes: requiredScope) { scopeInfo, error in
            if let scopeError = error {
                completion(scopeError)
                return
            }
            else {
                if let scopeInfo = scopeInfo, let currentScopes = scopeInfo.scopes {
                    var needScopes = [String]()
                    currentScopes.forEach { scope in
                        if scope.agreed == false {
                            needScopes.append(scope.id)
                        }
                    }
                    SdkLog.i("needScopes: \(needScopes)")
                    if !needScopes.isEmpty {
                        //동의 후 호출
                        UserApi.shared.loginWithKakaoAccount(scopes: needScopes) { _, error in
                            if let agreementError = error {
                                completion(agreementError)
                            }
                            else {
                                completion(nil)
                            }
                        }
                    }
                    else {
                        completion(nil)
                    }
                }
            }
        }
    }
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
/// error type casting helper
extension PickerApi {
    public func castSdkError(responseInfo:ResponseInfo?, error:Error?) -> Error? {
        if let kfSdkError = error as? KFSdkError {
            return SdkError(fromKfSdkError:kfSdkError)
        }
        else if let responseInfo = responseInfo, let data = responseInfo.data, let response = responseInfo.response {
            if let sdkError = SdkError(response: response, data: data, type: .KApi) {
                return sdkError
            }
        }
        return error
    }
}
