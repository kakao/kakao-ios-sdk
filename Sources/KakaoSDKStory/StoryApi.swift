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
import UIKit.UIImage
import KakaoSDKCommon
import KakaoSDKAuth

/// 카카오 Open API의 카카오스토리 API 호출을 담당하는 클래스입니다.
///
/// 프로필 가져오기, 내스토리 가져오기, 내스토리 쓰기 등의 기능을 제공합니다.
public class StoryApi {
    
    // MARK: Fields
    
    /// 간편하게 API를 호출할 수 있도록 제공되는 공용 싱글톤 객체입니다.
    public static let shared = StoryApi()
}


extension StoryApi {
    // MARK: Fields
    
    
    // MARK: API Methods

    /// 스토리 포스팅 api 으로부터 리다이렉트 된 URL 인지 체크합니다.
    public static func isStoryPostUrl(_ url:URL) -> Bool {
        if url.absoluteString.hasPrefix("kakao\(try! KakaoSDK.shared.appKey())://kakaostory") {
            return true
        }
        return false
    }

    /// 사용자가 카카오스토리 사용자인지 아닌지를 판별합니다.
    public func isStoryUser(completion:@escaping (Bool?, Error?) -> Void) {
        AUTH_API.responseData(.get, Urls.compose(path:Paths.isStoryUser),
                          apiType: .KApi) { (response, data, error) in
                            if let error = error {
                                completion(nil, error)
                                return
                            }
                            
                            if let data = data {
                                if let json = (try? JSONSerialization.jsonObject(with:data, options:[])) as? [String: Any] {
                                    if let isStoryUser = json["isStoryUser"] as? Bool {
                                        completion(isStoryUser, nil)
                                        return
                                    }
                                }
                            }

                            completion(nil, SdkError())
        }
    }
    
    /// 로그인된 사용자의 카카오스토리 프로필 정보를 얻을 수 있습니다.
    /// - seealso: `StoryProfile`
    
    public func profile(secureResource: Bool = true, completion:@escaping (StoryProfile?, Error?) -> Void) {
        AUTH_API.responseData(.get, Urls.compose(path:Paths.storyProfile),
                          parameters: ["secure_resource": secureResource].filterNil(),
                          apiType: .KApi) { (response, data, error) in
                            if let error = error {
                                completion(nil, error)
                                return
                            }
                            
                            if let data = data {
                                completion(try? SdkJSONDecoder.custom.decode(StoryProfile.self, from: data), nil)
                                return
                            }

                            completion(nil, SdkError())
        }
    }
    
    /// 카카오스토리의 특정 내스토리 정보를 얻을 수 있습니다. comments, likes등의 상세정보도 포함됩니다.
    /// - seealso: `Story`
    public func story(id:String, completion:@escaping (Story?, Error?) -> Void)  {
        AUTH_API.responseData(.get, Urls.compose(path:Paths.myStory),
                          parameters: ["id":id].filterNil(),
                          apiType: .KApi) { (response, data, error) in
                            if let error = error {
                                completion(nil, error)
                                return
                            }
                            
                            if let data = data {
                                completion(try? SdkJSONDecoder.customIso8601Date.decode(Story.self, from: data), nil)
                                return
                            }

                            completion(nil, SdkError())
        }
    }
    
    /// 카카오스토리의 여러 개의 내스토리 정보들을 얻을 수 있습니다. 단, comments, likes등의 상세정보는 없으며 이는 내스토리 정보 요청 `story(id:)`을 통해 얻을 수 있습니다.
    /// - seealso: `Story`
    public func stories(lastId:String? = nil, completion:@escaping ([Story]?, Error?) -> Void) {
        AUTH_API.responseData(.get, Urls.compose(path:Paths.myStories),
                          parameters: ["last_id":lastId].filterNil(),
                          apiType: .KApi) { (response, data, error) in
                            if let error = error {
                                completion(nil, error)
                                return
                            }
                            
                            if let data = data {
                                completion(try? SdkJSONDecoder.customIso8601Date.decode([Story].self, from: data), nil)
                                return
                            }

                            completion(nil, SdkError())
        }
    }
    
    /// 포스팅하고자 하는 URL을 스크랩하여 링크 정보를 생성합니다.
    /// - seealso: `LinkInfo`
    public func linkInfo(url: URL, completion:@escaping (LinkInfo?, Error?) -> Void) {
        AUTH_API.responseData(.get, Urls.compose(path:Paths.storyLinkInfo),
                          parameters: ["url":url].filterNil(),
                          apiType: .KApi) { (response, data, error) in
                            if let error = error {
                                completion(nil, error)
                                return
                            }
                            
                            if let data = data {
                                completion(try? SdkJSONDecoder.custom.decode(LinkInfo.self, from: data), nil)
                                return
                            }

                            completion(nil, SdkError())
        }
    }
    
    /// 카카오스토리에 글(노트)을 포스팅합니다.
    public func postNote(content:String,
                         permission:Story.Permission = .Public,
                         enableShare:Bool? = false,
                         androidExecParam: [String: String]? = nil,
                         iosExecParam: [String: String]? = nil,
                         androidMarketParam: [String: String]? = nil,
                         iosMarketParam: [String: String]? = nil,
                         completion:@escaping (String?, Error?) -> Void) {
        
        AUTH_API.responseData(.post, Urls.compose(path:Paths.postNote),
                          parameters: ["content":content,
                                       "permission":permission.parameterValue,
                                       "enable_share":enableShare,
                                       "android_exec_param":androidExecParam?.queryParameters,
                                       "ios_exec_param":iosExecParam?.queryParameters,
                                       "android_market_param":androidMarketParam?.queryParameters,
                                       "ios_market_param":iosMarketParam?.queryParameters].filterNil(),
                          apiType: .KApi) { (response, data, error) in
                            if let error = error {
                                completion(nil, error)
                                return
                            }
                            
                            if let data = data {
                                if let storyPostResult = try? SdkJSONDecoder.custom.decode(StoryPostResult.self, from: data) {
                                    completion(storyPostResult.id, error)
                                    return
                                }
                            }

                            completion(nil, SdkError(reason: .Unknown, message: "No post identifier in the response body. But posting is successful."))
        }
    }
    
    /// 카카오스토리에 링크(스크랩 정보)를 포스팅합니다.
    ///
    /// 먼저 포스팅하고자 하는 URL로 스크랩 API를 호출한 후 반환된 링크 정보를 파라미터로 전달하여 포스팅 해야 합니다.
    /// - seealso: `linkInfo(url:)` <br>`LinkInfo`
    public func postLink(content:String? = nil,
                         linkInfo:LinkInfo,
                         permission:Story.Permission = .Public,
                         enableShare:Bool? = false,
                         androidExecParam: [String: String]? = nil,
                         iosExecParam: [String: String]? = nil,
                         androidMarketParam: [String: String]? = nil,
                         iosMarketParam: [String: String]? = nil,
                         completion:@escaping (String?, Error?) -> Void) {
        
        AUTH_API.responseData(.post, Urls.compose(path:Paths.postLink),
                          parameters: ["content":content,
                                       "link_info":SdkUtils.toJsonString(linkInfo),
                                       "permission":permission.parameterValue,
                                       "enable_share":enableShare,
                                       "android_exec_param":androidExecParam?.queryParameters,
                                       "ios_exec_param":iosExecParam?.queryParameters,
                                       "android_market_param":androidMarketParam?.queryParameters,
                                       "ios_market_param":iosMarketParam?.queryParameters].filterNil(),
                          apiType: .KApi) { (response, data, error) in
                            if let error = error {
                                completion(nil, error)
                                return
                            }
                            
                            if let data = data {
                                if let storyPostResult = try? SdkJSONDecoder.custom.decode(StoryPostResult.self, from: data) {
                                    completion(storyPostResult.id, error)
                                    return
                                }
                            }

                            completion(nil, SdkError(reason: .Unknown, message: "No post identifier in the response body. But posting is successful."))
        }
    }
    
    /// 카카오스토리에 사진(들)을 포스팅합니다.
    public func postPhoto(content:String? = nil,
                          imagePaths:[String],
                          permission:Story.Permission = .Public,
                          enableShare:Bool? = false,
                          androidExecParam: [String: String]? = nil,
                          iosExecParam: [String: String]? = nil,
                          androidMarketParam: [String: String]? = nil,
                          iosMarketParam: [String: String]? = nil,
                          completion:@escaping (String?, Error?) -> Void) {
        
        AUTH_API.responseData(.post, Urls.compose(path:Paths.postPhoto),
                          parameters: ["content":content,
                                       "image_url_list":imagePaths.toJsonString(),
                                       "permission":permission.parameterValue,
                                       "enable_share":enableShare,
                                       "android_exec_param":androidExecParam?.queryParameters,
                                       "ios_exec_param":iosExecParam?.queryParameters,
                                       "android_market_param":androidMarketParam?.queryParameters,
                                       "ios_market_param":iosMarketParam?.queryParameters].filterNil(),
                          apiType: .KApi) { (response, data, error) in
                            if let error = error {
                                completion(nil, error)
                                return
                            }
                            
                            if let data = data {
                                if let storyPostResult = try? SdkJSONDecoder.custom.decode(StoryPostResult.self, from: data) {
                                    completion(storyPostResult.id, error)
                                    return
                                }
                            }

                            completion(nil, SdkError(reason: .Unknown, message: "No post identifier in the response body. But posting is successful."))
        }
    }
    
    /// 로컬 이미지 파일 여러장을 카카오스토리에 업로드합니다. (JPEG 형식)
    public func upload(_ images: [UIImage?],
                       completion:@escaping ([String]?, Error?) -> Void) {
        
        AUTH_API.upload(.post, Urls.compose(path:Paths.uploadMulti), images: images,
                          apiType: .KApi) { (response, data, error) in
                            if let error = error {
                                completion(nil, error)
                                return
                            }
                            
                            if let data = data {
                                if let json = try? JSONSerialization.jsonObject(with:data, options:[]), let paths = json as? [String] {
                                    completion(paths, error)
                                    return
                                }
                            }

                            completion(nil, SdkError(reason: .Unknown, message: "No post identifier in the response body. But posting is successful."))
        }
    }
    
    /// 카카오스토리의 특정 내스토리 정보를 지울 수 있습니다.
    public func delete(_ id: String, completion:@escaping (Error?) -> Void) {
        AUTH_API.responseData(.delete, Urls.compose(path:Paths.deleteMyStory),
                          parameters: ["id":id].filterNil(),
                          apiType: .KApi) { (response, data, error) in
                            if let error = error {
                                completion(error)
                                return
                            }
                            
                            completion(nil)
        }
    }
}


