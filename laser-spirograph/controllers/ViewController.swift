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
    @IBOutlet weak var loadSpiralButton: LSCircleButton!
    
    private var spiralController = LSSpiralController()
    
    private static let maxRotationsPerSecond: Float = pow(2, 7)
    
    // MARK: Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spiralController.canvas = canvas
        spiralController.isAnimating = true
        
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
        
        willPresent(navigationController)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag) {
            completion?()
            self.didDismiss()
        }
    }
    
    // MARK: Saving
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let context = managedObjectContext else {
            let alert = UIAlertController.okAlert(title: "Failed to save spiral", message: "Couldn't connect to database")
            present(alert, animated: true)
            return
        }
        
        let parameterSet = spiralController.getParameterSet(context)
        if let error = parameterSet.save() {
            let alert = UIAlertController.okAlert(title: "Failed to save spiral", message: error.localizedDescription)
            self.present(alert, animated: true)
            return
        }
        
        spiralController.isAnimating = false
        showSaveAnimation(completion: {
            self.spiralController.loadParameterSet(parameterSet)
            self.spiralController.isAnimating = true
        })
    }
    
    private func showSaveAnimation(completion: @escaping () -> ()) {
        canvas.layer.cornerRadius = canvas.bounds.width / 2
        
        let previousBackgroundColor = canvas.backgroundColor
        canvas.backgroundColor = .secondarySystemFill
        
        UIView.animate(withDuration: 1) {
            self.canvas.transform = self.getTransform(from: self.canvas, to: self.loadSpiralButton)
        } completion: { (finished) in
            self.canvas.layer.cornerRadius = 0
            self.canvas.backgroundColor = previousBackgroundColor
            self.canvas.transform = .identity
            completion()
        }
    }
    
    private func getTransform(from start: UIView, to destination: UIView) -> CGAffineTransform {
        let scaleX = destination.bounds.width / start.bounds.width
        let scaleY = destination.bounds.height / start.bounds.height
        let scaleTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        let destinationMiddle = CGPoint(x: destination.bounds.midX, y: destination.bounds.midY)
        let convertedCenter = destination.convert(destinationMiddle, to: start)
        let centerDeltaX = convertedCenter.x - start.center.x
        let centerDeltaY = convertedCenter.y - start.center.y
        let translationTransform = CGAffineTransform(translationX: centerDeltaX, y: centerDeltaY)
        
        return scaleTransform.concatenating(translationTransform)
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

// MARK: UIAdaptivePresentationControllerDelegate

extension ViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        didDismiss()
    }
    
    private func willPresent(_ navigationController: UINavigationController) {
        navigationController.presentationController?.delegate = self
        spiralController.isAnimating = false
    }
    
    private func didDismiss() {
        guard presentedViewController == nil else { return }
        spiralController.isAnimating = true
    }
}
