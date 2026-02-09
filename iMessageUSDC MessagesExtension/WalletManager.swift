//
//  WalletManager.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/7/26.
//

import Foundation

/// Manages wallet state, balances, and persistence
class WalletManager {
    static let shared = WalletManager()
    
    private let userDefaults = UserDefaults.standard
    private let walletService: WalletService
    
    // Keys for UserDefaults
    private let addressKey = "wallet_address"
    private let selectedNetworkKey = "selected_network"
    private let cachedBalancesKey = "cached_balances"
    
    // Current wallet state
    private(set) var currentAddress: String?
    private(set) var selectedNetwork: NetworkConfig
    private var cachedBalances: [String: WalletBalance] = [:]
    
    private init() {
        // Load saved network or default to Base
        if let savedNetworkName = userDefaults.string(forKey: selectedNetworkKey),
           let network = NetworkConfig.network(for: savedNetworkName) {
            self.selectedNetwork = network
        } else {
            self.selectedNetwork = .base
        }
        
        self.walletService = WalletService(rpcURL: selectedNetwork.rpcURL)
        
        // Load saved address
        self.currentAddress = userDefaults.string(forKey: addressKey)
        
        // Load cached balances
        if let data = userDefaults.data(forKey: cachedBalancesKey),
           let decoded = try? JSONDecoder().decode([String: CachedBalance].self, from: data) {
            self.cachedBalances = decoded.mapValues { $0.toWalletBalance() }
        }
    }
    
    // MARK: - Address Management
    
    func setAddress(_ address: String) {
        currentAddress = address
        userDefaults.set(address, forKey: addressKey)
        
        // Refresh balance for new address
        Task {
            try? await refreshBalance()
        }
    }
    
    func clearAddress() {
        currentAddress = nil
        userDefaults.removeObject(forKey: addressKey)
        cachedBalances.removeAll()
        saveCachedBalances()
    }
    
    // MARK: - Network Management
    
    func setNetwork(_ network: NetworkConfig) {
        selectedNetwork = network
        userDefaults.set(network.name, forKey: selectedNetworkKey)
        
        // Refresh balance for new network
        if currentAddress != nil {
            Task {
                try? await refreshBalance()
            }
        }
    }
    
    // MARK: - Balance Management
    
    func getBalance() -> WalletBalance? {
        guard let address = currentAddress else { return nil }
        return cachedBalances[balanceKey(address: address, network: selectedNetwork)]
    }
    
    func getMaxAmount(for token: Token) -> Double? {
        guard let balance = getBalance() else { return nil }
        
        if token.rawValue == "USDC" {
            return balance.usdcBalance
        } else if token.rawValue == "ETH" {
            // Reserve some ETH for gas
            let gasReserve = 0.001
            return max(0, balance.ethBalance - gasReserve)
        }
        
        return nil
    }
    
    @discardableResult
    func refreshBalance() async throws -> WalletBalance {
        guard let address = currentAddress else {
            throw WalletError.invalidAddress
        }
        
        let balance = try await walletService.getBalance(address: address)
        
        let key = balanceKey(address: address, network: selectedNetwork)
        cachedBalances[key] = balance
        saveCachedBalances()
        
        return balance
    }
    
    // MARK: - Transaction Validation
    
    func validateTransaction(_ transaction: Transaction) async throws -> ValidationResult {
        return try await walletService.validateTransaction(transaction)
    }
    
    // MARK: - Supported Options
    
    func supportedNetworks() -> [NetworkConfig] {
        return NetworkConfig.allNetworks
    }
    
    func supportedTokens(on network: NetworkConfig) -> [Token] {
        // For now, all networks support USDC and ETH
        return Token.supportedTokens
    }
    
    // MARK: - Private Helpers
    
    private func balanceKey(address: String, network: NetworkConfig) -> String {
        return "\(address.lowercased())_\(network.chainId)"
    }
    
    private func saveCachedBalances() {
        let cached = cachedBalances.mapValues { CachedBalance(from: $0) }
        if let data = try? JSONEncoder().encode(cached) {
            userDefaults.set(data, forKey: cachedBalancesKey)
        }
    }
}

// MARK: - Codable Balance Cache

private struct CachedBalance: Codable {
    let address: String
    let ethBalance: Double
    let usdcBalance: Double?
    
    init(from balance: WalletBalance) {
        self.address = balance.address
        self.ethBalance = balance.ethBalance
        self.usdcBalance = balance.usdcBalance
    }
    
    func toWalletBalance() -> WalletBalance {
        return WalletBalance(
            address: address,
            ethBalance: ethBalance,
            usdcBalance: usdcBalance
        )
    }
}
