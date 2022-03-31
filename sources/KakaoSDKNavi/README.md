# KakaoSDKNavi

카카오내비 모듈입니다. 카카오내비 앱을 실행하여 장소를 공유하거나 길안내를 받을 수 있습니다.

## Requirements
- Xcode 11.0
- iOS 11.0
- Swift 5.0
- CocoaPods 1.8.0

## Dependencies
- KakaoSDKCommon

## Installation
```
pod 'KakaoSDKNavi'
```

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
