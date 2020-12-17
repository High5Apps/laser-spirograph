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
    
    override var prefersStatusBarHidden: Bool { true }
    
    @IBOutlet weak var canvas: LSCanvas!
    @IBOutlet weak var multisliderView: LSMultisliderView!
    
    private var circleCombiner = LSCircleCombiner(radii: radii)!
    private var elapsedTime: TimeInterval { Date().timeIntervalSince(startTime) }
    
    private lazy var startTime = Date()
    
    private static let refreshRate: Double = 1 / 24
    private static let maxRotationsPerSecond: Float = pow(2, 7)
    private static let radii = [0.4, 0.1, 0.3, 0.2] // These should sum to 1 to span the canvas
    private static let persistenceOfVision: TimeInterval = 1 / 16
    private static let stepCount: Int = 256
    
    // MARK: Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvas.parametricFunction = circleCombiner
        
        multisliderView.maxValue = Self.maxRotationsPerSecond
        multisliderView.delegate = self
                
        Timer.scheduledTimer(withTimeInterval: Self.refreshRate, repeats: true) { (_) in
            let currentTime = self.elapsedTime
            self.canvas.draw(startTime: currentTime - Self.persistenceOfVision, endTime: currentTime, stepCount: Self.stepCount)
        }
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
        
        let endTime = elapsedTime
        let startTime = endTime - Self.persistenceOfVision
        let rotationsPerSeconds = circleCombiner.circles.map() { $0.rotationsPerSecond }
        let phases = circleCombiner.circles.map() { $0.phase }
        
        let parameterSet = LSParameterSet(context: context, startTime: startTime, endTime: endTime, rotationsPerSeconds: rotationsPerSeconds, phases: phases)
        parameterSet.save() { (error) in
            let alert = UIAlertController.okAlert(title: "Failed to save spiral", message: error.localizedDescription)
            self.present(alert, animated: true)
        }
    }
}

// MARK: LSMultisliderViewDelegate

extension ViewController: LSMultisliderViewDelegate {
    
    func multisliderView(_ sender: LSMultisliderView, didChange value: Float, at index: Int) {
        circleCombiner.circles[index].setRotationsPerSecond(Double(value), t: elapsedTime)
    }
}
