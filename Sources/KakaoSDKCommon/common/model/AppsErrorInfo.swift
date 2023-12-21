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

/// APPS 호출 시 발생하는 에러 정보입니다.
/// ## SeeAlso
/// - ``AppsFailureReason``
public struct AppsErrorInfo : Codable {
    public let errorCode : AppsFailureReason
    public let errorMsg : String
    
    enum CodingKeys : String, CodingKey {
        case errorCode, errorMsg
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        errorCode = try values.decode(AppsFailureReason.self, forKey: .errorCode)
        errorMsg = "[\(errorCode.rawValue)]\(try values.decode(String.self, forKey: .errorMsg))"
    }
}
