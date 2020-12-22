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
    @IBOutlet weak var parameterStepperContainer: LSParameterStepperContainer!
    
    private var spiralController = LSSpiralController()

    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .green
        
        spiralController.canvas = canvas
        
        nameField.delegate = self
        nameField.tintColor = .green
        adjustScrollViewOnKeyboardEvents(scrollView)
        
        parameterStepperContainer.addParameterStepper(name: "Start", step: 0.01, precision: 2)
        parameterStepperContainer.addParameterStepper(name: "Span", step: 0.0005, precision: 4)
        parameterStepperContainer.delegate = self
        
        load(parameterSet)
    }
    
    private func load(_ parameterSet: LSParameterSet) {
        title = parameterSet.displayName
        spiralController.loadParameterSet(parameterSet)
        nameField.text = parameterSet.name
        parameterStepperContainer.setValue(parameterSet.startTime, at: 0)
        parameterStepperContainer.setValue(parameterSet.endTime - parameterSet.startTime, at: 1)
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
    
    // MARK: Sharing
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        guard let image = spiralController.getImage() else { return }
        let items = [image]
        let shareController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(shareController, animated: true)
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

// MARK: LSParameterStepperContainerDelegate

extension SpiralDetailViewController: LSParameterStepperContainerDelegate {
    
    func parameterStepperContainer(_ sender: LSParameterStepperContainer, didChange value: Double, at index: Int) {
        switch index {
        case 0:
            let span = parameterSet.endTime - parameterSet.startTime
            parameterSet.startTime = value
            parameterSet.endTime = value + span
        case 1:
            parameterSet.endTime = parameterSet.startTime + value
        default:
            fatalError("You must handle the new parameter stepper value change")
        }
        
        if let error = parameterSet.save() {
            let alert = UIAlertController.okAlert(title: "Failed to update spiral", message: error.localizedDescription)
            present(alert, animated: true)
            parameterSet.managedObjectContext?.rollback()
            load(parameterSet)
            return
        }
        
        spiralController.loadParameterSet(parameterSet)
        delegate?.spiralDetailViewController(self, didUpdate: parameterSet)
    }
}
