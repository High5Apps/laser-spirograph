//
//  LSFunctionComposerTests.swift
//  laser-spirograph-tests
//
//  Created by Julian Tigler on 12/10/20.
//

import XCTest

class LSFunctionComposerTests: XCTestCase {

    func testIsConstantShouldBeTrueWhenAllFunctionsConstant() throws {
        var functions = [LSCircle]()
        for _ in 0..<4 {
            let circle = LSCircle()
            circle.setRotationsPerSecond(0, t: 0)
            functions.append(circle)
        }
        
        let functionComposer = LSFunctionComposer(functions)
        XCTAssert(functionComposer.isConstant())
        
        for function in functions {
            function.setRotationsPerSecond(1e-6, t: 0)
            XCTAssert(!functionComposer.isConstant())
            
            function.setRotationsPerSecond(0, t: 0)
            XCTAssert(functionComposer.isConstant())
        }
    }
}
