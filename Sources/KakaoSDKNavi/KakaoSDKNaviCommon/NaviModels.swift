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

/// 좌표계 타입 \
/// Type of the coordinate system
/// ## SeeAlso
/// - ``NaviOption/coordType``
public enum CoordType : String, Codable {
    
    /// Katec, 서버 기본값 \
    /// Katec, the default value on the server side
    case KATEC = "katec"
    
    /// World Geodetic System(WGS) 84 \
    /// World Geodetic System(WGS) 84
    case WGS84 = "wgs84"
}

/// 차종 \
/// Vehicle type
/// ## SeeAlso
/// - ``NaviOption/vehicleType``
public enum VehicleType : Int, Codable {
    
    /// 1종, 승용차, 소형승합차, 소형화물차 \
    /// Class 1, passenger car, small van, small truck
    case First = 1
    
    /// 2종, 중형승합차, 중형화물차 \
    /// Class 2, mid-size van, mid-size truck
    case Second = 2
    
    /// 3종, 대형승합차, 2축 대형화물차 \
    /// Class 3, large van, 2-axis large truck
    case Third = 3
    
    /// 4종, 3축 대형화물차 \
    /// Class 4, 3-axis large truck
    case Fourth = 4
    
    /// 5종, 4축 이상 특수화물차 \
    /// Class 5, special truck with four axes or more
    case Fifth = 5
    
    /// 6종, 경차 \
    /// Class 6, compact car
    case Sixth = 6
    
    /// 이륜차 \
    /// Two-wheeled vehicle
    case TwoWheel = 7
}

/// 경로 최적화 기준 \
/// Criteria to optimize the route
/// ## SeeAlso
/// - ``NaviOption/rpOption``
public enum RpOption : Int, Codable {
    
    /// 가장 빠른 경로 \
    /// Fastest route
    case Fast = 1
    
    /// 무료 도로 \
    /// Free route
    case Free = 2
    
    /// 가장 짧은 경로 \
    /// Shortest route
    case Shortest = 3
    
    /// 자동차 전용 도로 제외 \
    /// Exclude motorway
    case NoAuto = 4
    
    /// 큰길 우선 \
    /// Wide road first
    case Wide = 5
    
    /// 고속도로 우선 \
    /// Highway first
    case Highway = 6
    
    /// 일반 도로 우선 \
    /// Normal road first
    case Normal = 8
    
    /// 추천 경로(기본값) \
    /// Recommended route (Default)
    case Recommended = 100
}

/// 장소 정보 \
/// Location information
public struct NaviLocation : Codable {
    
    // MARK: Fields
    
    /// 장소 이름 \
    /// Location name
    public let name: String
    
    /// 경도 좌표 \
    /// Longitude coordinate
    public let x: String
    
    /// 위도 좌표 \
    /// Latitude coordinate
    public let y: String
    
    /// 도착 링크(현재 미지원) \
    /// Link for the destination (Currently not available)
    public let rpflag: String?
    
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    // MARK: Initializers
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

/// 경로 검색 옵션 \
/// Options for searching the route
public struct NaviOption : Codable {
    
    // MARK: Fields
    
    /// 좌표계 타입 \
    /// Type of the coordinate system
    /// ## SeeAlso
    /// - ``CoordType``
    public let coordType : CoordType?
    
    /// 차종(기본값: 카카오내비 앱에 설정된 차종) \
    /// Vehicle type (Default: vehicle type set on the Kakao Navi app)
    /// ## SeeAlso
    /// - ``VehicleType``
    public let vehicleType : VehicleType?
    
    /// 경로 최적화 기준 \
    /// Criteria to optimize the route
    /// ## SeeAlso
    /// - ``RpOption``
    public let rpOption : RpOption?
    
    /// 전체 경로 정보 보기 사용 여부 \
    /// Whether to view the full route information
    public let routeInfo : Bool?
    
    /// 시작 위치의 경도 좌표 \
    /// Longitude coordinate of the start point
    let startX : String?
    
    /// 시작 위치의 위도 좌표 \
    /// Latitude coordinate of the start point
    let startY : String?
    
    /// 시작 차량 각도(최소: 0, 최대: 359) \
    /// Angle of the vehicle at the start point (Minimum: 0, Maximum: 359)
    public let startAngle : Int?
    
    /// 전체 경로 보기 종료 시 호출될 URI \
    /// URI to be called upon exiting the full route view
    public let returnUri : URL?
    
    enum CodingKeys: String, CodingKey {
        case coordType, vehicleType, routeInfo, returnUri
        case startX = "s_x"
        case startY = "s_y"
        case startAngle = "s_angle"
        case rpOption = "rpoption"
    }
    

#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    // MARK: Initializers
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
