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
    /// 친구 피커 \
    /// Friends picker
    /// ## SeeAlso
    /// - [`OpenPickerFriendRequestParams`](https://developers.kakao.com/sdk/reference/ios/release/KakaoSDKFriendCore/documentation/kakaosdkfriendcore/openpickerfriendrequestparams)
    public func selectFriend(params:OpenPickerFriendRequestParams, viewType: ViewType, enableMulti: Bool = true, completion:@escaping (SelectedUsers?, Error?) -> Void) {
        let fullParams = PickerFriendRequestParams(params)
        prepareCallPickerApi { [weak self] error in
            if let error = error {
                completion(nil, error)
            }
            else {
                self?.____sf(params: fullParams, enableMulti: enableMulti, viewType: viewType) { [weak self] selectedUsers, responseInfo, error in
                    completion(selectedUsers, self?.castSdkError(responseInfo:responseInfo, error: error))
                }
            }
        }
    }
}
