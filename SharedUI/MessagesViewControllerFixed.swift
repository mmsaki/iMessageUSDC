//
//  MessagesViewController.swift
//  iMessageUSDC MessagesExtension
//
//  Created by Meek Msaki on 2/7/26.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    // MARK: - Properties
    
    private var walletVC: WalletViewController?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWalletView()
        print("🚀 Messages Extension loaded")
    }
    
    // MARK: - Setup
    
    private func setupWalletView() {
        let wallet = WalletViewController()
        wallet.conversation = activeConversation
        wallet.messagesViewController = self
        
        // Add as child view controller
        addChild(wallet)
        view.addSubview(wallet.view)
        
        wallet.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wallet.view.topAnchor.constraint(equalTo: view.topAnchor),
            wallet.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            wallet.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wallet.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        wallet.didMove(toParent: self)
        self.walletVC = wallet
        
        print("✅ Wallet view configured")
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        walletVC?.conversation = conversation
        
        print("💬 Became active in conversation with \(conversation.localParticipantIdentifier)")
    }
    
    override func didResignActive(with conversation: MSConversation) {
        super.didResignActive(with: conversation)
        print("💬 Resigned active from conversation")
    }
    
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        super.didReceive(message, conversation: conversation)
        print("📨 Received message")
        
        // Handle the message in wallet VC
        walletVC?.handleMessage(message)
        
        // Expand to show the transaction details
        requestPresentationStyle(.expanded)
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        super.didStartSending(message, conversation: conversation)
        print("📤 Started sending message")
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        super.didCancelSending(message, conversation: conversation)
        print("❌ Cancelled sending message")
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        
        switch presentationStyle {
        case .compact:
            print("📱 Transitioning to compact mode")
        case .expanded:
            print("📱 Transitioning to expanded mode")
        case .transcript:
            print("📱 Transitioning to transcript")
        @unknown default:
            break
        }
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
        
        // Update UI based on presentation style if needed
        updateUI(for: presentationStyle)
    }
    
    private func updateUI(for style: MSMessagesAppPresentationStyle) {
        // Customize UI based on expanded/compact mode
        switch style {
        case .compact:
            // Show minimal UI
            print("📱 Now in compact mode")
        case .expanded:
            // Show full UI
            print("📱 Now in expanded mode")
        default:
            break
        }
    }
}
