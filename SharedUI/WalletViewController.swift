//
//  WalletViewController.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/7/26.
//

import UIKit
import Messages
import SafariServices
// import EthereumKit // Uncomment when package is added

/// Main wallet view for sending/requesting USDC in iMessage
final class WalletViewController: UIViewController {
    
    // MARK: - Properties
    
    var conversation: MSConversation?
    weak var messagesViewController: MSMessagesAppViewController?
    private var messageSession: MSSession?
    private var currentTransaction = Transaction()
    
    // Configure your RPC endpoint
    private let rpcURL = "https://ethereum.publicnode.com"
    
    // MARK: - UI Components
    
    private let tokenButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.cornerStyle = .capsule
        config.image = UIImage(named: "usdc-3D-token")?
            .withRenderingMode(.alwaysOriginal)
        config.imagePlacement = .leading
        config.imagePadding = 8
        
        let button = UIButton(configuration: config)
        button.setTitle("USDC", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        return button
    }()
    
    private let walletButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "wallet.pass"), for: .normal)
        button.configuration = .bordered()
        return button
    }()
    
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
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Balance: --"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.tintColor = .systemBlue
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        loadWalletInfo()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Top bar
        let topBar = UIStackView(arrangedSubviews: [tokenButton, UIView(), walletButton])
        topBar.axis = .horizontal
        topBar.spacing = 16
        
        // Amount input
        let amountStack = UIStackView(arrangedSubviews: [currencyLabel, amountTextField])
        amountStack.axis = .horizontal
        amountStack.alignment = .center
        amountStack.spacing = 6
        
        // Action buttons
        let buttonStack = UIStackView(arrangedSubviews: [requestButton, sendButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually
        
        // Root stack
        let rootStack = UIStackView(arrangedSubviews: [
            topBar,
            UIView(),
            amountStack,
            balanceLabel,
            UIView(),
            buttonStack
        ])
        rootStack.axis = .vertical
        rootStack.spacing = 16
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(rootStack)
        
        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            rootStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            sendButton.heightAnchor.constraint(equalToConstant: 56),
            requestButton.heightAnchor.constraint(equalToConstant: 56),
            tokenButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        walletButton.addTarget(self, action: #selector(walletButtonTapped), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        requestButton.addTarget(self, action: #selector(requestButtonTapped), for: .touchUpInside)
        
        // Dismiss keyboard when tapping outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func walletButtonTapped() {
        // Check if wallet exists
        if let walletAddress = UserDefaults.standard.string(forKey: "walletAddress") {
            // Show wallet details
            showWalletInfo(address: walletAddress)
        } else {
            // Navigate to wallet creation
            if let createWalletVC = storyboard?.instantiateViewController(withIdentifier: "CreateWalletViewController") {
                navigationController?.pushViewController(createWalletVC, animated: true)
            } else {
                // Fallback: Show alert to create wallet
                showCreateWalletAlert()
            }
        }
    }
    
    private func showWalletInfo(address: String) {
        let alert = UIAlertController(
            title: "Wallet Address",
            message: address,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Copy Address", style: .default) { _ in
            UIPasteboard.general.string = address
            print("📋 Address copied: \(address)")
        })
        
        alert.addAction(UIAlertAction(title: "View on Explorer", style: .default) { [weak self] _ in
            let explorerURL = "https://etherscan.io/address/\(address)"
            if let url = URL(string: explorerURL) {
                self?.openWebView(url: url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showCreateWalletAlert() {
        let alert = UIAlertController(
            title: "No Wallet Found",
            message: "You need to create or import a wallet to send USDC.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Create Wallet", style: .default) { [weak self] _ in
            self?.createNewWallet()
        })
        
        alert.addAction(UIAlertAction(title: "Import Wallet", style: .default) { [weak self] _ in
            self?.showImportWallet()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func createNewWallet() {
        // TODO: Implement wallet creation with private key generation
        // For now, create a mock wallet for testing
        let mockAddress = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
        UserDefaults.standard.set(mockAddress, forKey: "walletAddress")
        
        showAlert(
            title: "Wallet Created! 🎉",
            message: "Address: \(mockAddress)\n\n⚠️ This is a test wallet. In production, securely store your private key!"
        )
        
        // Reload wallet info
        loadWalletInfo()
    }
    
    private func showImportWallet() {
        let alert = UIAlertController(
            title: "Import Wallet",
            message: "Enter your Ethereum address",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "0x..."
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }
        
        alert.addAction(UIAlertAction(title: "Import", style: .default) { [weak self, weak alert] _ in
            guard let address = alert?.textFields?.first?.text,
                  !address.isEmpty else {
                self?.showAlert(title: "Error", message: "Please enter a valid address")
                return
            }
            
            // Validate address format
            if self?.isValidEthereumAddress(address) == true {
                UserDefaults.standard.set(address, forKey: "walletAddress")
                self?.showAlert(title: "Success", message: "Wallet imported successfully!")
                self?.loadWalletInfo()
            } else {
                self?.showAlert(title: "Invalid Address", message: "Please enter a valid Ethereum address (0x...)")
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func isValidEthereumAddress(_ address: String) -> Bool {
        let pattern = "^0x[a-fA-F0-9]{40}$"
        return address.range(of: pattern, options: .regularExpression) != nil
    }
    
    @objc private func sendButtonTapped() {
        guard let amountText = amountTextField.text,
              !amountText.isEmpty,
              let amount = Double(amountText),
              amount > 0 else {
            showAlert(title: "Invalid Amount", message: "Please enter a valid amount to send")
            return
        }
        
        guard conversation != nil else {
            showAlert(title: "No Conversation", message: "Unable to send message")
            return
        }
        
        // Build transaction
        currentTransaction.amount = Amount(rawValue: amountText)
        currentTransaction.token = Token(rawValue: "USDC")
        currentTransaction.fromChain = Chain(rawValue: "ethereum")
        currentTransaction.toChain = Chain(rawValue: "ethereum")
        
        // Create or reuse session for interactive messages
        if messageSession == nil {
            messageSession = MSSession()
        }
        
        // Create message
        let message = composeTransferMessage(amount: amount, session: messageSession!)
        
        // Send message
        conversation?.insert(message) { [weak self] error in
            if let error = error {
                print("❌ Error sending message: \(error)")
                self?.showAlert(title: "Send Failed", message: "Could not send transfer request")
            } else {
                print("✅ Transfer message sent: \(amount) USDC")
                DispatchQueue.main.async {
                    self?.amountTextField.text = ""
                    // Collapse the extension after sending
                    self?.messagesViewController?.requestPresentationStyle(.compact)
                }
            }
        }
    }
    
    @objc private func requestButtonTapped() {
        guard let amountText = amountTextField.text,
              !amountText.isEmpty,
              let amount = Double(amountText),
              amount > 0 else {
            showAlert(title: "Invalid Amount", message: "Please enter a valid amount to request")
            return
        }
        
        guard conversation != nil else {
            showAlert(title: "No Conversation", message: "Unable to send message")
            return
        }
        
        // Create request message
        if messageSession == nil {
            messageSession = MSSession()
        }
        
        let message = composeRequestMessage(amount: amount, session: messageSession!)
        
        conversation?.insert(message) { [weak self] error in
            if let error = error {
                print("❌ Error sending request: \(error)")
                self?.showAlert(title: "Request Failed", message: "Could not send payment request")
            } else {
                print("✅ Request message sent: \(amount) USDC")
                DispatchQueue.main.async {
                    self?.amountTextField.text = ""
                    // Collapse the extension after sending
                    self?.messagesViewController?.requestPresentationStyle(.compact)
                }
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Message Composition
    
    private func composeTransferMessage(amount: Double, session: MSSession) -> MSMessage {
        let message = MSMessage(session: session)
        
        // Build URL with transaction data
        var components = URLComponents()
        components.queryItems = currentTransaction.queryItems
        message.url = components.url
        
        // Create message layout
        let layout = MSMessageTemplateLayout()
        layout.caption = "💸 Sending \(formatAmount(amount)) USDC"
        layout.subcaption = "Tap to enter your wallet address"
        layout.trailingCaption = "Pending"
        
        // Optional: Add an image
        if let image = UIImage(named: "usdc-icon") {
            layout.image = image
        }
        
        message.layout = layout
        return message
    }
    
    private func composeRequestMessage(amount: Double, session: MSSession) -> MSMessage {
        let message = MSMessage(session: session)
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "type", value: "request"),
            URLQueryItem(name: "amount", value: "\(amount)"),
            URLQueryItem(name: "token", value: "USDC")
        ]
        message.url = components.url
        
        let layout = MSMessageTemplateLayout()
        layout.caption = "💰 Requesting \(formatAmount(amount)) USDC"
        layout.subcaption = "Tap to send"
        
        message.layout = layout
        return message
    }
    
    // MARK: - Wallet Integration
    
    private func loadWalletInfo() {
        // Get wallet address from storage
        guard let walletAddress = UserDefaults.standard.string(forKey: "walletAddress") else {
            balanceLabel.text = "No wallet • Tap wallet icon"
            return
        }
        
        // Load balance using EthereumKit
        Task {
            await loadBalance(address: walletAddress)
        }
    }
    
    private func loadBalance(address: String) async {
        // Uncomment when EthereumKit is integrated:
        /*
        do {
            let service = EthereumService(rpcURL: rpcURL)
            
            // Get USDC balance
            let config = NetworkConfig.mainnet(apiKey: "")
            if let usdcAddress = config.usdcAddress {
                let balance = try await service.getUSDCBalance(
                    address: address,
                    usdcContractAddress: usdcAddress
                )
                
                await MainActor.run {
                    balanceLabel.text = "Balance: \(formatAmount(balance)) USDC"
                    tokenButton.setTitle("\(formatAmount(balance)) USDC", for: .normal)
                }
            }
        } catch {
            print("❌ Error loading balance: \(error)")
            await MainActor.run {
                balanceLabel.text = "Balance: Error loading"
            }
        }
        */
        
        // Mock data for now
        await MainActor.run {
            balanceLabel.text = "Balance: 1,234.56 USDC"
            tokenButton.setTitle("1,234.56 USDC", for: .normal)
        }
    }
    
    // MARK: - Helpers
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    /// Opens a URL in an embedded web view (for iMessage extension compatibility)
    private func openWebView(url: URL) {
        let webVC = WebViewController(url: url)
        let navController = UINavigationController(rootViewController: webVC)
        // iMessage extensions don't support .fullScreen, use default presentation
        present(navController, animated: true) {
            print("✅ Opened web view: \(url.absoluteString)")
        }
    }
}

// MARK: - Message Handling

extension WalletViewController {
    /// Handle incoming messages (when user taps a message bubble)
    func handleMessage(_ message: MSMessage) {
        guard let transaction = Transaction(message: message) else {
            print("❌ Could not parse transaction from message")
            return
        }
        
        if transaction.isComplete {
            // Show transaction details
            showTransactionDetails(transaction)
        } else {
            // Continue building the transaction
            currentTransaction = transaction
            
            // Pre-fill amount if available
            if let amount = transaction.amount {
                amountTextField.text = amount.rawValue
            }
        }
    }
    
    private func showTransactionDetails(_ transaction: Transaction) {
        // For now, show transaction details in an alert
        // TODO: Implement proper TransactionViewController initialization
        let alert = UIAlertController(
            title: "Transaction Details",
            message: """
            Amount: \(transaction.amount?.rawValue ?? "N/A")
            Token: \(transaction.token?.rawValue ?? "N/A")
            From: \(transaction.fromChain?.rawValue ?? "N/A")
            To: \(transaction.toChain?.rawValue ?? "N/A")
            Status: \(transaction.isComplete ? "Complete" : "Pending")
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        /* Alternative: If TransactionViewController should be loaded from storyboard:
        if let detailVC = storyboard?.instantiateViewController(
            withIdentifier: TransactionViewController.storyboardIdentifier
        ) as? TransactionViewController {
            // Configure the view controller
            navigationController?.pushViewController(detailVC, animated: true)
        }
        */
    }
}

// MARK: - Preview

#if DEBUG
import SwiftUI

struct WalletViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIKitPreview {
            let nav = UINavigationController(rootViewController: WalletViewController())
            nav.navigationBar.prefersLargeTitles = false
            return nav
        }
        .previewDevice("iPhone 15 Pro")
    }
}
#endif
