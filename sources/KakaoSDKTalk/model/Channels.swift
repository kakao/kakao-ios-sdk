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

/// 카카오톡 채널 추가상태 조회 API 응답 클래스입니다.
/// - seealso: `TalkApi.channels`
public struct Channels : Codable {
    
    // MARK: Fields
    
    /// 사용자 아이디
    public let userId: Int64?
    
    /// 사용자의 채널 추가상태 목록
    /// - seealso: `Channel`
    public let channels: [Channel]?
    
    enum CodingKeys : String, CodingKey {
        case userId
        case channels = "channels"
    }
}


/// 카카오톡 채널 추가상태 정보를 제공합니다.
public struct Channel : Codable {
    
    // MARK: Enumerations
    
    /// 카카오톡 채널과의 관계 열거형
    public enum Relation : String, Codable {
        /// 추가된 상태
        case Added = "ADDED"
        /// 추가하지 않음
        case None = "NONE"
        /// 차단 상태
        case Blocked = "BLOCKED"
    }
    
    /// 채널의 UUID
    public let uuid: String
    
    /// 채널의 인코딩 된 아이디
    public let encodedId: String
    
    /// 사용자의 채널 추가 상태
    public let relation: Relation
    
    /// 마지막 상태 변경 일시
    public let updatedAt: Date?
    
    enum CodingKeys : String, CodingKey {
        case uuid = "channelUuid"
        case encodedId = "channelPublicId"
        case relation = "relation"
        case updatedAt = "updatedTime"
    }
}


