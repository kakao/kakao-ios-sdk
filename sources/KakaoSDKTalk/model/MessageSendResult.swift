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

/// 메시지 전송 API 호출 결과 입니다.
/// - seealso:
/// `TalkApi.sendDefaultMessage(templatable:receiverUuids:)`<br>
/// `TalkApi.sendScrapMessage(requestUrl:templateId:templateArgs:receiverUuids:)`<br>
/// `TalkApi.sendCustomMessage(templateId:templateArgs:receiverUuids:)`
public struct MessageSendResult : Codable {
    
    // MARK: Fields
    
    /// 메시지 전송에 성공한 대상의 UUID
    public let successfulReceiverUuids: [String]?
    
    /// (복수의 전송 대상을 지정한 경우) 전송 실패한 일부 대상의 오류 정보
    public let failureInfos: [MessageFailureInfo]?
    
    
    // MARK: Internal
    
    enum CodingKeys: String, CodingKey {
        case successfulReceiverUuids
        case failureInfos = "failureInfo"
    }
}

/// 복수의 친구를 대상으로 메시지 전송 API 호출 시 대상 중 일부가 실패한 경우 오류 정보를 제공합니다.
/// - seealso: `MessageSendResult.failureInfos`
public struct MessageFailureInfo : Codable {
    
    // MARK: Fields
    
    /// 오류 코드
    public let code: Int
    
    /// 메시지
    public let msg: String
    
    /// 이 에러로 인해 실패한 대상 목록
    public let receiverUuids: [String]
}
