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

/// 이미지 업로드, 스크랩 요청 결과
public struct ImageUploadResult : Codable {
    
    /// 업로드된 이미지 정보
    public let infos: ImageInfos
}

public struct ImageInfos : Codable {
    
    /// 원본 이미지
    public let original: ImageInfo
}

public struct ImageInfo : Codable {
    
    // MARK: Fields
    
    /// 업로드 된 이미지의 URL
    public let url: URL
    
    /// 업로드 된 이미지의 Content-Type
    public let contentType: String
    
    /// 업로드 된 이미지의 용량 (단위: 바이트)
    public let length: Int
    
    /// 업로드 된 이미지의 너비 (단위: 픽셀)
    public let width: Int
    
    /// 업로드 된 이미지의 높이 (단위: 픽셀)
    public let height: Int
    
}
