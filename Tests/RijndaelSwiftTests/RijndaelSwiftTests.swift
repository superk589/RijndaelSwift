//
//  RijndaelSwiftTests.swift
//  RijndaelSwift
//
//  Created by superk on 02/01/2018.
//  Copyright © 2018 RijndaelSwift. All rights reserved.
//

import Foundation
import XCTest
import RijndaelSwift

class RijndaelSwiftTests: XCTestCase {
    
    func testK128B128() {
        
        let r = RijndaelBlock(key: "80000000000000000000000000000000".hexadecimal()!)
        let p = "00000000000000000000000000000000".hexadecimal()!
        let cipher = "0EDD33D3C621E546455BD8BA1418BEC8".hexadecimal()!
        
        XCTAssert(r?.encrypt(block: p) == cipher)
        XCTAssert(r?.decrypt(block: cipher) == p)
    }
    
    func testK192B128() {
        
        let r = RijndaelBlock(key: "800000000000000000000000000000000000000000000000".hexadecimal()!)
        let p = "00000000000000000000000000000000".hexadecimal()!
        let cipher = "DE885DC87F5A92594082D02CC1E1B42C".hexadecimal()!
        
        XCTAssert(r?.encrypt(block: p) == cipher)
        XCTAssert(r?.decrypt(block: cipher) == p)
    }
    
    func testK256B128() {
        
        let r = RijndaelBlock(key: "8000000000000000000000000000000000000000000000000000000000000000".hexadecimal()!)
        let p = "00000000000000000000000000000000".hexadecimal()!
        let cipher = "E35A6DCB19B201A01EBCFA8AA22B5759".hexadecimal()!
        
        XCTAssert(r?.encrypt(block: p) == cipher)
        XCTAssert(r?.decrypt(block: cipher) == p)
    }
    
    func testK256B192() {
        let r = RijndaelBlock(key: "8000000000000000000000000000000000000000000000000000000000000000".hexadecimal()!)
        let p = "000000000000000000000000000000000000000000000000".hexadecimal()!
        let cipher = "06EB844DEC23F29F029BE85FDCE578CEC5C663CE0C70403C".hexadecimal()!
        
        XCTAssert(r?.encrypt(block: p) == cipher)
        XCTAssert(r?.decrypt(block: cipher) == p)
    }
    
    func testK256B256() {

        let r = RijndaelBlock(key: "0000000002000000000000000000000000000000000000000000000000000000".hexadecimal()!)
        let p = "0000000000000000000000000000000000000000000000000000000000000000".hexadecimal()!
        let cipher = "151A240A0D998D734292BE7D2C7FA91E6CCF5F3F9901D811B7FF72CF8763462E".hexadecimal()!
        
        XCTAssert(r?.encrypt(block: p) == cipher)
        XCTAssert(r?.decrypt(block: cipher) == p)
    }
    
    func testUtility() {
        let p = "0000000000000000000000000000000000000000000000000000000000000000"
        XCTAssert(p == p.hexadecimal()?.hexadecimal() )
    }
    
    func testReversible() {
        let r = Rijndael(key: "0000000002000000000000000000000000000000000000000000000000000000".hexadecimal()!, mode: .cbc)
        let iv = "0000000008000000000000000000000000000000000000000000000000000000".hexadecimal()!
        let p = "abcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcd".hexadecimal()!
        
        let cipher = r?.encrypt(data: p, blockSize: 32, iv: iv)
        let plain = r?.decrypt(data: cipher!, blockSize: 32, iv: iv)
        
        XCTAssert(plain?.split(separator: 0)[0] == p)
    }
    
    func testZeroPadding() {
        guard let key = "abcdefabcdefabcd".data(using: .utf8) else {
            XCTAssertTrue(false, "Unable to create a valid key.")
            return
        }
        let iv = "abcdefabcdefabcd".data(using: .utf8)
        
        guard let dataToEncrypt = "abcdefabcdef".data(using: .utf8) else {
            XCTAssertTrue(false, "Unable to initialize the input data.")
            return
        }
        
        let rjn = Rijndael.init(key: key, mode: .cbc, padding: .zero)
        if let data = rjn?.encrypt(data: dataToEncrypt, blockSize: 16, iv: iv) {
            let result = "eb1b992985b21adfbb19d5197c1c3442" //.zero
            XCTAssertEqual(result, data.hexadecimal(), "The expected value desn't match.")
        } else {
            XCTAssertTrue(false, "Unable to encrypt the data.")
        }
    }
    
    func testPKCS7Padding() {
        guard let key = "abcdefabcdefabcd".data(using: .utf8) else {
            XCTAssertTrue(false, "Unable to create a valid key.")
            return
        }
        let iv = "abcdefabcdefabcd".data(using: .utf8)
        
        guard let dataToEncrypt = "abcdefabcdef".data(using: .utf8) else {
            XCTAssertTrue(false, "Unable to initialize the input data.")
            return
        }
        
        let rjn = Rijndael.init(key: key, mode: .cbc, padding: .pkcs7)
        if let data = rjn?.encrypt(data: dataToEncrypt, blockSize: 16, iv: iv) {
            let result = "2f4371f9f7e35c3c7065788adb17417a" //.pkcs7, .
            XCTAssertEqual(result, data.hexadecimal(), "The expected value desn't match.")
        } else {
            XCTAssertTrue(false, "Unable to encrypt the data.")
        }
    }
    
    func testANSIX923Padding() {
        guard let key = "abcdefabcdefabcd".data(using: .utf8) else {
            XCTAssertTrue(false, "Unable to create a valid key.")
            return
        }
        let iv = "abcdefabcdefabcd".data(using: .utf8)
        
        guard let dataToEncrypt = "abcdefabcdef".data(using: .utf8) else {
            XCTAssertTrue(false, "Unable to initialize the input data.")
            return
        }
        
        let rjn = Rijndael.init(key: key, mode: .cbc, padding: .ansix923)
        if let data = rjn?.encrypt(data: dataToEncrypt, blockSize: 16, iv: iv) {
            let result = "594b4796c24d898c4aa0eb516b740d82" //.ansix923
            XCTAssertEqual(result, data.hexadecimal(), "The expected value desn't match.")
        } else {
            XCTAssertTrue(false, "Unable to encrypt the data.")
        }
    }
    
    func testZeroPaddingDecode() {
        guard let key = "abcdefabcdefabcd".data(using: .utf8) else {
            XCTAssertTrue(false, "Unable to create a valid key.")
            return
        }
        let iv = "abcdefabcdefabcd".data(using: .utf8)
        
        guard let dataToDecrypt = "eb1b992985b21adfbb19d5197c1c3442".hexadecimal() else {
            XCTAssertTrue(false, "Unable to initialize the input data.")
            return
        }
        
        let rjn = Rijndael.init(key: key, mode: .cbc, padding: .zero)
        if let data = rjn?.decrypt(data: dataToDecrypt, blockSize: 16, iv: iv) {
            let result = "abcdefabcdef" //.zero
            XCTAssertEqual(result, String(data: data, encoding: .utf8), "The expected value desn't match.")
        } else {
            XCTAssertTrue(false, "Unable to encrypt the data.")
        }
    }
    
    func testPKCS7PaddingDecode() {
        guard let key = "abcdefabcdefabcd".data(using: .utf8) else {
            XCTAssertTrue(false, "Unable to create a valid key.")
            return
        }
        let iv = "abcdefabcdefabcd".data(using: .utf8)
        
        guard let dataToDecrypt = "2f4371f9f7e35c3c7065788adb17417a".hexadecimal() else {
            XCTAssertTrue(false, "Unable to initialize the input data.")
            return
        }
        
        let rjn = Rijndael.init(key: key, mode: .cbc, padding: .pkcs7)
        if let data = rjn?.decrypt(data: dataToDecrypt, blockSize: 16, iv: iv) {
            let result = "abcdefabcdef" //.zero
            XCTAssertEqual(result, String(data: data, encoding: .utf8), "The expected value desn't match.")
        } else {
            XCTAssertTrue(false, "Unable to encrypt the data.")
        }
    }
    
    func testANSIX923PaddingDecode() {
        guard let key = "abcdefabcdefabcd".data(using: .utf8) else {
            XCTAssertTrue(false, "Unable to create a valid key.")
            return
        }
        let iv = "abcdefabcdefabcd".data(using: .utf8)
        
        guard let dataToDecrypt = "594b4796c24d898c4aa0eb516b740d82".hexadecimal() else {
            XCTAssertTrue(false, "Unable to initialize the input data.")
            return
        }
        
        let rjn = Rijndael.init(key: key, mode: .cbc, padding: .pkcs7)
        if let data = rjn?.decrypt(data: dataToDecrypt, blockSize: 16, iv: iv) {
            let result = "abcdefabcdef" //.zero
            XCTAssertEqual(result, String(data: data, encoding: .utf8), "The expected value desn't match.")
        } else {
            XCTAssertTrue(false, "Unable to encrypt the data.")
        }
    }
    
}
