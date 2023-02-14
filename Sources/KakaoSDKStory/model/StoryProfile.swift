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

/// 카카오스토리 프로필 가져오기 API 응답 클래스 입니다.
/// - seealso: `StoryApi.profile(secureResource:)`
public struct StoryProfile : Codable {
    
    // MARK: Enumerations
    
    /// 스토리 프로필의 생일 타입
    public enum BirthdayType: String, Codable {
        /// 양력
        case Solar = "SOLAR"
        /// 음력
        case Lunar = "LUNAR"
    }
    
    
    // MARK: Fields
    
    /// 카카오스토리 닉네임
    public let nickName: String?
    
    /// 카카오스토리 프로필 이미지 URL
    public let profileImageUrl: URL?
    
    /// 카카오스토리 프로필 이미지 썸네일 URL
    public let thumbnailUrl: URL?
    
    /// 카카오스토리 배경이미지 URL
    public let bgImageUrl: URL?
    
    /// 카카오스토리 permanent link. 내 스토리를 방문할 수 있는 웹 page의 URL
    public let permalink: URL?
    
    /// 생일 (MMDD)
    public let birthday: String?
    
    /// 생일 타입
    /// - seealso: `BirthdayType`
    public let birthdayType: BirthdayType?
    
    
    // MARK: Internal
    
    enum CodingKeys: String, CodingKey {
        case nickName, permalink, birthday, birthdayType
        case profileImageUrl = "profileImageURL"
        case thumbnailUrl = "thumbnailURL"
        case bgImageUrl = "bgImageURL"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        nickName = try values.decode(String.self, forKey: .nickName)
        profileImageUrl = URL(string:(try? values.decode(String.self, forKey: .profileImageUrl)) ?? "")
        thumbnailUrl = URL(string:(try? values.decode(String.self, forKey: .thumbnailUrl)) ?? "")
        bgImageUrl = URL(string:(try? values.decode(String.self, forKey: .bgImageUrl)) ?? "")
        permalink = URL(string:(try? values.decode(String.self, forKey: .permalink)) ?? "")
        
        birthday = try? values.decode(String.self, forKey: .birthday)
        birthdayType = try? values.decode(BirthdayType.self, forKey: .birthdayType)
    }
}


