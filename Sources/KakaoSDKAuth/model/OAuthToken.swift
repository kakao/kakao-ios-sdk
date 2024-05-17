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

/// 카카오 로그인으로 발급받은 토큰 \
/// Tokens issued with Kakao Login
public struct OAuthToken: Codable {
    
    // MARK: Fields
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    /// 토큰 타입. 현재는 "Bearer" 타입만 사용됩니다.
    public let tokenType: String

    /// 액세스 토큰 \
    /// Access token
    public let accessToken: String
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    /// 액세스 토큰의 남은 만료시간 (단위: 초)
    public let expiresIn: TimeInterval
    
    /// 액세스 토큰 만료시각 \
    /// The expiration time of the access token
    public let expiredAt: Date
    
    /// 리프레시 토큰 \
    /// Refresh token
    public let refreshToken: String
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    /// 리프레시 토큰의 남은 만료시간 (단위: 초)
    public let refreshTokenExpiresIn: TimeInterval
    
    /// 리프레시 토큰 만료시각 \
    /// The expiration time of the refresh token
    public let refreshTokenExpiredAt: Date
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public let scope: String? //space delimited string
    
    // 인가 코드를 사용한 토큰 신규 발급 시점에만 저장되고 이후 같은 값으로 유지, 토큰 갱신으로는 최신정보로 업데이트되지 않음
    /// 인가된 동의항목 \
    /// Authorized scopes
    public let scopes: [String]?
    
    /// ID 토큰 \
    /// ID token
    public let idToken: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken, expiresIn, tokenType, refreshToken, refreshTokenExpiresIn, scope, idToken
    }
    
    
    // MARK: Initializers
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.accessToken = try values.decode(String.self, forKey: .accessToken)
        self.expiresIn = try values.decode(TimeInterval.self, forKey: .expiresIn)
        self.expiredAt = Date().addingTimeInterval(self.expiresIn)
        self.tokenType = try values.decode(String.self, forKey: .tokenType)
        self.refreshToken = try values.decode(String.self, forKey: .refreshToken)
        self.refreshTokenExpiresIn = try values.decode(TimeInterval.self, forKey: .refreshTokenExpiresIn)
        self.refreshTokenExpiredAt = Date().addingTimeInterval(self.refreshTokenExpiresIn)
        self.scope = try? values.decode(String.self, forKey: .scope)
        self.scopes = scope?.components(separatedBy:" ")
        self.idToken = try? values.decode(String.self, forKey: .idToken)
    }
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public init(accessToken: String,
                expiresIn: TimeInterval? = nil,
                expiredAt: Date? = nil,
                tokenType: String,
                refreshToken: String,
                refreshTokenExpiresIn: TimeInterval? = nil,
                refreshTokenExpiredAt: Date? = nil,
                scope: String?,
                scopes: [String]?,
                idToken: String? = nil) {
        
        self.accessToken = accessToken
        self.expiresIn = (expiresIn != nil) ? expiresIn! : 0
        
        if let expiredAt = expiredAt {
            self.expiredAt = expiredAt
        }
        else {
            self.expiredAt = (self.expiresIn == 0) ? Date(timeIntervalSince1970: 0) : Date().addingTimeInterval(self.expiresIn)
        }
        
        self.tokenType = tokenType
        self.refreshToken = refreshToken
        self.refreshTokenExpiresIn = (refreshTokenExpiresIn != nil) ? refreshTokenExpiresIn! : 0
        if let refreshTokenExpiredAt = refreshTokenExpiredAt {
            self.refreshTokenExpiredAt = refreshTokenExpiredAt
        }
        else {
            self.refreshTokenExpiredAt = (self.refreshTokenExpiresIn == 0) ? Date(timeIntervalSince1970: 0) : Date().addingTimeInterval(self.refreshTokenExpiresIn)
        }
        self.scope = scope
        self.scopes = scopes
        self.idToken = idToken
    }
    
    static func ==(left:OAuthToken, right:OAuthToken) -> Bool {
        if (left.accessToken == right.accessToken) {
            return true
        }
        else {
            return false
        }
    }
    
    static func !=(left:OAuthToken, right:OAuthToken) -> Bool {
        if (left.accessToken != right.accessToken) {
            return true
        }
        else {
            return false
        }
    }
    
//    static func ==(left:OAuthToken, right:OAuthToken) -> Bool {
//        if (left.accessToken == right.accessToken &&
//            left.expiresIn == right.expiresIn &&
//            left.tokenType == right.tokenType &&
//            left.refreshToken == right.refreshToken &&
//            left.refreshTokenExpiresIn == right.refreshTokenExpiresIn &&
//            left.scope == right.scope) {
//            return true
//        }
//        else {
//            return false
//        }
//    }
//    
//    static func !=(left:OAuthToken, right:OAuthToken) -> Bool {
//        if (left.accessToken != right.accessToken ||
//            left.expiresIn != right.expiresIn ||
//            left.tokenType != right.tokenType ||
//            left.refreshToken != right.refreshToken ||
//            left.refreshTokenExpiresIn != right.refreshTokenExpiresIn ||
//            left.scope != right.scope) {
//            return true
//        }
//        else {
//            return false
//        }
//    }
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
public struct Token: Codable {
    public let accessToken: String
    public let expiresIn: TimeInterval
    public let tokenType: String
    public let refreshToken: String?
    public let refreshTokenExpiresIn: TimeInterval?
    public let scope: String? //space delimited string
    public let scopes: [String]?
    public let idToken: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken, expiresIn, tokenType, refreshToken, refreshTokenExpiresIn, scope, idToken
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        accessToken = try values.decode(String.self, forKey: .accessToken)
        expiresIn = try values.decode(TimeInterval.self, forKey: .expiresIn)
        tokenType = try values.decode(String.self, forKey: .tokenType)
        refreshToken = try? values.decode(String.self, forKey: .refreshToken)
        refreshTokenExpiresIn = try? values.decode(TimeInterval.self, forKey: .refreshTokenExpiresIn)
        scope = try? values.decode(String.self, forKey: .scope)
        scopes = scope?.components(separatedBy:" ")
        idToken = try? values.decode(String.self, forKey: .idToken)
    }
}


#if swift(>=5.8)
@_documentation(visibility: private)
#endif
/// internal use only
public struct CertOAuthToken: Codable {
    public let tokenType: String
    public let accessToken: String
    public let expiresIn: TimeInterval
    public let expiredAt: Date
    public let refreshToken: String
    public let refreshTokenExpiresIn: TimeInterval
    public let refreshTokenExpiredAt: Date
    public let scope: String? //space delimited string
    public let scopes: [String]?
    public let txId: String?
    public let idToken: String?
    
    
    enum CodingKeys: String, CodingKey {
        case accessToken, expiresIn, tokenType, refreshToken, refreshTokenExpiresIn, scope, txId, idToken
    }
    
    
    // MARK: Initializers
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.accessToken = try values.decode(String.self, forKey: .accessToken)
        self.expiresIn = try values.decode(TimeInterval.self, forKey: .expiresIn)
        self.expiredAt = Date().addingTimeInterval(self.expiresIn)
        self.tokenType = try values.decode(String.self, forKey: .tokenType)
        self.refreshToken = try values.decode(String.self, forKey: .refreshToken)
        self.refreshTokenExpiresIn = try values.decode(TimeInterval.self, forKey: .refreshTokenExpiresIn)
        self.refreshTokenExpiredAt = Date().addingTimeInterval(self.refreshTokenExpiresIn)
        self.scope = try? values.decode(String.self, forKey: .scope)
        self.scopes = scope?.components(separatedBy:" ")
        self.txId = try? values.decode(String.self, forKey: .txId)
        self.idToken = try? values.decode(String.self, forKey: .idToken)
    }
}

/// 토큰 정보와 전자서명 접수번호 \
/// Token information and transaction ID
public struct CertTokenInfo: Codable {
    /// 토큰 정보 \
    /// Token information
    public let token: OAuthToken
    
    /// 전자서명 접수번호 \
    /// Transaction ID
    public let txId: String
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public init(token:OAuthToken,
                txId:String) {
        self.token = token
        self.txId = txId
    }
}

/// 상품 종류 \
/// Product type
public enum CertType: String {
    
    /// K2100, 카카오톡 인증 로그인 \
    /// K2100, Kakao Talk Certification Login
    case K2100 = "k2100"
    
    /// K2220, 카카오톡 축약서명 \
    /// K2220, Kakao Talk Abbreviated signature
    case K2220 = "k2220"
    
    /// K3220, 축약서명 \
    /// K3220, Abbreviated signature
    case K3220 = "k3220"
}

/// 확인할 서명자 정보 \
/// Signer information to verify
public enum IdentifyItem: String {
    /// 전화번호 \
    /// Phone number
    case PhoneNumber = "phone_number"
    /// 연계 정보 \
    ///  Connecting Information (CI)
    case CI = "ci"
    /// 이름 \
    ///  Name
    case Name = "name"
    /// 생일 \
    /// Birthday
    case Birthday = "birthday"
}
