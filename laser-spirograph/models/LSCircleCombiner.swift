//
//  LSCircleCombiner.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/11/20.
//

import Foundation

class LSCircleCombiner {
    
    // MARK: Properties
    
    let circles: [LSCircle]
    
    // MARK: Initialization
    
    init?(radii: [Double]) {
        guard (radii.count > 1) && radii.allSatisfy({ $0 > 0 }) else { return nil }
        circles = radii.map() { LSCircle(radius: $0) }
    }
}

// MARK: Parameterizable

extension LSCircleCombiner: Parameterizable {
    
    func getPoint(t: Double) -> (x: Double, y: Double) {
        var (x, y) = (0.0, 0.0)

        for (i, circle) in circles.enumerated() {
            let point = circle.getPoint(t: t)
            let isEven = (i % 2 == 0)
            x += isEven ? point.x : point.y
            y += isEven ? point.y : point.x
        }

        return (x, y)
    }
    
    func isConstant() -> Bool { circles.allSatisfy() { $0.isConstant() } }
}
