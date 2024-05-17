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


/// 카카오톡 프로필 \
/// Kakao Talk profile
/// ## SeeAlso
/// - ``TalkApi/profile(completion:)``
public struct TalkProfile : Codable {
    
    // MARK: Fields
    
    /// 프로필 닉네임 \
    /// Profile nickname
    public let nickname: String?
    
    /// 프로필 이미지 \
    /// Profile image
    public let profileImageUrl: URL?
    
    /// 프로필 썸네일 이미지 \
    /// Profile thumbnail image
    public let thumbnailUrl: URL?
    
    /// 국가 코드 \
    /// Country code
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
