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

/// 카카오톡 공유 호출 결과
///
/// 카카오톡 메시지 공유에 성공했더라도 템플릿과 입력 값에 위험요소가 있을 경우 warningMsg, argumentMsg에 기록될 수 있습니다. 개발 단계에서 꼼꼼히 체크하시길 권장합니다.
public struct SharingResult : Codable {
    
    // MARK: Fields
    
    /// 카카오톡 공유 URL
    ///
    /// 이 URL을 열면 카카오톡이 실행되고 카카오톡 메시지를 공유할 수 있습니다.
    public let url: URL
    
    /// 템플릿 내부 구성요소 유효성 검증결과
    /// - key: 메시지 템플릿 요소의 key path
    /// - value: 경고 내용
    public let warningMsg : [String:String]?
    
    /// templateArgs 입력 값 유효성 검증결과
    /// - key: templateArgs에 전달된 key 이름
    /// - value: 경고 내용
    public let argumentMsg : [String:String]?
    
    
    public init(url: URL, warningMsg: [String:String]?, argumentMsg: [String:String]?) {
        self.url = url
        self.warningMsg = warningMsg
        self.argumentMsg = argumentMsg
    }
}
