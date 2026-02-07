//
//  PrivyAuthViewController.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/6/26.
//

import UIKit
import WebKit

final class PrivyAuthViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
        webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        loadPrivy()
    }
    private func loadPrivy() {
        let url = URL(string: "https://privy-wallet.asyncswap.workers.dev")!
        webView.load(URLRequest(url: url))
    }
}

extension PrivyAuthViewController {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let url = navigationAction.request.url, url.scheme == "msaki" {
            handleCallback(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    func handleCallback(_ url: URL) {
        // handle callback
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let walletAddress = components.queryItems?.first(where: { $0.name == "walletAddress" })?.value else {
            return
        }
        print("Privy wallet created: \(walletAddress)")
    }
}
#if DEBUG
import SwiftUI

struct PrivyAuthViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIKitPreview {
           UINavigationController(rootViewController: PrivyAuthViewController())
        }
    }
}
#endif
