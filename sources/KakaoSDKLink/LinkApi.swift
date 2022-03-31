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

import Alamofire
import KakaoSDKCommon
import KakaoSDKTemplate

/// 카카오링크 호출을 담당하는 클래스입니다.
public class LinkApi {
    
    // MARK: Fields
    
    /// 간편하게 API를 호출할 수 있도록 제공되는 공용 싱글톤 객체입니다. 
    public static let shared = LinkApi()
        
    /// 카카오링크 API로부터 리다이렉트 된 URL 인지 체크합니다.
    public static func isKakaoLinkUrl(_ url:URL) -> Bool {
        if url.absoluteString.hasPrefix("\(try! KakaoSDK.shared.scheme())://kakaolink") {
            return true
        }
        return false
    }
    
    public static func isKakaoLinkAvailable() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string:Urls.compose(.TalkLink, path:Paths.talkLink))!)
    }
}
    
extension LinkApi {
    // MARK: Fields
    
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
        return count >= 1024 * 24
    }

    // MARK: Using Web Sharer
    
    /// 기본 템플릿을 공유하는 웹 공유 URL을 얻습니다.
    ///
    /// 획득한 URL을 브라우저에 요청하면 카카오톡이 없는 환경에서도 메시지를 공유할 수 있습니다. 공유 웹페이지 진입시 로그인된 계정 쿠키가 없다면 카카오톡에 연결된 카카오계정으로 로그인이 필요합니다.
    ///
    /// - seealso: [Template](../../KakaoSDKTemplate/Protocols/Templatable.html)
    public func makeSharerUrlforDefaultLink(templatable:Templatable, serverCallbackArgs:[String:String]? = nil) -> URL? {
        return self.makeSharerUrl(url: Urls.compose(.SharerLink, path:Paths.sharerLink),
                                  action:"default",
                                  parameters:["link_ver":"4.0",
                                              "template_object":templatable.toJsonObject()].filterNil(),
                                  serverCallbackArgs:serverCallbackArgs)
    }
    
    /// 기본 템플릿을 공유하는 웹 공유 URL을 얻습니다.
    /// 획득한 URL을 브라우저에 요청하면 카카오톡이 없는 환경에서도 메시지를 공유할 수 있습니다. 공유 웹페이지 진입시 로그인된 계정 쿠키가 없다면 카카오톡에 연결된 카카오계정으로 로그인이 필요합니다.
    public func makeSharerUrlforDefaultLink(templateObject:[String:Any], serverCallbackArgs:[String:String]? = nil) -> URL? {
        return self.makeSharerUrl(url: Urls.compose(.SharerLink, path:Paths.sharerLink),
                                  action:"default",
                                  parameters:["link_ver":"4.0",
                                              "template_object":templateObject].filterNil(),
                                  serverCallbackArgs:serverCallbackArgs)
    }
    
    /// 지정된 URL을 스크랩하여 만들어진 템플릿을 공유하는 웹 공유 URL을 얻습니다.
    ///
    /// 획득한 URL을 브라우저에 요청하면 카카오톡이 없는 환경에서도 메시지를 공유할 수 있습니다. 공유 웹페이지 진입시 로그인된 계정 쿠키가 없다면 카카오톡에 연결된 카카오계정으로 로그인이 필요합니다.
    public func makeSharerUrlforScrapLink(requestUrl:String, templateId:Int64? = nil, templateArgs:[String:String]? = nil, serverCallbackArgs:[String:String]? = nil) -> URL? {
        return self.makeSharerUrl(url: Urls.compose(.SharerLink, path:Paths.sharerLink),
                                  action:"scrap",
                                  parameters:["link_ver":"4.0",
                                              "request_url":requestUrl,
                                              "template_id":templateId,
                                              "template_args":templateArgs].filterNil(),
                                  serverCallbackArgs:serverCallbackArgs)
    }
    
    /// 카카오 디벨로퍼스에서 생성한 메시지 템플릿을 공유하는 웹 공유 URL을 얻습니다.
    ///
    /// 획득한 URL을 브라우저에 요청하면 카카오톡이 없는 환경에서도 메시지를 공유할 수 있습니다. 공유 웹페이지 진입시 로그인된 계정 쿠키가 없다면 카카오톡에 연결된 카카오계정으로 로그인이 필요합니다.
    public func makeSharerUrlforCustomLink(templateId:Int64, templateArgs:[String:String]? = nil, serverCallbackArgs:[String:String]? = nil) -> URL? {
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


extension LinkApi {
    // MARK: Fields
    
    public func transformResponseToLinkResult(response: HTTPURLResponse?, data:Data?, targetAppKey: String? = nil, serverCallbackArgs:[String:String]? = nil, completion:@escaping (LinkResult?, Error?) -> Void) {
        
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
                
                if LinkApi.isExceededLimit(linkParameters: linkParameters, validationResult: validationResult, extras: extraParameters) {
                    completion(nil, SdkError(reason: .ExceedKakaoLinkSizeLimit))
                } else {
                    completion(LinkResult(url:url, warningMsg: validationResult.warningMsg, argumentMsg: validationResult.argumentMsg), nil)
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
    
    func defaultLink(templateObjectJsonString:String?,
                     serverCallbackArgs:[String:String]? = nil,
                     completion:@escaping (LinkResult?, Error?) -> Void ) {
        return API.responseData(.post,
                                Urls.compose(path:Paths.defalutLink),
                                parameters: ["link_ver":"4.0",
                                             "template_object":templateObjectJsonString].filterNil(),
                                headers: ["Authorization":"KakaoAK \(try! KakaoSDK.shared.appKey())"],
                                sessionType: .Api,
                                apiType: .KApi) { [unowned self] (response, data, error) in
                                                                        
                                if let error = error {
                                    completion(nil, error)
                                }
                                else {
                                    self.transformResponseToLinkResult(response: response, data: data, serverCallbackArgs: serverCallbackArgs) { (linkResult, error) in
                                        if let error = error {
                                            completion(nil, error)
                                        }
                                        else {
                                            if let linkResult = linkResult {
                                                completion(linkResult, nil)
                                            }
                                            else {
                                                completion(nil, SdkError(reason:.Unknown, message: "linkResult is nil"))
                                            }
                                        }
                                    }
                                }
        }
    }
    
    /// 기본 템플릿을 카카오톡으로 공유합니다.
    /// - seealso: [Template](../../KakaoSDKTemplate/Protocols/Templatable.html) <br> `LinkResult`
    public func defaultLink(templatable: Templatable, serverCallbackArgs:[String:String]? = nil,
                            completion:@escaping (LinkResult?, Error?) -> Void) {
        self.defaultLink(templateObjectJsonString: templatable.toJsonObject()?.toJsonString(), serverCallbackArgs:serverCallbackArgs, completion: completion)
    }
    
    /// 기본 템플릿을 카카오톡으로 공유합니다.
    /// - seealso: `LinkResult`
    public func defaultLink(templateObject:[String:Any], serverCallbackArgs:[String:String]? = nil,
                            completion:@escaping (LinkResult?, Error?) -> Void ) {
        self.defaultLink(templateObjectJsonString: templateObject.toJsonString(), serverCallbackArgs:serverCallbackArgs, completion: completion)
    }
    
    /// 지정된 URL을 스크랩하여 만들어진 템플릿을 카카오톡으로 공유합니다.
    /// - seealso: `LinkResult`
    public func scrapLink(requestUrl:String, templateId:Int64? = nil, templateArgs:[String:String]? = nil, serverCallbackArgs:[String:String]? = nil,
                          completion:@escaping (LinkResult?, Error?) -> Void ) {
        return API.responseData(.post,
                                Urls.compose(path:Paths.scrapLink),
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
                                    self.transformResponseToLinkResult(response: response, data: data, serverCallbackArgs: serverCallbackArgs) { (linkResult, error) in
                                        if let error = error {
                                            completion(nil, error)
                                        }
                                        else {
                                            if let linkResult = linkResult {
                                                completion(linkResult, nil)
                                            }
                                            else {
                                                completion(nil, SdkError(reason:.Unknown, message: "linkResult is nil"))
                                            }
                                        }
                                    }
                                }
        }
    }
    
    /// 카카오 디벨로퍼스에서 생성한 메시지 템플릿을 카카오톡으로 공유합니다. 템플릿을 생성하는 방법은 https://developers.kakao.com/docs/latest/ko/message/ios#create-message 을 참고하시기 바랍니다.
    /// - seealso: `LinkResult`
    public func customLink(templateId:Int64, templateArgs:[String:String]? = nil, serverCallbackArgs:[String:String]? = nil,
                           completion:@escaping (LinkResult?, Error?) -> Void ) {
        return API.responseData(.post,
                                Urls.compose(path:Paths.validateLink),
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
                                    self.transformResponseToLinkResult(response: response, data: data, serverCallbackArgs: serverCallbackArgs) { (linkResult, error) in
                                        if let error = error {
                                            completion(nil, error)
                                        }
                                        else {
                                            if let linkResult = linkResult {
                                                completion(linkResult, nil)
                                            }
                                            else {
                                                completion(nil, SdkError(reason:.Unknown, message: "linkResult is nil"))
                                            }
                                        }
                                    }
                                }
        }
    }
        
    // MARK: Image Upload
    
    /// 카카오링크 컨텐츠 이미지로 활용하기 위해 로컬 이미지를 카카오 이미지 서버로 업로드 합니다.
    public func imageUpload(image: UIImage, secureResource: Bool = true,
                            completion:@escaping (ImageUploadResult?, Error?) -> Void ) {
        return API.upload(.post, Urls.compose(path:Paths.imageUploadLink),
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
    
    /// 카카오링크 컨텐츠 이미지로 활용하기 위해 원격 이미지를 카카오 이미지 서버로 스크랩 합니다.
    public func imageScrap(imageUrl: URL, secureResource: Bool = true,
                           completion:@escaping (ImageUploadResult?, Error?) -> Void) {
        API.responseData(.post, Urls.compose(path:Paths.imageScrapLink),
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
