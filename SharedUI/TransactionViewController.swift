//
//  TransactionViewController.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/7/26.
//

import UIKit

class TransactionViewController: UIViewController {
    
    enum CollectionViewItem {
        case transaction(Transaction)
        case createTransaction
    }
    
    static let storyboardIdentifier = "TransactionViewController"
    weak var delegate: TransactionViewControllerDelegate?
    private var items: [CollectionViewItem] = []
    private let transactionCache: TransactionViewCache
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    // MARK: - Initialization
    
    init() {
        self.transactionCache = TransactionViewCache.cache
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.transactionCache = TransactionViewCache.cache
        super.init(coder: aDecoder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadTransactions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload transactions when view appears (in case new ones were added)
        loadTransactions()
    }
    
    // MARK: - Setup
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Register cell types
        collectionView.register(TransactionCell.self, forCellWithReuseIdentifier: TransactionCell.reuseIdentifier)
        collectionView.register(CreateTransactionCell.self, forCellWithReuseIdentifier: CreateTransactionCell.reuseIdentifier)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    // MARK: - Data Loading
    
    private func loadTransactions() {
        // Load transaction history
        let history = TransactionHistory.load()
        
        // Create items array with "Create New" button at the top
        var newItems: [CollectionViewItem] = [.createTransaction]
        newItems.append(contentsOf: history.reversed().map { .transaction($0) })
        
        items = newItems
        collectionView.reloadData()
    }
    
}

// MARK: - UICollectionViewDataSource

extension TransactionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.item]
        
        switch item {
        case .createTransaction:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CreateTransactionCell.reuseIdentifier,
                for: indexPath
            ) as! CreateTransactionCell
            return cell
            
        case .transaction(let transaction):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TransactionCell.reuseIdentifier,
                for: indexPath
            ) as! TransactionCell
            cell.configure(with: transaction)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension TransactionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        
        switch item {
        case .createTransaction:
            delegate?.transactionViewControllerDidRequestCreateTransaction(self)
            
        case .transaction(let transaction):
            // User tapped an existing transaction - could show details or re-send
            print("Selected transaction: \(transaction)")
            // For now, we'll just deselect. You could show a detail view here.
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}

// MARK: - Delegate Protocol

protocol TransactionViewControllerDelegate: AnyObject {
    func transactionViewControllerDidRequestCreateTransaction(_ viewController: TransactionViewController)
}

// MARK: - Collection View Cells

class CreateTransactionCell: UICollectionViewCell {
    static let reuseIdentifier = "CreateTransactionCell"
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.text = "+"
        label.font = .systemFont(ofSize: 32, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Send USDC"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create a new transaction"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        
        contentView.addSubview(iconLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
}

class TransactionCell: UICollectionViewCell {
    static let reuseIdentifier = "TransactionCell"
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let routeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .systemGreen
        label.text = "✓ Sent"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 12
        
        contentView.addSubview(amountLabel)
        contentView.addSubview(routeLabel)
        contentView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            amountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            amountLabel.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -12),
            amountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            
            routeLabel.leadingAnchor.constraint(equalTo: amountLabel.leadingAnchor),
            routeLabel.trailingAnchor.constraint(equalTo: amountLabel.trailingAnchor),
            routeLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 4),
            routeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with transaction: Transaction) {
        // Format amount and token
        let amount = transaction.amount?.rawValue ?? "?"
        let token = transaction.token?.rawValue ?? "?"
        amountLabel.text = "\(amount) \(token)"
        
        // Format route
        let from = transaction.fromChain?.rawValue ?? "?"
        let to = transaction.toChain?.rawValue ?? "?"
        routeLabel.text = "\(from) → \(to)"
        
        // Status (all completed transactions)
        statusLabel.text = "✓ Sent"
        statusLabel.textColor = .systemGreen
    }
}


class TransactionViewCache {
    static let cache = TransactionViewCache()
    private let cacheURL: URL
    private let queue = OperationQueue()
    let placeholderTransaction: Transaction
    
    private init() {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheURL = urls.first!.appendingPathComponent("iMessageUSDC.transactions.plist")
        
        // Initialize placeholder transaction
        placeholderTransaction = Transaction()
    }
    
    deinit {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: cacheURL)
        } catch {
            assertionFailure("Failed to remove old cache file at \(cacheURL)")
        }
    }
    
    func transactions(completion: @escaping ([Transaction]) throws -> Void) {
        queue.addOperation {
            let fileManager = FileManager.default
            var cachedTransactions: [Transaction] = []
            
            if fileManager.fileExists(atPath: self.cacheURL.path) {
                do {
                    let data = try Data(contentsOf: self.cacheURL)
                    cachedTransactions = try PropertyListDecoder().decode([Transaction].self, from: data)
                } catch {
                    assertionFailure("Failed to decode cached transactions from \(self.cacheURL): \(error)")
                }
            }
            
            // Call completion with cached transactions
            try? completion(cachedTransactions)
        }
    }
}
// MARK: - SwiftUI Preview Support

#if DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct TransactionViewControllerPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> TransactionViewController {
        return TransactionViewController()
    }
    
    func updateUIViewController(_ uiViewController: TransactionViewController, context: Context) {
        // Updates handled automatically
    }
}

@available(iOS 13.0, *)
struct TransactionViewController_Previews: PreviewProvider {
    static var previews: some View {
        TransactionViewControllerPreview()
            .edgesIgnoringSafeArea(.all)
    }
}
#endif

