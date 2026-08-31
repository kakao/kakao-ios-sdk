# KakaoSDKNavi

카카오내비 모듈입니다. 카카오내비 앱을 실행하여 장소를 공유하거나 길안내를 받을 수 있습니다.

## Requirements
- iOS 15.0
- Swift 5.8

## Dependencies
- KakaoSDKCommon

## Installation
```swift
.package(url: "https://github.com/kakao/kakao-ios-sdk.git", from: "2.0.0")
```
2.x.x 버전을 사용합니다. 타겟의 Dependencies에 `KakaoSDKNavi`을 추가합니다.

## Import
```
import KakaoSDKNavi
```

## Usage
[NaviApi](Classes/NaviApi.html) 클래스를 이용하여 각종 카카오내비 API를 호출할 수 있습니다.
```
let url = NaviApi.shared.navigateUrl(...)
UIApplication.shared.open(url)
```
