//
//  ENSInputConroller.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/7/26.
//
import UIKit
import Messages

final class ENSInputViewController: UIViewController {
    private let amount: String
    private let originalMessage: MSMessage
    private let conversation: MSConversation

    private let amountLabel = UILabel()
    private let ensTextField = UITextField()
    private let confirmButton = UIButton(type: .system)

    init(amount: String, originalMessage: MSMessage, conversation: MSConversation) {
        self.amount = amount
        self.originalMessage = originalMessage
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        amountLabel.text = "\(amount) USDC"
        amountLabel.font = .systemFont(ofSize: 48, weight: .bold)
        amountLabel.textAlignment = .center

        ensTextField.placeholder = "Enter your ENS or wallet address"
        ensTextField.borderStyle = .roundedRect

        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        confirmButton.backgroundColor = .systemBlue
        confirmButton.tintColor = .white
        confirmButton.layer.cornerRadius = 12
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [amountLabel, ensTextField, confirmButton])
        stack.axis = .vertical
        stack.spacing = 32
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ensTextField.widthAnchor.constraint(equalToConstant: 250),
            confirmButton.widthAnchor.constraint(equalToConstant: 200),
            confirmButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func confirmTapped() {
        guard let recipientENS = ensTextField.text, !recipientENS.isEmpty else { return }

        let updatedMessage = MSMessage(session: originalMessage.session ?? MSSession())
        var components = URLComponents()
        components.scheme = "msaki"
        components.host = "share"
        components.queryItems = [
            URLQueryItem(name: "amount", value: amount),
            URLQueryItem(name: "recipientENS", value: recipientENS)
        ]
        updatedMessage.url = components.url

        let layout = MSMessageTemplateLayout()
        layout.caption = "Accept \(amount) USDC"  // Recipient caption
        layout.subcaption = "Recipient: \(recipientENS)"
        updatedMessage.layout = layout

        conversation.insert(updatedMessage) { error in
            if let error = error { print("Error sending message: \(error)") }
        }
    }
}
