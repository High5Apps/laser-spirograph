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
        didSet { canvas?.parametricFunction = circleCombiner }
    }
    
    var isAnimating: Bool = false {
        didSet {
            guard isAnimating != oldValue else { return }
            if isAnimating {
                drawTimer = Timer.scheduledTimer(withTimeInterval: Self.refreshRate, repeats: true) { (_) in
                    self.draw()
                }
            } else {
                drawTimer?.invalidate()
            }
        }
    }
    
    var drawResolution: Int = 256
    
    private var drawTimer: Timer?
    private var loadedParameterSet: LSParameterSet?
    
    private var elapsedTime: TimeInterval { Date().timeIntervalSince(startTime) }
    
    private let circleCombiner = LSCircleCombiner(radii: radii)!
    private let startTime = Date()
    
    private static let persistenceOfVision: TimeInterval = 1 / 16
    private static let radii = [0.4, 0.1, 0.3, 0.2] // These should sum to 1 to span the canvas
    private static let refreshRate: Double = 1 / 24
    
    // MARK: Parameter sets
    
    func getParameterSet(_ context: NSManagedObjectContext) -> LSParameterSet {
        let elapsedTime = self.elapsedTime
        let startTime = spiralStartTime(elapsedTime: elapsedTime)
        let endTime = spiralEndTime(elapsedTime: elapsedTime)
        let rotationsPerSeconds = circleCombiner.circles.map() { $0.rotationsPerSecond }
        let phases = circleCombiner.circles.map() { $0.phase }

        return LSParameterSet(context: context, startTime: startTime, endTime: endTime, rotationsPerSeconds: rotationsPerSeconds, phases: phases)
    }
    
    func loadParameterSet(_ parameterSet: LSParameterSet) {
        circleCombiner.setParameters(rotationsPerSeconds: parameterSet.rotationsPerSeconds, phases: parameterSet.phases)
        loadedParameterSet = parameterSet
        
        if !isAnimating {
            draw()
        }
    }
    
    // MARK: Speed updating
    
    func updateCircleSpeed(_ rotationsPerSecond: Double, at index: Int) {
        circleCombiner.circles[index].updateRotationsPerSecond(rotationsPerSecond, t: spiralEndTime(elapsedTime: elapsedTime))
    }
    
    // MARK: Drawing
    
    private func spiralStartTime(elapsedTime: TimeInterval) -> TimeInterval {
        if isAnimating {
            return spiralEndTime(elapsedTime: elapsedTime) - Self.persistenceOfVision
        } else {
            return loadedParameterSet?.endTime ?? -Self.persistenceOfVision
        }
    }
    
    private func spiralEndTime(elapsedTime: TimeInterval) -> TimeInterval {
        var t = (loadedParameterSet?.startTime ?? 0)
        if isAnimating {
            t += elapsedTime
        }
        return t
    }
    
    private func draw() {
        let elapsedTime = self.elapsedTime
        canvas?.draw(startTime: spiralStartTime(elapsedTime: elapsedTime), endTime: spiralEndTime(elapsedTime: elapsedTime), stepCount: drawResolution)
    }
    
    // MARK: Sharing
    
    func getImage() -> UIImage? {
        guard let view = canvas else { return nil }
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        return renderer.image { context in
            let previousBackgroundColor = view.backgroundColor
            view.backgroundColor = .black
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            view.backgroundColor = previousBackgroundColor
        }
    }
    
    func getSvgExporter() -> LSSvgExporter? {
        guard let parameterSet = loadedParameterSet, let exporter = canvas?.getSvgExporter() else { return nil }
        exporter.title = parameterSet.displayName
        return exporter
    }
}
