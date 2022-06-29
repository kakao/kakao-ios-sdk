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

/// :nodoc: 템플릿 조회 결과 (SDK 내부용)
public struct ValidationResult : Codable {
    
    public let templateId : Int64
    public let templateArgs : [String:String]?
    public let templateMsg : [String:Any]
    public let warningMsg : [String:String]?
    public let argumentMsg : [String:String]?
    
    //comment: 깊이가 있는 값의 키에 _가 있는 경우가 있어 이모델만 custom encoding, decoding rule를 적용하지 않는다.
    
    enum CodingKeys : String, CodingKey {
        case templateId = "template_id"
        case templateArgs = "template_args"
        case templateMsg = "template_msg"
        case warningMsg = "warning_msg"
        case argumentMsg = "argument_msg"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        templateId = try values.decode(Int64.self, forKey: .templateId)
        templateArgs = try? values.decode([String:String].self, forKey: .templateArgs)
        templateMsg = try values.decode([String:Any].self, forKey: .templateMsg)
        
        warningMsg = try? values.decode([String:String].self, forKey: .warningMsg)
        argumentMsg = try? values.decode([String:String].self, forKey: .argumentMsg)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(templateId, forKey: .templateId)
        try container.encodeIfPresent(templateArgs, forKey: .templateArgs)
        try container.encodeIfPresent(templateMsg, forKey: .templateMsg)
        try container.encode(warningMsg, forKey: .warningMsg)
        try container.encode(argumentMsg, forKey: .argumentMsg)
    }
}
