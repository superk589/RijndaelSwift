//
//  Rijndael.swift
//  RijndaelSwift
//
//  Created by zzk on 28/12/2017.
//  Copyright © 2017 RijnDaelSwift. All rights reserved.
//

import Foundation

public enum Mode {
    case ecb
    case cbc
}

public enum Padding {
    case no // behaves like .zero
    case pkcs7 // new version
    case ansix923 // TBD, behaves like .zero
    case iso10126 // behaves like pkcs7
    case zero // default one 
}

private let sizes = [16, 24, 32]

public struct Rijndael {
    
    public let key: Data
    public let mode: Mode

    public let keySize: Int
    public let padding: Padding
    
    public init?(key: Data, mode: Mode, padding: Padding = .zero) {
        if !sizes.contains(key.count) {
            return nil
        }
        self.mode = mode
        self.key = key
        self.keySize = key.count
        self.padding = padding
    }
    
    
    /// encrypt plain data to cipher data
    ///
    /// - Parameters:
    ///   - data: plain data
    ///   - blockSize: size in bytes
    ///   - iv: iv data
    /// - Returns: encrypted cipher data
    public func encrypt(data: Data, blockSize: Int, iv: Data?) -> Data? {
        
        if blockSize <= 32 && !sizes.contains(blockSize) {
            return nil
        } else if blockSize > 32 {
            if !sizes.contains(blockSize / 8) {
                return nil
            }
        }
        
        if mode == .cbc {
            if iv?.count != blockSize {
                return nil
            }
        }
        
        var _data = data
        var padLength = data.count % blockSize
        if padLength != 0 {
            padLength = blockSize - padLength
        }
        
        let extraByte: UInt8
        switch(padding) {
            case .no:
                break
            case .pkcs7, .iso10126:
                if padLength == 0 {
                    padLength = blockSize
                }
                extraByte = UInt8(padLength)
                for _ in 0..<padLength {
                    _data.append(extraByte)
                }
            case .ansix923:
                extraByte = UInt8(padLength)
                if padLength >= 1 {
                    let zero = UInt8(0)
                    for _ in 0..<(padLength - 1) {
                        _data.append(zero)
                    }
                    _data.append(extraByte)
                }
            case .zero:
                extraByte = UInt8(0)
                for _ in 0..<padLength {
                    _data.append(extraByte)
                }
        }
        
        let blockCount = _data.count / blockSize
        var cipherText = Data(count: _data.count)
        guard let cipher = RijndaelBlock(key: key) else {
            return nil
        }
        
        switch mode {
        case .ecb:
            for i in 0..<blockCount {
                let start = i * blockSize
                let end = (i + 1) * blockSize
                let block = Data(_data[start..<end])
                if let encrypted = cipher.encrypt(block: block) {
                    for j in 0..<blockSize {
                        cipherText[start + j] = encrypted[j]
                    }
                }
            }
        case .cbc:
            var newIV = iv!
            for i in 0..<blockCount {
                let start = i * blockSize
                let end = (i + 1) * blockSize
                var block = Data(_data[start..<end])
                
                for j in 0..<blockSize {
                    block[j] ^= newIV[j]
                }
                
                if let encrypted = cipher.encrypt(block: block) {
                    for j in 0..<blockSize {
                        cipherText[start + j] = encrypted[j]
                    }
                    newIV = encrypted
                }
            }
        }
        return cipherText
    }
    
    /// decrypt cipher data to plain data
    ///
    /// - Parameters:
    ///   - data: cipher data
    ///   - blockSize: size in bytes
    ///   - iv: iv data
    /// - Returns: decrypted plain data
    public func decrypt(data: Data, blockSize: Int, iv: Data?) -> Data? {
        
        if blockSize <= 32 && !sizes.contains(blockSize) {
            return nil
        } else if blockSize > 32 {
            if !sizes.contains(blockSize / 8) {
                return nil
            }
        }
        
        if mode == .cbc {
            if iv?.count != blockSize {
                return nil
            }
        }
        
        if data.count % blockSize != 0 {
            return nil
        }
        
        let blockCount = data.count / blockSize
        var plainText = Data(count: data.count)
        
        guard let cipher = RijndaelBlock(key: key) else {
            return nil
        }
        
        switch mode {
        case .ecb:
            for i in 0..<blockCount {
                let start = i * blockSize
                let end = (i + 1) * blockSize
                let block = Data(data[start..<end])
                if let decrypted = cipher.decrypt(block: block) {
                    for j in 0..<blockSize {
                        plainText[start + j] = decrypted[j]
                    }
                }
            }
        case .cbc:
            var newIV = iv!
            for i in 0..<blockCount {
                let start = i * blockSize
                let end = (i + 1) * blockSize
                let block = Data(data[start..<end])
                if let decrypted = cipher.decrypt(block: block) {
                    for j in 0..<blockSize {
                        plainText[start + j] = decrypted[j] ^ newIV[j]
                    }
                }
                newIV = block
            }
        }
        
        switch (padding) {
        case .zero:
            for _ in 0..<blockSize {
                if let last = plainText.last, last == 0 {
                    plainText.removeLast()
                } else {
                    break
                }
            }
        case .pkcs7:
            if let size = plainText.last {
                for _ in 0..<size {
                    plainText.removeLast()
                }
            }
        case .ansix923:
            if let size = plainText.last {
                for _ in 0..<size {
                    plainText.removeLast()
                }
            }
        default:
            break
        }
        return plainText
    }
}
