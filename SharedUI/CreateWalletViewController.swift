//
//  Untitled.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/6/26.
//

import SwiftUI

struct CreateWalletView: View {
    @State private var amount: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                TokenButton(title: "USDC")
                Spacer()
                WalletButton()
            }
            Spacer()
            
            HStack(spacing: 6) {
                Text("$")
                    .font(.system(size: 56,weight: .bold))
                
                TextField("", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 56, weight: .bold))
                    .multilineTextAlignment(.center)
            }
            Spacer()
            
            HStack(spacing: 16) {
                ActionButton(title: "Request", style: .tinted)
                ActionButton(title: "Send", style: .filled)
            }
        }
    }
}

struct TokenButton: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .bold, design: .default))
            .padding(.horizontal, 12)
    }
}

struct WalletButton: View {
    
    var body: some View {
        Image(systemName: "wallet.pass")
            .font(.system(size: 18, weight: .bold))
            .frame(width: 36, height: 36)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
    }
    
}

enum ActionStyle {
    case filled, tinted
}

struct ActionButton: View {
    let title: String
    let style: ActionStyle
    var body: some View {
        Button(action: {}) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .padding(18)
                .background(background)
                .clipShape(Capsule())
        }
    }
    @ViewBuilder
    private var background: some View {
        switch style {
            case .filled:
            Color.accentColor.font(.body)
            case .tinted:
            Color.accentColor.opacity(0.15)
        }
    }
}

#Preview {
    CreateWalletView()
}
