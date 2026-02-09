//
//  MessagesViewController.swift
//  iMessageUSDC MessagesExtension
//
//  Created by Meek Msaki on 2/6/26.
//

import UIKit
import Messages

final class USDCMessagesViewController: MSMessagesAppViewController {
    
    // MARK: Properties
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    // MARK: MSMessagesAppViewController overrides
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        // hide child view controllers during the transition
        removeAllChildViewControllers()
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
        guard let conversation = activeConversation else { fatalError("Expected an active conversation")}
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    // MARK: Child view controller presentation
    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        removeAllChildViewControllers()
        let controller: UIViewController
        if presentationStyle == .compact {
            // show a list of previously created transactions
            controller = instantiateTransactionListController()
        } else {
            // parse a Transaction from the conversation's selectedMessage or create a new Transaction
            let transaction = Transaction(message: conversation.selectedMessage) ?? Transaction()
            // show either the in progress construction process or the completed transaction.
            if transaction.isComplete {
                controller = instantiateTransactionCompletedController(with: transaction)
            } else {
                controller = instantiateTransactionBuilderController(with: transaction)
            }
        }
        addChild(controller)
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        NSLayoutConstraint.activate([
            controller.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            controller.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        controller.didMove(toParent: self)
    }
    
    private func instantiateTransactionListController() -> UIViewController {
        // Create programmatically
        let controller = TransactionViewController()
        controller.delegate = self
        return controller
    }
    
    private func instantiateTransactionBuilderController(with transaction: Transaction) -> UIViewController {
        // Create navigation controller with builder as root
        let builder = BuildTransactionViewController()
        builder.transaction = transaction
        builder.delegate = self
        
        let navController = UINavigationController(rootViewController: builder)
        return navController
    }
    
    private func instantiateTransactionCompletedController(with transaction: Transaction) -> UIViewController {
        let controller = CompletedTransactionViewController()
        controller.transaction = transaction
        return controller
    }
    
    // MARK: convenience
    private func removeAllChildViewControllers() {
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    // MARK: Message Composition
    
    private func composeMessage(with transaction: Transaction, caption: String, session: MSSession? = nil) -> MSMessage {
        var components = URLComponents()
        components.queryItems = transaction.queryItems
        
        let layout = MSMessageTemplateLayout()
        layout.caption = caption
        
        // Create a simple text-based image for now
        layout.image = renderTransactionImage(transaction)
        
        let message = MSMessage(session: session ?? MSSession())
        message.url = components.url!
        message.layout = layout
        
        return message
    }
    
    private func renderTransactionImage(_ transaction: Transaction) -> UIImage {
        // Create a simple text-based representation
        let size = CGSize(width: 300, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background
            UIColor.systemBlue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            let amount = transaction.amount?.rawValue ?? "?"
            let token = transaction.token?.rawValue ?? "?"
            let text = "\(amount) \(token)"
            
            let textRect = CGRect(x: 20, y: 70, width: size.width - 40, height: 60)
            text.draw(in: textRect, withAttributes: attributes)
            
            // From -> To
            let smallAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.9),
                .paragraphStyle: paragraphStyle
            ]
            
            let from = transaction.fromChain?.rawValue ?? "?"
            let to = transaction.toChain?.rawValue ?? "?"
            let route = "\(from) → \(to)"
            
            let routeRect = CGRect(x: 20, y: 130, width: size.width - 40, height: 30)
            route.draw(in: routeRect, withAttributes: smallAttributes)
        }
    }
}

// MARK: - TransactionViewControllerDelegate

extension USDCMessagesViewController: TransactionViewControllerDelegate {
    func transactionViewControllerDidRequestCreateTransaction(_ viewController: TransactionViewController) {
        requestPresentationStyle(.expanded)
    }
}
// MARK: - BuildTransactionViewControllerDelegate

extension USDCMessagesViewController: BuildTransactionViewControllerDelegate {
    func buildTransactionViewController(_ controller: BuildTransactionViewController, didUpdateTransaction transaction: Transaction) {
        guard let conversation = activeConversation else {
            fatalError("Expected a conversation")
        }
        
        // Determine if we should proceed to next step or send message
        if transaction.fromChain != nil && transaction.token != nil && transaction.amount != nil &&
           transaction.toChain == nil {
            // Move to destination selection
            let destinationVC = SelectDestinationViewController()
            destinationVC.transaction = transaction
            destinationVC.delegate = self
            
            if let navController = controller.navigationController {
                navController.pushViewController(destinationVC, animated: true)
            }
        } else {
            // Send intermediate message (shouldn't happen with current flow, but kept for flexibility)
            let caption = "Building transaction..."
            let message = composeMessage(with: transaction, caption: caption, session: conversation.selectedMessage?.session)
            
            conversation.insert(message) { error in
                if let error = error {
                    print("Error inserting message: \(error)")
                }
            }
        }
    }
}

// MARK: - SelectDestinationViewControllerDelegate

extension USDCMessagesViewController: SelectDestinationViewControllerDelegate {
    func selectDestinationViewController(_ controller: SelectDestinationViewController, didUpdateTransaction transaction: Transaction) {
        guard let conversation = activeConversation else {
            fatalError("Expected a conversation")
        }
        
        guard transaction.isComplete else { return }
        
        // Transaction is complete, send final message
        let caption = "💸 Send \(transaction.amount?.rawValue ?? "?") \(transaction.token?.rawValue ?? "?") to \(transaction.toChain?.rawValue ?? "?")"
        let message = composeMessage(with: transaction, caption: caption, session: conversation.selectedMessage?.session)
        
        conversation.insert(message) { error in
            if let error = error {
                print("Error inserting message: \(error)")
            }
        }
        
        // Save to history
        var history = TransactionHistory.load()
        history.append(transaction)
        history.save()
        
        // Dismiss back to compact mode
        dismiss()
    }
}



