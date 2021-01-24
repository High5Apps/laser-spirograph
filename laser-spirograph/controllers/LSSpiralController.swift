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
                drawTimer = Timer.scheduledTimer(withTimeInterval: Self.refreshRate, repeats: true) { [weak self] (_) in
                    guard let self = self else { return }
                    self.elapsedAnimationTime = (self.elapsedAnimationTime + Self.refreshRate).truncatingRemainder(dividingBy: self.maxAnimationDuration)
                    self.draw()
                }
            } else {
                drawTimer?.invalidate()
            }
        }
    }
    
    var maxAnimationDuration: TimeInterval {
        get { _maxAnimationDuration }
        set { _maxAnimationDuration = (newValue > 0) ? newValue : .greatestFiniteMagnitude }
    }
    private var _maxAnimationDuration: TimeInterval = .greatestFiniteMagnitude
    
    var drawResolution: Int = 256
    
    private var drawTimer: Timer?
    private var loadedParameterSet: LSParameterSet?
    private var elapsedAnimationTime: TimeInterval = 0
    
    private var gifRunTime: TimeInterval {
        let runTimeWithoutLastFrameRemoved: TimeInterval
        if maxAnimationDuration > Self.maxGifRunTime {
            let isMaxAnimationDurationSet = maxAnimationDuration < .greatestFiniteMagnitude
            runTimeWithoutLastFrameRemoved = isMaxAnimationDurationSet ? Self.maxGifRunTime : Self.defaultGifRunTime
        } else {
            runTimeWithoutLastFrameRemoved = maxAnimationDuration
        }
        return runTimeWithoutLastFrameRemoved - Self.refreshRate
    }
    
    private let circleCombiner = LSCircleCombiner(radii: radii)!
    
    private static let persistenceOfVision: TimeInterval = 1 / 16
    private static let radii = [0.4, 0.1, 0.3, 0.2] // These should sum to 1 to span the canvas
    private static let refreshRate: Double = 1 / 24
    private static let defaultGifRunTime: TimeInterval = 2.5
    private static let maxGifRunTime: TimeInterval = 60
    
    // MARK: Deinit
    
    deinit {
        drawTimer?.invalidate()
    }
    
    // MARK: Parameter sets
    
    func getParameterSet(_ context: NSManagedObjectContext) -> LSParameterSet {
        let elapsedTime = self.elapsedAnimationTime
        let startTime = spiralStartTime(elapsedTime: elapsedTime)
        let endTime = spiralEndTime(elapsedTime: elapsedTime)
        let rotationsPerSeconds = circleCombiner.circles.map() { $0.rotationsPerSecond }
        let phases = circleCombiner.circles.map() { $0.phase }

        return LSParameterSet(context: context, startTime: startTime, endTime: endTime, rotationsPerSeconds: rotationsPerSeconds, phases: phases)
    }
    
    func loadParameterSet(_ parameterSet: LSParameterSet) {
        elapsedAnimationTime = 0
        circleCombiner.setParameters(rotationsPerSeconds: parameterSet.rotationsPerSeconds, phases: parameterSet.phases)
        loadedParameterSet = parameterSet
        
        if !isAnimating {
            draw()
        }
    }
    
    // MARK: Speed updating
    
    func updateCircleSpeed(_ rotationsPerSecond: Double, at index: Int) {
        circleCombiner.circles[index].updateRotationsPerSecond(rotationsPerSecond, t: spiralEndTime(elapsedTime: elapsedAnimationTime))
    }
    
    // MARK: Drawing
    
    private func spiralStartTime(elapsedTime: TimeInterval) -> TimeInterval {
        if let loadedParameterSet = loadedParameterSet, !isAnimating {
            return loadedParameterSet.startTime + elapsedTime
        } else {
            return spiralEndTime(elapsedTime: elapsedTime) - Self.persistenceOfVision
        }
    }
    
    private func spiralEndTime(elapsedTime: TimeInterval) -> TimeInterval {
        return (loadedParameterSet?.endTime ?? 0) + elapsedTime
    }
    
    private func draw() {
        let elapsedTime = self.elapsedAnimationTime
        canvas?.draw(startTime: spiralStartTime(elapsedTime: elapsedTime), endTime: spiralEndTime(elapsedTime: elapsedTime), stepCount: drawResolution)
    }
    
    // MARK: Sharing
    
    func gifData(completion: @escaping (Data?) -> ()) {
        let initialElapsedTime = elapsedAnimationTime
        let gifBuilder = LSGifBuilder(refreshRate: Self.refreshRate)
        addGifFrames(to: gifBuilder, totalRunTime: gifRunTime) { (data) in
            self.elapsedAnimationTime = initialElapsedTime
            completion(data)
        }
    }
    
    private func addGifFrames(to gifBuilder: LSGifBuilder, elapsedTime: TimeInterval = 0, totalRunTime: TimeInterval, completion: @escaping (Data?) -> ()) {
        DispatchQueue.main.async {
            self.elapsedAnimationTime = elapsedTime
            self.draw()
            guard let image = self.getImage() else {
                completion(nil)
                return
            }
            gifBuilder.addImage(image)

            guard elapsedTime < totalRunTime else {
                completion(gifBuilder.getData())
                return
            }

            self.addGifFrames(to: gifBuilder, elapsedTime: elapsedTime + Self.refreshRate, totalRunTime: totalRunTime, completion: completion)
        }
    }
    
    func getImage() -> UIImage? {
        canvas?.getImage()
    }
    
    func getSvgExporter() -> LSSvgExporter? {
        guard let parameterSet = loadedParameterSet, let exporter = canvas?.getSvgExporter() else { return nil }
        exporter.title = parameterSet.displayName
        return exporter
    }
}
