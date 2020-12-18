//
//  ViewController.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/1/20.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK: Properties
    
    var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var canvas: LSCanvas!
    @IBOutlet weak var multisliderView: LSMultisliderView!
    
    private var spiralController: LSSpiralController!
    
    private static let refreshRate: Double = 1 / 24
    private static let maxRotationsPerSecond: Float = pow(2, 7)
    
    // MARK: Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spiralController = LSSpiralController(refreshRate: Self.refreshRate)
        spiralController.canvas = canvas
        
        multisliderView.maxValue = Self.maxRotationsPerSecond
        multisliderView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "PresentSpiralsTableViewController" {
            return managedObjectContext != nil
        }
        
        return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let navigationController = segue.destination as? UINavigationController else { return }
        
        if let spiralsTVC = navigationController.topViewController as? SpiralsTableViewController {
            spiralsTVC.managedObjectContext = managedObjectContext
            spiralsTVC.delegate = self
        }
    }
    
    // MARK: Color picking
    
    @IBAction func colorPickerButtonPressed(_ sender: Any) {
        print("color")
    }
    
    // MARK: Saving
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let context = managedObjectContext else {
            let alert = UIAlertController.okAlert(title: "Failed to save spiral", message: "Couldn't connect to database")
            present(alert, animated: true)
            return
        }
        
        if let error = spiralController.getParameterSet(context).save() {
            let alert = UIAlertController.okAlert(title: "Failed to save spiral", message: error.localizedDescription)
            self.present(alert, animated: true)
        }
    }
    
    // MARK: Loading
    
    private func load(_ parameterSet: LSParameterSet) {
        multisliderView.setValues(parameterSet.rotationsPerSeconds)
        spiralController.loadParameterSet(parameterSet)
    }
}

// MARK: LSMultisliderViewDelegate

extension ViewController: LSMultisliderViewDelegate {
    
    func multisliderView(_ sender: LSMultisliderView, didChange value: Float, at index: Int) {
        spiralController.updateCircleSpeed(Double(value), at: index)
    }
}

// MARK: SpiralsTableViewControllerDelegate

extension ViewController: SpiralsTableViewControllerDelegate {
    
    func spiralsTableViewController(_ sender: SpiralsTableViewController, didSelect parameterSet: LSParameterSet) {
        load(parameterSet)
    }
}
