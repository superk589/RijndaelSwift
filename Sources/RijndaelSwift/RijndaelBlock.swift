//
//  RijndaelBlock.swift
//  RijndaelSwift
//
//  Created by zzk on 28/12/2017.
//  Copyright © 2017 RijnDaelSwift. All rights reserved.
//

import Foundation

private let sizes = [16, 24, 32]

private let rounds = [
    16: [ 16: 10, 24: 12, 32: 14 ],
    24: [ 16: 12, 24: 12, 32: 14 ],
    32: [ 16: 14, 24: 14, 32: 14 ],
]

private func sbox(_ index: UInt8) -> UInt8 {
    return Precalculated.sbox[Int(index)]
}

private func mul02(_ index: UInt8) -> UInt8 {
    return Precalculated.mul2[Int(index)]
}

private func mul03(_ index: UInt8) -> UInt8 {
    return Precalculated.mul3[Int(index)]
}

private func mul09(_ index: UInt8) -> UInt8 {
    return Precalculated.mul9[Int(index)]
}

private func mul11(_ index: UInt8) -> UInt8 {
    return Precalculated.mul11[Int(index)]
}

private func mul13(_ index: UInt8) -> UInt8 {
    return Precalculated.mul13[Int(index)]
}

private func mul14(_ index: UInt8) -> UInt8 {
    return Precalculated.mul14[Int(index)]
}

private func rcon(_ index: Int) -> UInt8 {
    return Precalculated.rcon[index]
}

struct RijndaelBlock {
    
    let key: Data
    
    let keySize: Int
    
    init?(key: Data) {
        guard sizes.contains(key.count) else {
            return nil
        }
        self.keySize = key.count
        self.key = key
    }
    
    func expandKey(blockSize: Int) -> Data {
        let roundCount = rounds[blockSize]![keySize]!
        let keyCount = roundCount + 1
        var expandKey = Data(count: blockSize * keyCount)
        
        for i in 0..<keySize {
            expandKey[i] = key[i]
        }
        
        var rconIndex = 0
        
        for i in stride(from: keySize, to: expandKey.count, by: 4) {
            var temp = Data(expandKey[i - 4..<i])
            if i % keySize == 0 {
                temp = Data([
                    sbox(temp[1]) ^ rcon(rconIndex),
                    sbox(temp[2]),
                    sbox(temp[3]),
                    sbox(temp[0]),
                ])
                
                rconIndex += 1
            }
            
            if i % keySize < 16 {
                for j in 0..<4 {
                    expandKey[i + j] = expandKey[i - keySize + j] ^ temp[j]
                }
            }
            
            if keySize == 16 {
                continue
            }
            
            if keySize == 32 && i % keySize == 16 {
                temp = Data([
                    sbox(temp[0]),
                    sbox(temp[1]),
                    sbox(temp[2]),
                    sbox(temp[3])
                ])
                
                for j in 0..<4 {
                    expandKey[i + j] = expandKey[i - keySize + j] ^ temp[j]
                }
            } else {
                for j in 0..<4 {
                    expandKey[i + j] = expandKey[i - keySize + j] ^ temp[j]
                }
            }
        }

        return expandKey
    }
    
    func addRoundKey(block: inout Data, key: Data, keyIndex: Int) {
        let blockSize = block.count
        for i in 0..<blockSize {
            block[i] ^= key[keyIndex * blockSize + i]
        }
    }
    
    func subBytes(block: inout Data) {
        for i in 0..<block.count {
            block[i] = sbox(block[i])
        }
    }
    
    func subBytesReversed(block: inout Data) {
        for i in 0..<block.count {
            block[i] = UInt8(Precalculated.sbox.firstIndex(of: block[i])!)
        }
    }
    
    func shiftRows(block: inout Data) {
        var output = Data()
        for i in 0..<block.count {
            output.append(block[Precalculated.rowShift[block.count]![i]])
        }
        for i in 0..<block.count {
            block[i] = output[i]
        }
    }
    
    func shiftRowsReversed(block: inout Data) {
        var output = Data()
        for i in 0..<block.count {
            output.append(block[Precalculated.rowShift[block.count]!.firstIndex(of: i)!])
        }
        for i in 0..<block.count {
            block[i] = output[i]
        }
    }
    
    func mixColumns(block: inout Data) {
        for i in stride(from: 0, to: block.count, by: 4) {
            let a = Data(block[i..<i + 4])
            let b = [mul02(a[0]) ^ mul03(a[1]) ^ a[2] ^ a[3],
                     a[0] ^ mul02(a[1]) ^ mul03(a[2]) ^ a[3],
                     a[0] ^ a[1] ^ mul02(a[2]) ^ mul03(a[3]),
                     mul03(a[0]) ^ a[1] ^ a[2] ^ mul02(a[3])]
            
            block[i + 0] = b[0]
            block[i + 1] = b[1]
            block[i + 2] = b[2]
            block[i + 3] = b[3]
        }
    }
    
    func mixColumnsReversed(block: inout Data) {
        for i in stride(from: 0, to: block.count, by: 4) {
            let b = Data(block[i..<i + 4])
            let a = [
                mul14(b[0]) ^ mul11(b[1]) ^ mul13(b[2]) ^ mul09(b[3]),
                mul09(b[0]) ^ mul14(b[1]) ^ mul11(b[2]) ^ mul13(b[3]),
                mul13(b[0]) ^ mul09(b[1]) ^ mul14(b[2]) ^ mul11(b[3]),
                mul11(b[0]) ^ mul13(b[1]) ^ mul09(b[2]) ^ mul14(b[3])]
            block[i + 0] = a[0]
            block[i + 1] = a[1]
            block[i + 2] = a[2]
            block[i + 3] = a[3]
        }
    }
    
    func encrypt(block: Data) -> Data? {
        let blockSize = block.count
        let roundCount = rounds[blockSize]![keySize]!
        if !sizes.contains(blockSize) {
            return nil
        }
        var state = block
        let expandedKey = expandKey(blockSize: blockSize)
        
        addRoundKey(block: &state, key: expandedKey, keyIndex: 0)
        
        for round in 1..<roundCount {
            subBytes(block: &state)
            shiftRows(block: &state)
            mixColumns(block: &state)
            addRoundKey(block: &state, key: expandedKey, keyIndex: round)
        }
        
        subBytes(block: &state)
        shiftRows(block: &state)
        addRoundKey(block: &state, key: expandedKey, keyIndex: roundCount)
        
        return state
    }

    func decrypt(block: Data) -> Data? {
        let blockSize = block.count
        let roundCount = rounds[blockSize]![keySize]!
        
        if !sizes.contains(blockSize) {
            return nil
        }
        
        var state = block
        
        let expandedKey = expandKey(blockSize: blockSize)
        
        addRoundKey(block: &state, key: expandedKey, keyIndex: roundCount)
        shiftRowsReversed(block: &state)
        subBytesReversed(block: &state)
        
        
        for round in stride(from: roundCount - 1, through: 1, by: -1) {
            addRoundKey(block: &state, key: expandedKey, keyIndex: round)
            mixColumnsReversed(block: &state)
            shiftRowsReversed(block: &state)
            subBytesReversed(block: &state)
        }
        
        addRoundKey(block: &state, key: expandedKey, keyIndex: 0)
        
        return state
    }
}
