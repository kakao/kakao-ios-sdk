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

/// 카카오톡 채널 관계 목록 \
/// List of the Kakao Talk Channel relationship
/// ## SeeAlso
/// - ``TalkApi/channels(publicIds:completion:)``
public struct Channels : Codable {
    
    // MARK: Fields
    
    /// 회원번호 \
    /// Service user ID
    public let userId: Int64?
    
    /// 카카오톡 채널 관계 목록 \
    /// List of the Kakao Talk Channel relationship
    /// ## SeeAlso
    /// - ``Channel``
    public let channels: [Channel]?
    
    enum CodingKeys : String, CodingKey {
        case userId
        case channels = "channels"
    }
}


/// 카카오톡 채널 관계 \
/// Relationship with the Kakao Talk Channel
public struct Channel : Codable {
    
    // MARK: Enumerations
    
    /// 카카오톡 채널 관계 \
    /// Relationship with the Kakao Talk Channel
    public enum Relation : String, Codable {
        /// 카카오톡 채널이 추가된 상태 \
        /// The user has added the channel
        case Added = "ADDED"
        /// 카카오톡 채널이 추가되거나 차단된 적 없는 상태 \
        /// The user has not either added or blocked the channel
        case None = "NONE"
        /// 카카오톡 채널이 차단된 상태 \
        /// The user has blocked the channel
        case Blocked = "BLOCKED"
    }
    
    /// 카카오톡 채널 고유 ID \
    /// Kakao Talk Channel unique ID
    public let uuid: String
    
    /// 카카오톡 채널 프로필 ID \
    /// Kakao Talk Channel profile ID
    public let encodedId: String
    
    /// 카카오톡 채널 관계 \
    /// Relationship with the Kakao Talk Channel
    public let relation: Relation
    
    /// 최종 변경 일시 \
    /// Last update time
    public let updatedAt: Date?
    
    enum CodingKeys : String, CodingKey {
        case uuid = "channelUuid"
        case encodedId = "channelPublicId"
        case relation = "relation"
        case updatedAt = "updatedAt"
    }
}

/// 카카오톡 채널 간편 추가하기 결과 \
/// Result of Follow Kakao Talk Channel
public struct FollowChannelResult: Codable {
    /// 성공 여부 \
    /// Success status
    public let success: Bool
    
    /// 카카오톡 채널 프로필 ID \
    /// Kakao Talk Channel's profile ID
    public let channelPublicId: String
    
    enum CodingKeys : String, CodingKey {
        case success = "status"
        case channelPublicId = "channelPublicId"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        success = try values.decode(String.self, forKey: .success) == "success" ? true : false
        channelPublicId = try values.decode(String.self, forKey: .channelPublicId)
    }
}


