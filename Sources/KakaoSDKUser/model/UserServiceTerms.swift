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

/// 서비스 약관 조회 API 응답 클래스
/// - seealso: `UserApi.serviceTerms()`
public struct UserServiceTerms : Codable {
    
    // MARK: Fields
    
    /// 회원 번호
    public let id: Int64
    
    /// 조회한 서비스 약관 목록
    /// - seealso: `ServiceTerms`
    public let serviceTerms: [ServiceTerms]?
}

/// 3rd party 서비스 약관 정보 클래스
/// - seealso: `UserServiceTerms`
public struct ServiceTerms : Codable {
    
    // MARK: Fields
    
    /// 3rd에서 동의한 약관의 항목들을 정의한 값
    public let tag: String
    
    /// 최근 동의 시각
    public let agreedAt: Date?
    
    /// 동의  여부
    public let agreed: Bool
    
    /// 필수 동의 여부
    public let required: Bool
    
    /// 철회 가능 여부
    public let revocable: Bool
}

/// 서비스 약관 철회 API 응답 클래스
/// - seealso: `RevokedServiceTerms`
public struct UserRevokedServiceTerms : Codable {
    
    // MARK: Fields
    
    /// 회원 번호
    public var id: Int64
    
    /// 동의 철회가 반영된 서비스 약관 목록
    public var revokedServiceTerms: [RevokedServiceTerms]?
}

/// 동의 철회가 반영된 서비스  약관 클래스
/// - seealso: `UserRevokedServiceTerms`
public struct RevokedServiceTerms : Codable {
    
    // MARK: Fields
    
    /// 3rd에서 설정한 서비스 약관의 tag
    public let tag: String
    
    /// 동의 여부
    public let agreed: Bool
}
