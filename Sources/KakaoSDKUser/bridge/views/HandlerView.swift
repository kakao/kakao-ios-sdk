//
//  HandlerView.swift
//  KakaoOpenSDK
//
//  Created by kakao on 10/16/25.
//  Copyright © 2025 apiteam. All rights reserved.
//

import UIKit

final class HandlerView: UIView {
    init() {
        super.init(frame: .zero)
        
        layer.backgroundColor = ResourceHelper.color(name: "gray500s")?.cgColor
        layer.cornerRadius = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }        
}
