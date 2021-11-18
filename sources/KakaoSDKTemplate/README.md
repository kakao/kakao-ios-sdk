# KakaoSDKTemplate

메시지 기본 템플릿을 생성하기 위한 모듈입니다. 카카오링크 또는 메시지 API로 전송되는 템플릿을 개발자사이트 템플릿 도구를 사용하지 않고 소스코드 상에서 작성하고 싶을 때 사용할 수 있습니다.

## Requirements
- Xcode 11.0
- iOS 11.0
- Swift 4.2
- CocoaPods 1.8.0

## Installation
```
pod 'RxKakaoSDKTemplate'
```

## Usage
[Templatable](Protocols/Templatable.html) 프로토콜 기반의 메시지 템플릿을 생성하실 수 있습니다.
```
import RxKakaoSDKTemplate

...

let template = FeedTemplate()
```

