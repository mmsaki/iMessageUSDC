//
//  SelectDestinationViewController.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/7/26.
//

import UIKit

protocol SelectDestinationViewControllerDelegate: AnyObject {
    func selectDestinationViewController(_ controller: SelectDestinationViewController, didUpdateTransaction transaction: Transaction)
}

class SelectDestinationViewController: UIViewController {
    
    static let storyboardIdentifier = "SelectDestinationViewController"
    
    var transaction: Transaction?
    weak var delegate: SelectDestinationViewControllerDelegate?
    
    private let walletManager = WalletManager.shared
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Destination"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let toChainButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Destination Chain", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addressTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Tap to enter ENS name / address"
        field.font = .systemFont(ofSize: 17)
        field.borderStyle = .none
        field.backgroundColor = .systemGray6
        field.layer.cornerRadius = 12
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        
        // Add padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftView = paddingView
        field.leftViewMode = .always
        field.rightView = paddingView
        field.rightViewMode = .always
        
        return field
    }()
    
    private let addressHintLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter Ethereum address (0x...) or ENS name (vitalik.eth)"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.backgroundColor = .systemGray5
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let reviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Review Transaction", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        updateUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        contentStack.addArrangedSubview(toChainButton)
        contentStack.addArrangedSubview(addressTextField)
        contentStack.addArrangedSubview(addressHintLabel)
        
        let buttonStack = UIStackView(arrangedSubviews: [backButton, reviewButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        contentStack.addArrangedSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            
            toChainButton.heightAnchor.constraint(equalToConstant: 56),
            addressTextField.heightAnchor.constraint(equalToConstant: 56),
            backButton.heightAnchor.constraint(equalToConstant: 56),
            reviewButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupActions() {
        toChainButton.addTarget(self, action: #selector(selectToChain), for: .touchUpInside)
        addressTextField.addTarget(self, action: #selector(addressChanged), for: .editingChanged)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        reviewButton.addTarget(self, action: #selector(reviewTransaction), for: .touchUpInside)
    }
    
    private func updateUI() {
        guard let tx = transaction else { return }
        
        // Update button titles
        if let toChain = tx.toChain {
            toChainButton.setTitle(toChain.rawValue, for: .normal)
        }
        
        if let address = tx.toAddress {
            addressTextField.text = address.rawValue
        }
        
        // Enable review button if step 2 is complete
        let step2Complete = tx.toChain != nil && tx.toAddress != nil
        reviewButton.isEnabled = step2Complete
        reviewButton.alpha = step2Complete ? 1.0 : 0.5
    }
    
    // MARK: - Actions
    
    @objc private func selectToChain() {
        let alert = UIAlertController(title: "Select Destination Chain", message: nil, preferredStyle: .actionSheet)
        
        for network in walletManager.supportedNetworks() {
            alert.addAction(UIAlertAction(title: network.name, style: .default) { [weak self] _ in
                self?.didSelectToChain(network)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func didSelectToChain(_ network: NetworkConfig) {
        var tx = transaction ?? Transaction()
        tx.toChain = Chain(networkConfig: network)
        transaction = tx
        updateUI()
    }
    
    @objc private func addressChanged() {
        guard let text = addressTextField.text, !text.isEmpty else {
            var tx = transaction ?? Transaction()
            tx.toAddress = nil
            transaction = tx
            updateUI()
            return
        }
        
        // Basic validation: starts with 0x or ends with .eth
        let isValidFormat = text.hasPrefix("0x") || text.hasSuffix(".eth")
        
        if isValidFormat {
            var tx = transaction ?? Transaction()
            tx.toAddress = Address(rawValue: text)
            transaction = tx
        }
        
        updateUI()
    }
    
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func reviewTransaction() {
        guard let tx = transaction, tx.toChain != nil, tx.toAddress != nil else { return }
        
        // Notify delegate to proceed to confirmation
        delegate?.selectDestinationViewController(self, didUpdateTransaction: tx)
    }
}
