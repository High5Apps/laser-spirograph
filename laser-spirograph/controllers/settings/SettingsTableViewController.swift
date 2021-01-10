//
//  SettingsTableViewController.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 1/10/21.
//

import UIKit

struct Setting {
    let title: String
    let systemImageName: String
    let accessoryType: UITableViewCell.AccessoryType
    let onClick: (UITableViewCell) -> ()
}

class SettingsTableViewController: UITableViewController {
    
    // MARK: Properties
    
    private lazy var settings: [Int: [Setting]] = [
        0: [
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
    ]
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView() // Hides empty rows
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
            cell.imageView?.tintColor = .label
            cell.textLabel?.text = setting.title
            cell.accessoryType = setting.accessoryType
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let setting = settings[indexPath.section]?[indexPath.row], let cell = tableView.cellForRow(at: indexPath) else { return }
        setting.onClick(cell)
    }
    
    // MARK: Dismissing
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        presentingViewController?.dismiss(animated: true)
    }
}
