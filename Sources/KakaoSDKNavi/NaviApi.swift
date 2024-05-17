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

/// 카카오내비 API 클래스 \
/// Class for the Kakao Navi APIs
/// ## SeeAlso
/// - ``NaviLocation``
/// - ``NaviOption``
public class NaviApi {
    
    // MARK: Fields
    
    /// 카카오 SDK 싱글톤 객체 \
    /// A singleton object for Kakao SDK
    public static let shared = NaviApi()
    
    
    // MARK: Using KakaoNavi
    /// 카카오내비 설치 URL 반환 \
    /// Returns Kakao Navi installation URL
    public static var webNaviInstallUrl : URL {
        get {
            return URL(string:Urls.compose(.NaviInstall, path:Paths.webNaviInstall))!
        }
    }
    
    /// 카카오내비 앱으로 목적지 공유를 실행하는 URL 반환 \
    /// Returns a URL to share the destination with the Kakao Navi app
    /// - parameters:
    ///   - destination: 목적지 \
    ///                  Destination
    ///   - option: 경로 검색 옵션 \
    ///             Options for searching the route
    ///   - viaList: 경유지 목록(최대: 3개) \
    ///              List of stops (Maximum: 3 places)
    public func shareUrl(destination:NaviLocation,
                         option:NaviOption? = nil,
                         viaList:[NaviLocation]? = nil) -> URL? {
        let shareNaviOption = NaviOption(coordType: option?.coordType,
                                         vehicleType: option?.vehicleType,
                                         rpOption: option?.rpOption,
                                         routeInfo: true,
                                         startX: option?.startX,
                                         startY: option?.startY,
                                         startAngle: option?.startAngle,
                                         returnUri: option?.returnUri)
        
        return makeNaviUrl(url: Urls.compose(.Navi, path:Paths.navigateDestination), destination: destination, option: shareNaviOption, viaList: viaList)
    }
    
    /// 카카오내비 앱으로 길안내를 실행하는 URL 반환 \
    /// Returns a URL to navigate with the Kakao Navi app
    /// - parameters:
    ///   - destination: 목적지 \
    ///                  Destination
    ///   - option: 경로 검색 옵션 \
    ///             Options for searching the route
    ///   - viaList: 경유지 목록(최대: 3개) \
    ///              List of stops (Maximum: 3 places)
    ///## SeeAlso
    ///- [길 안내하기](https://developers.kakao.com/docs/latest/ko/kakaonavi/ios#navigation) \
    ///  [Start navigation](https://developers.kakao.com/docs/latest/en/kakaonavi/ios#navigation)
    public func navigateUrl(destination:NaviLocation,
                            option:NaviOption? = nil,
                            viaList:[NaviLocation]? = nil) -> URL? {
        return makeNaviUrl(url: Urls.compose(.Navi, path:Paths.navigateDestination), destination: destination, option: option, viaList: viaList)
    }    
    
    // MARK: Internal
    
    func makeNaviUrl(url:String,
                     destination:NaviLocation,
                     option:NaviOption? = nil,
                     viaList:[NaviLocation]? = nil) -> URL? {
        
        SdkLog.d("===================================================================================================")
        let url = SdkUtils.makeUrlWithParameters(url, parameters: ["param":SdkUtils.toJsonString(NaviParameters(destination: destination, option: option, viaList: viaList)),
                                                                   "appkey":try! KakaoSDK.shared.appKey(),
                                                                   "apiver":"1.0",
                                                                   "extras":["KA":Constants.kaHeader, "appPkg":Bundle.main.bundleIdentifier].filterNil()?.toJsonString()].filterNil())
        SdkLog.d(" url: \(url?.absoluteString ?? "") \n")
        
        
        
        
        return url
    }
    
}
