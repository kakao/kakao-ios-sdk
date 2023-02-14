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

/// 카카오스토리의 내스토리 정보 중 이미지 내용을 담고 있는 구조체 입니다.
public struct StoryMedia : Codable {
    
    // media 다 nonnull 맞는지 확인
    //  => 스펙 문서나 히스토리 파악이 잘 안됨
    //     mj 얘기로는 지금의 스펙이 생기기 전 아주 오래된 포스팅의 경우 안내려올 가능성이 있음. 스토리쪽에 물어봐도 잘 모를거라고..
    //     일단 사용성 불편하더라도 모두 nullable로 진행

    // MARK: Fields
    
    /// 원본 이미지의 url
    public let original: URL?
    
    /// xlarge 사이즈 이미지의 url
    public let xlarge: URL?
    
    /// large 사이즈 이미지의 url
    public let large: URL?
    
    /// medium 사이즈 이미지의 url
    public let medium: URL?
    
    /// small 사이즈 이미지의 url
    public let small: URL?
    
    
    // MARK: Internal
    enum CodingKeys: String, CodingKey {
        case original, xlarge, large, medium, small
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        original = URL(string: (try? values.decode(String.self, forKey: .original)) ?? "")
        xlarge = URL(string: (try? values.decode(String.self, forKey: .xlarge)) ?? "")
        large = URL(string: (try? values.decode(String.self, forKey: .large)) ?? "")
        medium = URL(string: (try? values.decode(String.self, forKey: .medium)) ?? "")
        small = URL(string: (try? values.decode(String.self, forKey: .small)) ?? "")
    }
}

/// 카카오스토리의 댓글 정보를 담고 있는 구조체 입니다.
public struct StoryComment : Codable {
    
    // MARK: Fields
    
    /// 댓글의 텍스트 내용
    public let text: String
    
    /// 댓글의 작성자
    public let writer: StoryActor
}

/// 카카오스토리의 작성자 정보를 담고 있는 구조체 입니다.
public struct StoryActor : Codable {
    
    // MARK: Fields
    
    /// 작성자의 이름
    public let displayName: String
    
    /// 작성자의 썸네일에 대한 URL
    public let profileThumbnailUrl: URL?
    
    
    // MARK: Internal
    
    enum CodingKeys: String, CodingKey {
        case displayName, profileThumbnailUrl
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        displayName = try values.decode(String.self, forKey: .displayName)
        profileThumbnailUrl = URL(string:(try? values.decode(String.self, forKey: .profileThumbnailUrl)) ?? "")
    }
}

/// 카카오스토리의 좋아요 등 느낌(이모티콘)에 대한 정보를 담고 있는 구조체 입니다.
public struct StoryLike : Codable {
    
    // MARK: Enumerations
    
    /// 느낌(이모티콘)에 대한 정의
    public enum Emotion : String, Codable {
        /// 알수 없는 형식
        case NotDefined = "NOT_DEFINED"
        /// 좋아요
        case Like = "LIKE"
        /// 멋져요
        case Cool = "COOL"
        /// 기뻐요
        case Happy = "HAPPY"
        /// 슬퍼요
        case Sad = "SAD"
        /// 힘내요
        case CheerUp = "CHEER_UP"
    }
    
    
    // MARK: Fields
    
    /// 느낌에 대한 정보. 예) 좋아요, 멋져요, 기뻐요, 슬퍼요, 힘내요
    public let emotion: Emotion
    /// 느낌 작성자의 이름
    public let actor: StoryActor
}

/// 스토리 조회 API 응답 클래스 입니다.
/// - seealso: `StoryApi.story(id:)` <br>`StoryApi.stories(lastId:)`
public struct Story : Codable {
    
    // MARK: Enumerations
    
    /// 스토리의 미디어 형식 열거형
    public enum MediaType : String, Codable {
        /// 지원되지 않는 미디어 형식
        case NotSupported = "NOT_SUPPORTED"
        /// 텍스트 형식
        case Note = "NOTE"
        /// 이미지 형식
        case Photo = "PHOTO"
    }
    
    /// 스토리의 공개 범위 열거형
    public enum Permission : String, Codable {
        /// 전체 공개
        case Public = "PUBLIC"
        /// 친구 공개
        case Friend = "FRIEND"
        /// 나만 보기
        case OnlyMe = "ONLY_ME"
        
        public var parameterValue: String {
            switch self {
            case .Friend:
                return "F"
            case .OnlyMe:
                return "M"
            default:
                return "A"
            }
        }
    }
    
    
    // MARK: Fields

    /// 내스토리 정보의 id(포스트 id)
    public let id: String
    
    /// 내스토리 정보의 url
    public let url: URL
    
    /// 미디어 형식
    /// - seealso: `MediaType`
    public let mediaType: MediaType?
    
    /// 작성된 시간
    public let createdAt: Date
    
    /// 포스팅 내용
    public let content: String?
    
    /// 미디어 목록
    /// - seealso: `StoryMedia`
    public let media: [StoryMedia]?
    
    /// 댓글 수
    public let commentCount: Int
    
    /// 좋아요 수
    public let likeCount: Int
    
    /// 공개 범위
    /// - seealso: `Permission`
    public let permission: Permission?
    
    /// 댓글 목록
    /// - seealso: `StoryComment`
    public let comments: [StoryComment]?
    
    /// 좋아요 정보 목록
    /// - seealso: `StoryLike`
    public let likes: [StoryLike]?
    
//    enum CodingKeys: String, CodingKey {
//        case id, url, mediaType, createdAt, content, commentCount, likeCount, permission, comments, likes
//        case medias = "media"
//    }
    
//    public init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        
//        id = try values.decode(String.self, forKey: .id)
//        profileThumbnailUrl = URL(string:(try? values.decode(String.self, forKey: .profileThumbnailUrl)) ?? "")
//    }
}

/// :nodoc:
public struct Stories : Codable {
    public let stories: [Story]?
    
    public init(from decoder: Decoder) throws {
        stories = try? decoder.singleValueContainer().decode([Story].self)
    }
}
