//
//  LSCircle.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/8/20.
//

import Foundation

class LSCircle {
    
    private var rotationalVelocity: Double = radiansPerCircle
    private var radius: Double = 1
    private var phase: Double = 0
    
    private static let radiansPerCircle: Double = 2 * .pi
    
    func setRotationalVelocity(_ newRotationalVelocity: Double, t: Double) {
        guard newRotationalVelocity != rotationalVelocity else { return }
        
        // Updating phase ensures that getPoint() returns the same value before and after update for the given value of t.
        // The new phase is found by solving the following equation for phi2:
        // r * cos(w1 * t + phi1) = r * cos(w2 * t + phi2)
        phase = ((rotationalVelocity - newRotationalVelocity) * t + phase).truncatingRemainder(dividingBy: Self.radiansPerCircle)
        
        rotationalVelocity = newRotationalVelocity
    }
}

extension LSCircle: Parameterizable {
    
    func getPoint(t: Double) -> (x: Double, y: Double) {
        let x = radius * cos(rotationalVelocity * t + phase)
        let y = radius * sin(rotationalVelocity * t + phase)
        
        return (x, y)
    }
}
