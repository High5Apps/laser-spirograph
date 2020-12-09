//
//  ViewController.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/1/20.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var canvas: LSCanvas!
    
    private var function = LSCircle()
    
    private static let refreshRate: Double = 1 / 24

    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvas.parametricFunction = function
        
        let startTime = Date()
        
        Timer.scheduledTimer(withTimeInterval: Self.refreshRate, repeats: true) { (_) in
            let t = Date().timeIntervalSince(startTime)
            let newRotationsPerSecond = max(0, Double(Int(t) % 16) - 0.1)
            self.function.setRotationsPerSecond(newRotationsPerSecond, t: t)
            self.canvas.draw(time: t)
        }
    }
}

