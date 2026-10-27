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

/// 배송지 조회 응답 \
/// Response for Retrieve shipping address
/// ## SeeAlso
/// - ``UserApi/shippingAddress(addressId:completion:)``
public struct UserShippingAddress : Codable {
    
    // MARK: Fields
    
    /// 회원번호 \
    /// Service user ID
    public let userId: Int64?
    
    /// 배송지를 얻기 위한 추가 동의 필요 여부 \
    /// Whether consent to shipping addresses is required
    public let needsAgreement: Bool?
    
    /// 기본 배송지 또는 `address_id`로 지정한 배송지 정보, 사용자가 [배송지 정보] 동의항목에 동의했고 조회할 배송지가 있는 경우 제공 \
    /// Default shipping address, or the shipping address specified by `address_id`, provided if the user has consented to the [Shipping information] consent item and the shipping address to retrieve exists
    /// ## SeeAlso
    /// - ``ShippingAddress``
    public let shippingAddress: ShippingAddress?
    
    
    enum CodingKeys: String, CodingKey {
        case userId, shippingAddress
        case needsAgreement = "shippingAddressNeedsAgreement"
    }
}


/// 배송지 정보 \
/// Shipping address information
/// ## SeeAlso
/// - ``UserShippingAddress``
public struct ShippingAddress : Codable {
    
    // MARK: Enumerations
    
    /// 배송지 타입 \
    /// Shipping address type
    public enum `Type` : String, Codable {
        /// 구주소 \
        /// Administrative address
        case Old = "OLD"
        /// 신주소 \
        /// Road name address
        case New = "NEW"
    }
    
    // MARK: Fields
    
    /// 배송지 ID \
    /// Shipping address ID
    public let id: Int64
    
    /// 배송지 이름 \
    /// Name of shipping address
    public let name: String?
    
    /// 기본 배송지 여부 \
    /// Whether shipping address is default
    public let isDefault: Bool
    
    /// 수정 시각 \
    /// Updated time
    public let updatedAt: Date?
    
    /// 배송지 타입 \
    /// Shipping address type
    /// ## SeeAlso
    /// - ``ShippingAddress/Type-swift.enum``
    public let type: Type?
    
    /// 우편번호 검색 시 채워지는 기본 주소 \
    /// Base address that is automatically input when searching for a zipcode
    public let baseAddress: String?
    
    /// 기본 주소에 추가하는 상세 주소 \
    /// Detailed address that a user adds to the base address
    public let detailAddress: String?
    
    /// 수령인 이름 \
    /// Recipient name
    public let receiverName: String?
    
    /// 수령인 연락처 \
    /// Recipient phone number
    public let receiverPhoneNumber1: String?
    
    /// 수령인 추가 연락처 \
    /// Additional recipient phone number
    public let receiverPhoneNumber2: String?
    
    /// 신주소 우편번호 \
    /// 5-digit postal code for a road name address system
    public let zoneNumber: String?
    
    /// 구주소 우편번호 \
    /// Old type of 6-digit postal code for an administrative address system
    public let zipCode: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, updatedAt, type, baseAddress, detailAddress, receiverName, receiverPhoneNumber1, receiverPhoneNumber2, zoneNumber, zipCode, isDefault
    }
}
