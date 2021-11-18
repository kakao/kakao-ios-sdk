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

/// 좌표계 타입을 선택합니다.
/// - seealso: `NaviOptions.coordType`
public enum CoordType : String, Codable {
    
    /// Katec 좌표계 (서버 기본값)
    case KATEC = "katec"
    
    /// World Geodetic System 84 좌표계
    case WGS84 = "wgs84"
}

/// 길안내를 사용할 차종(1~7)을 선택합니다.
/// - seealso: `NaviOptions.vehicleType`
public enum VehicleType : Int, Codable {
    
    /// 1종 (승용차/소형승합차/소형화물화)
    case First = 1
    
    /// 2종 (중형승합차/중형화물차)
    case Second = 2
    
    /// 3종 (대형승합차/2축 대형화물차)
    case Third = 3
    
    /// 4종 (3축 대형화물차)
    case Fourth = 4
    
    /// 5종 (4축이상 특수화물차)
    case Fifth = 5
    
    /// 6종 (경차)
    case Sixth = 6
    
    /// 이륜차
    case TwoWheel = 7
}

/// 안내할 경로를 최적화하기 위한 옵션입니다.
/// - seealso: `NaviOptions.rpOption`
public enum RpOption : Int, Codable {
    
    /// 빠른길
    case Fast = 1
    
    /// 무료도로
    case Free = 2
    
    /// 최단거리
    case Shortest = 3
    
    /// 자동차전용제외
    case NoAuto = 4
    
    /// 큰길우선
    case Wide = 5
    
    /// 고속도로우선
    case Highway = 6
    
    /// 일반도로우선
    case Normal = 8
    
    /// 추천 경로
    case Recommended = 100
}

/// 카카오내비에서 장소를 표현합니다.
public struct NaviLocation : Codable {
    
    // MARK: Fields
    
    /// 장소 이름. 예) 우리집, 회사
    public let name: String
    
    /// 경도 좌표
    /// - note: 사용할 좌표계는 `NaviOption.coordType` 으로 설정합니다. 기본 좌표계(KATEC)를 사용하지 않을 경우 API 호출 시 옵션 객체를 생성하고 원하는 좌표계를 설정한 후 파라미터로 전달해야 합니다.
    public let x: String
    
    /// 위도 좌표
    /// - note: 사용할 좌표계는 `NaviOption.coordType` 으로 설정합니다. 기본 좌표계(KATEC)를 사용하지 않을 경우 API 호출 시 옵션 객체를 생성하고 원하는 좌표계를 설정한 후 파라미터로 전달해야 합니다.
    public let y: String
    
    /// 도착링크 옵션 "G"
    public let rpflag: String?
    
    
    // MARK: Initializers
    
    /// 장소 객체를 생성합니다.
    public init(name : String,
                x : String,
                y : String,
                rpflag: String? = nil) {
        self.name = name
        self.x = x
        self.y = y
        self.rpflag = rpflag
    }
}

//public struct NaviCoordinate {
//    public let start : Numeric
//}
//

/// 길안내 옵션을 설정합니다.
public struct NaviOption : Codable {
    
    // MARK: Fields
    
    /// 사용할 좌표계
    /// - seealso: `CoordType`
    public let coordType : CoordType?
    
    /// 차종
    /// - seealso: `VehicleType`
    public let vehicleType : VehicleType?
    
    /// 경로 옵션
    /// - seealso: `RpOption`
    public let rpOption : RpOption?
    
    /// 전체 경로정보 보기 사용여부
    public let routeInfo : Bool?
    
    /// 시작 위치의 경도 좌표 (KATEC, WGS84) 공통
    let startX : String?
    
    /// 시작 위치의 위도 좌표 (KATEC, WGS84) 공통
    let startY : String?
    
    /// 시작 차량각도 (0~359)
    public let startAngle : Int?
    
    /// 길안내 종료(전체 경로보기시 종료) 후 호출 될 URI.
    public let returnUri : URL?
    
    enum CodingKeys: String, CodingKey {
        case coordType, vehicleType, routeInfo, returnUri
        case startX = "s_x"
        case startY = "s_y"
        case startAngle = "s_angle"
        case rpOption = "rpoption"
    }
    
    
    // MARK: Initializers
    
    /// 옵션 객체를 생성합니다.
    public init(coordType : CoordType? = nil,
                vehicleType : VehicleType? = nil,
                rpOption : RpOption? = nil,
                routeInfo : Bool? = false,
                startX : String? = nil,
                startY : String? = nil,
                startAngle : Int? = 0,
                returnUri : URL? = nil)  {
        self.coordType = coordType
        self.vehicleType = vehicleType
        self.rpOption = rpOption
        self.routeInfo = routeInfo
        self.startX = startX
        self.startY = startY
        self.startAngle = startAngle
        self.returnUri = returnUri
    }
}

//내부전용.
struct NaviParameters : Codable {
    var destination : NaviLocation
    var option : NaviOption?
    var viaList : [NaviLocation]?
    
    init(destination : NaviLocation,
                option : NaviOption? = nil,
                viaList : [NaviLocation]? = nil) {
        self.destination = destination
        self.option = option
        self.viaList = viaList
        
    }
}
