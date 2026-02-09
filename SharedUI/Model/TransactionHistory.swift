//
//  TransactionHistory.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/7/26.
//

import Foundation

struct TransactionHistory: Codable {
    var transactions: [Transaction]
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(transactions)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.transactions = try container.decode([Transaction].self)
    }
    
    init(transactions: [Transaction] = []) {
        self.transactions = transactions
    }
    
    // MARK: - Persistence
    
    private static let archiveURL: URL = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("transactions").appendingPathExtension("plist")
    }()
    
    static func load() -> [Transaction] {
        guard let data = try? Data(contentsOf: archiveURL) else { return [] }
        guard let history = try? PropertyListDecoder().decode(TransactionHistory.self, from: data) else { return [] }
        return history.transactions
    }
    
    func save() {
        guard let data = try? PropertyListEncoder().encode(self) else { return }
        try? data.write(to: TransactionHistory.archiveURL)
    }
}
extension Array where Element == Transaction {
    func save() {
        let history = TransactionHistory(transactions: self)
        history.save()
    }
}

