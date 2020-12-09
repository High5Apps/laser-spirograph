//
//  LSCanvas.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/1/20.
//

import UIKit

class LSCanvas: UIView {
    
    var color: UIColor = .green
    var parametricFunction: Parameterizable?
    
    private var shapeLayer: CAShapeLayer
        
    private static let persistenceOfVision: TimeInterval = 1 / 16
    private static let stepSize: Double = persistenceOfVision / 32
    private static let lineWidth: CGFloat = 4
    private static let semiLineWidth: CGFloat = lineWidth / 2
    
    required init?(coder: NSCoder) {
        shapeLayer = CAShapeLayer()
        super.init(coder: coder)
        
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = Self.lineWidth
        shapeLayer.strokeColor = color.cgColor
        layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
    }
        
    func draw(time: Double) {
        updateShapeLayer(time)
    }
    
    private func updateShapeLayer(_ time: Double) {
        let insetRect = bounds.insetBy(dx: Self.semiLineWidth, dy: Self.semiLineWidth)

        let path = UIBezierPath()
        let t0 = time - Self.persistenceOfVision
        path.move(to: getTransformedPoint(t: t0, rect: insetRect))
        
        for t in stride(from: t0 + Self.stepSize, through: time, by: Self.stepSize) {
            path.addLine(to: getTransformedPoint(t: t, rect: insetRect))
        }
        
        shapeLayer.path = path.cgPath
    }
    
    private func getTransformedPoint(t: Double, rect: CGRect) -> CGPoint {
        let (x, y) = parametricFunction?.getPoint(t: t) ?? (0, 0)
        let pointInUnitCircle = CGPoint(x: x, y: y)
        return transformUnitCircle(point: pointInUnitCircle, toFit: rect)
    }
    
    private func transformUnitCircle(point: CGPoint, toFit rect: CGRect) -> CGPoint {
        let shiftAxesTransform = CGAffineTransform(translationX: 1, y: 1)

        let radius: CGFloat = min(rect.height, rect.width) / 2
        let scaleTransform = CGAffineTransform(scaleX: radius, y: radius)
        
        let strokeOffsetTransform = CGAffineTransform(translationX: Self.semiLineWidth, y: Self.semiLineWidth)

        return point.applying(shiftAxesTransform).applying(scaleTransform).applying(strokeOffsetTransform)
    }
}
