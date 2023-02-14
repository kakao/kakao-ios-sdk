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
import KakaoSDKAuth
import KakaoSDKTemplate

/// 카카오 Open API의 카카오톡 API 호출을 담당하는 클래스입니다.
///
/// 프로필 가져오기, 친구 목록 가져오기, 메시지 보내기 등이 기능을 제공합니다.
public class TalkApi {
    
    // MARK: Fields
    
    /// 간편하게 API를 호출할 수 있도록 제공되는 공용 싱글톤 객체입니다.
    public static let shared = TalkApi()  

    
    /// 카카오톡 채널을 추가하기 위한 URL을 반환합니다. URL을 브라우저나 웹뷰에서 로드하면 연결 페이지(bridge page)를 통해 카카오톡을 실행합니다.
    ///
    /// - parameter channelPublicId: 카카오톡 채널 홈 URL에 들어간 {_영문}으로 구성된 고유 아이디입니다. 홈 URL은 카카오톡 채널 관리자센터 > 관리 > 상세설정 페이지에서 확인할 수 있습니다.
    ///
    /// 아래는 SFSafariViewController를 이용해 카카오톡 채널을 추가하는 예제입니다.
    /// ```
    /// guard let url = TalkApi.shared.makeUrlForAddChannel(channelPublicId:"<#Your Channel Public ID#>" else {
    ///     return
    /// }
    /// let safariViewController = SFSafariViewController(url: url)
    /// self.present(safariViewController, animated: true, completion: nil)
    /// ```
    public func makeUrlForAddChannel(channelPublicId:String) -> URL? {
        SdkLog.d("===================================================================================================")
        let url = SdkUtils.makeUrlWithParameters("\(Urls.compose(.Channel, path:Paths.channel))/\(channelPublicId)/friend",parameters:["app_key":try! KakaoSDK.shared.appKey(), "kakao_agent":Constants.kaHeader, "api_ver":"1.0"].filterNil())
        SdkLog.d("url: \(url?.absoluteString ?? "something wrong!") \n")
        return url
    }
    
    /// 카카오톡 채널 1:1 대화방 실행을 위한 URL을 반환합니다. URL을 브라우저나 웹뷰에서 로드하면 브릿지 웹페이지를 통해 카카오톡을 실행합니다.
    ///
    /// - parameter channelPublicId: 카카오톡 채널 홈 URL에 들어간 {_영문}으로 구성된 고유 아이디입니다. 홈 URL은 카카오톡 채널 관리자센터 > 관리 > 상세설정 페이지에서 확인할 수 있습니다.
    ///
    /// 아래는 SFSafariViewController를 이용해 1:1 대화방을 실행하는 예제입니다.
    /// ```
    /// guard let url = TalkApi.shared.makeUrlForChannelChat(channelPublicId:"<#Your Channel Public ID#>" else {
    ///     return
    /// }
    /// let safariViewController = SFSafariViewController(url: url)
    /// self.present(safariViewController, animated: true, completion: nil)
    /// ```
    public func makeUrlForChannelChat(channelPublicId:String) -> URL? {
        SdkLog.d("===================================================================================================")
        let url = SdkUtils.makeUrlWithParameters("\(Urls.compose(.Channel, path:Paths.channel))/\(channelPublicId)/chat",
            parameters:["app_key":try! KakaoSDK.shared.appKey(), "kakao_agent":Constants.kaHeader, "api_ver":"1.0"].filterNil())
        SdkLog.d("url: \(url?.absoluteString ?? "something wrong!") \n")
        return url
    }
}

extension TalkApi {
    // MARK: Profile
    
    /// 로그인된 사용자의 카카오톡 프로필 정보를 얻을 수 있습니다.
    /// - seealso: `TalkProfile`
    public func profile(completion:@escaping (TalkProfile?, Error?) -> Void) {
        
        AUTH_API.responseData(.get, Urls.compose(path:Paths.talkProfile),
                          apiType: .KApi) { (response, data, error) in
                            if let error = error {
                                completion(nil, error)
                                return
                            }
                            
                            if let data = data {
                                completion(try? SdkJSONDecoder.custom.decode(TalkProfile.self, from: data), nil)
                                return
                            }

                            completion(nil, SdkError())
        }
    }
    
    // MARK: Memo

    /// 카카오 디벨로퍼스에서 생성한 서비스만의 커스텀 메시지 템플릿을 사용하여, 카카오톡의 "나와의 채팅방"으로 메시지를 전송합니다. 템플릿을 생성하는 방법은 https://developers.kakao.com/docs/latest/ko/message/ios#create-message 을 참고하시기 바랍니다.
    public func sendCustomMemo(templateId: Int64, templateArgs: [String:String]? = nil, completion:@escaping (Error?) -> Void) {
        AUTH_API.responseData(.post, Urls.compose(path:Paths.customMemo), parameters: ["template_id":templateId, "template_args":templateArgs?.toJsonString()].filterNil(),
                          apiType: .KApi) { (_, _, error) in
                            completion(error)
                            return
        }
    }

    /// 기본 템플릿을 이용하여, 카카오톡의 "나와의 채팅방"으로 메시지를 전송합니다.
    /// - seealso: [Template](../../KakaoSDKTemplate/Protocols/Templatable.html)
    public func sendDefaultMemo(templatable: Templatable, completion:@escaping (Error?) -> Void) {
        AUTH_API.responseData(.post, Urls.compose(path:Paths.defaultMemo), parameters: ["template_object":templatable.toJsonObject()?.toJsonString()].filterNil(),
                          apiType: .KApi) { (_, _, error) in
                            completion(error)
                            return
        }
    }

    /// 지정된 URL을 스크랩하여, 카카오톡의 "나와의 채팅방"으로 메시지를 전송합니다.
    public func sendScrapMemo(requestUrl: String, templateId: Int64? = nil, templateArgs: [String:String]? = nil, completion:@escaping (Error?) -> Void) {
        AUTH_API.responseData(.post, Urls.compose(path:Paths.scrapMemo), parameters: ["request_url":requestUrl,"template_id":templateId, "template_args":templateArgs?.toJsonString()].filterNil(),
                          apiType: .KApi) { (_, _, error) in
                            completion(error)
                            return
        }
    }
    
    // MARK: Friends
     
     /// 카카오톡 친구 목록을 조회합니다.
     /// - seealso: `Friends`
     public func friends(offset: Int? = nil,
                         limit: Int? = nil,
                         order: Order? = nil,
                         friendOrder: FriendOrder? = nil,
                         completion:@escaping (Friends<Friend>?, Error?) -> Void) {
         
         AUTH_API.responseData(.get,
                           Urls.compose(path:Paths.friends),
                           parameters: ["offset": offset, "limit": limit, "order": order?.rawValue, "friend_order":friendOrder?.rawValue].filterNil(),
                           apiType: .KApi) { (response, data, error) in
                         
                             if let error = error {
                                 completion(nil, error)
                                 return
                             }

                             if let data = data {
                                 completion(try? SdkJSONDecoder.custom.decode(Friends<Friend>.self, from: data), nil)
                                 return
                             }

                             completion(nil, SdkError())
         }
     }
    
    /// 카카오톡 친구 목록을 FriendContext를 파라미터로 조회합니다.
    /// - seealso: `FriendsContext`
    public func friends(context: FriendsContext?,
                        completion:@escaping (Friends<Friend>?, Error?) -> Void) {
        
            friends(offset: context?.offset,
                    limit: context?.limit,
                    order: context?.order,
                    friendOrder: context?.friendOrder,
                    completion: completion)
    }
    
    
    
    // MARK: Message
        
    /// 기본 템플릿을 사용하여, 조회한 친구를 대상으로 카카오톡으로 메시지를 전송합니다.
    /// - seealso: [Template](../../KakaoSDKTemplate/Protocols/Templatable.html) <br> `MessageSendResult`
    public func sendDefaultMessage(templatable:Templatable, receiverUuids:[String],
                                   completion:@escaping (MessageSendResult?, Error?) -> Void) {
        AUTH_API.responseData(.post,
                          Urls.compose(path:Paths.defaultMessage),
                          parameters: ["template_object":templatable.toJsonObject()?.toJsonString(), "receiver_uuids":receiverUuids.toJsonString()].filterNil(),
                          apiType: .KApi) { (response, data, error) in
                            
                            if let error = error {
                                completion(nil, error)
                                return
                            }

                            if let data = data {
                                completion(try? SdkJSONDecoder.custom.decode(MessageSendResult.self, from: data), nil)
                                return
                            }

                            completion(nil, SdkError())
        }
    }
    
    /// 카카오 디벨로퍼스에서 생성한 메시지 템플릿을 사용하여, 조회한 친구를 대상으로 카카오톡으로 메시지를 전송합니다. 템플릿을 생성하는 방법은 https://developers.kakao.com/docs/latest/ko/message/ios#create-message 을 참고하시기 바랍니다.
    /// - seealso: `MessageSendResult`
    public func sendCustomMessage(templateId: Int64, templateArgs:[String:String]? = nil, receiverUuids:[String],
                                  completion:@escaping (MessageSendResult?, Error?) -> Void) {
        AUTH_API.responseData(.post, Urls.compose(path:Paths.customMessage), parameters: ["receiver_uuids":receiverUuids.toJsonString(), "template_id":templateId, "template_args":templateArgs?.toJsonString()].filterNil(),
                          apiType: .KApi) { (response, data, error) in
                            if let error = error {
                                completion(nil, error)
                                return
                            }

                            if let data = data {
                                completion(try? SdkJSONDecoder.custom.decode(MessageSendResult.self, from: data), nil)
                                return
                            }

                            completion(nil, SdkError())
        }
    }
    
    /// 지정된 URL을 스크랩하여, 조회한 친구를 대상으로 카카오톡으로 메시지를 전송합니다. 스크랩 커스텀 템플릿 가이드(https://developers.kakao.com/docs/latest/ko/message/ios#send-kakaotalk-msg) 를 참고하여 템플릿을 직접 만들고 스크랩 메시지 전송에 이용할 수도 있습니다.
    /// - seealso: `MessageSendResult`
    public func sendScrapMessage(requestUrl: String, templateId: Int64? = nil, templateArgs:[String:String]? = nil, receiverUuids:[String],
                                 completion:@escaping (MessageSendResult?, Error?) -> Void) {
        AUTH_API.responseData(.post, Urls.compose(path:Paths.scrapMessage),
                          parameters: ["receiver_uuids":receiverUuids.toJsonString(), "request_url": requestUrl, "template_id":templateId, "template_args":templateArgs?.toJsonString()].filterNil(),
                          apiType: .KApi) { (response, data, error) in
                            if let error = error {
                                completion(nil, error)
                                return
                            }

                            if let data = data {
                                completion(try? SdkJSONDecoder.custom.decode(MessageSendResult.self, from: data), nil)
                                return
                            }

                            completion(nil, SdkError())
        }
    }
        
    // MARK: Kakaotalk Channel
    
    /// 사용자가 특정 카카오톡 채널을 추가했는지 확인합니다.
    /// - seealso: `Channels`
    public func channels(publicIds: [String]? = nil,
                         completion:@escaping (Channels?, Error?) -> Void) {
        AUTH_API.responseData(.get, Urls.compose(path:Paths.channels),
                          parameters: ["channel_public_ids":publicIds?.toJsonString()].filterNil(),
                          apiType: .KApi) { (response, data, error) in
                            if let error = error {
                                completion(nil, error)
                                return
                            }

                            if let data = data {
                                completion(try? SdkJSONDecoder.customIso8601Date.decode(Channels.self, from: data), nil)
                                return
                            }

                            completion(nil, SdkError())
        }
    }
}
