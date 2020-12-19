//
//  SpiralDetailViewController.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/18/20.
//

import UIKit

protocol SpiralDetailViewControllerDelegate: AnyObject {
    func spiralDetailViewController(_ sender: SpiralDetailViewController, didUpdate parameterSet: LSParameterSet)
}

class SpiralDetailViewController: UIViewController {
    
    // MARK: Properties
    
    var parameterSet: LSParameterSet!
    
    weak var delegate: SpiralDetailViewControllerDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvas: LSCanvas!
    @IBOutlet weak var nameField: UITextField!
    
    private var spiralController: LSSpiralController!

    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .green
        
        spiralController = LSSpiralController()
        spiralController.canvas = canvas
        
        nameField.delegate = self
        nameField.tintColor = .green
        adjustScrollViewOnKeyboardEvents(scrollView)
        
        load(parameterSet)
    }
    
    private func load(_ parameterSet: LSParameterSet) {
        title = parameterSet.displayName
        spiralController.loadParameterSet(parameterSet)
        nameField.text = parameterSet.name
    }
    
    // MARK: Dismissing
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        updateName()
        dismiss(animated: true)
    }
    
    // MARK: Editing
    
    private func updateName() {
        let newName = nameField.text
        let name = (newName?.isEmpty ?? true) ? nil : newName
        
        let previousName = parameterSet.name
        parameterSet.name = name
        
        if let error = parameterSet.save() {
            parameterSet.name = previousName
            let alert = UIAlertController.okAlert(title: "Failed to save name", message: error.localizedDescription)
            present(alert, animated: true)
            return
        }
        
        title = parameterSet.displayName
        delegate?.spiralDetailViewController(self, didUpdate: parameterSet)
    }
}

// MARK: UITextFieldDelegate

extension SpiralDetailViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.scrollRectToVisible(textField.frame, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        updateName()
        return true
    }
}
