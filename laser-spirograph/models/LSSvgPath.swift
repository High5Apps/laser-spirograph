//
//  LSSvgPath.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/23/20.
//

import UIKit

// MARK: LSVectorizable

protocol LSVectorizable {
    func move(to point: CGPoint)
    func addLine(to point: CGPoint)
}

extension UIBezierPath: LSVectorizable {}

// MARK: LSSvgPath

class LSSvgPath: LSVectorizable {
    
    private var components = [String]()
    
    func move(to point: CGPoint) {
        components.append("M\(point.x) \(point.y)")
    }
    
    func addLine(to point: CGPoint) {
        components.append("L\(point.x) \(point.y)")
    }
}

// MARK: CustomStringConvertible

extension LSSvgPath: CustomStringConvertible {
    
    var description: String {
        components.joined(separator: " ")
    }
}
