//
//  NetworkConfig.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/7/26.
//

import Foundation

struct NetworkConfig {
    let chainId: Int
    let name: String
    let rpcURL: String
    let usdcAddress: String?
    let explorerURL: String
    
    static let base = NetworkConfig(
        chainId: 8453,
        name: "Base",
        rpcURL: "https://mainnet.base.org",
        usdcAddress: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
        explorerURL: "https://basescan.org"
    )
    
    static let ethereum = NetworkConfig(
        chainId: 1,
        name: "Ethereum",
        rpcURL: "https://eth.llamarpc.com",
        usdcAddress: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
        explorerURL: "https://etherscan.io"
    )
    
    static let polygon = NetworkConfig(
        chainId: 137,
        name: "Polygon",
        rpcURL: "https://polygon-rpc.com",
        usdcAddress: "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",
        explorerURL: "https://polygonscan.com"
    )
    
    static let arbitrum = NetworkConfig(
        chainId: 42161,
        name: "Arbitrum",
        rpcURL: "https://arb1.arbitrum.io/rpc",
        usdcAddress: "0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8",
        explorerURL: "https://arbiscan.io"
    )
    
    static let optimism = NetworkConfig(
        chainId: 10,
        name: "Optimism",
        rpcURL: "https://mainnet.optimism.io",
        usdcAddress: "0x7F5c764cBc14f9669B88837ca1490cCa17c31607",
        explorerURL: "https://optimistic.etherscan.io"
    )
    
    static let allNetworks: [NetworkConfig] = [
        .base,
        .ethereum,
        .polygon,
        .arbitrum,
        .optimism
    ]
    
    static func network(for chainName: String) -> NetworkConfig? {
        allNetworks.first { $0.name.lowercased() == chainName.lowercased() }
    }
    
    static func network(for chainId: Int) -> NetworkConfig? {
        allNetworks.first { $0.chainId == chainId }
    }
}

// Helper to convert between Chain and NetworkConfig
extension Chain {
    var networkConfig: NetworkConfig? {
        NetworkConfig.network(for: rawValue)
    }
    
    init?(networkConfig: NetworkConfig) {
        self.init(rawValue: networkConfig.name)
    }
}

extension Token {
    static let usdc = Token(rawValue: "USDC")
    static let eth = Token(rawValue: "ETH")
    
    static let supportedTokens: [Token] = [
        .usdc!,
        .eth!
    ]
}
