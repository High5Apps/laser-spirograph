//
//  ColorValueTransformer.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 1/31/21.
//

import UIKit.UIColor

@objc(UIColorValueTransformer)
final class ColorValueTransformer: NSSecureUnarchiveFromDataTransformer {

    static let name = NSValueTransformerName(rawValue: String(describing: ColorValueTransformer.self))

    override static var allowedTopLevelClasses: [AnyClass] {
        return [UIColor.self]
    }

    public static func register() {
        let transformer = ColorValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
