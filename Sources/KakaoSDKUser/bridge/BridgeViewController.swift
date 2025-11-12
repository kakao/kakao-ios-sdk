//
//  BridgeViewController.swift
//  KakaoOpenSDK
//
//  Created by kakao on 10/16/25.
//  Copyright © 2025 apiteam. All rights reserved.
//

import Foundation
import UIKit

import KakaoSDKCommon
import KakaoSDKAuth

final class BridgeViewController: UIViewController {
    private let LANDSCAPE_MIN_HEIGHT: CGFloat = 253
    private let PORTRAIT_MIN_HEIGHT: CGFloat = 266
    
    let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ResourceHelper.color(name: "background")
        return view
    }()
    let loginBridgeView: LoginBridgeView
    var backgroundHeight: CGFloat { calculateBackgroundHeight() }
    var loginBridgeViewHeightConstraint: NSLayoutConstraint?
    
    let properties: BridgeConfiguration
    var loginProperties: LoginConfiguration?
    var loginCompletion: ((OAuthToken?, Error?) -> Void) = { _, _ in }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch properties.orientation {
        case .portrait:
            return [ .portrait, .portraitUpsideDown ]
        case .landscape:
            return [ .landscape, .landscapeLeft, .landscapeRight ]
        case .auto:
            return .all
        }
    }
        
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(_ properties: BridgeConfiguration) {
        self.properties = properties
        loginBridgeView = LoginBridgeView(orientation: properties.orientation)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func loadView() {
        super.loadView()

        if properties.uiMode == .dark {
            overrideUserInterfaceStyle = .dark
        } else if properties.uiMode == .light {
            overrideUserInterfaceStyle = .light
        }
        
        view.addSubview(backgroundView)
        view.addSubview(loginBridgeView)
        loginBridgeView.addViews()
        addBackgroundViewAction()
        addButtonActions()
        addPanGesture()
    }
    
    public override func updateViewConstraints() {
        super.updateViewConstraints()
        
        layoutBackgroundView()
        layoutLoginBridge()
        loginBridgeView.layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loginBridgeView.transform = CGAffineTransform(translationX: 0, y: backgroundHeight)
        loginBridgeView.layoutIfNeeded()
        
        changeSheetTransform(to: .init(translationX: 0, y: 0))
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updateLoginBridge()
    }
    
    private func addBackgroundViewAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeBridge))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    private func addButtonActions() {
        loginBridgeView.setLoginAction { [weak self, loginCompletion] in
            guard let self = self  else { return }
            AuthController.shared._authorizeWithTalk(launchMethod: loginProperties?.talk.launchMethod,
                                                     channelPublicIds: loginProperties?.channelPublicIds,
                                                     serviceTerms: loginProperties?.channelPublicIds,
                                                     nonce: loginProperties?.nonce,
                                                     completion: loginCompletion)
            self.dismiss(animated: true)
        } accountLoginAction: { [weak self, loginCompletion] in
            guard let self = self  else { return }
            AuthController.shared._authorizeWithAuthenticationSession(prompts: loginProperties?.account.prompts,
                                                                      channelPublicIds: loginProperties?.channelPublicIds,
                                                                      serviceTerms: loginProperties?.serviceTerms,
                                                                      loginHint: loginProperties?.account.loginHint,
                                                                      completion: loginCompletion)
            self.dismiss(animated: true)
        }
    }
    
    @objc func closeBridge() {
        changeSheetTransform(to: .init(translationX: 0, y: loginBridgeView.frame.height))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [unowned self] in
            loginCompletion(nil, SdkError(reason: .Cancelled))
            dismiss(animated: true, completion: nil)
        })
    }
}

// MARK: - Layout views
extension BridgeViewController {
    private func layoutLoginBridge() {
        loginBridgeView.layer.cornerRadius = 12
        loginBridgeView.layer.maskedCorners = [ .layerMaxXMinYCorner, .layerMinXMinYCorner ]
        loginBridgeView.translatesAutoresizingMaskIntoConstraints = false
        
        loginBridgeView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        loginBridgeView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loginBridgeView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        loginBridgeViewHeightConstraint = loginBridgeView.heightAnchor.constraint(greaterThanOrEqualToConstant: LANDSCAPE_MIN_HEIGHT)
        loginBridgeViewHeightConstraint?.constant = backgroundHeight
        loginBridgeViewHeightConstraint?.isActive = true
    }
    
    private func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlPanGesture(_:)))
        loginBridgeView.addGestureRecognizer(panGesture)
    }
    
    private func updateLoginBridge() {
        loginBridgeViewHeightConstraint?.isActive = false
        loginBridgeViewHeightConstraint?.constant = backgroundHeight
        loginBridgeViewHeightConstraint?.isActive = true
    }
    
    private func layoutBackgroundView() {
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    @objc private func handlPanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: loginBridgeView)
        
        let newTranslationY = max(translation.y, 0)
        
        switch gesture.state {
        case .changed:
            loginBridgeView.transform = CGAffineTransform(translationX: 0, y: newTranslationY)
            
        case .ended:
            let velocity = gesture.velocity(in: loginBridgeView)
            
            if velocity.y > 500 || (newTranslationY > loginBridgeView.frame.height / 2) {
                changeSheetTransform(to: .init(translationX: 0, y: translation.y + loginBridgeView.frame.height))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [unowned self] in
                    closeBridge()                    
                }
                return
            }
            
            changeSheetTransform(to: .identity)
            
        default:
            break
        }
    }
    
    private func changeSheetTransform(to transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.loginBridgeView.transform = transform
            self?.loginBridgeView.layoutIfNeeded()
        }
    }
    
    private func calculateBackgroundHeight() -> CGFloat {
        switch properties.orientation {
        case .portrait:
            return  PORTRAIT_MIN_HEIGHT
        case .landscape:
            return LANDSCAPE_MIN_HEIGHT
        case .auto:
            if UIDevice.current.orientation.isLandscape {
                return LANDSCAPE_MIN_HEIGHT
            }
            
            return PORTRAIT_MIN_HEIGHT
        }
    }
}

// MARK: - settings
extension BridgeViewController {
    func setLoginCompletion(_ completion: @escaping (OAuthToken?, Error?) -> Void) {
        self.loginCompletion = completion
    }
    
    func setLoginConfiguration(_ properties: LoginConfiguration) {
        loginProperties = properties
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview(traits: .portrait, body: {
    KakaoSDK.initSDK(appKey: "test-app-key")
    return BridgeViewController(.init())
})

@available(iOS 17.0, *)
#Preview(traits: .landscapeLeft, body: {
    KakaoSDK.initSDK(appKey: "test-app-key")
    return BridgeViewController(.init())
})
#endif
