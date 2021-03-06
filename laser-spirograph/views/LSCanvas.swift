//
//  LSCanvas.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/1/20.
//

import UIKit

class LSCanvas: UIView {
    
    // MARK: Properties
    
    var parametricFunction: Parameterizable = LSConstantFunction(x: 1, y: 0)
    
    private var previousBounds: CGRect = .zero
    private var shapeLayer = CAShapeLayer()
    private var pathTransform: CGAffineTransform = .identity
    private var canvasRadius: CGFloat = 1
    private var startTime: TimeInterval = 0
    private var endTime: TimeInterval = 1
    private var stepCount: Int = 256
    private var lineWidth: CGFloat = 4
    
    private var semilineWidth: CGFloat { lineWidth / 2 }
    private var isDrawingConstant: Bool {
        parametricFunction.isConstant() || (startTime == endTime)
    }
    private var color: CGColor { window?.tintColor.cgColor ?? UIColor.clear.cgColor }
    
    private var filledLogo: UIImage? {
        if _filledLogo == nil {
            _filledLogo = UIImage(named: "logo-filled")?.withRenderingMode(.alwaysTemplate)
        }
        return _filledLogo
    }
    private var _filledLogo: UIImage?
    
    private static let lineWidthMultiplier: CGFloat = 2 / 85
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    private func commonInit() {
        layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds != previousBounds else { return }
        previousBounds = bounds
        onBoundsChanged()
    }
    
    private func onBoundsChanged() {
        let boundsRadius = min(bounds.size.height, bounds.size.width) / 2
        lineWidth = boundsRadius * Self.lineWidthMultiplier
        lineWidth = min(8, lineWidth)
        canvasRadius = boundsRadius - (lineWidth / 2)
        pathTransform = getTransformFromUnitCircleToRect()
        updateShapeLayer()
    }
    
    private func getTransformFromUnitCircleToRect() -> CGAffineTransform {
        let shiftAxesTransform = CGAffineTransform(translationX: 1, y: 1)
        let scaleTransform = CGAffineTransform(scaleX: canvasRadius, y: canvasRadius)
        let strokeOffsetTransform = CGAffineTransform(translationX: semilineWidth, y: semilineWidth)
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
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = .round
        
        let isConstant = isDrawingConstant
        
        let bezierPath = UIBezierPath()
        isConstant ? addConstantPath(to: bezierPath) : addVariablePath(to: bezierPath)
        bezierPath.apply(pathTransform)
        shapeLayer.path = bezierPath.cgPath
        
        shapeLayer.strokeColor = isConstant ? nil : color
        shapeLayer.fillColor = isConstant ? color : nil
        
        layer.replaceSublayer(self.shapeLayer, with: shapeLayer)
        self.shapeLayer = shapeLayer
    }
    
    private func addConstantPath(to path: UIBezierPath) {
        let pathRadius = semilineWidth / canvasRadius
        path.addArc(withCenter: getCGPoint(parametricFunction, endTime), radius: pathRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
    }
    
    private func addVariablePath(to path: LSVectorizable) {
        path.move(to: getCGPoint(parametricFunction, startTime))
        
        let stepSize = (endTime - startTime) / Double(stepCount)
        for t in stride(from: startTime, through: endTime, by: stepSize) {
            path.addLine(to: getCGPoint(parametricFunction, t))
        }
    }
    
    private func getCGPoint(_ parametricFunction: Parameterizable, _ time: Double) -> CGPoint {
        let (x, y) = parametricFunction.getPoint(t: time)
        return CGPoint(x: x, y: y)
    }
    
    // MARK: SVG exporting
    
    func getSvgExporter() -> LSSvgExporter? {
        guard !isDrawingConstant else { return nil }
        
        let svgPath = LSSvgPath()
        addVariablePath(to: svgPath)
        
        return LSSvgExporter(path: svgPath, bounds: bounds, strokeWidth: Self.lineWidthMultiplier, strokeColor: color, pathTransform: pathTransform)
    }
    
    func getImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { context in
            UIColor.black.setFill()
            context.fill(bounds)
            
            let previousBackgroundColor = backgroundColor
            backgroundColor = .clear
            drawHierarchy(in: bounds, afterScreenUpdates: true)
            backgroundColor = previousBackgroundColor
            
            guard let filledLogo = filledLogo else { return }
            tintColor.setFill()
            let logoWidth = canvasRadius / 2
            let logoHeight = logoWidth * (filledLogo.size.height / filledLogo.size.width)
            let logoRect = CGRect(x: bounds.maxX - logoWidth, y: bounds.maxY - logoHeight, width: logoWidth, height: logoHeight)
            filledLogo.draw(in: logoRect, blendMode: .normal, alpha: 0.75)
        }
    }
}
