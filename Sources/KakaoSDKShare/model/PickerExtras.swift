//  Copyright 2026 Kakao Corp.
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

/// 카카오톡 공유 피커 추가 설정 \
/// Additional settings for the Kakao Talk sharing picker
public struct PickerExtras: Codable {
    /// '나에게' 메뉴 노출 여부. nil이면 해당 설정을 전달하지 않음 \
    /// Whether to show the Send to Me menu. Omitted when nil
    public let showSendToMe: Bool?

    /// 피커 그룹 템플릿 ID
    public let groupId: Int64?

    /// 피커 타입: chat, friend, default
    public let type: String?

    /// 선택 가능한 대상 수
    public let limit: Int?

    public init(showSendToMe: Bool? = nil, groupId: Int64? = nil, type: String? = nil, limit: Int? = nil) {
        self.showSendToMe = showSendToMe
        self.groupId = groupId
        self.type = type
        self.limit = limit
    }

    @_documentation(visibility: private)
    /// 검증 API 요청에 사용할 JSON. 모든 필드가 nil이면 생략합니다.
    public func toRequestJsonString() throws -> String? {
        let encoded = try SdkJSONEncoder.default.encode(self)
        let json = String(decoding: encoded, as: UTF8.self)
        return json == "{}" ? nil : json
    }

    private enum CodingKeys: String, CodingKey {
        case showSendToMe = "show_send_to_me"
        case groupId = "group_id"
        case type
        case limit
    }
}
