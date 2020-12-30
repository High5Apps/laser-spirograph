//
//  SpiralsTableViewController.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/16/20.
//

import UIKit
import CoreData

protocol SpiralsTableViewControllerDelegate: AnyObject {
    func spiralsTableViewController(_ sender: SpiralsTableViewController, didSelect parameterSet: LSParameterSet)
}

class SpiralsTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var managedObjectContext: NSManagedObjectContext!
    
    weak var delegate: SpiralsTableViewControllerDelegate?
        
    private var parameterSets = [LSParameterSet]()
    private var selectedAccessoryIndex: Int?
    
    // MARK: Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView() // Hides empty rows
        addEmptyView()
        
        parameterSets = LSParameterSet.fetchAllByRecency(context: managedObjectContext)

        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    private func addEmptyView() {
        let attributedString = NSMutableAttributedString(string: "You don't have any saved spirals. To save a spiral, tap Cancel and then tap ")
        let image = UIImage(systemName: "square.and.arrow.down")!
        attributedString.append(NSAttributedString(attachment: NSTextAttachment(image: image)))
        
        let label = UILabel()
        label.attributedText = attributedString
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.numberOfLines = 0
        tableView.backgroundView = label
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let navigationController = segue.destination as? UINavigationController else { return }
        
        if let spiralDetailVC = navigationController.topViewController as? SpiralDetailViewController, let selectedAccessoryIndex = selectedAccessoryIndex {
            spiralDetailVC.parameterSet = parameterSets[selectedAccessoryIndex]
            spiralDetailVC.delegate = self
            self.selectedAccessoryIndex = nil
        }
    }

    // MARK: Data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = parameterSets.count
        tableView.backgroundView?.isHidden = (count > 0)
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParameterSetCell", for: indexPath) as! LSParameterSetCell
        cell.parameterSet = parameterSets[indexPath.row]
        return cell
    }
    
    // MARK: Selection
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parameterSet = parameterSets[indexPath.row]
        delegate?.spiralsTableViewController(self, didSelect: parameterSet)
        presentingViewController?.dismiss(animated: true)
    }
    
    // Showing details
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        selectedAccessoryIndex = indexPath.row
        performSegue(withIdentifier: "PresentSpiralDetailViewController", sender: self)
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
        presentingViewController?.dismiss(animated: true)
    }
}

// MARK: SpiralDetailViewControllerDelegate

extension SpiralsTableViewController: SpiralDetailViewControllerDelegate {
    
    func spiralDetailViewController(_ sender: SpiralDetailViewController, didUpdate parameterSet: LSParameterSet) {
        guard let index = parameterSets.firstIndex(of: parameterSet) else { return }
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}
