//
//  JSONRPCExamples.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/7/26.
//

import Foundation

/// Example usage of the JSON-RPC client
class EthereumService {
    let client: JSONRPCClient
    
    /// Initialize with your RPC endpoint (e.g., Infura, Alchemy, or local node)
    init(rpcURL: String) {
        // For production, use environment variables or secure configuration
        guard let client = JSONRPCClient(rpcURLString: rpcURL) else {
            fatalError("Invalid RPC URL")
        }
        self.client = client
    }
    
    /// Example: Get the latest block number
    func getLatestBlockNumber() async throws -> Int {
        let hexString = try await client.eth_blockNumber()
        return Int(hexString.dropFirst(2), radix: 16) ?? 0
    }
    
    /// Example: Get balance in Wei
    func getBalance(address: String) async throws -> String {
        try await client.eth_getBalance(address: address)
    }
    
    /// Example: Get balance in Ether
    func getBalanceInEther(address: String) async throws -> Double {
        let weiHex = try await client.eth_getBalance(address: address)
        let wei = Double(weiHex.dropFirst(2), radix: 16) ?? 0
        return wei / 1_000_000_000_000_000_000 // Convert Wei to Ether
    }
    
    /// Example: Check USDC balance (ERC-20)
    func getUSDCBalance(address: String, usdcContractAddress: String) async throws -> String {
        // ERC-20 balanceOf function signature: balanceOf(address)
        let functionSelector = "0x70a08231" // keccak256("balanceOf(address)")[:8]
        let paddedAddress = String(address.dropFirst(2)).padding(toLength: 64, withPad: "0", startingAt: 0)
        let data = functionSelector + paddedAddress
        
        let result = try await client.eth_call(to: usdcContractAddress, data: data)
        return result
    }
    
    /// Example: Get current gas price in Gwei
    func getGasPriceInGwei() async throws -> Double {
        let hexString = try await client.eth_gasPrice()
        let wei = Double(hexString.dropFirst(2), radix: 16) ?? 0
        return wei / 1_000_000_000 // Convert Wei to Gwei
    }
    
    /// Example: Get chain ID
    func getChainId() async throws -> Int {
        let hexString = try await client.eth_chainId()
        return Int(hexString.dropFirst(2), radix: 16) ?? 0
    }
    
    /// Example: Send a raw transaction (must be signed)
    func sendTransaction(signedTxHex: String) async throws -> String {
        try await client.eth_sendRawTransaction(signedTx: signedTxHex)
    }
}

// MARK: - Usage Examples

/// Example: Basic usage in a view or controller
func exampleUsage() async {
    // Initialize with your Ethereum node URL
    // Examples:
    // - Infura: "https://mainnet.infura.io/v3/YOUR_API_KEY"
    // - Alchemy: "https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY"
    // - Local node: "http://localhost:8545"
    
    let service = EthereumService(rpcURL: "https://mainnet.infura.io/v3/YOUR_API_KEY")
    
    do {
        // Get latest block number
        let blockNumber = try await service.getLatestBlockNumber()
        print("Latest block: \(blockNumber)")
        
        // Get balance
        let balance = try await service.getBalanceInEther(address: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb")
        print("Balance: \(balance) ETH")
        
        // Get gas price
        let gasPrice = try await service.getGasPriceInGwei()
        print("Gas price: \(gasPrice) Gwei")
        
        // Get chain ID
        let chainId = try await service.getChainId()
        print("Chain ID: \(chainId)")
        
    } catch let error as JSONRPCError {
        print("RPC Error [\(error.code)]: \(error.message)")
    } catch {
        print("Error: \(error)")
    }
}

/// Example: Using the raw client for custom methods
func exampleRawClientUsage() async {
    guard let client = JSONRPCClient(rpcURLString: "https://mainnet.infura.io/v3/YOUR_API_KEY") else {
        print("Invalid URL")
        return
    }
    
    Task {
        do {
            // Simple call
            let blockNumber: String = try await client.call(method: "eth_blockNumber")
            print("Block: \(blockNumber)")
            
            // Call with parameters
            let balance: String = try await client.call(
                method: "eth_getBalance",
                params: [
                    .string("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"),
                    .string("latest")
                ]
            )
            print("Balance: \(balance)")
            
        } catch {
            print("Error: \(error)")
        }
    }
}

// MARK: - Network Configuration

/// Helper for managing different network configurations
struct NetworkConfig {
    let name: String
    let rpcURL: String
    let chainId: Int
    let usdcAddress: String?
    
    static let mainnet = NetworkConfig(
        name: "Ethereum Mainnet",
        rpcURL: "https://mainnet.infura.io/v3/YOUR_API_KEY",
        chainId: 1,
        usdcAddress: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
    )
    
    static let polygon = NetworkConfig(
        name: "Polygon",
        rpcURL: "https://polygon-rpc.com",
        chainId: 137,
        usdcAddress: "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174"
    )
    
    static let arbitrum = NetworkConfig(
        name: "Arbitrum One",
        rpcURL: "https://arb1.arbitrum.io/rpc",
        chainId: 42161,
        usdcAddress: "0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8"
    )
    
    static let base = NetworkConfig(
        name: "Base",
        rpcURL: "https://mainnet.base.org",
        chainId: 8453,
        usdcAddress: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913"
    )
}
