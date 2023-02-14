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

/// 카카오 SDK의 기본 템플릿을 나타내는 프로토콜 입니다. 카카오 SDK에서는 카카오 디벨로퍼스에서 별도 템플릿을 만들지 않고도 소스코드 레벨에서 간단하게 템플릿을 작성할 수 있도록 기본 템플릿을 제공하고 있습니다.
///
/// 이 모듈에서 제공되는 모든 템플릿 클래스는 이 프로토콜을 구현하고 있습니다. 생성된 템플릿으로 카카오톡 공유, 카카오톡 메시지 전송에 활용할 수 있습니다.
///
/// - see:
/// `FeedTemplate`<br>
/// `ListTemplate`<br>
/// `LocationTemplate`<br>
/// `CommerceTemplate`<br>
/// `TextTemplate` <br>
/// `CalendarTemplate`
public protocol Templatable {
    
    /// API 요청 파라미터로 사용하기 위해 현재 객체를 JSON으로 변환합니다. SDK 내부적으로 사용합니다.
    func toJsonObject() -> [String:Any]?
}

/// 좋아요 수, 댓글 수 등의 소셜 정보를 표현하기 위해 사용되는 오브젝트 입니다.
///
/// 5개의 속성 중 최대 3개만 표시해 줍니다. 우선순위는 **Like > Comment > Shared > View > Subscriber** 입니다.
public struct Social : Codable {
    
    // MARK: Fields
    
    /// 좋아요 수
    public let likeCount : Int?
    
    /// 댓글 수
    public let commentCount : Int?
    
    /// 공유 수
    public let sharedCount : Int?
    
    /// 조회 수
    public let viewCount : Int?
    
    /// 구독 수
    public let subscriberCount : Int?
    
    
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

/// 메시지 하단에 추가되는 버튼 오브젝트 입니다.
public struct Button : Codable {
    
    // MARK: Fields
    
    /// 버튼의 타이틀
    public var title : String
    
    /// 버튼 클릭 시 이동할 링크 정보
    /// - seealso: `Link`
    public var link : Link
    
    
    // MARK: Initializers
    
    public init (title: String,
                 link: Link) {
        self.title = title
        self.link = link
    }
}

/// 메시지에서 컨텐츠 영역이나 버튼 클릭 시에 이동되는 링크 정보 오브젝트 입니다.
///
///   - 오브젝트 내 프로퍼티 중 하나 이상은 반드시 존재해야 합니다.
///   - 링크에 사용되는 **도메인**은 반드시 내 애플리케이션 설정에 등록되어야 합니다. 도메인은 개발자 웹사이트의 **[내 애플리케이션] - [앱 설정] - [플랫폼] - [Web]** 메뉴에서 등록할 수 있습니다.
///   - 링크 실행 우선순위는 {android/ios}**ExecutionParams > mobileWebURL > webURL** 입니다.
///
///   - 자세한 사항은 가이드(https://developers.kakao.com/docs/latest/ko/message/message-template#component)를 참고하시기 바랍니다.
public struct Link : Codable {
    
    // MARK: Fields
    
    /// PC버전 카카오톡에서 사용하는 웹 링크 URL
    public let webUrl : URL?
    
    /// 모바일 카카오톡에서 사용하는 웹 링크 URL
    public let mobileWebUrl : URL?
    
    /// Android 카카오톡에서 사용하는 앱 링크 URL에 사용될 파라미터
    public let androidExecutionParams : String?
    
    /// iOS 카카오톡에서 사용하는 앱 링크 URL에 사용될 파라미터
    public let iosExecutionParams : String?
    
    
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

/// 컨텐츠의 내용을 담고 있는 오브젝트 입니다. **1개의 이미지, 제목, 설명, 링크** 정보를 가질 수 있습니다.
public struct Content : Codable {
    
    // MARK: Fields
    
    /// 컨텐츠 제목
    public let title : String
    
    /// 이미지 URL
    public let imageUrl : URL
    
    /// 이미지 너비 (단위: 픽셀)
    public let imageWidth : Int?
    
    /// 이미지 높이 (단위: 픽셀)
    public let imageHeight : Int?
    
    /// 컨텐츠 상세 설명
    public let description : String?
    
    /// 컨텐츠 클릭 시 이동할 링크 정보
    /// - seealso: `Link`
    public let link : Link
    
    
    // MARK: Initializers
    
    public init(title: String,
                imageUrl: URL,
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

/// 아이템 목록 형태의 콘텐츠의 내용을 담고 있는 오브젝트 입니다.
public struct ItemContent : Codable {
    
    // MARK: Fields
    
    /// 헤더 또는 프로필 영역에 출력될 텍스트
    /// profileImageUrl 값이 없을 경우, 볼드(Bold)체로 된 제목만 담은 헤더 형태로 출력됨, 최대 16자까지 출력
    public let profileText : String?
    
    /// 프로필 영역에 출력될 이미지
    /// 작은 원형의 프로필 사진 형태로 출력됨
    public let profileImageUrl : URL?
    
    /// 이미지 아이템의 제목
    /// 최대 2줄, 최대 24자까지 출력
    public let titleImageText : String?
    
    /// 이미지 아이템의 이미지
    /// iOS 108*108, Android 98*98 크기 1:1 비율이 아닌 이미지는 센터 크롭(Center crop) 방식으로 재조정됨
    public let titleImageUrl : URL?
    
    /// 이미지 아이템의 제목 아래에 회색 글씨로 출력되는 카테고리 정보
    /// 최대 한 줄, 최대 14자까지 출력
    public let titleImageCategory : String?
    
    /// 각 텍스트 아이템 정보
    /// 아이템 이름과 가격에 해당하는 item, itemOp를 포함한 JSON 배열, 최대 5개의 아이템 지원
    public let items : [ItemInfo]?
    
    /// 주문금액, 결제금액 등 아이템 목록을 종합하는 제목
    /// 텍스트 아이템 영역 아래에 최대 6자까지 출력
    public let sum : String?
    
    /// 아이템 목록의 가격 합산 정보
    /// 아이템 영역 아래에 볼드체로 최대 11자까지 출력
    public let sumOp : String?
    
    
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

/// 아이템 목록 형태의 콘텐츠의 내용을 담고 있는 오브젝트 입니다.
public struct ItemInfo : Codable {
    
    /// 아이템 이름, 최대 6자까지 출력
    /// item과 itemOp는 둘 다 값이 있어야만 아이템 목록에 출력
    public let item : String
    
    /// 아이템 가격. 최대 2줄, 1줄인 경우 최대 14자, 2줄인 경우 최대 25자까지 출력
    /// 사용 가능한 문자: 숫자, 통화기호, 쉼표(,), 마침표(.), 띄어쓰기 소수 단위 금액을 포함한 경우, 소수점 아래 2자리까지만 사용 권장
    /// item과 itemOp는 둘 다 값이 있어야만 아이템 목록에 출력
    public let itemOp : String
    
    // MARK: Initializers
    public init (item : String,
                 itemOp : String) {
        self.item = item
        self.itemOp = itemOp
    }
}

/// 가격, 할인율 등 커머스 정보를 나타내는 오브젝트 입니다.
public struct CommerceDetail : Codable {
    
    // MARK: Fields
    
    /// 정상 가격
    public let regularPrice : Int
    
    /// 할인 가격
    public let discountPrice : Int?
    
    /// 할인율
    public let discountRate : Int?
    
    /// 정액 할인 가격 (할인율과 동시 사용불가)
    public let fixedDiscountPrice : Int?
    
    /// 상품명
    public let productName : String?
    
    /// 가격 단위
    public let currencyUnit : String?
    
    /// 가격 단위 위치 (0: 가격뒤에 단위 표시, 1 : 가격앞에 단위 표시)
    public let currencyUnitPosition : Int?

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

/// 기본 템플릿으로 제공되는 피드 템플릿 클래스 입니다.
///
/// 피드 템플릿은 하나의 컨텐츠와 하나의 기본 버튼을 가집니다. 소셜 정보를 추가할 수 있으며 임의의 버튼을 설정할 수도 있습니다.
///
/// 아래는 간단한 피드템플릿 생성 예제입니다.
///
///     let template = FeedTemplate(content: Content(title: "딸기 치즈 케익",
///                                                  imageUrl: URL(string: "http://mud-kage.kakao.co.kr/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png")!,
///                                                  description: "#케익 #딸기 #삼평동 #까페 #분위기 #소개팅",
///                                                  link: Link(webUrl: URL(string: "https://developers.kakao.com")!,
///                                                             mobileWebUrl:  URL(string: "https://developers.kakao.com")!)),
///                                 social: Social(likeCount: 286,
///                                                commentCount: 45,
///                                                sharedCount: 845))
public struct FeedTemplate : Codable, Templatable {
    
    // MARK: Fields
    
    /// "feed" 고정 값
    public let objectType : String
    
    /// 메시지의 메인 콘텐츠 정보입니다.
    /// - seealso: `Content`
    
    public let content: Content
    
    /// 아이템 영역에 포함할 콘텐츠 정보입니다.
    /// - seealso: `ItemContent`
    public let itemContent: ItemContent?
    
    /// 콘텐츠에 대한 소셜 정보입니다.
    /// - seealso: `Social`
    public let social: Social?
    
    /// 기본 버튼 타이틀(자세히 보기)을 변경하고 싶을 때 설정. 이 값을 사용하면 클릭 시 이동할 링크는 content 에 입력된 값이 사용됩니다.
    public let buttonTitle: String?
    
    /// 버튼 목록, 최대 2개. 버튼 타이틀과 링크를 변경하고 싶을 때, 버튼 두 개를 넣고 싶을 때 사용합니다.
    /// - seealso: `Button`
    public let buttons : [Button]?
    
    
    // MARK: Initializers
    
    /// - parameter content: [required] 메인 컨텐츠
    /// - parameter social: 좋아요, 구독수 등 소셜 정보
    ///
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
    
    /// :nodoc:
    public func toJsonObject() -> [String:Any]? {
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(self)) {
            return SdkUtils.toJsonObject(templateJsonData)
        }
        return nil
    }
}

/// 여러 개의 컨텐츠를 리스트 형태로 보여줄 수 있는 메시지 템플릿 입니다.
///
/// 리스트 템플릿은 메시지 상단에 노출되는 헤더 타이틀과, 컨텐츠 목록, 버튼 등으로 구성됩니다. 헤더와 컨텐츠 각각의 링크를 가질 수 있습니다. 피드 템플릿과 마찬가지로 하나의 기본 버튼을 가지며 임의의 버튼을 설정할 수 있습니다.
///
///     let template = ListTemplate(headerTitle: "WEEKLY MAGAZINE",
///                                 headerLink: Link(mobileWebUrl: URL(string: "https://developers.kakao.com")!),
///                                 contents: [Content(title: "취미의 특징, 탁구",
///                                                    imageUrl: URL(string: "http://mud-kage.kakao.co.kr/dn/bDPMIb/btqgeoTRQvd/49BuF1gNo6UXkdbKecx600/kakaolink40_original.png")!,
///                                                    description: "스포츠",
///                                                    link: Link(mobileWebUrl: URL(string: "https://developers.kakao.com")!)),
///                                            Content(title: "크림으로 이해하는 커피이야기",
///                                                    imageUrl: URL(string: "http://mud-kage.kakao.co.kr/dn/QPeNt/btqgeSfSsCR/0QJIRuWTtkg4cYc57n8H80/kakaolink40_original.png")!,
///                                                    description: "음식",
///                                                    link: Link(mobileWebUrl: URL(string: "https://developers.kakao.com")!)),
///                                            Content(title: "감성이 가득한 분위기",
///                                                    imageUrl: URL(string: "http://mud-kage.kakao.co.kr/dn/c7MBX4/btqgeRgWhBy/ZMLnndJFAqyUAnqu4sQHS0/kakaolink40_original.png")!,
///                                                    description: "사진",
///                                                    link: Link(mobileWebUrl: URL(string: "https://developers.kakao.com")!)),])
public struct ListTemplate : Codable, Templatable {
    
    // MARK: Fields
    
    /// "list" 고정 값
    public let objectType : String
    
    /// 리스트 상단에 노출되는 헤더 타이틀. (최대 200자)
    public let headerTitle : String
    
    /// :nodoc: 리스트 템플릿의 상단에 보이는 이미지 URL : headerImageUrl은 2.0.3에 삭제 되었습니다.
    /// :nodoc: 리스트 템플릿의 상단에 보이는 이미지 가로 길이, 권장 800 (단위: 픽셀) : headerImageWidth 은 2.0.3에 삭제 되었습니다.
    /// :nodoc: 리스트 템플릿의 상단에 보이는 이미지 세로 길이, 권장 190 (단위: 픽셀) : headerImageHeight 은 2.0.3에 삭제 되었습니다.
    
    /// 헤더 타이틀 내용에 해당하는 링크 정보.
    /// - seealso: `Link`
    public let headerLink : Link
    
    /// 리스트에 노출되는 컨텐츠 목록. (최소 2개, 최대 3개)
    /// - seealso: `Content`
    public let contents: [Content]
    
    /// 기본 버튼 타이틀("자세히 보기")을 변경하고 싶을 때 설정. 이 값을 사용하면 클릭 시 이동할 링크는 content에 입력된 값이 사용됩니다.
    public let buttonTitle: String?
    
    /// 버튼 목록. 버튼 타이틀과 링크를 변경하고 싶을때, 버튼 두개를 사용하고 싶을때 사용.
    /// - seealso: `Button`
    public let buttons : [Button]?
    
    
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
    
    
    public func toJsonObject() -> [String:Any]? {
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(self)) {
            return SdkUtils.toJsonObject(templateJsonData)
        }
        return nil
    }
}

/// 주소를 이용하여 특정 위치를 공유할 수 있는 메시지 템플릿 입니다.
///
/// 위치 템플릿은 지도 표시에 사용되는 주소 정보와 해당 위치를 설명할 수 있는 컨텐츠 오브젝트로 구성됩니다. 왼쪽 하단에 기본 버튼, 오른쪽 하단에 지도를 보여주기 위한 "위치 보기" 버튼이 추가됩니다. "위치 보기" 버튼을 클릭하면 카카오톡 채팅방 내에서 바로 지도 화면으로 전환하여 해당 주소의 위치를 확인할 수 있습니다.
///
///     let template = LocationTemplate(address: "경기 성남시 분당구 판교역로 235 에이치스퀘어 N동 8층",
///                                     addressTitle: "카카오 판교오피스 카페톡",
///                                     content: Content(title: "신메뉴 출시❤️ 체리블라썸라떼",
///                                                      imageUrl: URL(string: "http://mud-kage.kakao.co.kr/dn/bSbH9w/btqgegaEDfW/vD9KKV0hEintg6bZT4v4WK/kakaolink40_original.png")!,
///                                                      description: "이번 주는 체리블라썸라떼 1+1",
///                                                      link: Link(mobileWebUrl: URL(string: "https://developers.kakao.com")!)),
///                                     buttonTitle: "메뉴 보기")
public struct LocationTemplate : Codable, Templatable {
    
    // MARK: Fields
    
    /// "location" 고정 값
    public let objectType : String
    
    /// 공유할 위치의 주소. 예) 경기 성남시 분당구 판교역로 235
    public let address: String
    
    /// 카카오톡 내의 지도 뷰에서 사용되는 타이틀. 예) 카카오판교오피스
    public let addressTitle: String?
    
    /// 위치에 대해 설명하는 컨텐츠 정보
    /// - seealso: `Content`
    public let content: Content
    
    /// 댓글수, 좋아요수 등, 컨텐츠에 대한 소셜 정보
    /// - seealso: `Social`
    public let social: Social?
    
    /// 기본 버튼 타이틀("자세히 보기")을 변경하고 싶을 때 설정. 이 값을 사용하면 클릭 시 이동할 링크는 content에 입력된 값이 사용됩니다.
    public let buttonTitle: String?
    
    /// 버튼 목록. 기본 버튼의 타이틀 외에 링크도 변경하고 싶을 때 설정 합니다. (최대 1개, 오른쪽 "위치 보기" 버튼은 고정)
    /// - seealso: `Button`
    public let buttons : [Button]?
    
    
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
    
    
    public func toJsonObject() -> [String:Any]? {
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(self)) {
            return SdkUtils.toJsonObject(templateJsonData)
        }
        return nil
    }
}

/// 기본 템플릿으로 제공되는 커머스 템플릿 클래스 입니다.
///
/// 커머스 템플릿은 하나의 컨텐츠와 하나의 커머스 정보, 하나의 기본 버튼을 가집니다. 임의의 버튼을 최대 2개까지 설정할 수 있습니다.
///
///     let template = CommerceTemplate(content: Content(title: "Ivory long dress (4 Color)",
///                                                      imageUrl: URL(string: "http://mud-kage.kakao.co.kr/dn/RY8ZN/btqgOGzITp3/uCM1x2xu7GNfr7NS9QvEs0/kakaolink40_original.png")!,
///                                                      link: Link(mobileWebUrl: URL(string: "https://developers.kakao.com")!)),
///                                     commerce: CommerceDetail(regularPrice: 208800,
///                                                              discountPrice: 146160,
///                                                              discountRate: 30),
///                                     buttons: [Button(title: "구매하기",
///                                                      link: Link(mobileWebUrl: URL(string: "https://developers.kakao.com")!)),
///                                               Button(title: "공유하기",
///                                                      link: Link(mobileWebUrl: URL(string: "https://developers.kakao.com")!)),
///                                               ])
public struct CommerceTemplate : Codable, Templatable {
    
    // MARK: Fields
    
    /// "commerce" 고정 값
    public let objectType : String
    
    /// 메시지의 내용. 텍스트 및 이미지, 링크 정보를 포함합니다.
    /// - seealso: `Content`
    public let content: Content
    
    /// 컨텐츠에 대한 가격 정보.
    /// - seealso: `CommerceDetail`
    public let commerce : CommerceDetail
    
    /// 기본 버튼 타이틀("자세히 보기")을 변경하고 싶을 때 설정. 이 값을 사용하면 클릭 시 이동할 링크는 content에 입력된 값이 사용됩니다.
    public let buttonTitle: String?
    
    /// 버튼 목록. 버튼 타이틀과 링크를 변경하고 싶을때, 버튼 두개를 사용하고 싶을때 사용합니다. (최대 2개)
    /// - seealso: `Button`
    public let buttons : [Button]?
    
    
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
    
    
    public func toJsonObject() -> [String:Any]? {
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(self)) {
            return SdkUtils.toJsonObject(templateJsonData)
        }
        return nil
    }
}

/// 텍스트형 기본 템플릿 클래스 입니다.
public struct TextTemplate : Codable, Templatable {
    
    // MARK: Fields
    
    /// "text" 고정 값
    public let objectType : String
    
    /// 메시지에 들어갈 텍스트 (최대 200자)
    public let text: String
    
    /// 컨텐츠 클릭 시 이동할 링크 정보
    /// - seealso: `Link`
    public let link: Link
    
    /// 기본 버튼 타이틀("자세히 보기")을 변경하고 싶을 때 설정. 이 값을 사용하면 클릭 시 이동할 링크는 content에 입력된 값이 사용됩니다.
    public let buttonTitle: String?
    
    /// 버튼 목록. 버튼 타이틀과 링크를 변경하고 싶을때, 버튼 두개를 사용하고 싶을때 사용합니다. (최대 2개)
    /// - seealso: `Button`
    public let buttons : [Button]?
    
    
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
    
    
    public func toJsonObject() -> [String:Any]? {
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(self)) {
            return SdkUtils.toJsonObject(templateJsonData)
        }
        return nil
    }
}


/// 톡캘린더의 구독 캘린더 또는 공개 일정 정보를 포함한 메시지 형식입니다.
/// 카카오톡 채널의 구독 캘린더 또는 공개 일정을 사용자의 톡캘린더에 추가하는 기능을 제공합니다.
public struct CalendarTemplate : Codable, Templatable {
    
    /// 캘린더 ID 타입 열거형
    public enum IdType : String, Codable {
        /// 이벤트
        case Event = "event"
        /// 캘린더
        case Calendar = "calendar"
    }
    
    // MARK: Fields
    
    /// "calendar" 고정 값
    public let objectType : String
    
    /// 공개 일정 Id or 구독 캘린더 Id
    public let id : String
    
    /// event, calendar 둘 중 하나
    public let idType: IdType
    
    /// 일정에 대해 설명하는 컨텐츠 정보
    /// - seealso: `Content`
    public let content: Content
    
    /// 버튼 목록. 기본 버튼의 타이틀 외에 링크도 변경하고 싶을 때 설정 합니다. (최대 1개, 오른쪽 "위치 보기" 버튼은 고정)
    /// - seealso: `Button`
    public let buttons : [Button]?
    
    
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
    
    public func toJsonObject() -> [String:Any]? {
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(self)) {
            return SdkUtils.toJsonObject(templateJsonData)
        }
        return nil
    }
}
