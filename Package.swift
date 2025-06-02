// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

// sdk-version:2.24.3
import PackageDescription

let package = Package(
    name: "KakaoOpenSDK",
    defaultLocalization: "ko",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "KakaoSDK",
            targets: ["KakaoSDKCommon", "KakaoSDKAuth", "KakaoSDKUser", "KakaoSDKCert", "KakaoSDKCertCore", "KakaoSDKTalk", "KakaoSDKFriend", "KakaoSDKFriendCore", "KakaoSDKShare", "KakaoSDKNavi", "KakaoSDKTemplate"]),
        .library(
            name: "KakaoSDKCommon",
            targets: ["KakaoSDKCommon"]),        
        .library(
            name: "KakaoSDKAuth",
            targets: ["KakaoSDKAuth"]),
        .library(
            name: "KakaoSDKUser",
            targets: ["KakaoSDKUser"]),
        .library(
            name: "KakaoSDKCert",
            targets: ["KakaoSDKCert"]),
        .library(
            name: "KakaoSDKCertCore",
            targets: ["KakaoSDKCertCore"]),
        .library(
            name: "KakaoSDKTalk",
            targets: ["KakaoSDKTalk"]),
        .library(
            name: "KakaoSDKFriend",
            targets: ["KakaoSDKFriend"]),
        .library(
            name: "KakaoSDKFriendCore",
            targets: ["KakaoSDKFriendCore"]),
        .library(
            name: "KakaoSDKShare",
            targets: ["KakaoSDKShare"]),
        .library(
            name: "KakaoSDKNavi",
            targets: ["KakaoSDKNavi"]),
        .library(
            name: "KakaoSDKTemplate",
            targets: ["KakaoSDKTemplate"])
    ],
    dependencies: [
        .package(name: "Alamofire",
                  url: "https://github.com/Alamofire/Alamofire.git",
                  Version(5,9,0)..<Version(6,0,0))
    ],
    targets: [
        .target(
            name: "KakaoSDKCommon",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
            ],
            exclude: ["Info.plist", "README.md"],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        ),
        .target(
            name: "KakaoSDKAuth",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .target(name: "KakaoSDKCommon")
            ],
            exclude: ["Info.plist", "README.md"]
        ),
        .target(
            name: "KakaoSDKUser",
            dependencies: [
                .target(name: "KakaoSDKAuth")
            ],
            exclude: ["Info.plist", "README.md"]
        ),
        .target(
            name: "KakaoSDKCert",
            dependencies: [
                .target(name: "KakaoSDKUser"),
                .target(name: "KakaoSDKCertCore")
            ],
            exclude: ["Info.plist", "README.md"]
        ),
        .binaryTarget(
            name: "KakaoSDKCertCore",
            path: "Sources/KakaoSDKCertCore/KakaoSDKCertCore.xcframework"
        ),
        .target(
            name: "KakaoSDKTalk",
            dependencies: [
                .target(name: "KakaoSDKUser"),
                .target(name: "KakaoSDKTemplate")
            ],
            exclude: ["Info.plist", "README.md"]
        ),
        .target(
            name: "KakaoSDKFriend",
            dependencies: [
                .target(name: "KakaoSDKUser"),
                .target(name: "KakaoSDKFriendCore")
            ],
            exclude: ["Info.plist", "README.md"]
        ),
        .binaryTarget(
            name: "KakaoSDKFriendCore",
            path: "Sources/KakaoSDKFriendCore/KakaoSDKFriendCore.xcframework"
        ),
        .target(
            name: "KakaoSDKShare",
            dependencies: [
                .target(name: "KakaoSDKCommon"),
                .target(name: "KakaoSDKTemplate")
            ],
            exclude: ["Info.plist", "README.md"]
        ),
        .target(
            name: "KakaoSDKNavi",
            dependencies: [
                .target(name: "KakaoSDKCommon")
            ],
            exclude: ["Info.plist", "README.md"]
        ),
        .target(
            name: "KakaoSDKTemplate",
            dependencies: [
                .target(name: "KakaoSDKCommon")
            ],
            exclude: ["Info.plist", "README.md"]
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
