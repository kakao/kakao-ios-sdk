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

/// 사용자 정보 가져오기 응답 \
/// Response for Retrieve user information
/// ## SeeAlso
/// - ``UserApi/me(propertyKeys:secureResource:completion:)``
public struct User : Codable {
    
    // MARK: Fields
    
    /// 회원번호 \
    /// Service user ID
    public let id: Int64?
    
    /// 사용자 프로퍼티 \
    /// User properties
    public let properties: [String:String]?
    
    /// 카카오계정 정보 \
    /// Kakao Account information
    /// ## SeeAlso
    /// - ``Account``
    public let kakaoAccount: Account?
    
    /// 그룹에서 맵핑 정보로 사용할 수 있는 값 \
    /// Token to map users in the group apps
    public let groupUserToken: String?
    
    /// 서비스에 연결 완료된 시각, UTC \
    /// Time connected to the service, UTC
    public let connectedAt : Date?
    
    /// 카카오싱크 간편가입을 통해 로그인한 시각, UTC \
    /// The time when the user is logged in through Kakao Sync Simple Signup, UTC
    public let synchedAt : Date?
    
    /// 연결하기 호출의 완료 여부 \
    /// Whether the user is completely linked with the app
    public let hasSignedUp: Bool?
    
    /// 다른 사용자의 친구 정보에서 보여지는 해당 사용자의 고유 ID \
    /// Unique ID for the friend information
    public let uuid: String?
    
    enum CodingKeys: String, CodingKey {
        case id, properties, kakaoAccount, groupUserToken, connectedAt, synchedAt, hasSignedUp
        case uuid = "forPartner"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try? container.decode(Int64.self, forKey: .id)
        self.properties = try? container.decode([String : String].self, forKey: .properties)
        self.kakaoAccount = try? container.decode(Account.self, forKey: .kakaoAccount)
        self.groupUserToken = try? container.decode(String.self, forKey: .groupUserToken)
        self.connectedAt = try? container.decode(Date.self, forKey: .connectedAt)
        self.synchedAt = try? container.decode(Date.self, forKey: .synchedAt)
        self.hasSignedUp = try? container.decode(Bool.self, forKey: .hasSignedUp)
        
        let forPartner = try? container.decode([String:Any].self, forKey: .uuid)
        self.uuid = forPartner?["uuid"] as? String
    }
}

// MARK: Enumerations

/// 연령대 \
/// Age range
public enum AgeRange : String, Codable {
    /// 0세~9세 \
    /// 0 to 9 years old
    case Age0_9  = "0~9"
    /// 10세~14세 \
    /// 10 to 14 years old
    case Age10_14 = "10~14"
    /// 15세~19세 \
    /// 15 to 19 years old
    case Age15_19 = "15~19"
    /// 20세~29세 \
    /// 20 to 29 years old
    case Age20_29 = "20~29"
    /// 30세~39세 \
    /// 30 to 39 years old
    case Age30_39 = "30~39"
    /// 40세~49세 \
    /// 40 to 49 years old
    case Age40_49 = "40~49"
    /// 50세~59세 \
    /// 50 to 59 years old
    case Age50_59 = "50~59"
    /// 60세~69세 \
    /// 60 to 69 years old
    case Age60_69 = "60~69"
    /// 70세~79세 \
    /// 70 to 79 years old
    case Age70_79 = "70~79"
    /// 80세~89세 \
    /// 80 to 89 years old
    case Age80_89 = "80~89"
    /// 90세 이상 \
    /// Over 90 years old
    case Age90_Above = "90~"
}

/// 성별 \
/// Gender
public enum Gender : String, Codable {
    /// 남자 \
    /// Male
    case Male = "male"
    /// 여자 \
    /// Female
    case Female = "female"
}

/// 생일 타입 \
/// Birthday type
public enum BirthdayType : String, Codable {
    /// 양력 \
    /// Solar
    case Solar = "SOLAR"
    /// 음력 \
    /// Lunar
    case Lunar = "LUNAR"
}

/// 카카오계정 정보 \
/// Kakao Account information
/// ## SeeAlso
/// - ``User/kakaoAccount``

public struct Account : Codable {
    
    // MARK: Fields
    
    /// 사용자 동의 시 프로필 제공 가능 여부 \
    /// Whether ``profile`` can be provided under user consent
    public let profileNeedsAgreement: Bool?
    /// 사용자 동의 시 닉네임 제공 가능 여부 \
    /// Whether ``Profile/nickname`` can be provided under user consent
    public let profileNicknameNeedsAgreement: Bool?    
    /// 사용자 동의 시 프로필 사진 제공 가능 여부 \
    /// Whether ``Profile/profileImageUrl`` can be provided under user consent
    public let profileImageNeedsAgreement: Bool?
    
    /// 프로필 정보 \
    /// Profile information
    /// ## SeeAlso
    /// - ``Profile``
    public let profile: Profile?
    
    /// 사용자 동의 시 이름 제공 가능 여부 \
    /// Whether ``name`` can be provided under user consent
    public let nameNeedsAgreement: Bool?
    /// 카카오계정 이름 \
    /// Name of Kakao Account
    public let name: String?
    
    /// 사용자 동의 시 카카오계정 대표 이메일 제공 가능 여부 \
    /// Whether ``email`` can be provided under user consent
    public let emailNeedsAgreement: Bool?
    /// 이메일 유효 여부 \
    /// Whether email address is valid
    public let isEmailValid: Bool?
    /// 이메일 인증 여부 \
    /// Whether email address is verified
    public let isEmailVerified: Bool?
    /// 카카오계정 대표 이메일 \
    /// Representative email of Kakao Account
    public let email: String?
    
    /// 사용자 동의 시 연령대 제공 가능 여부 \
    /// Whether ``ageRange`` can be provided under user consent
    public let ageRangeNeedsAgreement: Bool?
    /// 연령대 \
    /// Age range
    /// ## SeeAlso
    /// - ``AgeRange``
    public let ageRange: AgeRange?
    /// 사용자 동의 시 출생 연도 제공 가능 여부 \
    /// Whether ``birthyear`` can be provided under user consent
    public let birthyearNeedsAgreement: Bool?
    /// 출생 연도, YYYY 형식 \
    /// Birthyear in YYYY format
    public let birthyear: String?
    /// 사용자 동의 시 생일 제공 가능 여부 \
    /// Whether ``birthday`` can be provided under user consent
    public let birthdayNeedsAgreement: Bool?
    /// 생일, MMDD 형식 \
    /// Birthday in MMDD format
    public let birthday: String?
    /// 생일 타입 \
    /// Birthday type
    public let birthdayType: BirthdayType?
    
    /// 사용자 동의 시 성별 제공 가능 여부 \
    /// Whether ``gender`` can be provided under user consent
    public let genderNeedsAgreement: Bool?
    /// 성별 \
    /// Gender
    /// ## SeeAlso
    /// - ``Gender``
    public let gender: Gender?
    
    /// 사용자 동의 시 전화번호 제공 가능 여부 \
    /// Whether ``phoneNumber`` can be provided under user consent
    public let phoneNumberNeedsAgreement: Bool?
    /// 카카오계정의 전화번호 \
    /// Phone number of Kakao Account
    public let phoneNumber: String?
    

    
    /// 사용자 동의 시 실명 제공 가능 여부 \
    /// Whether ``legalName`` can be provided under user consent
    public let legalNameNeedsAgreement : Bool?
    
    /// 실명 \
    /// Legal name
    public let legalName : String?
        
    /// 사용자 동의 시 법정 생년월일 제공 가능 여부 \
    /// Whether ``isKorean`` can be provided under user consent
    public let legalBirthDateNeedsAgreement : Bool?
    
    /// 법정 생년월일, yyyyMMDD 형식 \
    /// Legal birth date in yyyyMMDD format
    public let legalBirthDate : String?
    
    /// 사용자 동의 시 법정 성별 제공 가능 여부 \
    /// Whether ``legalGender`` can be provided under user consent
    public let legalGenderNeedsAgreement : Bool?
    
    /// 법정 성별 \
    /// Legal gender
    public let legalGender : Gender?
    
    /// 사용자 동의 시 내외국인 제공 가능 여부 \
    /// Whether ``isKorean`` can be provided under user consent
    public let isKoreanNeedsAgreement : Bool?
    
    /// 본인인증을 거친 내국인 여부 \
    /// Whether the user is Korean
    public let isKorean : Bool?
}

/// 프로필 정보 \
/// Profile information
/// ## SeeAlso
/// - ``Account/profile``
public struct Profile : Codable {
    
    // MARK: Fields

    /// 닉네임 \
    /// Nickname
    public let nickname: String?
    
    // 사용자가 프로필 이미지를 등록하지 않은 경우 nil
    // 사용자가 등록한 프로필 이미지가 사진인 경우 640 * 640 규격의 이미지, 동영상인 경우 480 * 480 규격의 스냅샷 이미지 제공
    /// 프로필 사진 URL \
    /// Profile image URL
    public let profileImageUrl: URL?
    
    // 사용자가 프로필 이미지를 등록하지 않은 경우 nil
    // 사용자가 등록한 프로필 이미지가 사진인 경우 110 * 110 규격의 이미지, 동영상인 경우 100 * 100 규격의 스냅샷 이미지 제공
    /// 프로필 미리보기 이미지 URL \
    /// Thumbnail image URL
    public let thumbnailImageUrl: URL?
    
    /// 프로필 사진 URL이 기본 프로필 사진 URL인지 여부 \
    /// Whether the default image is used for profile image
    public let isDefaultImage: Bool?
    
    enum CodingKeys : String, CodingKey {
        case nickname, profileImageUrl, thumbnailImageUrl, isDefaultImage
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        nickname = try? values.decode(String.self, forKey: .nickname)
        profileImageUrl = URL(string: (try? values.decode(String.self, forKey: .profileImageUrl)) ?? "")
        thumbnailImageUrl = URL(string: (try? values.decode(String.self, forKey: .thumbnailImageUrl)) ?? "")
        isDefaultImage = try? values.decode(Bool.self, forKey: .isDefaultImage)
    }
}

