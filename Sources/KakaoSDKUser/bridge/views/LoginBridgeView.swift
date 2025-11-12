//
//  LoginBridgeView.swift
//  KakaoOpenSDK
//
//  Created by kakao on 10/16/25.
//  Copyright © 2025 apiteam. All rights reserved.
//

import UIKit

final class LoginBridgeView: UIView {
    let handlerView: HandlerView = HandlerView()
    let brandImageView: UIImageView = UIImageView()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 16, weight: .semibold))
        label.textColor = ResourceHelper.color(name: "gray900s")
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    let talkLoginButton: LoginButton
    let accountLoginButton: LoginButton
    let buttonMinHeight: CGFloat = 46.0
    
    var horizontalPadding: CGFloat { calculateHorizontalPadding() }
    var talkLoginButtonLeadingConstraint: NSLayoutConstraint?
    var talkLoginButtonTrailingConstraint: NSLayoutConstraint?
    var accountLoginButtonLeadingConstraint: NSLayoutConstraint?
    var accountLoginButtonTrailingConstraint: NSLayoutConstraint?
    var orientation: LoginOrientation?
    
    // action
    private var talkLoginAction: (() -> Void)?
    private var accountLoginAction: (() -> Void)?
    
    init(orientation: LoginOrientation? = nil) {
        self.orientation = orientation
        
        talkLoginButton = LoginButton(imgName: "chat", title: ResourceHelper.localizedString(key: "talk_login") ?? "", style: .yellow)
        accountLoginButton = LoginButton(imgName: "friends", title: ResourceHelper.localizedString(key: "account_login") ?? "", style: .gray)
        
        super.init(frame: .zero)
        backgroundColor = ResourceHelper.color(name: "white001s")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViews() {
        addSubview(handlerView)
        addSubview(titleLabel)
        addSubview(talkLoginButton)
        addSubview(accountLoginButton)
        addSubview(brandImageView)
    }
    
    func layout() {
        layoutHandlerView()
        layoutTitleLabel()
        layoutTalkLoginButton()
        layoutAccountLoginButton()
        layoutBrandImageView()
        
        talkLoginButton.addTarget(self, action: #selector(handleTalkLoginAction), for: .touchUpInside)
        accountLoginButton.addTarget(self, action: #selector(handlAccountLoginAction), for: .touchUpInside)
    }
    
    @objc func handleTalkLoginAction() {
        talkLoginAction?()
    }
    
    @objc func handlAccountLoginAction() {
        accountLoginAction?()
    }
    
    func setLoginAction(_ talkLoginAction: @escaping () -> Void, accountLoginAction: @escaping () -> Void) {
        self.talkLoginAction = talkLoginAction
        self.accountLoginAction = accountLoginAction
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updateImage()
        updateTalkLoginButtonConstraints()
        updateAccountLoginButtonConstraints()
    }
}

extension LoginBridgeView {
    private func layoutHandlerView() {
        handlerView.translatesAutoresizingMaskIntoConstraints = false
        
        handlerView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        handlerView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        
        handlerView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        handlerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    private func layoutTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20).isActive = true
        titleLabel.topAnchor.constraint(equalTo: handlerView.bottomAnchor, constant: 24.5).isActive = true
        
        titleLabel.text = ResourceHelper.localizedString(key: "bridge_title") ?? ""
    }
    
    private func layoutTalkLoginButton() {
        talkLoginButton.translatesAutoresizingMaskIntoConstraints = false
        
        talkLoginButtonLeadingConstraint = talkLoginButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding)
        talkLoginButtonLeadingConstraint?.isActive = true
        talkLoginButtonTrailingConstraint = talkLoginButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding)
        talkLoginButtonTrailingConstraint?.isActive = true
        
        talkLoginButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 26.5).isActive = true
        talkLoginButton.heightAnchor.constraint(greaterThanOrEqualToConstant: buttonMinHeight).isActive = true
        
    }
    
    private func updateTalkLoginButtonConstraints() {
        talkLoginButtonLeadingConstraint?.isActive = false
        talkLoginButtonLeadingConstraint?.constant = horizontalPadding
        talkLoginButtonLeadingConstraint?.isActive = true
        
        talkLoginButtonTrailingConstraint?.isActive = false
        talkLoginButtonTrailingConstraint?.constant = -horizontalPadding
        talkLoginButtonTrailingConstraint?.isActive = true
    }
    
    private func layoutAccountLoginButton() {
        accountLoginButton.translatesAutoresizingMaskIntoConstraints = false
        
        accountLoginButtonLeadingConstraint = accountLoginButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding)
        accountLoginButtonLeadingConstraint?.isActive = true
        accountLoginButtonTrailingConstraint = accountLoginButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding)
        accountLoginButtonTrailingConstraint?.isActive = true
        accountLoginButton.topAnchor.constraint(equalTo: talkLoginButton.bottomAnchor, constant: 12).isActive = true
        accountLoginButton.heightAnchor.constraint(greaterThanOrEqualToConstant: buttonMinHeight).isActive = true
    }
    
    private func updateAccountLoginButtonConstraints() {
        accountLoginButtonLeadingConstraint?.isActive = false
        accountLoginButtonLeadingConstraint?.constant = horizontalPadding
        accountLoginButtonLeadingConstraint?.isActive = true
        
        accountLoginButtonTrailingConstraint?.isActive = false
        accountLoginButtonTrailingConstraint?.constant = -horizontalPadding
        accountLoginButtonTrailingConstraint?.isActive = true
    }
    
    private func layoutBrandImageView() {
        updateImage()
        
        brandImageView.translatesAutoresizingMaskIntoConstraints = false
        brandImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        brandImageView.topAnchor.constraint(equalTo: accountLoginButton.bottomAnchor, constant: 24).isActive = true
        brandImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16).isActive = true
    }
    
    private func updateImage() {
        brandImageView.image = ResourceHelper.image(name: "logo", renderingMode: .alwaysOriginal)
    }
    
    private func calculateHorizontalPadding() -> CGFloat {
        switch orientation {
        case .landscape:
            return 73.0
        case .portrait:
            return 25.0
        default:
            if UIDevice.current.orientation.isLandscape {
                return 73.0
            }
            
            return 25.0
        }
    }
}
