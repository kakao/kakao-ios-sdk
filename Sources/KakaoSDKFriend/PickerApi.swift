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
@_exported import KakaoSDKFriendCore


//open picker APIs
extension PickerApi {    
    /// 여러 명의 친구를 선택(멀티 피커)할 수 있는 친구 피커를 화면 전체에 표시합니다.
    /// - seealso: `OpenPickerFriendRequestParams`
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
    
    /// 여러 명의 친구를 선택(멀티 피커)할 수 있는 친구 피커를 팝업 형태로 표시합니다.
    /// - seealso: `OpenPickerFriendRequestParams`
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
    
    /// 한 명의 친구만 선택(싱글 피커)할 수 있는 친구 피커를 화면 전체에 표시합니다.
    /// - seealso: `OpenPickerFriendRequestParams`
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
    
    /// 한 명의 친구만 선택(싱글 피커)할 수 있는 친구 피커를 팝업 형태로 표시합니다.
    /// - seealso: `OpenPickerFriendRequestParams`
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
