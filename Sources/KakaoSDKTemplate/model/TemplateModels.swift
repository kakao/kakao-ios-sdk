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

/// [메시지 템플릿](https://developers.kakao.com/docs/latest/ko/message/message-template) 기본 템플릿 프로토콜 \
/// Protocols of the default template for the [message template](https://developers.kakao.com/docs/latest/en/message/message-template)
/// ## SeeAlso
/// - ``FeedTemplate``
/// - ``ListTemplate``
/// - ``LocationTemplate``
/// - ``CommerceTemplate``
/// - ``TextTemplate``
/// - ``CalendarTemplate``
public protocol Templatable {
    
#if swift(>=5.8)
@_documentation(visibility: private)
#endif
    /// API 요청 파라미터로 사용하기 위해 현재 객체를 JSON으로 변환합니다. SDK 내부적으로 사용합니다.
    func toJsonObject() -> [String:Any]?
}

/// 소셜 정보 \
/// Social information
public struct Social : Codable {
    
    // MARK: Fields
    
    /// 좋아요 수 \
    /// Number of likes
    public let likeCount : Int?
    
    /// 댓글 수 \
    /// Number of comments
    public let commentCount : Int?
    
    /// 공유 수 \
    /// Number of shares
    public let sharedCount : Int?
    
    /// 조회 수 \
    /// Views
    public let viewCount : Int?
    
    /// 구독 수 \
    /// Number of subscribers
    public let subscriberCount : Int?
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    // MARK: Initializers
    public init?(likeCount: Int? = nil,
                 commentCount: Int? = nil,
                 sharedCount: Int? = nil,
                 viewCount: Int? = nil,
                 subscriberCount: Int? = nil
                 ) {
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.sharedCount = sharedCount
        self.viewCount = viewCount
        self.subscriberCount = subscriberCount
    }    
}

/// 메시지 하단 버튼 \
/// Button at the bottom of the message
public struct Button : Codable {
    
    // MARK: Fields
    
    /// 버튼 문구 \
    /// Label for the button
    public var title : String
    
    /// 바로가기 URL \
    /// Link URL
    /// ## SeeAlso `Link`
    public var link : Link
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    // MARK: Initializers
    public init (title: String,
                 link: Link) {
        self.title = title
        self.link = link
    }
}

/// 바로가기 정보 \
/// Link information
public struct Link : Codable {
    
    // MARK: Fields
    
    /// 웹 URL \
    /// Web URL
    public let webUrl : URL?
    
    /// 모바일 웹 URL \
    /// Mobile web URL
    public let mobileWebUrl : URL?
    
    /// Android 앱 실행 시 전달할 파라미터 \
    /// Parameters to pass to the Android app
    public let androidExecutionParams : String?
    
    /// iOS 앱 실행 시 전달할 파라미터 \
    /// Parameters to pass to the iOS app
    public let iosExecutionParams : String?
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    // MARK: Initializers
    public init(webUrl: URL? = nil,
                mobileWebUrl: URL? = nil,
                androidExecutionParams: [String: String]? = nil,
                iosExecutionParams: [String: String]? = nil) {
        self.webUrl = webUrl
        self.mobileWebUrl = mobileWebUrl
        self.androidExecutionParams = androidExecutionParams?.queryParameters
        self.iosExecutionParams = iosExecutionParams?.queryParameters
    }
}

/// 메시지 콘텐츠 \
/// Contents for the message
public struct Content : Codable {
    
    // MARK: Fields
    
    /// 제목 \
    /// Title
    public let title : String?
    
    /// 이미지 URL \
    /// Image URL
    public let imageUrl : URL?
    
    /// 이미지 너비(단위: 픽셀) \
    /// Image width (Unit: Pixel)
    public let imageWidth : Int?
    
    /// 이미지 높이(단위: 픽셀) \
    /// Image height (Unit: Pixel)
    public let imageHeight : Int?
    
    /// 설명 \
    /// Description
    public let description : String?
    
    /// 바로가기 URL \
    /// Link URL
    /// ## SeeAlso `Link`
    public let link : Link
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    // MARK: Initializers
    public init(title: String? = nil,
                imageUrl: URL? = nil,
                imageWidth: Int? = nil,
                imageHeight: Int? = nil,
                description: String? = nil,
                link: Link) {
        self.title = title
        self.imageUrl = imageUrl
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.description = description
        
        self.link = link
    }
}

/// 아이템 콘텐츠 \
/// Item contents
public struct ItemContent : Codable {
    
    // MARK: Fields
    
    /// 프로필 텍스트 \
    /// Profile text
    public let profileText : String?
    
    /// 프로필 이미지 URL \
    /// Profile image URL
    public let profileImageUrl : URL?
    
    /// 이미지 아이템 제목 \
    /// Title of the image item
    public let titleImageText : String?
    
    /// 이미지 아이템 이미지 URL  \
    /// Image URL of the image item
    public let titleImageUrl : URL?
    
    /// 이미지 아이템의 카테고리 \
    /// Category of the image item
    public let titleImageCategory : String?
    
    /// 아이템 정보 \
    /// Item information
    public let items : [ItemInfo]?
    
    /// 요약 정보 \
    /// Summary
    public let sum : String?
    
    /// 합산 가격 \
    /// Total price
    public let sumOp : String?
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    // MARK: Initializers
    public init(profileText: String? = nil,
                profileImageUrl: URL? = nil,
                titleImageText: String? = nil,
                titleImageUrl: URL? = nil,
                titleImageCategory: String? = nil,
                items: [ItemInfo]? = nil,
                sum: String? = nil,
                sumOp: String? = nil) {
        self.profileText = profileText
        self.profileImageUrl = profileImageUrl
        self.titleImageText = titleImageText
        self.titleImageUrl = titleImageUrl
        self.titleImageCategory = titleImageCategory
        
        self.items = items
        
        self.sum = sum
        self.sumOp = sumOp
    }
}

/// 아이템 정보 \
/// Item information
public struct ItemInfo : Codable {
    
    /// 아이템 이름 \
    /// Name of the item
    public let item : String
    
    /// 아이템 가격 \
    /// Price of the item
    public let itemOp : String
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    // MARK: Initializers
    public init (item : String,
                 itemOp : String) {
        self.item = item
        self.itemOp = itemOp
    }
}

/// 상품 정보 \
/// Product information
public struct CommerceDetail : Codable {
    
    // MARK: Fields
    
    /// 정가 \
    /// Regular price
    public let regularPrice : Int
    
    /// 할인 가격 \
    /// Discount price
    public let discountPrice : Int?
    
    /// 할인율 \
    /// Discount rate
    public let discountRate : Int?
    
    /// 정액 할인 가격 \
    /// Fixed disount price
    public let fixedDiscountPrice : Int?
    
    /// 상품 이름 \
    /// Product name
    public let productName : String?
    
    /// 화폐 단위 \
    /// Currency unit
    public let currencyUnit : String?
    
    /// 화폐 단위 표시 위치(0: 가격 뒤 | 1: 가격 앞, 기본값: 0) \
    /// Position of currency unit (0: before the price | 1: behind the price, Default: 0)
    public let currencyUnitPosition : Int?

#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    // MARK: Initializers
    public init (regularPrice : Int,
                 discountPrice : Int? = nil,
                 discountRate : Int? = nil,
                 fixedDiscountPrice : Int? = nil,
                 productName : String? = nil,
                 currencyUnit : String? = nil,
                 currencyUnitPosition : Int? = nil) {
        self.regularPrice = regularPrice
        self.discountPrice = discountPrice
        self.discountRate = discountRate
        self.fixedDiscountPrice = fixedDiscountPrice
        self.productName = productName
        self.currencyUnit = currencyUnit
        self.currencyUnitPosition = currencyUnitPosition
    }
}

/// 피드 메시지용 기본 템플릿 \
/// Default template for feed messages
/// ## SeeAlso
/// - [고급: 생성자를 사용해 메시지 만들기](https://developers.kakao.com/docs/latest/ko/message/ios-link#advanced-guide) \
///   [Advanced: Create a message using constructor](https://developers.kakao.com/docs/latest/en/message/ios-link#advanced-guide)
public struct FeedTemplate : Codable, Templatable {
    
    // MARK: Fields
    
    /// 메시지 템플릿 타입, "feed"로 고정 \
    /// Type of the message template, fixed as "feed"
    public let objectType : String
    
    /// 메시지 콘텐츠 \
    /// Contents for the message
    /// ## SeeAlso `Content`
    public let content: Content
    
    /// 아이템 콘텐츠 \
    /// Item contents
    /// ## SeeAlso `ItemContent`
    public let itemContent: ItemContent?
    
    /// 소셜 정보 \
    /// Social information
    /// ## SeeAlso `Social`
    public let social: Social?
    
    /// 버튼 문구 \
    /// Label for the button
    public let buttonTitle: String?
    
    /// 메시지 하단 버튼 \
    /// Button at the bottom of the message
    /// ## SeeAlso `Button`
    public let buttons : [Button]?
    

#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    // MARK: Initializers
    public init (content: Content,
                 itemContent: ItemContent? = nil,
                 social: Social? = nil,
                 buttonTitle: String? = nil,
                 buttons: [Button]? = nil ) {
        
        self.objectType = "feed"
        self.content = content
        self.itemContent = itemContent
        self.social = social
        self.buttonTitle = buttonTitle
        self.buttons = buttons
    }
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public func toJsonObject() -> [String:Any]? {
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(self)) {
            return SdkUtils.toJsonObject(templateJsonData)
        }
        return nil
    }
}

/// 리스트 메시지용 기본 템플릿 \
/// Default template for list messages
public struct ListTemplate : Codable, Templatable {
    
    // MARK: Fields
    
    /// 메시지 템플릿 타입, "list"로 고정 \
    /// Type of the message template, fixed as "list"
    public let objectType : String
    
    /// 헤더 문구 \
    /// Title of the header
    public let headerTitle : String
    
    // 리스트 템플릿의 상단에 보이는 이미지 URL : headerImageUrl은 2.0.3에 삭제 되었습니다.
    // 리스트 템플릿의 상단에 보이는 이미지 가로 길이, 권장 800 (단위: 픽셀) : headerImageWidth 은 2.0.3에 삭제 되었습니다.
    // 리스트 템플릿의 상단에 보이는 이미지 세로 길이, 권장 190 (단위: 픽셀) : headerImageHeight 은 2.0.3에 삭제 되었습니다.
    
    /// 헤더 바로가기 정보 \
    /// Link of the header
    /// ## SeeAlso
    /// - ``Link``
    public let headerLink : Link
    
    /// 메시지 콘텐츠 \
    /// Contents for the message
    /// ## SeeAlso
    /// - ``Content``
    public let contents: [Content]
    
    /// 버튼 문구 \
    /// Label for the button
    public let buttonTitle: String?
    
    /// 메시지 하단 버튼 \
    /// Button at the bottom of the message
    /// ## SeeAlso
    /// - ``Button``
    public let buttons : [Button]?
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    // MARK: Initializers
    public init (headerTitle: String,
                 headerLink: Link,
                 
                 contents: [Content],
                 
                 buttonTitle: String? = nil,
                 buttons: [Button]? = nil ) {
        self.objectType = "list"
        self.headerTitle = headerTitle
        self.headerLink = headerLink
            
        self.contents = contents
        
        self.buttonTitle = buttonTitle
        self.buttons = buttons
    }
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public func toJsonObject() -> [String:Any]? {
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(self)) {
            return SdkUtils.toJsonObject(templateJsonData)
        }
        return nil
    }
}

/// 위치 메시지용 기본 템플릿 \
/// Default template for location messages
public struct LocationTemplate : Codable, Templatable {
    
    // MARK: Fields
    
    /// 메시지 템플릿 타입, "location"으로 고정 \
    /// Type of the message template, fixed as "location"
    public let objectType : String
    
    /// 주소 \
    /// Address
    public let address: String
    
    /// 장소 이름 \
    /// Name of the place
    public let addressTitle: String?
    
    /// 메시지 콘텐츠 \
    /// Contents for the message
    /// ## SeeAlso `Content`
    public let content: Content
    
    /// 소셜 정보 \
    /// Social information
    /// ## SeeAlso `Social`
    public let social: Social?
    
    /// 버튼 문구 \
    /// Label for the button
    public let buttonTitle: String?
    
    /// 메시지 하단 버튼 \
    /// Button at the bottom of the message
    /// ## SeeAlso `Button`
    public let buttons : [Button]?
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    // MARK: Initializers
    public init (address: String,
                 addressTitle: String? = nil,
                 content: Content,
                 social: Social? = nil,
                 buttonTitle: String? = nil,
                 buttons: [Button]? = nil
                 ) {
        self.objectType = "location"
        self.address = address
        self.addressTitle = addressTitle
        self.content = content
        self.social = social
        self.buttonTitle = buttonTitle
        self.buttons = buttons
    }
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public func toJsonObject() -> [String:Any]? {
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(self)) {
            return SdkUtils.toJsonObject(templateJsonData)
        }
        return nil
    }
}

/// 커머스 메시지용 기본 템플릿 \
/// Default template for commerce messages
public struct CommerceTemplate : Codable, Templatable {
    
    // MARK: Fields
    
    /// 메시지 템플릿 타입, "commerce"로 고정 \
    /// Type of the message template, fixed as "commerce"
    public let objectType : String
    
    /// 메시지 콘텐츠 \
    /// Contents for the message
    /// ## SeeAlso `Content`
    public let content: Content
    
    /// 상품 정보 \
    /// Product information
    /// ## SeeAlso `CommerceDetail`
    public let commerce : CommerceDetail
    
    /// 버튼 문구 \
    /// Label for the button
    public let buttonTitle: String?
    
    /// 메시지 하단 버튼 \
    /// Button at the bottom of the message
    /// ## SeeAlso `Button`
    public let buttons : [Button]?
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    // MARK: Initializers
    public init (content: Content,
                 commerce: CommerceDetail,
                 buttonTitle: String? = nil,
                 buttons: [Button]? = nil ) {
        self.objectType = "commerce"
        self.content = content
        self.commerce = commerce
        self.buttonTitle = buttonTitle
        self.buttons = buttons
    }
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public func toJsonObject() -> [String:Any]? {
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(self)) {
            return SdkUtils.toJsonObject(templateJsonData)
        }
        return nil
    }
}

/// 텍스트 메시지용 기본 템플릿 \
/// Default template for text messages
public struct TextTemplate : Codable, Templatable {
    
    // MARK: Fields
    
    /// 메시지 템플릿 타입, "text"로 고정 \
    /// Type of the message template, fixed as "text"
    public let objectType : String
    
    /// 텍스트 \
    /// Text
    public let text: String
    
    /// 바로가기 정보 \
    /// Link information
    /// ## SeeAlso `Link`
    public let link: Link
    
    /// 버튼 문구 \
    /// Label for the button
    public let buttonTitle: String?
    
    /// 메시지 하단 버튼 \
    /// Button at the bottom of the message
    /// ## SeeAlso `Button`
    public let buttons : [Button]?
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    // MARK: Initializers
    public init (text: String,
                 link: Link,
                 buttonTitle: String? = nil,
                 buttons: [Button]? = nil ) {
        self.objectType = "text"
        self.text = text
        self.link = link
        self.buttonTitle = buttonTitle
        self.buttons = buttons
    }
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public func toJsonObject() -> [String:Any]? {
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(self)) {
            return SdkUtils.toJsonObject(templateJsonData)
        }
        return nil
    }
}


/// 캘린더 메시지용 기본 템플릿 \
/// Default template for calendar messages
public struct CalendarTemplate : Codable, Templatable {
    
    /// ID 타입 \
    /// ID type
    public enum IdType : String, Codable {
        /// 공개 일정 \
        /// Public event
        case Event = "event"
        /// 구독 캘린더 \
        /// Subscribed calendar
        case Calendar = "calendar"
    }
    
    // MARK: Fields
    
    /// 메시지 템플릿 타입, "calendar"로 고정 \
    /// Type of the message template, fixed as "calendar"
    public let objectType : String
    
    /// 구독 캘린더 또는 공개 일정 ID \
    /// ID for subscribed calendar or public event
    public let id : String
    
    /// ID 타입 \
    /// ID type
    public let idType: IdType
    
    /// 일정 설명 \
    /// Event description
    /// ## SeeAlso
    /// - ``Content``
    public let content: Content
    
    /// 메시지 하단 버튼 \
    /// Button at the bottom of the message
    /// ## SeeAlso
    /// - ``Button``
    public let buttons : [Button]?
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    // MARK: Initializers
    public init (id: String,
                 idType: IdType,
                 content: Content,
                 buttons: [Button]? = nil
                 ) {
        self.objectType = "calendar"
        self.id = id
        self.idType = idType
        self.content = content
        self.buttons = buttons
    }    
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public func toJsonObject() -> [String:Any]? {
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(self)) {
            return SdkUtils.toJsonObject(templateJsonData)
        }
        return nil
    }
}
