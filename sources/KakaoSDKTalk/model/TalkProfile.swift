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

/// 카카오톡 프로필 가져오기 API 응답 클래스 입니다.
/// - seealso: `TalkApi.profile()`
public struct TalkProfile : Codable {
    
    // MARK: Fields
    
    /// 카카오톡 닉네임
    public let nickname: String?
    
    /// 카카오톡 프로필 이미지 URL
    public let profileImageUrl: URL?
    
    /// 카카오톡 프로필 이미지 썸네일 URL
    public let thumbnailUrl: URL?
    
    /// 카카오톡 국가 코드
    public let countryISO: String?  // nullability: http://papi.talk.kakao.com:8354/doc/protocol/common_type.md#User    
    
    enum CodingKeys : String, CodingKey {
        case nickname = "nickName"
        case profileImageUrl = "profileImageURL"
        case thumbnailUrl = "thumbnailURL"
        case countryISO
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        nickname = try? values.decode(String.self, forKey: .nickname)
        profileImageUrl = URL(string:(try? values.decode(String.self, forKey: .profileImageUrl)) ?? "")
        thumbnailUrl = URL(string:(try? values.decode(String.self, forKey: .thumbnailUrl)) ?? "")
        countryISO = try? values.decode(String.self, forKey: .countryISO)
    }
}
