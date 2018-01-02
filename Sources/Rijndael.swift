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

private let sizes = [16, 24, 32]

public struct Rijndael {
    
    let key: Data
    let mode: Mode

    let keySize: Int
    
    init?(key: Data, mode: Mode) {
        if !sizes.contains(key.count) {
            return nil
        }
        self.mode = mode
        self.key = key
        self.keySize = key.count
    }
    
    
    func encrypt(data: Data, blockSize: Int, iv: Data) -> Data? {
        
        if blockSize <= 32 && !sizes.contains(blockSize) {
            return nil
        } else if blockSize > 32 {
            if !sizes.contains(blockSize / 8) {
                return nil
            }
        }
        
        if mode == .cbc {
            if iv.count != blockSize {
                return nil
            }
        }
        
        var _data = data
        var padLength = data.count % blockSize
        if padLength != 0 {
            padLength = blockSize - padLength
        }
        for _ in 0..<padLength {
            _data.append(0)
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
                let block = _data[start..<end]
                if let encrypted = cipher.encrypt(block: block) {
                    for j in 0..<blockSize {
                        cipherText[start + j] = encrypted[j]
                    }
                }
            }
        case .cbc:
            var newIV = iv
            for i in 0..<blockCount {
                let start = i * blockSize
                let end = (i + 1) * blockSize
                var block = _data[start..<end]
                
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
    
    func decrypt(data: Data, blockSize: Int, iv: Data) -> Data? {
        
        if blockSize <= 32 && !sizes.contains(blockSize) {
            return nil
        } else if blockSize > 32 {
            if !sizes.contains(blockSize / 8) {
                return nil
            }
        }
        
        if mode == .cbc {
            if iv.count != blockSize {
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
            var newIV = iv
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
        return plainText
    }
}
