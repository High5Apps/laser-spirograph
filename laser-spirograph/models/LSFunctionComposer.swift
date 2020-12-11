//
//  LSFunctionComposer.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/10/20.
//

import Foundation

class LSFunctionComposer {
    
    // MARK: Properties
    
    private var functions: [Parameterizable]
    private var variableFunctions: [Parameterizable] { functions.filter() { !$0.isConstant() } }
    
    // MARK: Initialization
    
    init(_ functions: [Parameterizable]) {
        self.functions = functions
    }
}

// MARK: Parameterizable

extension LSFunctionComposer: Parameterizable {
    
    func getPoint(t: Double) -> (x: Double, y: Double) {
        var (x, y) = (0.0, 0.0)
        for (i, function) in variableFunctions.reversed().enumerated() {
            if i == 0 {
                (x, y) = function.getPoint(t: t)
            } else {
                x = function.getPoint(t: x).x
                y = function.getPoint(t: y).y
            }
        }
        
        return (x: x, y: y)
    }
    
    func isConstant() -> Bool { functions.allSatisfy() { $0.isConstant() } }
}
