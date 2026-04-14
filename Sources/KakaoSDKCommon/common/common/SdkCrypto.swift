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
import UIKit

import CommonCrypto

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
public final class SdkCrypto {
    public static let shared = SdkCrypto()
    
    let iteration : Int
    var seed : Data = Data()
    var iv : Data?
    
    private let lock = NSLock()
    private var _cachedKey: Data?
    
    init() {
        self.iteration = 10000
    }
    
    func createSeed() -> Data? {
        guard let appId = Bundle.main.bundleIdentifier else {
            SdkLog.e("Invalid AppId")
            return nil
        }
        guard let seed = self.sha256(string: appId), seed.count == 32 else {
            SdkLog.e("Invalid Seed")
            return nil
        }
        return seed
    }
    
    private func key() -> Data? {
        if _cachedKey != nil { return _cachedKey }
        
        if let seed = createSeed() {
            self.seed = seed
            //SdkLog.d("seed: \(self.seed)")
            
            guard seed.count == 32 else {
                SdkLog.e("invalid seed length.")
                return nil
            }
            self.iv = seed.subdata(in: 0..<16)
            //SdkLog.d("iv: \(self.iv?.hexEncodedString() ?? "iv is nil?")")
        }
        else { return nil }
        
        guard let venderId = UIDevice.current.identifierForVendor?.uuidString else {
            SdkLog.e("venderId is nil.")
            return nil
        }
        //SdkLog.d("venderId: \(venderId)")
        
        let password = "SDK-\(venderId)"
        let salt =  seed.subdata(in: 16..<seed.count)
        //SdkLog.d("salt: \(salt.hexEncodedString())")
        
        _cachedKey = pbkdf2(algorithm: CCPBKDFAlgorithm(kCCPRFHmacAlgSHA256), password: password, salt: salt, keyByteCount: size_t(kCCKeySizeAES256), rounds: self.iteration)
        return _cachedKey
    }
    
    public func encrypt(data: Data?) -> Data? {
        lock.lock(); defer { lock.unlock() }

        return encryptTagged(data: data, algorithm: .aesGcm, key: self.key())
    }
    
    public func decrypt(data: Data?) -> Data? {
        lock.lock(); defer { lock.unlock() }
        let storageFormat = parseStorageFormat(data)

        switch storageFormat {
        case .legacy(let payload):
            return crypt(data: data,
                         key:self.key(),
                         keyLength: size_t(kCCKeySizeAES256),
                         iv:self.iv,
                         operation: CCOperation(kCCDecrypt),
                         option: CCOptions(kCCOptionPKCS7Padding))
        case .tag(let algorithm, let payload):
            return decryptTagged(algorithm: algorithm, key: key(), payload: payload)
        case .invalid:
            return nil
        }
    }
    
    public func encryptForMigration(data: Data?) -> Data? {
        guard let venderId = UIDevice.current.identifierForVendor?.uuidString else {
            SdkLog.e("venderId is nil.")
            return nil
        }
        //SdkLog.d("venderId: \(venderId)")
        let key = self.sha256(string:"SDK-\(venderId)")
        //SdkLog.d("key: \(key?.hexEncodedString() ?? "key is nil?")")
        
        return self.encryptForMigration(data: data, key: key)
    }
    
    public func encryptForMigration(data: Data?, key: Data?) -> Data? {
        return crypt(data: data,
                     key:key,
                     keyLength: size_t(kCCKeySizeAES256),
                     iv:nil,
                     operation: CCOperation(kCCEncrypt),
                     option: CCOptions(kCCOptionECBMode|kCCOptionPKCS7Padding))
    }
    
    public func decryptForMigration(data: Data?) -> Data? {
        guard let venderId = UIDevice.current.identifierForVendor?.uuidString else {
            SdkLog.e("venderId is nil.")
            return nil
        }
        //SdkLog.d("venderId: \(venderId)")
        
        let key = self.sha256(string:"SDK-\(venderId)")
        //SdkLog.d("key: \(key?.hexEncodedString() ?? "key is nil?")")
        
        return self.decryptForMigration(data: data, key: key)
    }

    public func decryptForMigration(data: Data?, key: Data?) -> Data? {
        return crypt(data: data,
                     key:key,
                     keyLength: size_t(kCCKeySizeAES256),
                     iv:nil,
                     operation: CCOperation(kCCDecrypt),
                     option: CCOptions(kCCOptionECBMode|kCCOptionPKCS7Padding))
    }
    
    func crypt(data:Data?, key: Data?, keyLength: Int, iv: Data?, operation: CCOperation, option: CCOptions) -> Data? {

        guard var data = data else { return nil }
        //SdkLog.d("data: \(data.hexEncodedString())")
        
        guard let key = key else { return nil }
        //SdkLog.d("key: \(key.hexEncodedString())")
            
        var resultLength :size_t = 0
        let cryptLength = size_t(data.count + kCCBlockSizeAES128)
        var cryptData = Data(count:cryptLength)
        
        let cryptStatus = performCCCrypt(key: key,
                                             keyLength: keyLength,
                                             data: data,
                                             iv: iv,
                                             operation: operation,
                                             option: option,
                                             cryptLength: cryptLength,
                                             cryptData: &cryptData,
                                             resultLength: &resultLength)
        
        if (Int32(cryptStatus) != Int32(kCCSuccess)) {
            SdkLog.e("== operation : \(operation) -- crypt failed : \(cryptStatus)")
            return nil
        }
        
        cryptData.removeSubrange(resultLength..<cryptData.count)
        return cryptData
    }
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension SdkCrypto {
    public func generateCodeVerifier() -> String? {
        let uuid = UUID().uuidString
        if let codeVerifierData = self.sha512(string: uuid) {
            return self.base64(data: codeVerifierData).replacingOccurrences(of: "=", with: "")
        }
        return nil
    }
    
    func sha512(data: Data) -> Data? {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA512_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA512($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
    
    func sha512(string: String) -> Data? {
        guard let data = string.data(using: String.Encoding.utf8) else {
            SdkLog.e("Invalid Seed.")
            return nil
        }
        return self.sha512(data: data)
    }
    
    public func base64(data: Data) -> String {
        return data.base64EncodedString(options: [.endLineWithCarriageReturn, .endLineWithLineFeed])
    }
    
    public func base64url(data: Data) -> String {
        let base64url = self.base64(data:data)
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return base64url
    }
    
    public func sha256(data: Data) -> Data? {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
    
    public func sha256(string: String) -> Data? {
        guard let data = string.data(using: String.Encoding.utf8) else {
            SdkLog.e("Invalid Seed.")
            return nil
        }
        return self.sha256(data: data)
    }
}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension SdkCrypto {
    // MARK: - Helper ---------------------------------------------------------------------------------
    
    func performCCCrypt(key: Data,
                        keyLength: Int,
                        data: Data,
                        iv: Data?,
                        operation: CCOperation,
                        option: CCOptions,
                        cryptLength: Int,
                        cryptData: inout Data,
                        resultLength: inout size_t) -> CCCryptorStatus {
        return key.withUnsafeBytes { keyTempBytes in
            let keyBytes = UnsafeRawPointer(keyTempBytes.bindMemory(to: UInt8.self).baseAddress)
            return data.withUnsafeBytes { dataTempBytes in
                let dataBytes = UnsafeRawPointer(dataTempBytes.bindMemory(to: UInt8.self).baseAddress)
                
                return cryptData.withUnsafeMutableBytes { (tempBytes) in
                    let cryptBytes = UnsafeMutableRawPointer(tempBytes.bindMemory(to: UInt8.self).baseAddress)
                    
                    if let iv = iv {
                        return iv.withUnsafeBytes { ivTempBytes in
                            let ivBytes = UnsafeRawPointer(ivTempBytes.bindMemory(to: UInt8.self).baseAddress)
                            
                            return CCCrypt(operation,
                                           CCAlgorithm(kCCAlgorithmAES),
                                           option,
                                           keyBytes, keyLength,
                                           ivBytes,
                                           dataBytes, data.count, //data in
                                           cryptBytes, cryptLength, //data out
                                           &resultLength) //data move
                        }
                    }
                    
                    return CCCrypt(operation,
                                   CCAlgorithm(kCCAlgorithmAES),
                                   option,
                                   keyBytes, keyLength,
                                   nil,
                                   dataBytes, data.count, //data in
                                   cryptBytes, cryptLength, //data out
                                   &resultLength) //data move
                }
            }
        }
    }
    
    func pbkdf2(algorithm :CCPBKDFAlgorithm, password: String, salt: Data, keyByteCount: Int, rounds: Int) -> Data? {
        guard let passwordData = password.data(using:String.Encoding.utf8) else {
            return nil
        }
        var derivedKeyData = Data(repeating:0, count:keyByteCount)
        let count = derivedKeyData.count
        let derivationStatus = derivedKeyData.withUnsafeMutableBytes {derivedKeyBytes in
            salt.withUnsafeBytes { saltBytes in
                
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    password, passwordData.count,
                    saltBytes.bindMemory(to: UInt8.self).baseAddress, salt.count,
                    algorithm,
                    UInt32(rounds),
                    derivedKeyBytes.bindMemory(to: UInt8.self).baseAddress, count)
            }
        }
        if (derivationStatus != 0) {
            SdkLog.e("key generation failed : \(derivationStatus)")
            return nil
        }
        
        return derivedKeyData
    }
}
