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

// MARK: Enumerations
    
/// 정렬 방식 \
/// Sorting method
public enum Order: String, Codable {
    /// 오름차순
    /// Ascending
    case Asc = "asc"
    /// 내림차순
    /// Descending
    case Desc = "desc"
    
//        public var parameterValue: String {
//            switch self {
//            case .Asc:
//                return "asc"
//            case .Desc:
//                return "desc"
//            }
//        }
}

/// 친구 정렬 방식 \
/// Method to sort the friend list
public enum FriendOrder : String, Codable {
    
    /// 닉네임순 정렬 \
    /// Sort by nickname
    case Nickname = "nickname"
    
    /// 나이순 정렬 \
    /// Sort by age
    case Age = "age"
    
    /// 즐겨찾기 우선 정렬 \
    /// Sort favorite friends first
    case Favorite = "favorite"
    
//    public var parameterValue: String {
//        switch self {
//        case .Nickname:
//            return "nickname"
//        case .Age:
//            return "age"
//        }
//    }
}

/// 친구 목록 \
/// Friend list
/// ## SeeAlso
/// - ``TalkApi.friends(offset:limit:order:)``
public struct Friends<T:Codable> : Codable {
    
    // MARK: Fields
    
    /// 친구 목록 \
    /// Friend list
    public let elements: [T]?
    
    /// 친구 수 \
    /// Number of friends
    public let totalCount: Int
    
    /// 즐겨찾기 친구 수 \
    /// Number of favorite friends
    public let favoriteCount: Int?
    
    /// 이전 페이지 URL \
    /// URL for the prior page
    public let beforeUrl : URL?
    
    /// 다음 페이지 URL \
    /// URL for the next page
    public let afterUrl : URL?
    
    public init(elements:[T]?, totalCount:Int, favoriteCount:Int? = nil, beforeUrl:URL? = nil, afterUrl:URL? = nil) {
        self.elements = elements
        self.totalCount = totalCount
        self.favoriteCount = favoriteCount
        self.beforeUrl = beforeUrl
        self.afterUrl = afterUrl
    }
}

/// 친구 목록 조회 설정 \
/// Context for retrieving friend list
/// ## SeeAlso
/// - ``TalkApi/friends(context:completion:)``
public struct FriendsContext {
    /// 친구 목록 시작 지점 \
    /// Start point of the friend list
    public let offset : Int?
    
    /// 페이지당 결과 수 \
    /// Number of results in a page
    public let limit : Int?
    
    /// 정렬 방식 \
    /// Sorting method
    public let order : Order?
    
    /// 친구 정렬 방식 \
    /// Method to sort the friend list
    public let friendOrder : FriendOrder?
    
    public init(offset: Int? = nil,
                limit: Int? = nil,
                order: Order? = nil,
                friendOrder: FriendOrder? = nil) {
        self.offset = offset
        self.limit = limit
        self.order = order
        self.friendOrder = friendOrder
    }
    
    public init?(_ url:URL?) {
        if let params = url?.params() {
            if let offset = params["offset"] as? String { self.offset = Int(offset) ?? 0 } else { self.offset = nil }
            if let limit = params["limit"] as? String { self.limit = Int(limit) ?? 0 } else { self.limit = nil }
            if let order = params["order"] as? String { self.order = Order(rawValue: order) ?? .Asc } else { self.order = nil }
            if let friendOrder = params["friend_order"] as? String { self.friendOrder = FriendOrder(rawValue: friendOrder) ?? .Favorite } else { self.friendOrder = nil }
        }
        else {
            return nil
        }
    }
}


/// 친구 정보 \
/// Friend information
public struct Friend : Codable {
    
    // MARK: Fields
    
    /// 회원번호 \
    /// Service user ID
    public let id: Int64?
    
    /// 고유 ID \
    /// Unique ID
    public let uuid: String
    
    /// 프로필 닉네임 \
    /// Profile nickname
    public let profileNickname: String?
    
    /// 프로필 썸네일 이미지 \
    /// Profile thumbnail image
    public let profileThumbnailImage: URL?
    
    /// 즐겨찾기 친구 여부 \
    /// Whether a favorite friend
    public let favorite: Bool?
    
    ///  메시지 수신 허용 여부 \
    ///  Whether to allow receiving messages
    public let allowedMsg: Bool?
    
    // MARK: Internal
    
    enum CodingKeys : String, CodingKey {
        case id, uuid, profileNickname, profileThumbnailImage, favorite, allowedMsg
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try? values.decode(Int64.self, forKey: .id)
        uuid = try values.decode(String.self, forKey: .uuid)
        profileNickname = try? values.decode(String.self, forKey: .profileNickname)
        profileThumbnailImage = URL(string:(try? values.decode(String.self, forKey: .profileThumbnailImage)) ?? "")
        favorite = try? values.decode(Bool.self, forKey: .favorite)
        allowedMsg = try? values.decode(Bool.self, forKey: .allowedMsg)
    }
}
