//
//  Parameterizable.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/1/20.
//

import Foundation

protocol Parameterizable: AnyObject {
    func getPoint(t: Double) -> (x: Double, y: Double)
    func isConstant() -> Bool
}
