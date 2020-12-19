//
//  UIViewController+KeyboardEvents.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/18/20.
//

import UIKit

extension UIViewController {
    
    func adjustScrollViewOnKeyboardEvents(_ scrollView: UIScrollView) {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (_) in
            scrollView.contentInset = .zero
            scrollView.scrollIndicatorInsets = scrollView.contentInset
        }
        
        notificationCenter.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil) { (notification) in
            guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            let keyboardScreenEndFrame = keyboardValue.cgRectValue
            let keyboardViewEndFrame = self.view.convert(keyboardScreenEndFrame, from: self.view.window)
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - self.view.safeAreaInsets.bottom + 8, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            scrollView.flashScrollIndicators()
        }
    }
}
