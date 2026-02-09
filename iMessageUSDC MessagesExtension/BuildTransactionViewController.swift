//
//  BuildTransactionViewController.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/7/26.
//

import UIKit

protocol BuildTransactionViewControllerDelegate: AnyObject {
    func buildTransactionViewController(_ controller: BuildTransactionViewController, didUpdateTransaction transaction: Transaction)
}

class BuildTransactionViewController: UIViewController {
    
    static let storyboardIdentifier = "BuildTransactionViewController"
    
    var transaction: Transaction?
    weak var delegate: BuildTransactionViewControllerDelegate?
    
    private let walletManager = WalletManager.shared
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Send USDC"
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
    
    // Step 1: Source Chain, Token, Amount
    private let fromChainButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Source Chain", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tokenButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Token", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    private let amountTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Amount"
        field.font = .systemFont(ofSize: 17)
        field.borderStyle = .none
        field.backgroundColor = .systemGray6
        field.layer.cornerRadius = 12
        field.keyboardType = .decimalPad
        field.translatesAutoresizingMaskIntoConstraints = false
        
        // Add padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftView = paddingView
        field.leftViewMode = .always
        field.rightView = paddingView
        field.rightViewMode = .always
        
        return field
    }()
    
    private let maxButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("MAX", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
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
        
        // Amount field container with MAX button
        let amountContainer = UIView()
        amountContainer.translatesAutoresizingMaskIntoConstraints = false
        amountContainer.addSubview(amountTextField)
        amountContainer.addSubview(maxButton)
        
        contentStack.addArrangedSubview(fromChainButton)
        contentStack.addArrangedSubview(tokenButton)
        contentStack.addArrangedSubview(amountContainer)
        contentStack.addArrangedSubview(balanceLabel)
        contentStack.addArrangedSubview(nextButton)
        
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
            
            fromChainButton.heightAnchor.constraint(equalToConstant: 56),
            tokenButton.heightAnchor.constraint(equalToConstant: 56),
            
            amountContainer.heightAnchor.constraint(equalToConstant: 56),
            amountTextField.leadingAnchor.constraint(equalTo: amountContainer.leadingAnchor),
            amountTextField.trailingAnchor.constraint(equalTo: maxButton.leadingAnchor, constant: -8),
            amountTextField.topAnchor.constraint(equalTo: amountContainer.topAnchor),
            amountTextField.bottomAnchor.constraint(equalTo: amountContainer.bottomAnchor),
            
            maxButton.trailingAnchor.constraint(equalTo: amountContainer.trailingAnchor, constant: -12),
            maxButton.centerYAnchor.constraint(equalTo: amountContainer.centerYAnchor),
            maxButton.widthAnchor.constraint(equalToConstant: 50),
            
            nextButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupActions() {
        fromChainButton.addTarget(self, action: #selector(selectFromChain), for: .touchUpInside)
        tokenButton.addTarget(self, action: #selector(selectToken), for: .touchUpInside)
        maxButton.addTarget(self, action: #selector(setMaxAmount), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(proceedToNext), for: .touchUpInside)
        
        amountTextField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
    }
    
    private func updateUI() {
        guard let tx = transaction else { return }
        
        // Update button titles
        if let fromChain = tx.fromChain {
            fromChainButton.setTitle(fromChain.rawValue, for: .normal)
            tokenButton.isEnabled = true
        }
        
        if let token = tx.token {
            tokenButton.setTitle(token.rawValue, for: .normal)
        }
        
        if let amount = tx.amount {
            amountTextField.text = amount.rawValue
        }
        
        // Update balance label
        if let token = tx.token {
            if let maxAmount = walletManager.getMaxAmount(for: token) {
                balanceLabel.text = "Balance: \(String(format: "%.4f", maxAmount)) \(token.rawValue)"
            } else {
                balanceLabel.text = "Balance: --"
            }
        } else {
            balanceLabel.text = ""
        }
        
        // Enable next button if step 1 is complete
        let step1Complete = tx.fromChain != nil && tx.token != nil && tx.amount != nil
        nextButton.isEnabled = step1Complete
        nextButton.alpha = step1Complete ? 1.0 : 0.5
    }
    
    // MARK: - Actions
    
    @objc private func selectFromChain() {
        let alert = UIAlertController(title: "Select Source Chain", message: nil, preferredStyle: .actionSheet)
        
        for network in walletManager.supportedNetworks() {
            alert.addAction(UIAlertAction(title: network.name, style: .default) { [weak self] _ in
                self?.didSelectFromChain(network)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func didSelectFromChain(_ network: NetworkConfig) {
        var tx = transaction ?? Transaction()
        tx.fromChain = Chain(networkConfig: network)
        transaction = tx
        
        // Update wallet manager's selected network
        walletManager.setNetwork(network)
        
        updateUI()
    }
    
    @objc private func selectToken() {
        guard let fromChain = transaction?.fromChain,
              let network = fromChain.networkConfig else { return }
        
        let alert = UIAlertController(title: "Select Token", message: nil, preferredStyle: .actionSheet)
        
        for token in walletManager.supportedTokens(on: network) {
            alert.addAction(UIAlertAction(title: token.rawValue, style: .default) { [weak self] _ in
                self?.didSelectToken(token)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func didSelectToken(_ token: Token) {
        var tx = transaction ?? Transaction()
        tx.token = token
        transaction = tx
        updateUI()
    }
    
    @objc private func setMaxAmount() {
        guard let token = transaction?.token,
              let maxAmount = walletManager.getMaxAmount(for: token) else { return }
        
        amountTextField.text = String(format: "%.4f", maxAmount)
        amountChanged()
    }
    
    @objc private func amountChanged() {
        guard let text = amountTextField.text, !text.isEmpty else {
            var tx = transaction ?? Transaction()
            tx.amount = nil
            transaction = tx
            updateUI()
            return
        }
        
        var tx = transaction ?? Transaction()
        tx.amount = Amount(rawValue: text)
        transaction = tx
        updateUI()
    }
    
    @objc private func proceedToNext() {
        guard let tx = transaction,
              tx.fromChain != nil,
              tx.token != nil,
              tx.amount != nil else { return }
        
        // Notify delegate to move to destination selection
        delegate?.buildTransactionViewController(self, didUpdateTransaction: tx)
    }
}
