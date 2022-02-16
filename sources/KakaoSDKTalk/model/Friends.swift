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
    
    /// 목록 조회 API에 사용되는 정렬 방식 열거형
    public enum Order: String, Codable {
        /// 오름차순
        case Asc = "asc"
        /// 내림차순
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

/// 친구 목록 정렬 타입
public enum FriendOrder : String, Codable {
    
    /// 닉네임 기준으로 정렬
    case Nickname = "nickname"
    
    /// 19세 이상인 사용자 기준으로 정렬
    case Age = "age"
    
    /// 즐겨찾기 기준으로 정렬
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

/// 친구 목록 조회 API 응답 클래스 입니다.
/// - seealso: `TalkApi.friends(offset:limit:order:)`
public struct Friends<T:Codable> : Codable {
    
    // MARK: Fields
    
    /// 친구 목록
    public let elements: [T]?
    
    /// 조회 가능한 전체 친구 수
    public let totalCount: Int
    
    /// 조회된 친구 중 즐겨찾기에 등록된 친구 수
    public let favoriteCount: Int?
    
    public let beforeUrl : URL?
    public let afterUrl : URL?
    
    public init(elements:[T]?, totalCount:Int, favoriteCount:Int? = nil, beforeUrl:URL? = nil, afterUrl:URL? = nil) {
        self.elements = elements
        self.totalCount = totalCount
        self.favoriteCount = favoriteCount
        self.beforeUrl = beforeUrl
        self.afterUrl = afterUrl
    }
}

/// 친구 목록 조회 컨텍스트 입니다.
/// - seealso: `TalkApi.friends(friendsContext:)`
public struct FriendsContext {
    public let offset : Int?
    public let limit : Int?
    public let order : Order?
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


/// 카카오톡 친구 입니다.
public struct Friend : Codable {
    
    // MARK: Fields
    
    /// 사용자 아이디
    public let id: Int64?
    
    /// :nodoc:
    public let serviceUserId: Int64?
    
    /// 메시지를 전송하기 위한 고유 아이디
    ///
    /// 사용자의 계정 상태에 따라 이 정보는 바뀔 수 있습니다. 앱내의 사용자 식별자로 저장 사용되는 것은 권장하지 않습니다.
    public let uuid: String
    
    /// 닉네임
    public let profileNickname: String?
    
    /// 썸네일 이미지 URL
    public let profileThumbnailImage: URL?
    
    /// 즐겨찾기 추가 여부
    public let favorite: Bool?
    
    ///  메시지 수신이 허용되었는지 여부. 앱가입 친구의 경우는 feed msg에 해당. 앱미가입친구는 invite msg에 해당
    public let allowedMsg: Bool?
    
    // MARK: Internal
    
    enum CodingKeys : String, CodingKey {
        case id, serviceUserId, uuid, profileNickname, profileThumbnailImage, favorite, allowedMsg
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try? values.decode(Int64.self, forKey: .id)
        serviceUserId = try? values.decode(Int64.self, forKey: .serviceUserId)
        uuid = try values.decode(String.self, forKey: .uuid)
        profileNickname = try? values.decode(String.self, forKey: .profileNickname)
        profileThumbnailImage = URL(string:(try? values.decode(String.self, forKey: .profileThumbnailImage)) ?? "")
        favorite = try? values.decode(Bool.self, forKey: .favorite)
        allowedMsg = try? values.decode(Bool.self, forKey: .allowedMsg)
    }
}
