//
//  SendConfirmeViewController.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/7/26.
//

import UIKit
import Messages

final class SendConfirmViewController: UIViewController {

    private let amount: Double
    private let recipientENS: String
    private let message: MSMessage
    private let conversation: MSConversation

    // UI
    private let amountLabel = UILabel()
    private let ensLabel = UILabel()
    private let sendButton = UIButton(type: .system)

    init(
        amount: Double,
        recipientENS: String,
        message: MSMessage,
        conversation: MSConversation
    ) {
        self.amount = amount
        self.recipientENS = recipientENS
        self.message = message
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        buildUI()
    }

    private func buildUI() {
        amountLabel.text = "\(Int(amount)) USDC"
        amountLabel.font = .systemFont(ofSize: 48, weight: .bold)
        amountLabel.textAlignment = .center

        ensLabel.text = "To: \(recipientENS)"
        ensLabel.font = .systemFont(ofSize: 18, weight: .medium)
        ensLabel.textAlignment = .center
        ensLabel.textColor = .secondaryLabel

        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        sendButton.configuration = .filled()
        sendButton.configuration?.cornerStyle = .capsule
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            UIView(),
            amountLabel,
            ensLabel,
            UIView(),
            sendButton
        ])

        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            sendButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    @objc
    private func sendTapped() {
        // This is where your blockchain tx will go later
        print("🚀 Sending \(amount) USDC to \(recipientENS)")

        // For now: visual confirmation
        let alert = UIAlertController(
            title: "Transaction",
            message: "Sending \(Int(amount)) USDC to \(recipientENS)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
