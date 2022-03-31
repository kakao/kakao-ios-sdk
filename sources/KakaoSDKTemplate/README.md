# KakaoSDKTemplate

카카오링크 및 카카오톡 메시지에 사용하는 기본 템플릿 모듈입니다. [카카오디벨로퍼스 메시지 템플릿 도구](https://developers.kakao.com/tool/template-builder/app)를 사용하지 않고 소스코드 상에서 메시지 템플릿을 작성하고 싶을 때 사용할 수 있습니다.

## Requirements
- Xcode 11.0
- iOS 11.0
- Swift 5.0
- CocoaPods 1.8.0

## Installation
```
pod 'KakaoSDKTemplate'
```

## Usage
[Templatable](Protocols/Templatable.html) 프로토콜 기반의 메시지 템플릿을 생성하실 수 있습니다.
```
import KakaoSDKTemplate
...

let template = FeedTemplate()
```

