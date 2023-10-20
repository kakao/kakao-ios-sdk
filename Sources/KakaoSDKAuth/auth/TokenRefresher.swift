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

import UIKit
import Foundation
import KakaoSDKCommon

///:nodoc:
@available(iOSApplicationExtension, unavailable)
class TokenRefresher {
    static let shared = TokenRefresher()
    
    private var updatedAt: Date?
    private let coolTime: TimeInterval = 60 * 60 * 6 // 6시간
    
    init() {
        //SdkLog.v("[TokenRefresher] didBecomActiveNotification observer for CAT added.")
        NotificationCenter.default.addObserver(self, selector: #selector(self.didBecomeActiveForRefreshToken), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func registTokenRefresher() {
    }
}

@available(iOSApplicationExtension, unavailable)
extension TokenRefresher {
    ///:nodoc:
    @objc func didBecomeActiveForRefreshToken(_ notification: Notification) {
        if (shouldRefreshToken()) {
            cat {[weak self] (_) in
                self?.updatedAt = Date()
                //SdkLog.v("[TokenRefresher] CAT call time updated")
            }
        }
    }

    ///:nodoc:
    func shouldRefreshToken() -> Bool {
        let currentTimeStamp = Date().timeIntervalSince1970
        
        if let updatedAt = updatedAt {
            if (abs(updatedAt.timeIntervalSince1970 - currentTimeStamp) < coolTime) {
                //SdkLog.v("[TokenRefresher] dont have to call CAT ==> cooltimeInterval: \(coolTime)  passedTimeInterval: \(abs(updatedAt.timeIntervalSince1970 - currentTimeStamp))")
                return false
            }
            else {
                //SdkLog.v("[TokenRefresher] have to call CAT : ==> cooltimeInterval: \(coolTime)  passedTimeInterval: \(abs(updatedAt.timeIntervalSince1970 - currentTimeStamp))")
            }
        }
        
        return true
    }
    
    ///:nodoc:
    func cat(completion:@escaping (Error?) -> Void) {
        AUTH_API.responseData(.get,
              Urls.compose(path:Paths.checkAccessToken),
              apiType: .KApi) { (response, data, error) in
                if let error = error {
                    //SdkLog.v(error)
                    completion(error)
                    return
                }
                
                if let _ = data {
                    //SdkLog.v("[TokenRefresher] success to call CAT")
                    completion(nil)
                    return
                }
        }
    }
}
