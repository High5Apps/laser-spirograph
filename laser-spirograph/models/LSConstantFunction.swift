//
//  LSConstantFunction.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/10/20.
//

import Foundation

class LSConstantFunction {
    
    // MARK: Properties
    
    private let x: Double
    private let y: Double
    
    // MARK: Initialization
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

// MARK: Parameterizable

extension LSConstantFunction: Parameterizable {
    
    func getPoint(t: Double) -> (x: Double, y: Double) { (x: x, y: y) }
    
    func isConstant() -> Bool { true }
}
