//
//  SettingsTableViewController.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 1/10/21.
//

import UIKit
import SafariServices
import CoreData

struct Setting {
    let title: String
    let systemImageName: String
    let accessoryType: UITableViewCell.AccessoryType
    let onClick: (UITableViewCell) -> ()
}

class SettingsTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var managedObjectContext: NSManagedObjectContext?
    
    private lazy var settings: [Int: [Setting]] = [
        0: [
            Setting(
                title: "Color",
                systemImageName: "paintpalette",
                accessoryType: .disclosureIndicator,
                onClick: { (_) in
                    self.performSegue(withIdentifier: "ShowSpiralColorViewController", sender: self)
                })
        ],
        1: [
            Setting(
                title: "Contact Us",
                systemImageName: "message",
                accessoryType: .none,
                onClick: { (_) in
                    let subject = "Spiralize iOS Feedback"
                    EmailComposer.show(from: self, with: subject)
            }),
            Setting(
                title: "Report a Bug",
                systemImageName: "ant",
                accessoryType: .none,
                onClick: { (_) in
                    EmailComposer.showBugReport(from: self)
            }),
        ],
        2: [
            Setting(
                title: "Privacy Policy",
                systemImageName: "doc",
                accessoryType: .none,
                onClick: { (_) in
                    self.presentBrowser(at: Self.privacyPolicyUrl)
            }),
            Setting(
                title: "Source Code",
                systemImageName: "chevron.left.slash.chevron.right",
                accessoryType: .none,
                onClick: { (_) in
                    self.presentBrowser(at: Self.sourceCodeUrl)
            }),
        ],
    ]
    
    private static let sourceCodeUrl = URL(string: "https://github.com/High5Apps/laser-spirograph")!
    private static let privacyPolicyUrl = URL(string: "https://docs.google.com/document/d/16mbLSRJBjWGRGmZbMlCLgX2mozD2ukCKVFeqARRFtWc/edit?usp=sharing")!
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView() // Hides empty rows
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let spiralColorVC = segue.destination as? SpiralColorViewController {
            spiralColorVC.managedObjectContext = managedObjectContext
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settings[section]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        
        if let setting = settings[indexPath.section]?[indexPath.row] {
            cell.imageView?.image = UIImage(systemName: setting.systemImageName)
            cell.textLabel?.text = setting.title
            cell.accessoryType = setting.accessoryType
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Spiral"
        case 1:
            return "Communication"
        case 2:
            return "About"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let setting = settings[indexPath.section]?[indexPath.row], let cell = tableView.cellForRow(at: indexPath) else { return }
        setting.onClick(cell)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Dismissing
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        presentingViewController?.dismiss(animated: true)
    }
    
    // MARK: Web browsing
    
    private func presentBrowser(at url: URL) {
        let browser = SFSafariViewController(url: url)
        browser.preferredControlTintColor = self.view.window?.tintColor
        self.present(browser, animated: true)
    }
}
