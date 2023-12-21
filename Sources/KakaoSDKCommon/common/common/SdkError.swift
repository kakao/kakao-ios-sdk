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

/// 카카오 SDK를 사용하면서 발생하는 모든 에러를 나타냅니다.
public enum SdkError : Error {
    
    /// SDK 내에서 발생하는 클라이언트 에러
    case ClientFailed(reason:ClientFailureReason, errorMessage:String?)
    
    /// API 호출 에러
    case ApiFailed(reason:ApiFailureReason, errorInfo:ErrorInfo?)
    
    /// 로그인 에러
    case AuthFailed(reason:AuthFailureReason, errorInfo:AuthErrorInfo?)
    
    /// Apps 에러
    case AppsFailed(reason:AppsFailureReason, errorInfo:AppsErrorInfo?)
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension SdkError {
    public init(reason:ClientFailureReason = .Unknown, message:String? = nil) {
        switch reason {
        case .ExceedKakaoLinkSizeLimit:
            self = .ClientFailed(reason: reason, errorMessage: message ?? "failed to send message because it exceeds the message size limit.")
        case .MustInitAppKey:
            self = .ClientFailed(reason: reason, errorMessage: "initSDK(appKey:) must be initialized.")
        case .Cancelled:
            self = .ClientFailed(reason: reason, errorMessage:message ?? "user cancelled")
        case .NotSupported:
            self = .ClientFailed(reason: reason, errorMessage:message ?? "target app is not installed.")
        case .BadParameter:
            self = .ClientFailed(reason: reason, errorMessage:message ?? "bad parameters.")
        case .TokenNotFound:
            self = .ClientFailed(reason: reason, errorMessage: message ?? "authentication tokens not exist.")
        case .CastingFailed:
            self = .ClientFailed(reason: reason, errorMessage: message ?? "casting failed.")
        case .IllegalState:
            self = .ClientFailed(reason: reason, errorMessage:message ?? "illegal state.")
        case .Unknown:
            self = .ClientFailed(reason: reason, errorMessage:message ?? "unknown error.")
        }
    }
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension SdkError {
    public init?(response:HTTPURLResponse, data:Data, type:ApiType) {
        if 200 ..< 300 ~= response.statusCode { return nil }
        
        switch type {
        case .KApi:
            if let errorInfo = try? SdkJSONDecoder.custom.decode(ErrorInfo.self, from: data) {
                self = .ApiFailed(reason: errorInfo.code, errorInfo:errorInfo)
            }
            else {
                return nil
            }
        case .KAuth:
            if let authErrorInfo = try? SdkJSONDecoder.custom.decode(AuthErrorInfo.self, from: data) {
                self =  .AuthFailed(reason: authErrorInfo.error, errorInfo:authErrorInfo)
            }
            else {
                return nil
            }
        @unknown default:
            return nil
        }
    }
    
    //for Auth
    public init?(parameters: [String: String]) {
        if let authErrorInfo = try? SdkJSONDecoder.custom.decode(AuthErrorInfo.self, from: JSONSerialization.data(withJSONObject: parameters, options: [])) {
            self = .AuthFailed(reason: authErrorInfo.error, errorInfo: authErrorInfo)
        } 
        else {
            return nil
        }
    }
    
    //for Api
    public init(scopes:[String]?) {
        let errorInfo = ErrorInfo(code: .InsufficientScope, msg: "", requiredScopes: scopes)
        self = .ApiFailed(reason: errorInfo.code, errorInfo: errorInfo)
    }
    
    public init(apiFailedMessage:String? = nil) {
        self = .ApiFailed(reason: .Unknown, errorInfo: ErrorInfo(code: .Unknown, msg:apiFailedMessage ?? "Unknown Error", requiredScopes: nil))
    }
    
    //for Apps
    public init?(appsParameters: [String: String]) {
        if let appsErrorInfo = try? SdkJSONDecoder.custom.decode(AppsErrorInfo.self, from: JSONSerialization.data(withJSONObject: appsParameters, options: [])) {
            self = .AppsFailed(reason: appsErrorInfo.errorCode, errorInfo: appsErrorInfo)
        }
        else {
            return nil
        }
    }
}

//helper
extension SdkError {
    
    /// 클라이언트 에러인지 확인합니다.
    /// ## SeeAlso
    /// - ``ClientFailureReason``
    public var isClientFailed : Bool {
        if case .ClientFailed = self {
            return true
        }
        return false
    }
    
    /// API 서버 에러인지 확인합니다.
    /// ## SeeAlso
    /// - ``ApiFailureReason``
    public var isApiFailed : Bool {
        if case .ApiFailed = self {
            return true
        }
        return false
    }
    
    /// 인증 서버 에러인지 확인합니다.
    /// ## SeeAlso
    /// - ``AuthFailureReason``
    public var isAuthFailed : Bool {
        if case .AuthFailed = self {
            return true
        }
        return false
    }
    
    /// APPS 서버 에러인지 확인합니다.
    /// ## SeeAlso
    /// - ``AppsFailureReason``
    public var isAppsFailed : Bool {
        if case .AppsFailed = self {
            return true
        }
        return false
    }
    
    
    /// 클라이언트 에러 정보를 얻습니다. `isClientFailed`가 true인 경우 사용해야 합니다.
    /// ## SeeAlso
    /// - ``ClientFailureReason``
    public func getClientError() -> (reason:ClientFailureReason, message:String?) {
        if case let .ClientFailed(reason, message) = self {
            return (reason, message)
        }
        return (ClientFailureReason.Unknown, nil)
    }
    
    /// API 요청 에러에 대한 정보를 얻습니다. `isApiFailed`가 true인 경우 사용해야 합니다.
    /// ## SeeAlso
    /// - ``ApiFailureReason``
    /// - ``ErrorInfo``
    public func getApiError() -> (reason:ApiFailureReason, info:ErrorInfo?) {
        if case let .ApiFailed(reason, info) = self {
            return (reason, info)
        }
        return (ApiFailureReason.Unknown, nil)
    }
    
    /// 로그인 요청 에러에 대한 정보를 얻습니다. `isAuthFailed`가 true인 경우 사용해야 합니다.
    /// ## SeeAlso
    /// - ``AuthFailureReason``
    /// - ``AuthErrorInfo``
    public func getAuthError() -> (reason:AuthFailureReason, info:AuthErrorInfo?) {
        if case let .AuthFailed(reason, info) = self {
            return (reason, info)
        }
        return (AuthFailureReason.Unknown, nil)
    }
    
    /// APPS 요청 에러에 대한 정보를 얻습니다. `isAppsFailed`가 true인 경우 사용해야 합니다.
    /// ## SeeAlso
    /// - ``AppsFailureReason``
    /// - ``AppsErrorInfo``
    public func getAppsError() -> (reason:AppsFailureReason, info:AppsErrorInfo?) {
        if case let .AppsFailed(reason, info) = self {
            return (reason, info)
        }
        return (AppsFailureReason.Unknown, nil)
    }
    
    /// 유효하지 않은 토큰 에러인지 체크합니다.
    public func isInvalidTokenError() -> Bool {
        if case .ApiFailed = self, getApiError().reason == .InvalidAccessToken {
            return true
        }
        else if case .AuthFailed = self, getAuthError().reason == .InvalidGrant {
            return true
        }
        
        return false
    }
}

//MARK: - error code enum


/// 클라이언트 에러 종류 입니다.
public enum ClientFailureReason {
    
    /// 기타 에러
    case Unknown
    
    /// 사용자의 취소 액션 등
    case Cancelled
    
    /// API 요청에 사용할 토큰이 없음
    case TokenNotFound
    
    /// 지원되지 않는 기능
    case NotSupported
    
    /// 잘못된 파라미터
    case BadParameter
    
    /// SDK 초기화를 하지 않음
    case MustInitAppKey
    
    /// 카카오톡 공유 템플릿 용량 초과
    case ExceedKakaoLinkSizeLimit
    
    /// type casting 실패
    case CastingFailed
    
    /// 정상적으로 실행할 수 없는 상태
    case IllegalState
}

/// API 서버 에러 종류 입니다.
public enum ApiFailureReason : Int, Codable {
    
    /// 기타 서버 에러
    case Unknown = -9999
    
    /// 기타 서버 에러
    case Internal = -1
    
    /// 잘못된 파라미터
    case BadParameter = -2
    
    /// 지원되지 않는 API
    case UnsupportedApi = -3
    
    /// API 호출이 금지됨
    case Blocked = -4
    
    /// 호출 권한이 없음
    case Permission = -5
    
    /// 더이상 지원하지 않은 API를 요청한 경우
    case DeprecatedApi = -9
    
    /// 쿼터 초과
    case ApiLimitExceed = -10
    
    /// 연결되지 않은 사용자
    case NotSignedUpUser = -101
    
    /// 이미 연결된 사용자에 대해 signup 시도
    case AlreadySignedUpUsercase = -102
    
    /// 존재하지 않는 카카오계정
    case NotKakaoAccountUser = -103
    
    /// 등록되지 않은 user property key
    case InvalidUserPropertyKey = -201
    
    /// 등록되지 않은 앱키의 요청 또는 존재하지 않는 앱으로의 요청. (앱키가 인증에 사용되는 경우는 -401 참조)
    case NoSuchApp = -301
    
    /// 앱키 또는 토큰이 잘못된 경우. 예) 토큰 만료
    case InvalidAccessToken = -401
    
    /// 해당 API에서 접근하는 리소스에 대해 사용자의 동의를 받지 않음
    case InsufficientScope = -402
    
    ///연령인증이 필요함
    case RequiredAgeVerification = -405
    
    ///연령제한에 걸림
    case UnderAgeLimit = -406
    
    //TODO: aos와 이름 맞춰야 함.
    ///아직 서명이 완료되지 않은 경우 (papi error code=E2006)
    case SigningIsNotCompleted = -421
    
    ///전자서명 유효시간 내에(5분) 서명이 완료되지 않은 경우 (papi error code=E2007)
    case InvalidTransaction = -422
    
    ///public key 유효시간(24시간)이 expired 된 경우 (papi error code=E2016)
    case TransactionHasExpired = -423
    

    /// 앱의 연령제한보다 사용자의 연령이 낮음
    case LowerAgeLimit = -451

    /// 이미 연령인증이 완료 됨
    case AlreadyAgeAuthorized = -452

    /// 연령인증 허용 횟수 초과
    case AgeCheckLimitExceed = -453

    /// 이전 연령인증과 일치하지 않음
    case AgeResultMismatched = -480

    /// CI 불일치
    case CIResultMismatched = -481
    
    /// 카카오톡 사용자가 아님
    case NotTalkUser = -501
    
    /// 지원되지 않는 기기로 메시지 보내는 경우
    case UserDevicedUnsupported = -504
    
    /// 메시지 수신자가 수신을 거부한 경우
    case TalkMessageDisabled = -530
    
    /// 월간 메시지 전송 허용 횟수 초과
    case TalkSendMessageMonthlyLimitExceed = -531
    
    /// 일간 메시지 전송 허용 횟수 초과
    case TalkSendMessageDailyLimitExceed = -532
        
    /// 이미지 업로드 시 최대 용량을 초과한 경우
    case ImageUploadSizeExceed = -602
    
    /// 카카오 플랫폼 내부에서 요청 처리 중 타임아웃이 발생한 경우
    case ServerTimeout = -603
    
    /// 이미지 업로드시 허용된 업로드 파일 수가 넘을 경우
    case ImageMaxUploadNumberExceed = -606
    
    /// 서버 점검 중
    case UnderMaintenance = -9798
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension ApiFailureReason {
    public init(from decoder: Decoder) throws {
        self = try ApiFailureReason(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .Unknown
    }
}

/// 로그인 요청 에러 종류 입니다.
public enum AuthFailureReason : String, Codable {
    
    /// 기타 에러
    case Unknown = "unknown"
    
    /// 요청 파라미터 오류
    case InvalidRequest = "invalid_request"
    
    /// 유효하지 않은 앱
    case InvalidClient = "invalid_client"
    
    /// 유효하지 않은 scope
    case InvalidScope = "invalid_scope"
    
    /// 인증 수단이 유효하지 않아 인증할 수 없는 상태
    case InvalidGrant = "invalid_grant"
    
    /// 설정이 올바르지 않음. 예) bundle id
    case Misconfigured = "misconfigured"
    
    /// 앱이 요청 권한이 없음
    case Unauthorized = "unauthorized"
    
    /// 접근이 거부 됨 (동의 취소)
    case AccessDenied = "access_denied"
    
    /// 서버 내부 에러
    case ServerError = "server_error"
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    /// 카카오싱크 전용
    case AutoLogin = "auto_login"
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension AuthFailureReason {
    public init(from decoder: Decoder) throws {
        self = try AuthFailureReason(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .Unknown
    }
}

/// Apps 요청 에러 종류 입니다.
public enum AppsFailureReason : String, Codable {
    /// 내부 서버 에러가 발생하는 경우
    case InternalServerError = "KAE001"

    /// 잘못된 요청을 사용하는 경우
    case InvalidRequest = "KAE002"

    /// 잘못된 파라미터를 사용하는 경우
    case InvalidParameter = "KAE003"

    /// 유효시간이 만료된 경우
    case TimeExpired = "KAE004"
    
    /// 채널 정보를 확인할 수 없는 경우
    case InvalidChannel = "KAE005"
    
    /// 채널 추가 가능한 상태가 아닌 경우
    case IllegalStateChannel = "KAE006"

    /// API를 사용할 수 없는 앱 타입인 경우
    case AppTypeError = "KAE101"

    /// API 사용에 필요한 scope이 설정되지 않은 경우
    case AppScopeError = "KAE102"

    /// API 사용에 필요한 권한이 없는 경우
    case PermissionError = "KAE103"

    /// API 호출에 사용할 수 없는 앱키 타입으로 API를 호출하는 경우
    case AppKeyTypeError = "KAE104"
    
    /// 앱과 연결되지 않은 채널 정보로 요청한 경우
    case AppChannelNotConnected = "KAE105"

    /// Access Token, KPIDT, 톡세션 등으로 앱 유저 인증에 실패하는 경우
    case AuthError = "KAE201"

    /// 앱에 연결되지 않은 유저가 API를 호출하는 경우
    case NotRegistredUser = "KAE202"

    /// API 호출에 필요한 scope에 동의하지 않은 경우
    case InvalidScope = "KAE203"

    /// API 사용에 필요한 계정 약관 동의가 되어 있지 않은 경우
    case AccountTermsError = "KAE204"

    /// 계정 페이지에서 배송지 콜백으로 로그인 필요 응답을 전달하는 경우
    case LoginRequired = "KAE205"

    /// 계정에 등록되어있지 않은 배송지 ID를 파라미터로 사용하는 경우
    case InvalidShippingAddressId = "KAE206"
    
    /// 예외
    case Unknown
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension AppsFailureReason {
    public init(from decoder: Decoder) throws {
        self = try AppsFailureReason(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .Unknown
    }
}
