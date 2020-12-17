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
//        navigationItem.leftBarButtonItem = editButtonItem
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

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    
    // MARK: Canceling
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
