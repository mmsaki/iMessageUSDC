//
//  OldWalletView.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/7/26.
//

import UIKit
import SwiftUI

final class OldWalletViewController: UIViewController {
    // MARK: - Top controls
    private let tokenButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.cornerStyle = .capsule
        config.image = UIImage(named: "usdc-3D-token")?
            .withRenderingMode(.alwaysOriginal)
        config.imagePlacement = .leading
        config.imagePadding = 8
        
        let button = UIButton(configuration: config)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        return button
    }()
    
    private let createWalletButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "wallet.pass"), for: .normal)
        button.configuration = .bordered()
        return button
    }()
    
    // MARK: - Amount Input
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "0"
        textField.keyboardType = .decimalPad
        textField.font = .systemFont(ofSize: 56, weight: .bold)
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 40
        return textField
    }()
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = "USDC"
        label.font = .systemFont(ofSize: 56, weight: .bold)
        return label
    }()
    
    // MARK: - Action buttons
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.tintColor = .black
        return button
    }()
    private let requestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Request", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        button.configuration = .tinted()
        button.configuration?.cornerStyle = .capsule
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(createWalletButton)
        createWalletButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        createWalletButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        createWalletButton.addTarget(self, action: #selector(createWalletButtonTapped), for: .touchUpInside)
        setupUI()
    }
    
    private func setupUI() {
        tokenButton.imageView?.contentMode = .scaleAspectFit
        tokenButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        let topBar = UIStackView(arrangedSubviews: [tokenButton, UIView(), createWalletButton])
        topBar.axis = .horizontal
        topBar.spacing = 16
        
        let amountStack = UIStackView(arrangedSubviews: [currencyLabel, amountTextField])
        amountStack.axis = .horizontal
        amountStack.alignment = .center
        amountStack.spacing = 6
        
        let buttonStack = UIStackView(arrangedSubviews: [requestButton, sendButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually
        
        
        let root = UIStackView(arrangedSubviews: [topBar,UIView(),amountStack,UIView(),buttonStack])
        
        root.axis = .vertical
        root.spacing = 16
        root.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(root)
        
        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            root.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            root.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            
            sendButton.heightAnchor.constraint(equalToConstant: 56),
            requestButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    @objc
    private func createWalletButtonTapped() {
        let vc = PrivyAuthViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}


#if DEBUG
import SwiftUI
struct CreateWalletViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIKitPreview {
            UINavigationController(rootViewController: OldWalletViewController() )
        }
        .edgesIgnoringSafeArea(.all)
        .previewDevice("iPhone 17 Pro")
    }
}
#endif

