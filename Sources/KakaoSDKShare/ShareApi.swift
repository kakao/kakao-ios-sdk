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
import UIKit

import KakaoSDKCommon
import KakaoSDKTemplate

/// [카카오톡 공유](https://developers.kakao.com/docs/latest/ko/message/common) API 클래스 \
/// Class for the [Kakao Talk Sharing](https://developers.kakao.com/docs/latest/en/message/common) APIs
public class ShareApi {
    
    // MARK: Fields
    
    /// 카카오 SDK 싱글톤 객체 \
    /// A singleton object for Kakao SDK
    public static let shared = ShareApi()
        
    /// 카카오톡 공유 API로부터 리다이렉트된 URL인지 확인 \
    /// Checks whether the URL is redirected by the Kakao Talk Sharing APIs
    public static func isKakaoTalkSharingUrl(_ url:URL) -> Bool {
        if url.absoluteString.hasPrefix("\(try! KakaoSDK.shared.scheme())://kakaolink") {
            return true
        }
        return false
    }
    
    /// 카카오톡 공유 가능 여부 확인 \
    /// Checks whether the Kakao Talk Sharing is available
    @available(iOS 13.0, *)
    @available(iOSApplicationExtension, unavailable)
    public static func isKakaoTalkSharingAvailable() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string:Urls.compose(.TalkLink, path:Paths.talkLink))!)
    }
}
    
extension ShareApi {
    // MARK: Fields
    
#if swift(>=5.8)
@_documentation(visibility: private)
#endif
    public static func isExceededLimit(linkParameters: [String: Any]?, validationResult: ValidationResult, extras: [String: Any]?) -> Bool {
        var attachment = [String: Any]()
        
        if let linkParameters = linkParameters {
            attachment["ak"] = linkParameters["appkey"] as? String
            attachment["av"] = linkParameters["appver"] as? String
            attachment["lv"] = linkParameters["linkver"] as? String
        }
        
        attachment["ti"] = validationResult.templateId.description
        attachment["p"]  = validationResult.templateMsg["P"]
        attachment["c"]  = validationResult.templateMsg["C"]
        
        if let templateArgs = validationResult.templateArgs, templateArgs.toJsonString() != nil, templateArgs.count > 0 {
            attachment["ta"] = templateArgs
        }
        
        
        if let extras = extras, extras.toJsonString() != nil, extras.count > 0 {
            attachment["extras"] = extras
        }
        
        guard let count = attachment.toJsonString()?.data(using: .utf8)?.count else {
            // 측정 불가 bypass
            return false
        }
        return count >= 1024 * 10
    }

    // MARK: Using Web Sharer
    
    /// 기본 템플릿을 카카오톡으로 공유하기 위한 URL 생성 \
    /// Creates a URL to share a default template via Kakao Talk
    /// - parameters:
    ///    - templatable: 기본 템플릿으로 변환 가능한 객체 \
    ///                   Object to convert to a default template
    ///    - serverCallbackArgs: 카카오톡 공유 전송 성공 알림에 포함할 키와 값 \
    ///                          Keys and values for the Kakao Talk Sharing success callback
    /// ## SeeAlso
    /// - [Template](javascript:window.location.href=window.location.pathname.split\('KakaoSDKShare'\)[0].concat\('KakaoSDKTemplate/documentation/kakaosdktemplate/templatable'\))
    public func makeDefaultUrl(templatable:Templatable, serverCallbackArgs:[String:String]? = nil) -> URL? {
        return self.makeSharerUrl(url: Urls.compose(.SharerLink, path:Paths.sharerLink),
                                  action:"default",
                                  parameters:["link_ver":"4.0",
                                              "template_object":templatable.toJsonObject()].filterNil(),
                                  serverCallbackArgs:serverCallbackArgs)
    }
    
    /// 기본 템플릿을 카카오톡으로 공유하기 위한 URL 생성 \
    /// Creates a URL to share a default template via Kakao Talk
    /// - parameters:
    ///   - templateObject: 기본 템플릿 객체 \
    ///                     Default template object
    ///   - serverCallbackArgs: 카카오톡 공유 전송 성공 알림에 포함할 키와 값 \
    ///                          Keys and values for the Kakao Talk Sharing success callback
    public func makeDefaultUrl(templateObject:[String:Any], serverCallbackArgs:[String:String]? = nil) -> URL? {
        return self.makeSharerUrl(url: Urls.compose(.SharerLink, path:Paths.sharerLink),
                                  action:"default",
                                  parameters:["link_ver":"4.0",
                                              "template_object":templateObject].filterNil(),
                                  serverCallbackArgs:serverCallbackArgs)
    }
    
    /// 스크랩 정보로 구성된 메시지 템플릿을 카카오톡으로 공유하기 위한 URL 생성 \
    /// Creates a URL to share a scrape message via Kakao Talk
    /// - parameters:
    ///   - requestUrl: 스크랩할 URL \
    ///                 URL to scrape
    ///   - templateId: 사용자 정의 템플릿 ID \
    ///                 Custom template ID
    ///   - templateArgs: 사용자 인자 키와 값 \
    ///                   Keys and values of the user argument
    ///   - serverCallbackArgs: 카카오톡 공유 전송 성공 알림에 포함할 키와 값 \
    ///                          Keys and values for the Kakao Talk Sharing success callback
    public func makeScrapUrl(requestUrl:String, templateId:Int64? = nil, templateArgs:[String:String]? = nil, serverCallbackArgs:[String:String]? = nil) -> URL? {
        return self.makeSharerUrl(url: Urls.compose(.SharerLink, path:Paths.sharerLink),
                                  action:"scrap",
                                  parameters:["link_ver":"4.0",
                                              "request_url":requestUrl,
                                              "template_id":templateId,
                                              "template_args":templateArgs].filterNil(),
                                  serverCallbackArgs:serverCallbackArgs)
    }
    
    /// 사용자 정의 템플릿을 카카오톡으로 공유하기 위한 URL 생성 \
    /// Creates a URL to share a custom template via Kakao Talk
    /// - parameters:
    ///   - templateId: 사용자 정의 템플릿 ID \
    ///                 Custom template ID
    ///   - templateArgs: 사용자 인자 키와 값 \
    ///                   Keys and values of the user argument
    ///   - serverCallbackArgs: 카카오톡 공유 전송 성공 알림에 포함할 키와 값 \
    ///                          Keys and values for the Kakao Talk Sharing success callback
    public func makeCustomUrl(templateId:Int64, templateArgs:[String:String]? = nil, serverCallbackArgs:[String:String]? = nil) -> URL? {
        return self.makeSharerUrl(url: Urls.compose(.SharerLink, path:Paths.sharerLink),
                                  action:"custom",
                                  parameters:["link_ver":"4.0",
                                              "template_id":templateId,
                                              "template_args":templateArgs].filterNil(),
                                  serverCallbackArgs:serverCallbackArgs)
    }
    
    //공통
    private func makeSharerUrl(url:String, action:String, parameters:[String:Any]? = nil, serverCallbackArgs:[String:String]? = nil) -> URL? {
        return SdkUtils.makeUrlWithParameters(url, parameters: ["app_key":try! KakaoSDK.shared.appKey(),
                                                                "validation_action":action,
                                                                "validation_params":parameters?.toJsonString(),
                                                                "ka":Constants.kaHeader,
                                                                "lcba":serverCallbackArgs?.toJsonString()].filterNil())
    }
}


extension ShareApi {
    // MARK: Fields
    
#if swift(>=5.8)
@_documentation(visibility: private)
#endif
    public func transformResponseToSharingResult(response: HTTPURLResponse?, data:Data?, targetAppKey: String? = nil, serverCallbackArgs:[String:String]? = nil, completion:@escaping (SharingResult?, Error?) -> Void) {
        
        if let data = data, let validationResult = try? SdkJSONDecoder.default.decode(ValidationResult.self, from: data) {
            let extraParameters = ["KA":Constants.kaHeader,
                                   "iosBundleId":Bundle.main.bundleIdentifier,
                                   "lcba":serverCallbackArgs?.toJsonString()
                ].filterNil()
            
            let linkParameters = ["appkey" : (targetAppKey != nil) ? targetAppKey! : try! KakaoSDK.shared.appKey(),
                                  "appver" : Constants.appVersion(),
                                  "linkver" : "4.0",
                                  "template_json" : validationResult.templateMsg.toJsonString(),
                                  "template_id" : validationResult.templateId,
                                  "template_args" : validationResult.templateArgs?.toJsonString(),
                                  "extras" : extraParameters?.toJsonString()
                ].filterNil()
            
            if let url = SdkUtils.makeUrlWithParameters(Urls.compose(.TalkLink, path:Paths.talkLink), parameters: linkParameters) {
                SdkLog.d("--------------------------------url \(url)")
                
                if ShareApi.isExceededLimit(linkParameters: linkParameters, validationResult: validationResult, extras: extraParameters) {
                    completion(nil, SdkError(reason: .ExceedKakaoLinkSizeLimit))
                } else {
                    completion(SharingResult(url:url, warningMsg: validationResult.warningMsg, argumentMsg: validationResult.argumentMsg), nil)
                }
            }
            else {
                completion(nil, SdkError(reason:.BadParameter, message: "Invalid Url."))
            }
        }
        else {
            completion(nil, SdkError(reason:.Unknown, message: "Invalid Validation Result."))
        }
    }
    
    // MARK: Using KakaoTalk
    
    /// 기본 템플릿으로 메시지 보내기 \
    /// Send message with default template
    /// - parameters:
    ///   - templateObjectJsonString: 기본 템플릿 객체를 JSON 형식으로 변환한 문자열 \
    ///                               String converted in JSON format from a default template
    ///   - serverCallbackArgs: 카카오톡 공유 전송 성공 알림에 포함할 키와 값 \
    ///                          Keys and values for the Kakao Talk Sharing success callback
    public func shareDefault(templateObjectJsonString:String?,
                     serverCallbackArgs:[String:String]? = nil,
                     completion:@escaping (SharingResult?, Error?) -> Void ) {
        return API.responseData(.post,
                                Urls.compose(path:Paths.shareDefalutValidate),
                                parameters: ["link_ver":"4.0",
                                             "template_object":templateObjectJsonString].filterNil(),
                                headers: ["Authorization":"KakaoAK \(try! KakaoSDK.shared.appKey())"],
                                sessionType: .Api,
                                apiType: .KApi) { [unowned self] (response, data, error) in
                                                                        
                                if let error = error {
                                    completion(nil, error)
                                }
                                else {
                                    self.transformResponseToSharingResult(response: response, data: data, serverCallbackArgs: serverCallbackArgs) { (sharingResult, error) in
                                        if let error = error {
                                            completion(nil, error)
                                        }
                                        else {
                                            if let sharingResult = sharingResult {
                                                completion(sharingResult, nil)
                                            }
                                            else {
                                                completion(nil, SdkError(reason:.Unknown, message: "sharingResult is nil"))
                                            }
                                        }
                                    }
                                }
        }
    }
        
    /// 기본 템플릿으로 메시지 보내기 \
    /// Send message with default template
    /// - parameters:
    ///   - templatable: 기본 템플릿으로 변환 가능한 객체 \
    ///                  Object to convert to a default template
    ///   - serverCallbackArgs: 카카오톡 공유 전송 성공 알림에 포함할 키와 값 \
    ///                         Keys and values for the Kakao Talk Sharing success callback
    /// ## SeeAlso
    /// - [Template](javascript:window.location.href=window.location.pathname.split\('KakaoSDKShare'\)[0].concat\('KakaoSDKTemplate/documentation/kakaosdktemplate/templatable'\))
    /// - ``SharingResult``
    public func shareDefault(templatable: Templatable, serverCallbackArgs:[String:String]? = nil,
                            completion:@escaping (SharingResult?, Error?) -> Void) {
        self.shareDefault(templateObjectJsonString: templatable.toJsonObject()?.toJsonString(), serverCallbackArgs:serverCallbackArgs, completion: completion)
    }
    
    /// 기본 템플릿으로 메시지 보내기 \
    /// Send message with default template
    /// - parameters:
    ///   - templateObject: 기본 템플릿 객체 \
    ///                     Default template object
    ///   - serverCallbackArgs: 카카오톡 공유 전송 성공 알림에 포함할 키와 값 \
    ///                         Keys and values for the Kakao Talk Sharing success callback
    /// ## SeeAlso
    /// - ``SharingResult``
    public func shareDefault(templateObject:[String:Any], serverCallbackArgs:[String:String]? = nil,
                            completion:@escaping (SharingResult?, Error?) -> Void ) {
        self.shareDefault(templateObjectJsonString: templateObject.toJsonString(), serverCallbackArgs:serverCallbackArgs, completion: completion)
    }
    
    /// 스크랩 메시지 보내기 \
    /// Send scrape message
    ///  - parameters:
    ///    - requestUrl: 스크랩할 URL \
    ///                  URL to scrape
    ///    - templateId: 사용자 정의 템플릿 ID \
    ///                  Custom template ID
    ///    - templateArgs: 사용자 인자 키와 값 \
    ///                    Keys and values of the user argument
    ///    - serverCallbackArgs: 카카오톡 공유 전송 성공 알림에 포함할 키와 값 \
    ///                          Keys and values for the Kakao Talk Sharing success callback
    /// ## SeeAlso
    /// - ``SharingResult``
    public func shareScrap(requestUrl:String, templateId:Int64? = nil, templateArgs:[String:String]? = nil, serverCallbackArgs:[String:String]? = nil,
                          completion:@escaping (SharingResult?, Error?) -> Void ) {
        return API.responseData(.post,
                                Urls.compose(path:Paths.shareScrapValidate),
                                parameters: ["link_ver":"4.0",
                                             "request_url":requestUrl,
                                             "template_id":templateId,
                                             "template_args":templateArgs?.toJsonString()]
                                    .filterNil(),
                                headers: ["Authorization":"KakaoAK \(try! KakaoSDK.shared.appKey())"],
                                sessionType: .Api,
                                apiType: .KApi) { [unowned self] (response, data, error) in
                                if let error = error {
                                    completion(nil, error)
                                }
                                else {
                                    self.transformResponseToSharingResult(response: response, data: data, serverCallbackArgs: serverCallbackArgs) { (sharingResult, error) in
                                        if let error = error {
                                            completion(nil, error)
                                        }
                                        else {
                                            if let sharingResult = sharingResult {
                                                completion(sharingResult, nil)
                                            }
                                            else {
                                                completion(nil, SdkError(reason:.Unknown, message: "sharingResult is nil"))
                                            }
                                        }
                                    }
                                }
        }
    }
    
    /// 사용자 정의 템플릿으로 메시지 보내기 \
    /// Send message with custom template
    /// - parameters:
    ///   - templateId: 사용자 정의 템플릿 ID \
    ///                 Custom template ID
    ///   - templateArgs: 사용자 인자 키와 값 \
    ///                   Keys and values of the user argument
    ///   - serverCallbackArgs: 카카오톡 공유 전송 성공 알림에 포함할 키와 값 \
    ///                         Keys and values for the Kakao Talk Sharing success callback
    /// ## SeeAlso
    /// - ``SharingResult``
    public func shareCustom(templateId:Int64, templateArgs:[String:String]? = nil, serverCallbackArgs:[String:String]? = nil,
                           completion:@escaping (SharingResult?, Error?) -> Void ) {
        return API.responseData(.post,
                                Urls.compose(path:Paths.shareCustomValidate),
                                parameters: ["link_ver":"4.0",
                                             "template_id":templateId,
                                             "template_args":templateArgs?.toJsonString()]
                                    .filterNil(),
                                headers: ["Authorization":"KakaoAK \(try! KakaoSDK.shared.appKey())"],
                                sessionType: .Api,
                                apiType: .KApi ) { [unowned self] (response, data, error) in
                                if let error = error {
                                    completion(nil, error)
                                }
                                else {
                                    self.transformResponseToSharingResult(response: response, data: data, serverCallbackArgs: serverCallbackArgs) { (sharingResult, error) in
                                        if let error = error {
                                            completion(nil, error)
                                        }
                                        else {
                                            if let sharingResult = sharingResult {
                                                completion(sharingResult, nil)
                                            }
                                            else {
                                                completion(nil, SdkError(reason:.Unknown, message: "sharingResult is nil"))
                                            }
                                        }
                                    }
                                }
        }
    }
        
    // MARK: Image Upload
    
    /// 이미지 업로드하기 \
    /// Upload image
    /// - parameters:
    ///   - image: 이미지 파일 \
    ///            Image file
    ///   - secureResource: 이미지 URL을 HTTPS로 설정 \
    ///                     Whether to use HTTPS for the image URL
    public func imageUpload(image: UIImage, secureResource: Bool = true,
                            completion:@escaping (ImageUploadResult?, Error?) -> Void ) {
        return API.upload(.post, Urls.compose(path:Paths.shareImageUpload),
                          images: [image],
                          parameters: ["secure_resource": secureResource],
                          headers: ["Authorization":"KakaoAK \(try! KakaoSDK.shared.appKey())"],
                          sessionType: .Api,
                          apiType: .KApi) { (response, data, error) in
                            if let error = error {
                                completion(nil, error)
                            }
                            else {
                                if let data = data {
                                    completion(try? SdkJSONDecoder.custom.decode(ImageUploadResult.self, from: data), nil)
                                }
                                else {
                                    completion(nil, SdkError())
                                }
                            }
        }
    }
    
    /// 이미지 스크랩하기 \
    /// Scrape image
    /// - parameters:
    ///   - imageUrl: 이미지 URL \
    ///               Image URL
    ///   - secureResource: 이미지 URL을 HTTPS로 설정 \
    ///                     Whether to use HTTPS for the image URL
    public func imageScrap(imageUrl: URL, secureResource: Bool = true,
                           completion:@escaping (ImageUploadResult?, Error?) -> Void) {
        API.responseData(.post, Urls.compose(path:Paths.shareImageScrap),
                                parameters: ["image_url": imageUrl.absoluteString, "secure_resource": secureResource],
                                headers: ["Authorization":"KakaoAK \(try! KakaoSDK.shared.appKey())"],
                                sessionType: .Api,
                                apiType: .KApi) { (response, data, error) in
                                    if let error = error {
                                        completion(nil, error)
                                    }
                                    else {
                                        if let data = data {
                                            completion(try? SdkJSONDecoder.custom.decode(ImageUploadResult.self, from: data), nil)
                                        }
                                        else {
                                            completion(nil, SdkError())
                                        }
                                    }
        }
    }
}
