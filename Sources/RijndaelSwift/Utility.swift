//
//  Utility.swift
//  RijndaelSwift
//
//  Created by zzk on 02/01/2018.
//  Copyright © 2018 RijndaelSwift. All rights reserved.
//

import Foundation

public extension Data {
    
    func hexadecimal() -> String {
        return map { String(format: "%02x", $0) }
            .joined(separator: "")
    }
    
}

public extension String {
    
    func hexadecimal() -> Data? {
        let len = count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = index(startIndex, offsetBy: i*2)
            let k = index(j, offsetBy: 2)
            let bytes = self[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        return data
    }
    
}
