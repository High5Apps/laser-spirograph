//
//  LSCircleTests.swift
//  laser-spirograph-tests
//
//  Created by Julian Tigler on 12/9/20.
//

import XCTest

class LSCircleTests: XCTestCase {
    
    func testGetPointShouldBeContinuousThroughRotationsPerSecondUpdate() throws {
        let circle = LSCircle(radius: 1)
        var time: Double = 0
        
        for rotationsPerSecond in stride(from: 0, through: 10, by: 0.25) {
            time += 1
            
            let initialPoint = circle.getPoint(t: time)
            circle.updateRotationsPerSecond(rotationsPerSecond, t: time)
            
            let newPoint = circle.getPoint(t: time)
            
            XCTAssertEqual(initialPoint.x, newPoint.x, accuracy: 1e-6)
            XCTAssertEqual(initialPoint.y, newPoint.y, accuracy: 1e-6)
        }
    }
    
    func testIsConstantShouldBeTrueWhenRotationsPerSecondZero() throws {
        let circle = LSCircle(radius: 1)
        
        circle.updateRotationsPerSecond(0, t: 1)
        XCTAssert(circle.isConstant())
        
        circle.updateRotationsPerSecond(1e-6, t: 1)
        XCTAssert(!circle.isConstant())
    }
}
