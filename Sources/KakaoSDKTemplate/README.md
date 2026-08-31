# KakaoSDKTemplate

카카오톡 공유 및 카카오톡 메시지에 사용하는 기본 템플릿 모듈입니다. [카카오디벨로퍼스 메시지 템플릿 도구](https://developers.kakao.com/tool/template-builder/app)를 사용하지 않고 소스코드 상에서 메시지 템플릿을 작성하고 싶을 때 사용할 수 있습니다.

## Requirements
- iOS 15.0
- Swift 5.8

## Installation
```swift
.package(url: "https://github.com/kakao/kakao-ios-sdk.git", from: "2.0.0")
```
2.x.x 버전을 사용합니다. 타겟의 Dependencies에 `KakaoSDKTemplate`을 추가합니다.

## Usage
[Templatable](Protocols/Templatable.html) 프로토콜 기반의 메시지 템플릿을 생성하실 수 있습니다.
```
import KakaoSDKTemplate
...

let template = FeedTemplate()
```

