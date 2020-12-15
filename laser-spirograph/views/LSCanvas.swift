//
//  LSCanvas.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/1/20.
//

import UIKit

class LSCanvas: UIView {
    
    // MARK: Properties
    
    var color: UIColor = .green
    var parametricFunction: Parameterizable = LSConstantFunction(x: 1, y: 0)
    
    private var shapeLayer = CAShapeLayer()
    private var pathTransform: CGAffineTransform = .identity
    private var canvasRadius: CGFloat = 1
    private var startTime: TimeInterval = 0
    private var endTime: TimeInterval = 1
    private var stepCount: Int = 256
    
    private static let lineWidth: CGFloat = 4
    private static let semiLineWidth: CGFloat = lineWidth / 2
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        canvasRadius = getCanvasRadius()
        pathTransform = getTransformFromUnitCircleToRect()
    }
    
    private func getCanvasRadius() -> CGFloat {
        let insetRect = bounds.insetBy(dx: Self.semiLineWidth, dy: Self.semiLineWidth)
        return min(insetRect.size.height, insetRect.size.width) / 2
    }
    
    private func getTransformFromUnitCircleToRect() -> CGAffineTransform {
        let shiftAxesTransform = CGAffineTransform(translationX: 1, y: 1)
        let scaleTransform = CGAffineTransform(scaleX: canvasRadius, y: canvasRadius)
        let strokeOffsetTransform = CGAffineTransform(translationX: Self.semiLineWidth, y: Self.semiLineWidth)
        return shiftAxesTransform.concatenating(scaleTransform).concatenating(strokeOffsetTransform)
    }
    
    // MARK: Drawing
    
    func draw(startTime: Double, endTime: Double, stepCount: Int) {
        self.startTime = startTime
        self.endTime = endTime
        self.stepCount = stepCount
        updateShapeLayer()
    }
    
    private func updateShapeLayer() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = bounds
        shapeLayer.lineWidth = Self.lineWidth
        
        let isConstant = parametricFunction.isConstant()
        
        let bezierPath = isConstant ? getConstantPath() : getVariablePath()
        bezierPath.apply(pathTransform)
        shapeLayer.path = bezierPath.cgPath
        
        shapeLayer.strokeColor = isConstant ? nil : UIColor.green.cgColor
        shapeLayer.fillColor = isConstant ? UIColor.green.cgColor : nil
        
        layer.replaceSublayer(self.shapeLayer, with: shapeLayer)
        self.shapeLayer = shapeLayer
    }
    
    private func getConstantPath() -> UIBezierPath {
        let path = UIBezierPath()
        
        let pathRadius = Self.semiLineWidth / canvasRadius
        path.addArc(withCenter: getCGPoint(parametricFunction, endTime), radius: pathRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        
        return path
    }
    
    private func getVariablePath() -> UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: getCGPoint(parametricFunction, startTime))
        
        let stepSize = (endTime - startTime) / Double(stepCount)
        for t in stride(from: startTime, through: endTime, by: stepSize) {
            path.addLine(to: getCGPoint(parametricFunction, t))
        }
        
        return path
    }
    
    private func getCGPoint(_ parametricFunction: Parameterizable, _ time: Double) -> CGPoint {
        let (x, y) = parametricFunction.getPoint(t: time)
        return CGPoint(x: x, y: y)
    }
}
