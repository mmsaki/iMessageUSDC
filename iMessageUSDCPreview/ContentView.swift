//
//  ContentView.swift
//  iMessageUSDCPreview
//
//  Created by Meek Msaki on 2/6/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        UIKitPreview {
            UINavigationController(rootViewController: OldWalletViewController())
        }
        .edgesIgnoringSafeArea(.all)
        UIKitPreview {
            UINavigationController(rootViewController: PrivyAuthViewController())
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
