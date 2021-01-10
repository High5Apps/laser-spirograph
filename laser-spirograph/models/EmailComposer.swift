//
//  EmailComposer.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 1/10/21.
//

import Foundation
import MessageUI

class EmailComposer {
    
    // MARK: Properties
    
    private static let supportEmail = "high5apps@gmail.com"
    private static let bugReportBody =
"""
Please tell us as much as you can remember. Thanks!
<ul>
<li>What were you doing in the app right before the bug happened?</li>
</ul>
</br>
<ul>
<li>What did you expect to happen?</li>
</ul>
</br>
<ul>
<li>What actually happened?</li>
</ul>
</br>
"""
    
    // MARK: Showing
    
    static func show(from viewController: UIViewController, with subject: String, htmlBody: String? = nil) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.setToRecipients([supportEmail])
            mailComposer.setSubject(subject)
            if let htmlBody = htmlBody {
                mailComposer.setMessageBody(htmlBody, isHTML: true)
            }
            viewController.present(mailComposer, animated: true)
        } else {
            let alert = UIAlertController.okAlert(title: "You haven't set up your iPhone's email yet.", message: "But feel free to email us any time at \(supportEmail)")
            viewController.present(alert, animated: true)
        }
    }
    
    static func showBugReport(from viewController: UIViewController) {
        let subject = "Spiralize iOS Bug Report"
        show(from: viewController, with: subject, htmlBody: bugReportBody)
    }
}
