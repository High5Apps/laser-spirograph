//
//  LSCircle.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/8/20.
//

import Foundation

class LSCircle {
    
    // MARK: Properties
    
    private var rotationsPerSecond: Double = 0
    private var phase: Double = 0
    
    private let radius: Double
    
    private static let radiansInCircle: Double = 2 * .pi
    
    // MARK: Initialization
    
    init(radius: Double) {
        self.radius = radius
    }
    
    // MARK: Rotational velocity updating
    
    func setRotationsPerSecond(_ newRotationsPerSecond: Double, t: Double) {
        guard newRotationsPerSecond != rotationsPerSecond else { return }
        
        // Updating phase ensures that getPoint() returns the same value before and after update for the given value of t.
        // The new phase is found by solving the following equation for phi2:
        // r * cos(w1 * t + phi1) = r * cos(w2 * t + phi2)
        phase = (Self.radiansInCircle * (rotationsPerSecond - newRotationsPerSecond) * t + phase).truncatingRemainder(dividingBy: Self.radiansInCircle)
        
        rotationsPerSecond = newRotationsPerSecond
    }
}

// MARK: Parameterizable

extension LSCircle: Parameterizable {
    
    func getPoint(t: Double) -> (x: Double, y: Double) {
        let x = radius * cos(Self.radiansInCircle * rotationsPerSecond * t + phase)
        let y = radius * sin(Self.radiansInCircle * rotationsPerSecond * t + phase)
        return (x, y)
    }
    
    func isConstant() -> Bool { rotationsPerSecond == 0 }
}
