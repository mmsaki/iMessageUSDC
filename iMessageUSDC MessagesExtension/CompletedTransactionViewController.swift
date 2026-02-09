//
//  CompletedTransactionViewController.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/7/26.
//

import UIKit
import Messages

class CompletedTransactionViewController: UIViewController {
    
    static let storyboardIdentifier = "CompletedTransactionViewController"
    
    var transaction: Transaction?
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let statusIcon: UILabel = {
        let label = UILabel()
        label.text = "✓"
        label.font = .systemFont(ofSize: 60, weight: .bold)
        label.textColor = .systemGreen
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Transaction Ready"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailsCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let detailsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Accept USDC", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send USDC", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        displayTransactionDetails()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        contentStack.addArrangedSubview(statusIcon)
        contentStack.addArrangedSubview(titleLabel)
        
        // Details card
        detailsCard.addSubview(detailsStack)
        contentStack.addArrangedSubview(detailsCard)
        
        contentStack.addArrangedSubview(acceptButton)
        contentStack.addArrangedSubview(sendButton)
        contentStack.addArrangedSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            
            detailsStack.topAnchor.constraint(equalTo: detailsCard.topAnchor, constant: 20),
            detailsStack.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 20),
            detailsStack.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -20),
            detailsStack.bottomAnchor.constraint(equalTo: detailsCard.bottomAnchor, constant: -20),
            
            acceptButton.heightAnchor.constraint(equalToConstant: 56),
            sendButton.heightAnchor.constraint(equalToConstant: 56),
            cancelButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        acceptButton.addTarget(self, action: #selector(acceptTransaction), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendTransaction), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTransaction), for: .touchUpInside)
    }
    
    private func displayTransactionDetails() {
        guard let tx = transaction else { return }
        
        detailsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // From
        if let fromChain = tx.fromChain {
            let fromRow = createDetailRow(label: "From", value: fromChain.rawValue)
            detailsStack.addArrangedSubview(fromRow)
        }
        
        // Token & Amount
        if let token = tx.token, let amount = tx.amount {
            let amountRow = createDetailRow(label: "Amount", value: "\(amount.rawValue) \(token.rawValue)")
            detailsStack.addArrangedSubview(amountRow)
        }
        
        // To Chain
        if let toChain = tx.toChain {
            let toChainRow = createDetailRow(label: "To Chain", value: toChain.rawValue)
            detailsStack.addArrangedSubview(toChainRow)
        }
        
        // To Address
        if let toAddress = tx.toAddress {
            let addressRow = createDetailRow(label: "To Address", value: shortenAddress(toAddress.rawValue))
            detailsStack.addArrangedSubview(addressRow)
        }
    }
    
    private func createDetailRow(label: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 15)
        labelView.textColor = .secondaryLabel
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        let valueView = UILabel()
        valueView.text = value
        valueView.font = .systemFont(ofSize: 15, weight: .medium)
        valueView.textColor = .label
        valueView.textAlignment = .right
        valueView.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(labelView)
        container.addSubview(valueView)
        
        NSLayoutConstraint.activate([
            labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            labelView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            labelView.topAnchor.constraint(equalTo: container.topAnchor),
            labelView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            valueView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            valueView.leadingAnchor.constraint(greaterThanOrEqualTo: labelView.trailingAnchor, constant: 16)
        ])
        
        return container
    }
    
    private func shortenAddress(_ address: String) -> String {
        guard address.count > 10 else { return address }
        let start = address.prefix(6)
        let end = address.suffix(4)
        return "\(start)...\(end)"
    }
    
    // MARK: - Actions
    
    @objc private func acceptTransaction() {
        // TODO: Implement accept logic (receive transaction)
        showAlert(title: "Accept Transaction", message: "This will initiate receiving the USDC transfer.")
    }
    
    @objc private func sendTransaction() {
        // TODO: Implement send logic (execute transaction)
        showAlert(title: "Send Transaction", message: "This will execute the USDC transfer on-chain.")
    }
    
    @objc private func cancelTransaction() {
        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
