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

/// SDK 내부 동작 에러 \
/// SDK internal operation errors
public enum SdkError : Error {
    
    /// 클라이언트 에러 \
    /// Client errors
    case ClientFailed(reason:ClientFailureReason, errorMessage:String?)
    
    /// API 에러  \
    /// API errors
    case ApiFailed(reason:ApiFailureReason, errorInfo:ErrorInfo?)
    
    /// 인증 및 인가 에러 \
    /// Authorization or authentication errors
    case AuthFailed(reason:AuthFailureReason, errorInfo:AuthErrorInfo?)
    
    /// Apps 에러 \
    /// Apps error
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
    
    /// 클라이언트 에러인지 확인 \
    /// Checks if the error is a client error
    /// ## SeeAlso
    /// - ``ClientFailureReason``
    public var isClientFailed : Bool {
        if case .ClientFailed = self {
            return true
        }
        return false
    }
    
    /// API 에러인지 확인 \
    /// Checks if the error is a API error
    /// ## SeeAlso
    /// - ``ApiFailureReason``
    public var isApiFailed : Bool {
        if case .ApiFailed = self {
            return true
        }
        return false
    }
    
    /// 인증 및 인가 에러인지 확인 \
    /// Checks if the error is a authorization or authentication error
    /// ## SeeAlso
    /// - ``AuthFailureReason``
    public var isAuthFailed : Bool {
        if case .AuthFailed = self {
            return true
        }
        return false
    }
    
    /// Apps 에러인지 확인 \
    /// Checks if the error is a Apps error
    /// ## SeeAlso
    /// - ``AppsFailureReason``
    public var isAppsFailed : Bool {
        if case .AppsFailed = self {
            return true
        }
        return false
    }
    
    
    // `isClientFailed`가 true인 경우 사용
    /// 클라이언트 에러 정보 확인 \
    /// Returns the client error information
    /// ## SeeAlso
    /// - ``ClientFailureReason``
    public func getClientError() -> (reason:ClientFailureReason, message:String?) {
        if case let .ClientFailed(reason, message) = self {
            return (reason, message)
        }
        return (ClientFailureReason.Unknown, nil)
    }
    
    // `isApiFailed`가 true인 경우 사용
    /// API 에러 정보 확인 \
    /// Returns the API error information
    /// ## SeeAlso
    /// - ``ApiFailureReason``
    /// - ``ErrorInfo``
    public func getApiError() -> (reason:ApiFailureReason, info:ErrorInfo?) {
        if case let .ApiFailed(reason, info) = self {
            return (reason, info)
        }
        return (ApiFailureReason.Unknown, nil)
    }
    
    // `isAuthFailed`가 true인 경우 사용
    /// 인증 및 인가 에러 정보 확인 \
    /// Returns the authorization or authentication error information
    /// ## SeeAlso
    /// - ``AuthFailureReason``
    /// - ``AuthErrorInfo``
    public func getAuthError() -> (reason:AuthFailureReason, info:AuthErrorInfo?) {
        if case let .AuthFailed(reason, info) = self {
            return (reason, info)
        }
        return (AuthFailureReason.Unknown, nil)
    }
    
    // `isAppsFailed`가 true인 경우 사용
    /// Apps 에러 정보 확인 \
    /// Returns the Apps error information
    /// ## SeeAlso
    /// - ``AppsFailureReason``
    /// - ``AppsErrorInfo``
    public func getAppsError() -> (reason:AppsFailureReason, info:AppsErrorInfo?) {
        if case let .AppsFailed(reason, info) = self {
            return (reason, info)
        }
        return (AppsFailureReason.Unknown, nil)
    }
    
    /// 유효하지 않은 토큰으로 인한 에러인지 확인 \
    /// Checks if the error caused by an invalid token
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


/// 클라이언트 에러 원인 \
/// Reasons for client errors
public enum ClientFailureReason {
    
    /// 알 수 없음 \
    /// Unknown
    case Unknown
    
    /// 사용자가 취소한 경우 \
    /// User canceled
    case Cancelled
    
    /// API 요청에 사용할 토큰이 없는 경우 \
    /// A token for API requests not found
    case TokenNotFound
    
    /// 지원하지 않는 기능 \
    /// Not supported feature
    case NotSupported
    
    /// 잘못된 파라미터를 전달한 경우 \
    /// Passed wrong parameters
    case BadParameter
    
    /// Kakao SDK를 초기화하지 않음 \
    /// Kakao SDK is not initialized
    case MustInitAppKey
    
    /// 카카오톡 공유 메시지 템플릿 용량 초과 \
    /// Exceeded the size limit of the message template for Kakao Talk Sharing
    case ExceedKakaoLinkSizeLimit
    
    /// 타입 캐스팅 실패 \
    /// Failed type casting
    case CastingFailed
    
    /// 요청을 정상적으로 처리할 수 없는 상태 \
    /// Illegal state to process the request
    case IllegalState
}

/// API 에러 원인 \
/// Reasons for API errors
public enum ApiFailureReason : Int, Codable {
    
    /// 알 수 없음 \
    /// Unknown
    case Unknown = -9999
    
    /// 서버 내부에서 처리 중 에러가 발생한 경우 \
    /// An Error occurred during the internal processing on the server
    case Internal = -1
    
    /// 필수 파라미터가 포함되지 않았거나, 파라미터 값이 올바르지 않은 경우 \
    /// Requested without required parameters or using invalid values
    case BadParameter = -2
    
    /// API 사용에 필요한 사전 설정을 완료하지 않은 경우 \
    /// Required prerequisites for the API are not completed
    case UnsupportedApi = -3
    
    /// 카카오계정이 제재되었거나, 카카오계정에 제한된 동작을 요청한 경우 \
    /// Requested by a blocked Kakao Account, or requested restricted actions to the Kakao Account
    case Blocked = -4
    
    /// 앱에 사용 권한이 없는 API를 호출한 경우 \
    /// Requested an API using an app that does not have permission
    case Permission = -5
    
    /// 제공 종료된 API를 호출한 경우 \
    /// Requested a deprecated API
    case DeprecatedApi = -9
    
    /// 사용량 제한을 초과한 경우 \
    /// Exceeded the quota
    case ApiLimitExceed = -10
    
    /// 앱과 연결되지 않은 사용자가 요청한 경우 \
    /// Requested by a user who is not linked to the app
    case NotSignedUpUser = -101
    
    /// 이미 앱과 연결되어 있는 사용자에 대해 연결하기 요청한 경우 \
    /// Requested manual sign-up to a linked user
    case AlreadySignedUpUsercase = -102
    
    /// 휴면 상태, 또는 존재하지 않는 카카오계정으로 요청한 경우 \
    /// Requested with a Kakao Account that is in the dormant state or does not exist
    case NotKakaoAccountUser = -103
    
    /// 앱에 추가하지 않은 사용자 프로퍼티 키 값을 불러오거나 저장하려고 한 경우 \
    /// Requested to retrieve or save value for not registered user properties key
    case InvalidUserPropertyKey = -201
    
    /// 등록되지 않은 앱 키로 요청했거나, 존재하지 않는 앱에 대해 요청한 경우 \
    /// Requested with an app key of not registered app, or requested to an app that does not exist
    case NoSuchApp = -301
    
    /// 유효하지 않은 앱 키나 액세스 토큰으로 요청했거나, 앱 정보가 등록된 앱 정보와 일치하지 않는 경우 \
    /// Requested with an invalid app key or an access token, or the app information is not equal to the registered app information
    case InvalidAccessToken = -401
    
    /// 접근하려는 리소스에 대해 사용자 동의를 받지 않은 경우 \
    /// The user has not agreed to the scope of the desired resource
    case InsufficientScope = -402
    
    /// 연령인증 필요 \
    /// Age verification is required
    case RequiredAgeVerification = -405
    
    /// 앱에 설정된 제한 연령보다 사용자의 연령이 낮음 \
    /// User's age does not meet the app's age limit
    case UnderAgeLimit = -406
    
    //TODO: aos와 이름 맞춰야 함.
    // papi error code=E2006
    /// 서명이 완료되지 않은 경우 \
    /// Signing is not completed
    case SigningIsNotCompleted = -421
    
    // papi error code=E2007
    /// 유효시간 안에 서명이 완료되지 않은 경우 \
    /// Signing is not completed in the valid time
    case InvalidTransaction = -422
    
    // papi error code=E2016
    /// 공개 키가 만료된 경우 \
    /// The public key has been expired
    case TransactionHasExpired = -423
    

    /// 14세 미만 미허용 설정이 되어 있는 앱으로 14세 미만 사용자가 API 호출한 경우 \
    /// Users under age 14 requested in the app that does not allow users under age 14
    case LowerAgeLimit = -451

    /// 이미 연령인증을 완료함 \
    /// Age verification is already completed
    case AlreadyAgeAuthorized = -452

    /// 연령인증 요청 제한 회수 초과 \
    /// Exceeded the limit of request for the age verification
    case AgeCheckLimitExceed = -453

    /// 기존 연령인증 결과와 일치하지 않음 \
    /// The result is not equal to the previous result of age verification
    case AgeResultMismatched = -480

    /// CI 불일치 \
    /// CI is mismatched
    case CIResultMismatched = -481
    
    /// 카카오톡 미가입 사용자가 카카오톡 API를 호출한 경우 \
    /// Users not signed up for Kakao Talk requested the Kakao Talk APIs
    case NotTalkUser = -501
    
    /// 지원되지 않는 기기로 메시지를 전송한 경우 \
    /// Sent message to an unsupported device
    case UserDevicedUnsupported = -504
    
    /// 받는 이가 프로필 비공개로 설정한 경우 \
    /// The receiver turned off the profile visibility
    case TalkMessageDisabled = -530
    
    /// 보내는 이가 한 달 동안 보낼 수 있는 쿼터를 초과한 경우 \
    /// The sender exceeded the monthly quota for sending messages
    case TalkSendMessageMonthlyLimitExceed = -531
    
    /// 보내는 이가 하루 동안 보낼 수 있는 쿼터를 초과한 경우 \
    /// The sender exceeded the daily quota for sending messages
    case TalkSendMessageDailyLimitExceed = -532
        
    /// 업로드 가능한 이미지 최대 용량을 초과한 경우 \
    /// Exceeded the maximum size of images to upload
    case ImageUploadSizeExceed = -602
    
    /// 카카오 플랫폼 내부에서 요청 처리 중 타임아웃이 발생한 경우 \
    /// Timeout occurred during the internal processing in the server
    case ServerTimeout = -603
    
    /// 업로드할 수 있는 최대 이미지 개수를 초과한 경우 \
    /// Exceeded the maximum number of images to upload
    case ImageMaxUploadNumberExceed = -606
    
    /// 서비스 점검 중 \
    /// Under the service maintenance
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

/// 인증 및 인가 에러 원인 \
/// Reasons for authentication or authorization errors
public enum AuthFailureReason : String, Codable {
    
    /// 알 수 없음 \
    /// Unknown
    case Unknown = "unknown"
    
    /// 잘못된 파라미터를 전달한 경우 \
    /// Passed wrong parameters
    case InvalidRequest = "invalid_request"
    
    /// 잘못된 앱 키를 전달한 경우 \
    /// Passed with the wrong app key
    case InvalidClient = "invalid_client"
    
    /// 잘못된 동의항목 ID를 전달한 경우 \
    /// Passed with invalid scope IDs
    case InvalidScope = "invalid_scope"
    
    /// 리프레시 토큰이 만료되었거나 존재하지 않는 경우 \
    /// The refresh token has expired or does not exist
    case InvalidGrant = "invalid_grant"
    
    /// 앱의 플랫폼 설정이 올바르지 않은 경우 \
    /// Platform settings of the app are misconfigured
    case Misconfigured = "misconfigured"
    
    /// 앱에 사용 권한이 없는 경우 \
    /// The app does not have permission
    case Unauthorized = "unauthorized"
    
    /// 사용자가 동의 화면에서 카카오 로그인을 취소한 경우 \
    /// The user canceled Kakao Login at the consent screen
    case AccessDenied = "access_denied"
    
    /// 서버 에러 \
    /// Server error
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

/// Apps 에러 원인 \
/// Reasons for Apps error
public enum AppsFailureReason : String, Codable {
    /// 서버 내부에서 처리 중 에러가 발생한 경우 \
    /// An Error occurred during the internal processing on the server
    case InternalServerError = "KAE001"

    /// 잘못된 요청을 전달한 경우 \
    /// Passed wrong request
    case InvalidRequest = "KAE002"

    /// 잘못된 파라미터를 전달한 경우 \
    /// Passed wrong parameters
    case InvalidParameter = "KAE003"

    /// 유효시간이 만료된 경우 \
    /// Validity period has expired
    case TimeExpired = "KAE004"
    
    /// 카카오톡 채널 정보를 확인할 수 없는 경우 \
    /// Unable to check Kakao Talk channel information
    case InvalidChannel = "KAE005"
    
    /// 카카오톡 채널이 추가 불가능 상태인 경우 \
    /// Kakao Talk channel in a state that cannot be added
    case IllegalStateChannel = "KAE006"

    /// 사용할 수 없는 앱 타입인 경우 \
    /// Unavailable app type
    case AppTypeError = "KAE101"

    /// 필요한 동의항목이 설정되지 않은 경우 \
    /// Required consent items are not set
    case AppScopeError = "KAE102"

    /// 앱에 사용 권한이 없는 API를 호출한 경우	\
    /// Requested an API using an app that does not have permission
    case PermissionError = "KAE103"

    /// 잘못된 타입의 앱 키를 전달한 경우 \
    /// Passed wrong type app key
    case AppKeyTypeError = "KAE104"
    
    /// 앱과 연결되지 않은 카카오톡 채널 정보를 전달한 경우 \
    /// Passed Kakao Talk channel is not connected to an app
    case AppChannelNotConnected = "KAE105"

    /// 사용자 인증에 실패한 경우 \
    /// Failed user authentication
    case AuthError = "KAE201"

    /// 앱에 연결되지 않은 사용자가 API를 호출한 경우 \
    /// Requested an API by users not connected to the app
    case NotRegistredUser = "KAE202"

    /// 필요한 동의항목이 동의 상태가 아닌 경우 \
    /// Required consent items are not agreed to
    case InvalidScope = "KAE203"

    /// 필요한 서비스 약관이 동의 상태가 아닌 경우 \
    /// Required service terms are not agreed to
    case AccountTermsError = "KAE204"

    /// 로그인이 필요한 경우 \
    /// Login is required
    case LoginRequired = "KAE205"

    /// 등록되지 않은 배송지 ID를 전달한 경우 \
    /// Unregistered delivery ID
    case InvalidShippingAddressId = "KAE206"
    
    /// 토큰 유효성 확인 \
    /// Check token validation 
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
