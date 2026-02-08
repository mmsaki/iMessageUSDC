//
//  JSONRPCClient.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/7/26.
//

import Foundation

// MARK: - JSON-RPC Types

/// Represents a JSON-RPC 2.0 request
struct JSONRPCRequest: Codable {
    let jsonrpc: String = "2.0"
    let id: Int
    let method: String
    let params: [JSONValue]
    
    init(id: Int = 1, method: String, params: [JSONValue] = []) {
        self.id = id
        self.method = method
        self.params = params
    }
}

/// Represents a JSON-RPC 2.0 response
struct JSONRPCResponse<T: Codable>: Codable {
    let jsonrpc: String
    let id: Int
    let result: T?
    let error: JSONRPCError?
    
    var isSuccess: Bool {
        error == nil && result != nil
    }
}

/// Represents a JSON-RPC error
struct JSONRPCError: Codable, Error {
    let code: Int
    let message: String
    let data: JSONValue?
}

/// A flexible JSON value type for encoding/decoding dynamic JSON
enum JSONValue: Codable, Equatable {
    case string(String)
    case number(Double)
    case int(Int)
    case bool(Bool)
    case null
    case array([JSONValue])
    case object([String: JSONValue])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .number(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([JSONValue].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: JSONValue].self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unable to decode JSONValue"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        case .array(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        }
    }
}

// MARK: - JSONValue Convenience Extensions

extension JSONValue: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension JSONValue: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension JSONValue: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension JSONValue: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: JSONValue...) {
        self = .array(elements)
    }
}

extension JSONValue: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (String, JSONValue)...) {
        self = .object(Dictionary(uniqueKeysWithValues: elements))
    }
}

// MARK: - JSON-RPC Client

/// A simple async/await JSON-RPC client for Ethereum interactions
actor JSONRPCClient {
    let rpcURL: URL
    let session: URLSession
    private var requestID: Int = 0
    
    init(rpcURL: URL, session: URLSession = .shared) {
        self.rpcURL = rpcURL
        self.session = session
    }
    
    /// Convenience initializer with string URL
    init?(rpcURLString: String, session: URLSession = .shared) {
        guard let url = URL(string: rpcURLString) else { return nil }
        self.rpcURL = url
        self.session = session
    }
    
    /// Generate next request ID
    private func nextRequestID() -> Int {
        requestID += 1
        return requestID
    }
    
    /// Make a JSON-RPC call and return the raw string result
    func call(method: String, params: [JSONValue] = []) async throws -> String {
        let response: JSONRPCResponse<String> = try await callRPC(method: method, params: params)
        
        if let error = response.error {
            throw error
        }
        
        guard let result = response.result else {
            throw JSONRPCClientError.noResult
        }
        
        return result
    }
    
    /// Make a JSON-RPC call with a typed result
    func call<T: Codable>(method: String, params: [JSONValue] = []) async throws -> T {
        let response: JSONRPCResponse<T> = try await callRPC(method: method, params: params)
        
        if let error = response.error {
            throw error
        }
        
        guard let result = response.result else {
            throw JSONRPCClientError.noResult
        }
        
        return result
    }
    
    /// Internal method to make the actual RPC call
    private func callRPC<T: Codable>(method: String, params: [JSONValue]) async throws -> JSONRPCResponse<T> {
        let request = JSONRPCRequest(id: nextRequestID(), method: method, params: params)
        
        var urlRequest = URLRequest(url: rpcURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, urlResponse) = try await session.data(for: urlRequest)
        
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw JSONRPCClientError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw JSONRPCClientError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let response = try JSONDecoder().decode(JSONRPCResponse<T>.self, from: data)
        return response
    }
}

// MARK: - Errors

enum JSONRPCClientError: Error, LocalizedError {
    case invalidResponse
    case noResult
    case httpError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .noResult:
            return "No result in response"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        }
    }
}

// MARK: - Common Ethereum Methods

extension JSONRPCClient {
    /// Get the current block number
    func eth_blockNumber() async throws -> String {
        try await call(method: "eth_blockNumber", params: [])
    }
    
    /// Get the balance of an address at a given block
    func eth_getBalance(address: String, block: String = "latest") async throws -> String {
        try await call(method: "eth_getBalance", params: [.string(address), .string(block)])
    }
    
    /// Get the current gas price
    func eth_gasPrice() async throws -> String {
        try await call(method: "eth_gasPrice", params: [])
    }
    
    /// Call a contract method (read-only)
    func eth_call(to: String, data: String, block: String = "latest") async throws -> String {
        let params: [JSONValue] = [
            .object([
                "to": .string(to),
                "data": .string(data)
            ]),
            .string(block)
        ]
        return try await call(method: "eth_call", params: params)
    }
    
    /// Get transaction count (nonce) for an address
    func eth_getTransactionCount(address: String, block: String = "latest") async throws -> String {
        try await call(method: "eth_getTransactionCount", params: [.string(address), .string(block)])
    }
    
    /// Send a raw signed transaction
    func eth_sendRawTransaction(signedTx: String) async throws -> String {
        try await call(method: "eth_sendRawTransaction", params: [.string(signedTx)])
    }
    
    /// Get transaction receipt
    func eth_getTransactionReceipt(txHash: String) async throws -> JSONValue {
        try await call(method: "eth_getTransactionReceipt", params: [.string(txHash)])
    }
    
    /// Estimate gas for a transaction
    func eth_estimateGas(to: String, data: String, from: String? = nil) async throws -> String {
        var txObject: [String: JSONValue] = [
            "to": .string(to),
            "data": .string(data)
        ]
        
        if let from = from {
            txObject["from"] = .string(from)
        }
        
        return try await call(method: "eth_estimateGas", params: [.object(txObject)])
    }
    
    /// Get the chain ID
    func eth_chainId() async throws -> String {
        try await call(method: "eth_chainId", params: [])
    }
}
