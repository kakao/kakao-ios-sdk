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
@_exported import KakaoSDKFriendCore

/// :nodoc: //SdkError casting helper
extension SdkError {
    /// :nodoc:
    public init(fromKfSdkError kfSdkError:KFSdkError) {
        switch kfSdkError {
        case .ClientFailed(let reason, let message):
            self = .ClientFailed(reason: ClientFailureReason(fromKfClientFailureReason: reason), errorMessage:message)
        @unknown default:
            self = .ClientFailed(reason: .Unknown, errorMessage: "cannot type casting to SdkError")
        }
    }
}

/// :nodoc: //SdkError casting helper
extension ClientFailureReason {
    /// :nodoc:
    public init(fromKfClientFailureReason kfClientFailureReason:KFClientFailureReason) {
        switch kfClientFailureReason {
        case .Unknown:
            self = .Unknown
        case .Cancelled:
            self = .Cancelled
        case .TokenNotFound:
            self = .TokenNotFound
        case .NotSupported:
            self = .NotSupported
        case .BadParameter:
            self = .BadParameter
        case .MustInitAppKey:
            self = .MustInitAppKey
        case .ExceedKakaoLinkSizeLimit:
            self = .ExceedKakaoLinkSizeLimit
        case .CastingFailed:
            self = .CastingFailed
        @unknown default:
            self = .Unknown
        }
    }
}
