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

/// 카카오내비 API 호출을 담당하는 클래스입니다.
///
/// 원하는 목적지 정보를 입력하여 `NaviLocation` 객체를 만들고 길안내 API를 호출할 수 있습니다.
/// 사용하는 좌표계를 변경하거나 각종 옵션을 설정하려면 `NaviOptions` 를 생성하고 해당 API **options** 파라미터로 함께 전달합니다.
/// 경유지가 있다면 경유지에 대한 `NaviLocation` 객체를 추가로 만들고 배열에 담아 해당 API **viaList** 파라미터로 전달합니다.
///
/// - seealso:
/// `NaviLocation` <br>
/// `NaviOptions`
///
/// 아래는 간단한 카카오내비 길안내 예제입니다.
///
///     let destination = NaviLocation(name: "카카오판교오피스", x: 321286, y: 533707)
///     guard let navigateUrl = NaviApi.shared.navigateUrl(destination: destination) else {
///         return
///     }
///     UIApplication.shared.open(navigateUrl, options: [:], completion: nil)
public class NaviApi {
    
    // MARK: Fields
    
    /// 간편하게 API를 호출할 수 있도록 제공되는 공용 싱글톤 객체입니다.
    public static let shared = NaviApi()
    
    
    // MARK: Using KakaoNavi
    
    /// 카카오내비 장소 공유 URL을 얻습니다. 획득한 URL을 열면 카카오내비 앱이 실행됩니다.
    public func shareUrl(destination:NaviLocation,
                         option:NaviOption? = nil,
                         viaList:[NaviLocation]? = nil) -> URL? {
        return makeNaviUrl(url: Urls.compose(.Navi, path:Paths.shareDestination), destination: destination, option: option, viaList: viaList)
    }
    
    /// 카카오내비 길안내 URL을 얻습니다. 획득된 URL을 열면 카카오내비 앱이 실행됩니다.
    public func navigateUrl(destination:NaviLocation,
                            option:NaviOption? = nil,
                            viaList:[NaviLocation]? = nil) -> URL? {
        return makeNaviUrl(url: Urls.compose(.Navi, path:Paths.navigateDestination), destination: destination, option: option, viaList: viaList)
    }
    
    
    // MARK: Using Web Navigation
    
    /// 웹 길안내 URL을 얻습니다. 획득한 URL을 브라우저에 요청하면 카카오내비 앱이 설치되지 않은 환경에서도 길안내를 받을 수 있습니다.
    ///
    /// - important:
    /// 외부 브라우저로 열지 않고 **웹뷰**를 사용할 경우 추가 설정이 필요합니다. 사용자의 위치정보에 접근할 수 있도록 info.plist 파일에 **"Privacy - Location When In Use Usage Description"** 항목을 추가해야 합니다.
    public func webNavigateUrl(destination:NaviLocation,
                               option:NaviOption? = nil,
                               viaList:[NaviLocation]? = nil) -> URL? {
        return makeNaviUrl(url:Urls.compose(.WebNavi, path:Paths.webNavigateDestination), destination: destination, option: option, viaList: viaList)
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
