//
//  LSCircleTests.swift
//  laser-spirograph-tests
//
//  Created by Julian Tigler on 12/9/20.
//

import XCTest

class LSCircleTests: XCTestCase {
    
    func testGetPointShouldBeContinuousThroughRotationalVelocityUpdate() throws {
        let circle = LSCircle()
        var time: Double = 0
        
        for rpm in stride(from: 0, through: 10, by: 0.25) {
            let newRotationalVelocity: Double = rpm * 2 * .pi
            time += 1
            
            let initialPoint = circle.getPoint(t: time)
            circle.setRotationalVelocity(newRotationalVelocity, t: time)
            
            let newPoint = circle.getPoint(t: time)
            
            XCTAssertEqual(initialPoint.x, newPoint.x, accuracy: 1e-6)
            XCTAssertEqual(initialPoint.y, newPoint.y, accuracy: 1e-6)
        }
    }
}
