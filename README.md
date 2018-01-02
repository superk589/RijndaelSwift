# RijndaelSwift

This is an implementation of Rijndael algorithm.

Supports 128/192/256 bit key/block, and ECB, CBC modes.

## Requirements
* Xcode 9.0+
* Swift 4.0+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```
To integrate RijndaelSwift into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!
target 'YourApp' do
    pod 'RijndaelSwift'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate RijndaelSwift into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "superk589/RijndaelSwift"
```

Run `carthage update` to build the framework and drag the built `RijndaelSwift.framework` into your Xcode project.

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate RijndaelSwift into your project manually.

## Usage

### Encrypt

```Swift
let key: Data = yourKey
let iv: Data = yourIV // for ecb, use empty data "Data()" instead
let r = Rijndael(key: key, mode: .cbc)!
let plainData: Data = yourPlainData
let cipherData = r.encrypt(data: plainData, blockSize: 32, iv: iv)
```
      
### Decrypt

```Swift
let key = yourKey
let iv = yourIV // for ecb, use empty data "Data()" instead
let r = Rijndael(key: key, mode: .cbc)!
let cipherData = yourPlainData
let plainData = r.decrypt(data: cipherData, blockSize: 32, iv: iv)
```

### Utility for String and Data conversion

```Swift
let data = "00000".hexadecimal()!
let string = data.hexadecimal()
```