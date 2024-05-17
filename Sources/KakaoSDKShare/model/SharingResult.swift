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

/// 카카오톡 공유 결과 \
/// Kakao Talk Sharing result
public struct SharingResult : Codable {
    
    // MARK: Fields
    
    /// 카카오톡 공유 실행 URL \
    /// URL to execute the Kakao Talk Sharing
    public let url: URL
    
    /// 메시지 템플릿 검증 결과 \
    /// Message template validation result
    public let warningMsg : [String:String]?
    
    /// 사용자 인자 검증 결과 \
    /// User argument validation result
    public let argumentMsg : [String:String]?
    
    
    public init(url: URL, warningMsg: [String:String]?, argumentMsg: [String:String]?) {
        self.url = url
        self.warningMsg = warningMsg
        self.argumentMsg = argumentMsg
    }
}
