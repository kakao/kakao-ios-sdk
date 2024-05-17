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


//open picker APIs
/// [피커](https://developers.kakao.com/docs/latest/ko/kakaotalk-social/common) API 클래스 \
/// Class for the [picker](https://developers.kakao.com/docs/latest/en/kakaotalk-social/common) APIs
extension PickerApi {    
    /// 풀 스크린 형태의 멀티 피커 요청 \
    /// Requests a multi-picker in full-screen view
    /// ## SeeAlso
    /// - [`OpenPickerFriendRequestParams`](https://developers.kakao.com/sdk/reference/ios/release/KakaoSDKFriendCore/documentation/kakaosdkfriendcore/openpickerfriendrequestparams)
    public func selectFriends(params:OpenPickerFriendRequestParams, completion:@escaping (SelectedUsers?, Error?) -> Void) {
        let fullParams = PickerFriendRequestParams(params)
        prepareCallPickerApi { [weak self] error in
            if let error = error {
                completion(nil, error)
            }
            else {
                self?.____sfs(params: fullParams) { [weak self] selectedUsers, responseInfo, error in
                    completion(selectedUsers, self?.castSdkError(responseInfo:responseInfo, error: error))
                }
            }
        }
    }
    
    /// 팝업 형태의 멀티 피커 요청 \
    /// Requests a multi-picker in pop-up view
    /// ## SeeAlso
    /// - [`OpenPickerFriendRequestParams`](https://developers.kakao.com/sdk/reference/ios/release/KakaoSDKFriendCore/documentation/kakaosdkfriendcore/openpickerfriendrequestparams)
    public func selectFriendsPopup(params:OpenPickerFriendRequestParams, completion:@escaping (SelectedUsers?, Error?) -> Void) {
        let fullParams = PickerFriendRequestParams(params)
        prepareCallPickerApi { [weak self] error in
            if let error = error {
                completion(nil, error)
            }
            else {
                self?.____sfsp(params: fullParams) { [weak self] selectedUsers, responseInfo, error in
                    completion(selectedUsers, self?.castSdkError(responseInfo:responseInfo, error: error))
                }
            }
        }
    }
    
    /// 풀 스크린 형태의 싱글 피커 요청 \
    /// Requests a single picker in full-screen view
    /// ## SeeAlso
    /// - [`OpenPickerFriendRequestParams`](https://developers.kakao.com/sdk/reference/ios/release/KakaoSDKFriendCore/documentation/kakaosdkfriendcore/openpickerfriendrequestparams)
    public func selectFriend(params:OpenPickerFriendRequestParams, completion:@escaping (SelectedUsers?, Error?) -> Void) {
        let fullParams = PickerFriendRequestParams(params)
        prepareCallPickerApi { [weak self] error in
            if let error = error {
                completion(nil, error)
            }
            else {
                self?.____sf(params: fullParams) { [weak self] selectedUsers, responseInfo, error in
                    completion(selectedUsers, self?.castSdkError(responseInfo:responseInfo, error: error))
                }
            }
        }
    }
    
    /// 팝업 형태의 싱글 피커 요청 \
    /// Requests a single picker in pop-up view
    /// ## SeeAlso
    /// - [`OpenPickerFriendRequestParams`](https://developers.kakao.com/sdk/reference/ios/release/KakaoSDKFriendCore/documentation/kakaosdkfriendcore/openpickerfriendrequestparams)
    public func selectFriendPopup(params:OpenPickerFriendRequestParams, completion:@escaping (SelectedUsers?, Error?) -> Void) {
        let fullParams = PickerFriendRequestParams(params)
        prepareCallPickerApi { [weak self] error in
            if let error = error {
                completion(nil, error)
            }
            else {
                self?.____sfp(params: fullParams) { [weak self] selectedUsers, responseInfo, error in
                    completion(selectedUsers, self?.castSdkError(responseInfo:responseInfo, error: error))
                }
            }
        }
    }
}
