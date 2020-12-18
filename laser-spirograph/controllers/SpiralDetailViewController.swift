//
//  SpiralDetailViewController.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/18/20.
//

import UIKit

class SpiralDetailViewController: UIViewController {
    
    // MARK: Properties
    
    var parameterSet: LSParameterSet!
    
    @IBOutlet weak var canvas: LSCanvas!
    
    private var spiralController: LSSpiralController!

    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .green
        
        spiralController = LSSpiralController()
        spiralController.canvas = canvas
        
        load(parameterSet)
    }
    
    private func load(_ parameterSet: LSParameterSet) {
        title = parameterSet.displayName
        spiralController.loadParameterSet(parameterSet)
    }
    
    // MARK: Dismissing
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
