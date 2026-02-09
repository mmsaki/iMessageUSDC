//
//  JSONRPCExamples.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/7/26.
//

import Foundation
// Import your new EthereumKit package
// import EthereumKit

// MARK: - Usage Examples for iMessage Wallet

/// Example: Basic usage in your iMessage app
func exampleUsage() async {
    // Note: Replace with your actual RPC endpoint
    // You can get free API keys from:
    // - Infura: https://infura.io
    // - Alchemy: https://alchemy.com
    
    // Uncomment when EthereumKit is added to your project:
    /*
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
    */
}

/// Example: Check USDC balance for wallet
func checkUSDCBalance(walletAddress: String) async {
    // Uncomment when EthereumKit is added:
    /*
    let config = NetworkConfig.polygon // Using Polygon network
    let service = EthereumService(rpcURL: config.rpcURL)
    
    do {
        if let usdcAddress = config.usdcAddress {
            let balance = try await service.getUSDCBalance(
                address: walletAddress,
                usdcContractAddress: usdcAddress
            )
            print("USDC Balance: \(balance)")
        }
    } catch {
        print("Error fetching balance: \(error)")
    }
    */
}

/// Example: Monitor transaction status
func monitorTransaction(txHash: String) async {
    // Uncomment when EthereumKit is added:
    /*
    let service = EthereumService(rpcURL: "YOUR_RPC_URL")
    
    // Poll for transaction receipt
    for _ in 0..<60 { // Try for 60 iterations
        do {
            let receipt = try await service.getTransactionReceipt(txHash: txHash)
            if case .object(let obj) = receipt {
                if let status = obj["status"] {
                    print("Transaction completed with status: \(status)")
                    return
                }
            }
        } catch {
            print("Receipt not available yet...")
        }
        
        // Wait 2 seconds before trying again
        try? await Task.sleep(nanoseconds: 2_000_000_000)
    }
    
    print("Transaction monitoring timeout")
    */
}

/// Example: Get gas estimate for USDC transfer
func estimateUSDCTransferGas(from: String, to: String, amount: String, contractAddress: String) async {
    // Uncomment when EthereumKit is added:
    /*
    let service = EthereumService(rpcURL: "YOUR_RPC_URL")
    
    // ERC-20 transfer function: transfer(address,uint256)
    let functionSelector = "0xa9059cbb" // transfer(address,uint256)
    let paddedTo = HexUtils.padAddress(to)
    let paddedAmount = HexUtils.padHex(amount, toLength: 64)
    let data = functionSelector + paddedTo + paddedAmount
    
    do {
        let gas = try await service.estimateGas(to: contractAddress, data: data, from: from)
        print("Estimated gas: \(gas)")
        
        let gasPrice = try await service.getGasPriceInGwei()
        print("Gas price: \(gasPrice) Gwei")
        
        let cost = Double(gas) * gasPrice / 1_000_000_000 // Convert to ETH
        print("Estimated cost: \(cost) ETH")
    } catch {
        print("Error estimating gas: \(error)")
    }
    */
}

// MARK: - Integration Notes

/*
 To use EthereumKit in your iMessage app:
 
 1. Add EthereumKit as a package dependency:
    - In Xcode: File → Add Package Dependencies
    - Enter: /path/to/EthereumKit or your git URL
    
 2. Import it in your files:
    import EthereumKit
    
 3. Initialize the service:
    let service = EthereumService(rpcURL: "YOUR_RPC_URL")
    
 4. Use it in your wallet operations:
    - Check balances
    - Estimate gas costs
    - Monitor transactions
    - Read contract data
    
 5. For iMessage integration:
    - Store transaction data in MSMessage URLs
    - Use the Transaction struct for encoding/decoding
    - Display balances and transaction history in your UI
 */
