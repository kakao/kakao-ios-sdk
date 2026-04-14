//
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
import CryptoKit

extension SdkCrypto {
    func parseStorageFormat(_ data: Data?) -> StorageFormat {
        guard let data, data.isEmpty == false else { return .invalid }

        guard let separatorIndex = data.firstIndex(of: UInt8(ascii: ":")) else {
            return .legacy(payload: data)
        }

        let headerData = data.prefix(separatorIndex)
        let payload = Data(data.suffix(from: data.index(after: separatorIndex)))

        if let algorithm = Algorithm(rawValue: String(data: headerData, encoding: .utf8) ?? "") {
            return .tag(algorithm: algorithm, payload: payload)
        } else {
            return .legacy(payload: data)
        }
    }

    func encryptTagged(data: Data?, algorithm: Algorithm, key: Data?) -> Data? {
        guard let encryptedData = encryptPayload(data: data, algorithm: algorithm, key: key) else { return nil }

        var resultData = Data()
        resultData.append(algorithm.header)
        resultData.append(encryptedData)

        return resultData
    }

    func encryptPayload(data: Data?, algorithm: Algorithm, key: Data?) -> Data? {
        guard let data = data, let key else { return nil }
        let symmetricKey = SymmetricKey(data: key)

        var resultData = Data()
        switch algorithm {
        case .aesGcm:
            guard let encryptedData = try? AES.GCM.seal(data, using: symmetricKey).combined else { return nil}
            resultData.append(encryptedData)
        }

        return resultData
    }

    func decryptTagged(algorithm: Algorithm, key: Data?, payload: Data) -> Data? {
        guard let key else { return nil }

        let symmetricKey = SymmetricKey(data: key)
        switch algorithm {
        case .aesGcm:
            guard let sealBox = try? AES.GCM.SealedBox(combined: payload) else { return nil }
            return try? AES.GCM.open(sealBox, using: symmetricKey)
        }
    }
}

extension SdkCrypto {
    enum StorageFormat {
        case legacy(payload: Data)
        case tag(algorithm: Algorithm, payload: Data)
        case invalid
    }

    enum Algorithm: String, CaseIterable {
        case aesGcm

        var header: Data {
            "\(self.rawValue):".data(using: .utf8) ?? Data()
        }
    }
}
