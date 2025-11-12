//
//  LoginButtonView.swift
//  KakaoOpenSDK
//
//  Created by kakao on 10/16/25.
//  Copyright © 2025 apiteam. All rights reserved.
//

import UIKit

final class LoginButton: UIButton {
    private let title: String
    private let imgName: String
    private let style: Style
    
    let leadingImgView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 19).isActive = true
        view.widthAnchor.constraint(equalToConstant: 19).isActive = true
        
        return view
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 15, weight: .medium))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        
        return label
    }()
    
    let contentView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 4
        view.alignment = .center
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override var isHighlighted: Bool {
        didSet {
            updateButtonStyle()
        }
    }
    
    init(imgName: String, title: String, style: LoginButton.Style) {
        self.imgName = imgName
        self.title = title
        self.style = style
        
        super.init(frame: .infinite)
        
        initViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        leadingImgView.image = ResourceHelper.image(name: imgName, renderingMode: .alwaysOriginal)
        
        label.text = title
        label.textColor = style.titleColor
        backgroundColor = style.backgroundColor
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        addSubview(contentView)
        contentView.addArrangedSubview(leadingImgView)
        contentView.addArrangedSubview(label)
    }
    
    func layoutViews() {
        contentView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        contentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20).isActive = true
        contentView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20).isActive = true
        contentView.topAnchor.constraint(lessThanOrEqualTo: topAnchor, constant: 15.5).isActive = true
        contentView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -15.5).isActive = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        leadingImgView.image = ResourceHelper.image(name: imgName, renderingMode: .alwaysOriginal)
    }
    
    private func updateButtonStyle() {
        if isHighlighted && backgroundColor == style.backgroundColor {
            backgroundColor = style.highlightedColor
            return
        }
        
        if !isHighlighted {
            backgroundColor = style.backgroundColor
        }
    }
}
