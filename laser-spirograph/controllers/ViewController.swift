//
//  ViewController.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/1/20.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var canvas: LSCanvas!
    @IBOutlet weak var multisliderView: LSMultisliderView!
    
    private var circleCombiner = LSCircleCombiner(radii: radii)!
    private var elapsedTime: TimeInterval { Date().timeIntervalSince(startTime) }
    
    private lazy var startTime = Date()
    
    private static let refreshRate: Double = 1 / 24
    private static let maxRotationsPerSecond: Float = pow(2, 7)
    private static let radii = [0.4, 0.1, 0.3, 0.2] // These should sum to 1 to span the canvas
    
    // MARK: Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvas.parametricFunction = circleCombiner
        
        multisliderView.maxValue = Self.maxRotationsPerSecond
        multisliderView.delegate = self
                
        Timer.scheduledTimer(withTimeInterval: Self.refreshRate, repeats: true) { (_) in
            self.canvas.draw(time: self.elapsedTime)
        }
    }
}

// MARK: LSMultisliderViewDelegate

extension ViewController: LSMultisliderViewDelegate {
    
    func multisliderView(_ sender: LSMultisliderView, didChange value: Float, at index: Int) {
        circleCombiner.circles[index].setRotationsPerSecond(Double(value), t: elapsedTime)
    }
}
