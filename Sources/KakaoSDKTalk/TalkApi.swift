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
import UIKit

import AuthenticationServices

/// [카카오톡 채널](https://developers.kakao.com/docs/latest/ko/kakaotalk-channel/common), [카카오톡 소셜](https://developers.kakao.com/docs/latest/ko/kakaotalk-social/common), [카카오톡 메시지](https://developers.kakao.com/docs/latest/ko/message/common) API 클래스 \
/// Class for the [Kakao Talk Channel](https://developers.kakao.com/docs/latest/en/kakaotalk-channel/common), [Kakao Talk Social](https://developers.kakao.com/docs/latest/en/kakaotalk-social/common), [Kakao Talk Message](https://developers.kakao.com/docs/latest/en/message/common) APIs
public class TalkApi {
    
    // MARK: Fields
    
    /// 카카오 SDK 싱글톤 객체 \
    /// A singleton object for Kakao SDK
    public static let shared = TalkApi()
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public var presentationContextProvider: Any?
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public var authenticationSession : ASWebAuthenticationSession?
    
    public init() {
        self.presentationContextProvider = DefaultASWebAuthenticationPresentationContextProvider()
    }
    
    /// 카카오톡 채널 추가 페이지 URL 반환 \
    /// Returns a URL to add a Kakao Talk Channel as a friend
    /// - parameters:
    ///    - channelPublicId:카카오톡 채널 프로필 ID \
    ///                      Kakao Talk Channel profile ID
    ///## SeeAlso
    ///- [연결 페이지](https://developers.kakao.com/docs/latest/ko/kakaotalk-channel/ios#add-channel-url) \
    ///  [Bridge page](https://developers.kakao.com/docs/latest/en/kakaotalk-channel/ios#add-channel-url)
    public func makeUrlForAddChannel(channelPublicId:String) -> URL? {
        SdkLog.d("===================================================================================================")
        let url = SdkUtils.makeUrlWithParameters("\(Urls.compose(.Channel, path:Paths.channel))/\(channelPublicId)/friend",parameters:["app_key":try! KakaoSDK.shared.appKey(), "kakao_agent":Constants.kaHeader, "api_ver":"1.0"].filterNil())
        SdkLog.d("url: \(url?.absoluteString ?? "something wrong!") \n")
        return url
    }
    
    @available(*, deprecated, message: "use makeUrlForChatChannel(channelPublicId:) instead")
    public func makeUrlForChannelChat(channelPublicId:String) -> URL? {
        return makeUrlForChatChannel(channelPublicId: channelPublicId)
    }
    
    /// 카카오톡 채널 채팅 페이지 URL 반환 \
    /// Returns a URL to start a chat with a Kakao Talk Channel
    /// - parameters:
    ///    - channelPublicId:카카오톡 채널 프로필 ID \
    ///                      Kakao Talk Channel profile ID
    ///## SeeAlso
    ///- [연결 페이지](https://developers.kakao.com/docs/latest/ko/kakaotalk-channel/ios#chat-channel-url) \
    ///  [Bridge page](https://developers.kakao.com/docs/latest/en/kakaotalk-channel/ios#chat-channel-url)
    public func makeUrlForChatChannel(channelPublicId:String) -> URL? {
        SdkLog.d("===================================================================================================")
        let url = SdkUtils.makeUrlWithParameters("\(Urls.compose(.Channel, path:Paths.channel))/\(channelPublicId)/chat",
            parameters:["app_key":try! KakaoSDK.shared.appKey(), "kakao_agent":Constants.kaHeader, "api_ver":"1.0"].filterNil())
        SdkLog.d("url: \(url?.absoluteString ?? "something wrong!") \n")
        return url
    }
}

extension TalkApi {
    // MARK: Profile
    
    /// 카카오톡 프로필 가져오기 \
    /// Retrieve Kakao Talk profile
    /// ## SeeAlso
    /// - ``TalkProfile``
    /// - [프로필 가져오기](https://developers.kakao.com/docs/latest/ko/kakaotalk-social/ios#get-profile) \
    ///   [Retrieve Kakao Talk profile](https://developers.kakao.com/docs/latest/en/kakaotalk-social/ios#get-profile)
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
    
    /// 나에게 사용자 정의 템플릿으로 메시지 보내기 \
    /// Send message with custom template to me
    /// - parameters:
    ///    - templateId: 메시지 템플릿 ID \
    ///                  Message template ID
    ///    - templateArgs: 사용자 인자 \
    ///                    User arguments
    public func sendCustomMemo(templateId: Int64, templateArgs: [String:String]? = nil, completion:@escaping (Error?) -> Void) {
        AUTH_API.responseData(.post, Urls.compose(path:Paths.customMemo), parameters: ["template_id":templateId, "template_args":templateArgs?.toJsonString()].filterNil(),
                              apiType: .KApi) { (_, _, error) in
            completion(error)
            return
        }
    }
    
    /// 나에게 기본 템플릿으로 메시지 보내기 \
    /// Send message with default template to me
    /// - parameters:
    ///    - templatable: 메시지 템플릿 객체 \
    ///                   An object of a message template
    /// ## SeeAlso
    /// - [`Templatable`](https://developers.kakao.com/sdk/reference/ios/release/KakaoSDKTemplate/documentation/kakaosdktemplate/templatable)
    public func sendDefaultMemo(templatable: Templatable, completion:@escaping (Error?) -> Void) {
        AUTH_API.responseData(.post, Urls.compose(path:Paths.defaultMemo), parameters: ["template_object":templatable.toJsonObject()?.toJsonString()].filterNil(),
                              apiType: .KApi) { (_, _, error) in
            completion(error)
            return
        }
    }
    
    /// 나에게 스크랩 메시지 보내기 \
    /// Send scrape message to me
    ///  - parameters:
    ///     - requestUrl: 스크랩할 URL \
    ///                   URL to scrape
    ///     - templateId: 메시지 템플릿 ID \
    ///                   Message template ID
    ///     - templateArgs: 사용자 인자 \
    ///                     User arguments
    public func sendScrapMemo(requestUrl: String, templateId: Int64? = nil, templateArgs: [String:String]? = nil, completion:@escaping (Error?) -> Void) {
        AUTH_API.responseData(.post, Urls.compose(path:Paths.scrapMemo), parameters: ["request_url":requestUrl,"template_id":templateId, "template_args":templateArgs?.toJsonString()].filterNil(),
                              apiType: .KApi) { (_, _, error) in
            completion(error)
            return
        }
    }
    
    // MARK: Friends
    
    /// 친구 목록 가져오기 \
    /// Retrieve list of friends
    /// - parameters:
    ///   - offset: 친구 목록 시작 지점 \
    ///             Start point of the friend list
    ///   - limit: 페이지당 결과 수 \
    ///            Number of results in a page
    ///   - order: 정렬 방식 \
    ///            Sorting method
    ///   - friendOrder: 친구 정렬 방식 \
    ///                  Method to sort the friend list
    /// ## SeeAlso
    /// - ``Friends``
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
    
    /// 친구 목록 가져오기 \
    /// Retrieve list of friends
    /// ## SeeAlso
    /// - ``FriendsContext``
    public func friends(context: FriendsContext?,
                        completion:@escaping (Friends<Friend>?, Error?) -> Void) {
        
        friends(offset: context?.offset,
                limit: context?.limit,
                order: context?.order,
                friendOrder: context?.friendOrder,
                completion: completion)
    }
    
    
    
    // MARK: Message
    
    /// 친구에게 기본 템플릿으로 메시지 보내기 \
    /// Send message with default template to friends
    ///  - parameters:
    ///     - templatable: 메시지 템플릿 객체 \
    ///                    An object of a message template
    ///     - receiverUuids: 수신자 UUID \
    ///                      Receiver UUIDs
    /// ## SeeAlso
    /// - [`Templatable`](https://developers.kakao.com/sdk/reference/ios/release/KakaoSDKTemplate/documentation/kakaosdktemplate/templatable)
    /// - ``MessageSendResult``
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
    
    /// 친구에게 사용자 정의 템플릿으로 메시지 보내기 \
    /// Send message with custom template
    /// - parameters:
    ///    - templateId: 메시지 템플릿 ID \
    ///                  Message template ID
    ///    - templateArgs: 사용자 인자 \
    ///                    User arguments
    ///    - receiverUuids: 수신자 UUID \
    ///                     Receiver UUIDs
    /// ## SeeAlso
    /// - ``MessageSendResult``
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
    
    /// 친구에게 스크랩 메시지 보내기 \
    /// Send scrape message to friends
    /// - parameters:
    ///    - requestUrl: 스크랩할 URL \
    ///                   URL to scrape
    ///    - templateId: 메시지 템플릿 ID \
    ///                  Message template ID
    ///    - templateArgs: 사용자 인자 \
    ///                    User arguments
    ///    - receiverUuids: 수신자 UUID \
    ///                     Receiver UUIDs
    /// ## SeeAlso
    /// - ``MessageSendResult``
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
}

extension TalkApi {
        
    // MARK: Kakaotalk Channel
    
    /// 카카오톡 채널 관계 확인하기 \
    /// Check Kakao Talk Channel relationship
    /// - parameters:
    ///    - publicIds: 카카오톡 채널 프로필 ID 목록 \
    ///                 A list of Kakao Talk Channel profile IDs
    /// ## SeeAlso
    /// - ``Channels``
    public func channels(publicIds: [String]? = nil,
                         completion:@escaping (Channels?, Error?) -> Void) {
        AUTH_API.responseData(.get, Urls.compose(path:Paths.channels),                              
                              parameters: ["channel_ids":publicIds?.joined(separator:","), "channel_id_type":"channel_public_id"].filterNil(),
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
    
    private func validateChannel(validatePathUri: String, channelPublicId: String, completion: @escaping (Error?) -> Void) {
        // https://kakao.agit.in/g/434664/wall/355508801#comment_panel_387703878
        API.responseData(.post,
                     Urls.compose(path: Paths.channelValidate),
                     parameters: ["quota_properties": ["uri": validatePathUri, "channel_public_id": channelPublicId].toJsonString()].filterNil(),
                     headers: ["Authorization": "KakaoAK \(try! KakaoSDK.shared.appKey())"],
                     sessionType: .Api,
                     apiType: .KApi) { (response, data, error) in
            if let error = error {
                completion(error)
                return
            }
            
            completion(nil)
        }
    }    
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public static func isKakaoTalkChannelAvailable(path: String) -> Bool {
        guard let url = URL(string: Urls.compose(.PlusFriend, path: path)) else { return false }
        
        return UIApplication.shared.canOpenURL(url)
    }
    
    /// 카카오톡 채널 친구 추가하기 \
    /// Add Kakao Talk Channel
    /// - parameters:
    ///    - channelPublicId: 카카오톡 채널 프로필 ID \
    ///                       Kakao Talk Channel profile ID
    public func addChannel(channelPublicId: String, completion: @escaping (Error?) -> Void) {
        let path = "plusfriend/home/\(channelPublicId)/add"
        if !TalkApi.isKakaoTalkChannelAvailable(path: path) {
            completion(SdkError.ClientFailed(reason: .IllegalState, errorMessage: "KakaoTalk is not available"))
            return
        }
         
        validateChannel(validatePathUri: "/sdk/channel/add", channelPublicId: channelPublicId) { (error) in
            if let error = error {
                completion(error)
                return
            }
            
            UIApplication.shared.open(URL(string: Urls.compose(.PlusFriend, path: path))!)
        }
    }
    
    /// 카카오톡 채널 채팅하기 \
    /// Start Kakao Talk Channel chat
    /// - parameters:
    ///    - channelPublicId: 카카오톡 채널 프로필 ID \
    ///                       Kakao Talk Channel profile ID
    public func chatChannel(channelPublicId: String, completion: @escaping (Error?) -> Void) {
        let path = "plusfriend/talk/chat/\(channelPublicId)"
        if !TalkApi.isKakaoTalkChannelAvailable(path: path) {
            completion(SdkError.ClientFailed(reason: .IllegalState, errorMessage: "KakaoTalk is not available"))
            return
        }
                
        validateChannel(validatePathUri: "/sdk/channel/chat", channelPublicId: channelPublicId) { (error) in
            if let error = error {
                completion(error)
                return
            }
            
            UIApplication.shared.open(URL(string: Urls.compose(.PlusFriend, path: path))!)
        }
    }
    
    /// 카카오톡 채널 간편 추가하기 \
    /// Follow Kakao Talk Channel
    /// - parameters:
    ///    - channelPublicId: 카카오톡 채널 프로필 ID \
    ///                       Kakao Talk Channel's profile ID
    public func followChannel(channelPublicId: String,
                              completion: @escaping (FollowChannelResult?, Error?) -> Void) {
        
        guard AuthApi.hasToken() == true else {
            self._followChannelWithAuthenticationSession(channelPublicId:channelPublicId, completion:completion)
            return
        }

        AuthApi.shared.refreshToken(token: AUTH.tokenManager.getToken()) {[weak self]  _, error in
            if let error = error {
                completion(nil, error)
            }
            else {
                AuthApi.shared.agt { (agtToken, error) in
                    if let error = error {
                        completion(nil, error)
                    }
                    else {
                        self?._followChannelWithAuthenticationSession(channelPublicId: channelPublicId, agtToken:agtToken, completion: completion)
                    }
                }
            }
        }
    }    
}
