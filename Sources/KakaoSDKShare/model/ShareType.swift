//
//  ShareList.swift
//  KakaoOpenSDK
//
//  Created by kakao on 10/13/25.
//

import Foundation

/// 카카오톡 공유 대상 선택 화면 유형 \
/// Type of share target selection screen in Kakao Talk.
public enum ShareType: String {
    /// 친구 목록과 채팅방 목록 모두 노출(기본값) \
    /// Shows both friends list and chat rooms list (default)
    case `default` = "default"
    /// 채팅방 목록만 노출 \
    /// Shows chat rooms list only
    case chat = "chat"
    /// 친구 목록만 노출 \
    /// Shows friends list only
    case friend = "friend"
}
