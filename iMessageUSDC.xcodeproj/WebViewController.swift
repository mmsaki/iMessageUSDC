//
//  WebViewController.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/7/26.
//

import UIKit
import WebKit

/// A reusable web view controller for displaying web content in the iMessage extension
final class WebViewController: UIViewController {
    
    // MARK: - Properties
    
    private var webView: WKWebView!
    private let url: URL
    private let showsToolbar: Bool
    
    // Toolbar items
    private var backButton: UIBarButtonItem!
    private var forwardButton: UIBarButtonItem!
    private var refreshButton: UIBarButtonItem!
    private var safariButton: UIBarButtonItem!
    
    // MARK: - Initialization
    
    init(url: URL, showsToolbar: Bool = true) {
        self.url = url
        self.showsToolbar = showsToolbar
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupToolbar()
        loadURL()
    }
    
    // MARK: - Setup
    
    private func setupWebView() {
        view.backgroundColor = .systemBackground
        
        // Configure web view
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Add loading indicator
        activityIndicator.style = .medium
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Observe loading state
        observeWebViewLoading()
    }
    
    private let activityIndicator = UIActivityIndicatorView()
    
    private func observeWebViewLoading() {
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.isLoading) {
            if webView.isLoading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        } else if keyPath == #keyPath(WKWebView.canGoBack) || keyPath == #keyPath(WKWebView.canGoForward) {
            updateNavigationButtons()
        }
    }
    
    deinit {
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.isLoading))
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
    }
    
    private func setupToolbar() {
        guard showsToolbar else { return }
        
        // Create toolbar buttons
        backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
        backButton.isEnabled = false
        
        forwardButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.right"),
            style: .plain,
            target: self,
            action: #selector(goForward)
        )
        forwardButton.isEnabled = false
        
        refreshButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refresh)
        )
        
        safariButton = UIBarButtonItem(
            image: UIImage(systemName: "safari"),
            style: .plain,
            target: self,
            action: #selector(openInSafari)
        )
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissWebView)
        )
        
        // Set up navigation bar
        navigationItem.rightBarButtonItem = doneButton
        
        // Set up toolbar
        setToolbarItems([
            backButton,
            flexibleSpace,
            forwardButton,
            flexibleSpace,
            refreshButton,
            flexibleSpace,
            safariButton
        ], animated: false)
        
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    private func loadURL() {
        let request = URLRequest(url: url)
        webView.load(request)
        
        // Update navigation title with domain
        if let host = url.host {
            title = host
        }
    }
    
    // MARK: - Actions
    
    @objc private func goBack() {
        webView.goBack()
    }
    
    @objc private func goForward() {
        webView.goForward()
    }
    
    @objc private func refresh() {
        webView.reload()
    }
    
    @objc private func openInSafari() {
        // Show alert with URL that user can copy
        let alert = UIAlertController(
            title: "Open in Safari",
            message: "Copy this URL to open in Safari:\n\n\(webView.url?.absoluteString ?? url.absoluteString)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Copy URL", style: .default) { [weak self] _ in
            UIPasteboard.general.string = self?.webView.url?.absoluteString ?? self?.url.absoluteString
            
            // Show confirmation
            let confirmAlert = UIAlertController(
                title: "✓ Copied",
                message: "URL copied to clipboard",
                preferredStyle: .alert
            )
            self?.present(confirmAlert, animated: true)
            
            // Auto-dismiss after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                confirmAlert.dismiss(animated: true)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func dismissWebView() {
        dismiss(animated: true)
    }
    
    // MARK: - Navigation Updates
    
    private func updateNavigationButtons() {
        backButton?.isEnabled = webView.canGoBack
        forwardButton?.isEnabled = webView.canGoForward
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateNavigationButtons()
        
        // Update title with page title
        if let pageTitle = webView.title, !pageTitle.isEmpty {
            title = pageTitle
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ Web view failed to load: \(error.localizedDescription)")
        
        let alert = UIAlertController(
            title: "Failed to Load",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        // Allow all navigation by default
        // You can add custom URL scheme handling here if needed
        decisionHandler(.allow)
    }
}

// MARK: - Preview

#if DEBUG
import SwiftUI

struct WebViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIKitPreview {
            let webVC = WebViewController(url: URL(string: "https://etherscan.io")!)
            return UINavigationController(rootViewController: webVC)
        }
        .previewDevice("iPhone 15 Pro")
    }
}
#endif
