//
//  UIKitPreview.swift
//  iMessageUSDC
//
//  Created by Meek Msaki on 2/6/26.
//

#if DEBUG
import SwiftUI
import UIKit

struct UIKitPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let builder: () -> ViewController
    
    init(builder: @escaping () -> UIViewController) {
        self.builder = builder as! () -> ViewController
    }
    func makeUIViewController(context: Context) -> UIViewController {
        builder()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
}
#endif
