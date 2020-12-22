//
//  LSCircleCombinerTests.swift
//  laser-spirograph-tests
//
//  Created by Julian Tigler on 12/10/20.
//

import XCTest

class LSCircleCombinerTests: XCTestCase {

    func testIsConstantShouldBeTrueWhenAllFunctionsConstant() throws {
        let radii: [Double] = [1, 1, 1, 1]
        let circleCombiner = LSCircleCombiner(radii: radii)!
        circleCombiner.circles.forEach() { $0.updateRotationsPerSecond(0, t: 0) }
        XCTAssert(circleCombiner.isConstant())
        
        for circle in circleCombiner.circles {
            circle.updateRotationsPerSecond(1e-6, t: 0)
            XCTAssert(!circleCombiner.isConstant())
            
            circle.updateRotationsPerSecond(0, t: 0)
            XCTAssert(circleCombiner.isConstant())
        }
    }
}
