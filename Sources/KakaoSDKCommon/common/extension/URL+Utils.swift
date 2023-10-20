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

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension URL {
  public func params() -> [String:Any]? {
    var dict = [String:Any]()

    if let components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
      if let queryItems = components.queryItems {
        for item in queryItems {
          dict[item.name] = item.value!
        }
      }
      return dict
    } else {
      return nil
    }
  }
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension URL {
    public func oauthResult() -> (code: String?, error: Error?, state: String?) {
        var parameters = [String: String]()
        if let queryItems = URLComponents(string: self.absoluteString)?.queryItems {
            for item in queryItems {
                parameters[item.name] = item.value
            }
        }
        
        let state = parameters["state"]
        if let code = parameters["code"] {
            return (code, nil, state)
        } else {
            if parameters["error"] == nil {
                parameters["error"] = "unknown"
                parameters["error_description"] = "Invalid authorization redirect URI."
            }
            if parameters["error"] == "cancelled" {
                // 간편로그인 취소버튼 예외처리
                return (nil, SdkError(reason: .Cancelled, message: "The KakaoTalk authentication has been canceled by user."), state)
            } else {
                return (nil, SdkError(parameters: parameters), state)
            }
        }
    }
}
