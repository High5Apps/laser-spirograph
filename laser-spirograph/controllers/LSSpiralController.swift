//
//  LSSpiralController.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/18/20.
//

import UIKit
import CoreData

class LSSpiralController {
    
    // MARK: Properties
    
    var canvas: LSCanvas? {
        didSet {
            if canvas == nil {
                stopDrawing()
            } else {
                startDrawing()
            }
        }
    }
        
    private var drawTimer: Timer?
    private var startTime = Date()
    private var span: TimeInterval = persistenceOfVision
    
    private var elapsedTime: TimeInterval { Date().timeIntervalSince(startTime) }
    
    private let circleCombiner: LSCircleCombiner
    private let refreshRate: Double?
    
    private static let persistenceOfVision: TimeInterval = 1 / 16
    private static let radii = [0.4, 0.1, 0.3, 0.2] // These should sum to 1 to span the canvas
    private static let stepCount: Int = 256
    
    // MARK: Initializtion
    
    init(refreshRate: Double? = nil) {
        self.refreshRate = refreshRate
        circleCombiner = LSCircleCombiner(radii: Self.radii)!
    }
    
    // MARK: Parameter sets
    
    func getParameterSet(_ context: NSManagedObjectContext) -> LSParameterSet {
        let endTime = elapsedTime
        let startTime = endTime - span
        let rotationsPerSeconds = circleCombiner.circles.map() { $0.rotationsPerSecond }
        let phases = circleCombiner.circles.map() { $0.phase }

        return LSParameterSet(context: context, startTime: startTime, endTime: endTime, rotationsPerSeconds: rotationsPerSeconds, phases: phases)
    }
    
    func loadParameterSet(_ parameterSet: LSParameterSet) {
        stopDrawing()
        startTime = Date(timeIntervalSinceNow: -1 * parameterSet.startTime)
        span = parameterSet.endTime - parameterSet.startTime
        circleCombiner.setParameters(rotationsPerSeconds: parameterSet.rotationsPerSeconds, phases: parameterSet.phases)
        startDrawing()
    }
    
    // MARK: Speed updating
    
    func updateCircleSpeed(_ rotationsPerSecond: Double, at index: Int) {
        circleCombiner.circles[index].updateRotationsPerSecond(rotationsPerSecond, t: elapsedTime)
    }
    
    // MARK: Drawing
    
    private func startDrawing() {
        canvas?.parametricFunction = circleCombiner
        if let refreshRate = refreshRate {
            self.span = Self.persistenceOfVision
            drawTimer = Timer.scheduledTimer(withTimeInterval: refreshRate, repeats: true) { (_) in
                self.draw(self.elapsedTime)
            }
        } else {
            draw(elapsedTime)
        }
    }
    
    private func draw(_ elapsedTime: TimeInterval) {
        canvas?.draw(startTime: elapsedTime - span, endTime: elapsedTime, stepCount: Self.stepCount)
    }
    
    private func stopDrawing() {
        drawTimer?.invalidate()
    }
}
