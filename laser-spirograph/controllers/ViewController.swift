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
    
    private var functions = [LSCircle]()
    private var elapsedTime: TimeInterval { Date().timeIntervalSince(startTime) }
    
    private lazy var startTime = Date()
    
    private static let refreshRate: Double = 1 / 24
    private static let maxRotationsPerSecond: Float = 16
    
    // MARK: Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0..<4 {
            functions.append(LSCircle())
        }
        
        canvas.parametricFunction = LSFunctionComposer(functions)
        
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
        functions[index].setRotationsPerSecond(Double(value), t: elapsedTime)
    }
}
