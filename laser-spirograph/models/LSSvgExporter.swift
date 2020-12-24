//
//  LSSvgExporter.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/23/20.
//

import UIKit

class LSSvgExporter {
    
    // MARK: Properties
    
    var title: String
    
    private let path: LSSvgPath
    private let bounds: CGRect
    private let strokeWidth: CGFloat
    private let strokeColor: CGColor
    private let pathTransform: CGAffineTransform
    
    // MARK: Initialization
    
    init(path: LSSvgPath, bounds: CGRect, strokeWidth: CGFloat, strokeColor: CGColor,  pathTransform: CGAffineTransform) {
        self.path = path
        self.title = "Spiral"
        self.strokeWidth = strokeWidth
        self.bounds = bounds
        self.strokeColor = strokeColor
        self.pathTransform = pathTransform
    }
}

// MARK: CustomStringConvertible

extension LSSvgExporter: CustomStringConvertible {
    
    var description: String {
        return """
<?xml version="1.0" encoding="UTF-8"?>
<svg width="\(width)px" height="\(height)px" viewBox="0 0 \(width) \(height)" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <!-- Generator: \(appName) \(semanticVersion) (\(versionNumber)) -->
    <title>\(title)</title>
    <desc>Created with \(appName) for iOS.</desc>
    <g stroke="\(strokeColorHex)" fill="none" transform="\(transformMatrix)" stroke-width="\(strokeWidth)" stroke-linejoin="round">
        <path d="\(path)" />
    </g>
</svg>
"""
    }
    
    private var appName: String { getBundleInfo(withKey: "CFBundleDisplayName", default: "Spiralize") }
    private var semanticVersion: String { getBundleInfo(withKey: "CFBundleShortVersionString", default: "0.0.0") }
    private var versionNumber: String { getBundleInfo(withKey: "CFBundleVersion", default: "0") }
    private var width: CGFloat { bounds.width }
    private var height: CGFloat { bounds.height }
    private var strokeColorHex: String { hexStringFromColor(color: strokeColor) }
    private var transformMatrix: String { "matrix(\(pathTransform.a) \(pathTransform.b) \(pathTransform.c) \(pathTransform.d) \(pathTransform.tx) \(pathTransform.ty))" }
    
    private func getBundleInfo(withKey key: String, default: String) -> String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Spiralize"
    }
    
    private func hexStringFromColor(color: CGColor) -> String {
        let components = color.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
     }

}
