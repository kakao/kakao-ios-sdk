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

// string -> type 확인 [v]
// 정확한 스펙 확인이 안되고 v1에서도 string으로 처리하고 코멘트로 안내하였음. "ex) video, music, book, article, profile, website 등"
// 관련 히스토리 https://kakao.agit.in/g/300008305/wall/306743222#comment_panel_306948604. 쓰레드 내 스펙 문서 링크도 404

/// 카카오스토리 포스팅을 위한 스크랩 API 응답 클래스 입니다.
/// - seealso: `StoryApi.linkInfo(url:)`
///
/// 이 스크랩된 정보를 바탕으로 URL 링크를 포스팅 할 수 있습니다.
/// - seealso: `StoryApi.postLink(content:linkInfo:permission:enableShare:androidExecParam:iosExecParam:androidMarketParam:iosMarketParam:)`
public struct LinkInfo : Codable {
    
    // MARK: Fields
    
    /// 스크랩 한 주소의 URL. 단축 URL의 경우 resolution한 실제 URL
    public let url: URL?
    
    /// 요청시의 URL 원본. resolution을 하기 전의 URL
    public let requestedUrl: URL?
    
    /// 스크랩한 호스트 도메인
    public let host: String?
    
    /// 웹 페이지의 제목
    public let title: String?
    
    /// 웹 페이지의 대표 이미지 주소의 URL 배열. 최대 3개.
    public let images: [URL]?
    
    /// 웹 페이지의 설명
    public let description: String?
    
    /// 웹 페이지의 섹션 정보
    public let section: String?
    
    /// 웹 페이지의 콘텐츠 타입. 예) video, music, book, article, profile, website 등.
    public let type: String?
    
    
    // MARK: Internal
    
    enum CodingKeys: String, CodingKey {
        case url, requestedUrl, host, title, description, section, type
        case images = "image"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        url = URL(string:(try? values.decode(String.self, forKey: .url)) ?? "")
        requestedUrl = URL(string:(try? values.decode(String.self, forKey: .requestedUrl)) ?? "")
        host = try? values.decode(String.self, forKey: .host)
        title = try? values.decode(String.self, forKey: .title)
        images = try? values.decode([URL].self, forKey: .images)
        description = try? values.decode(String.self, forKey: .description)
        section = try? values.decode(String.self, forKey: .section)
        type = try? values.decode(String.self, forKey: .type)
    }
}
