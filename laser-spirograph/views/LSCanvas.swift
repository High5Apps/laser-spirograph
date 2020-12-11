//
//  LSCanvas.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/1/20.
//

import UIKit

class LSCanvas: UIView {
    
    var color: UIColor = .green
    var parametricFunction: Parameterizable = LSConstantFunction(x: 1, y: 0)
    
    private let shapeLayer = CAShapeLayer()
    private var pathTransform: CGAffineTransform = .identity
        
    private static let persistenceOfVision: TimeInterval = 1 / 16
    private static let stepSize: Double = persistenceOfVision / 32
    private static let lineWidth: CGFloat = 4
    private static let semiLineWidth: CGFloat = lineWidth / 2
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = Self.lineWidth
        shapeLayer.strokeColor = color.cgColor
        layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        pathTransform = getTransformFromUnitCircleToRect(bounds)
    }
    
    private func getTransformFromUnitCircleToRect(_ rect: CGRect) -> CGAffineTransform {
        let insetRect = rect.insetBy(dx: Self.semiLineWidth, dy: Self.semiLineWidth)
        
        let shiftAxesTransform = CGAffineTransform(translationX: 1, y: 1)

        let radius: CGFloat = min(insetRect.size.height, insetRect.size.width) / 2
        let scaleTransform = CGAffineTransform(scaleX: radius, y: radius)
        
        let strokeOffsetTransform = CGAffineTransform(translationX: Self.semiLineWidth, y: Self.semiLineWidth)
        return shiftAxesTransform.concatenating(scaleTransform).concatenating(strokeOffsetTransform)
    }
        
    func draw(time: Double) {
        updateShapeLayer(time)
    }
    
    private func updateShapeLayer(_ time: Double) {
        let path = UIBezierPath()
        
        let t0 = time - Self.persistenceOfVision
        path.move(to: getCGPoint(parametricFunction, t0))
        
        for t in stride(from: t0 + Self.stepSize, through: time, by: Self.stepSize) {
            path.addLine(to: getCGPoint(parametricFunction, t))
        }
        
        path.apply(pathTransform)

        shapeLayer.path = path.cgPath
    }
    
    private func getCGPoint(_ parametricFunction: Parameterizable, _ time: Double) -> CGPoint {
        let (x, y) = parametricFunction.getPoint(t: time)
        return CGPoint(x: x, y: y)
    }
}
