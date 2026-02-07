//
//  Untitled.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/6/26.
//

import UIKit

final class CreateWalletViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Wallet"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create a new wallet to store your USDC."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private let createWalletButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Wallet", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Create Wallet"
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.text = "Create a Wallet"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        
        subtitleLabel.text = "Create a new wallet to store your USDC."
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        
        createWalletButton.setTitle("Create Wallet", for: .normal)
        createWalletButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        createWalletButton.configuration = .filled()
        createWalletButton.addTarget(self, action: #selector(createWalletButtonTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, createWalletButton])
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 24
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
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
            UINavigationController(rootViewController: CreateWalletViewController() )
        }
        .edgesIgnoringSafeArea(.all)
        .previewDevice("iPhone 17 Pro")
    }
}
#endif
