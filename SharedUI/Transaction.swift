//
//  TransactionFlow.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/7/26.
//

import Foundation
import Messages

struct Transaction: Codable, Equatable, Hashable {
    var fromChain: Chain?
    var token: Token?
    var amount: Amount?
    var toChain: Chain?
    var toAddress: Address?
    
    init(fromChain: Chain? = nil, token: Token? = nil, amount: Amount? = nil, toChain: Chain? = nil, toAddress: Address? = nil) {
        self.fromChain = fromChain
        self.token = token
        self.amount = amount
        self.toChain = toChain
        self.toAddress = toAddress
    }
    
    var isComplete: Bool {
        return fromChain != nil &&
            token != nil &&
            amount != nil &&
            toChain != nil &&
            toAddress != nil
    }
}

extension Transaction: CustomStringConvertible {
    var description: String {
        "\(amount?.rawValue ?? "?") \(token?.rawValue ?? "?") from \(fromChain?.rawValue ?? "?") to \(toChain?.rawValue ?? "?") at \(toAddress?.rawValue ?? "?")"
        
    }
}

extension Transaction {
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        if let part = fromChain { items.append(part.queryItem) }
        if let part = token { items.append(part.queryItem) }
        if let part = amount { items.append(part.queryItem) }
        if let part = toChain { items.append(part.queryItem) }
        if let part = toAddress { items.append(part.queryItem) }
        return items
    }
    
    init?(queryItems: [URLQueryItem]) {
        var fromChain: Chain?
        var token: Token?
        var amount: Amount?
        var toChain: Chain?
        var toAddress: Address?
        
        for queryItem in queryItems {
            guard let value = queryItem.value else { continue }
            if let decoded = Chain(rawValue: value),
                queryItem.name == Chain.queryItemKey {
                if fromChain == nil {
                    fromChain = decoded
                } else {
                    toChain = decoded
                }
            }
            if let decoded = Token(rawValue: value),
                queryItem.name == Token.queryItemKey {
                token = decoded
            }
            if let decoded = Amount(rawValue: value),
                queryItem.name == Amount.queryItemKey {
                amount = decoded
            }
            if let decoded = Address(rawValue: value),
                queryItem.name == Address.queryItemKey {
                toAddress = decoded
            }
        }
        guard let decodedFrom = fromChain else { return nil }
        self.fromChain = decodedFrom
        self.token = token
        self.amount = amount
        self.toChain = toChain
        self.toAddress = toAddress
    }
}

extension Transaction {
    init?(message: MSMessage?) {
        guard let messageUrl = message?.url else { return nil }
        guard let urlComponents = NSURLComponents(url: messageUrl, resolvingAgainstBaseURL: false) else { return nil}
        guard let queryItems = urlComponents.queryItems else { return nil }
        
        self.init(queryItems: queryItems)
    }
}

struct Chain: Codable, Equatable, Hashable {
    let rawValue: String
    init?(rawValue: String) {
        self.rawValue = rawValue
    }
    
    static let queryItemKey = "chain"
    var queryItem: URLQueryItem {
        URLQueryItem(name: Self.queryItemKey, value: String(describing: self))
    }
}
struct Token: Codable, Equatable, Hashable {
    let rawValue: String
    init?(rawValue: String) {
        self.rawValue = rawValue
    }
    
    static let queryItemKey = "token"
    var queryItem: URLQueryItem {
        URLQueryItem(name: Self.queryItemKey, value: String(describing: self))
    }
}
struct Address: Codable, Equatable, Hashable {
    let rawValue: String
    init?(rawValue: String) {
        self.rawValue = rawValue
    }
    static let queryItemKey = "address"
    var queryItem: URLQueryItem {
        URLQueryItem(name: Self.queryItemKey, value: rawValue)
    }
}
struct Amount: Codable, Equatable, Hashable {
    let rawValue: String
    init?(rawValue: String) {
        self.rawValue = rawValue
    }
    static let queryItemKey = "amount"
    var queryItem: URLQueryItem {
        URLQueryItem(name: Self.queryItemKey, value: rawValue)
    }
}
