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

/// 이미지 업로드 결과 \
/// Image upload result
public struct ImageUploadResult : Codable {
    
    /// 이미지 정보 목록 \
    /// List of image information
    public let infos: ImageInfos
}

/// 이미지 정보 목록 \
/// List of image information
public struct ImageInfos : Codable {
    
    /// 이미지 정보 \
    /// Image information
    public let original: ImageInfo
}

/// 이미지 정보 \
/// Image information
public struct ImageInfo : Codable {
    
    // MARK: Fields
    
    /// 이미지 URL \
    /// Image URL
    public let url: URL
    
    /// 이미지 포맷 \
    /// Image format
    public let contentType: String
    
    /// 이미지 파일 크기(단위: 바이트) \
    /// Image file size (Unit: byte)
    public let length: Int
    
    /// 이미지 너비 \
    /// Image width
    public let width: Int
    
    /// 이미지 높이 \
    /// Image height
    public let height: Int
    
}
