//
//  UIAlertController+CommonAlerts.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/16/20.
//

import UIKit

extension UIAlertController {

    class func okAlert(title: String?, message: String?, completion: (() -> ())? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        return alert
    }
}
