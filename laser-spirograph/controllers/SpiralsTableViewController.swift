//
//  SpiralsTableViewController.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/16/20.
//

import UIKit
import CoreData

class SpiralsTableViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
        
    private var parameterSets = [LSParameterSet]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        parameterSets = LSParameterSet.fetchAllByRecency(context: managedObjectContext)

        navigationController?.navigationBar.tintColor = .green
        navigationItem.leftBarButtonItem = editButtonItem
    }

    // MARK: Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parameterSets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParameterSetCell", for: indexPath)

        cell.textLabel?.text = parameterSets[indexPath.row].displayName

        return cell
    }

    // MARK: Editing
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let parameterSet = parameterSets[indexPath.row]
        
        if let error = parameterSet.delete() {
            let alert = UIAlertController.okAlert(title: "Failed to delete spiral", message: error.localizedDescription)
            self.present(alert, animated: true)
        } else {
            parameterSets.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: Canceling
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
