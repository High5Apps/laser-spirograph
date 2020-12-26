//
//  LSCircleButton.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/15/20.
//

import UIKit

class LSCircleButton: UIButton {
    
    private static let normalBackgroundColor: UIColor = .systemFill
    private static let highlightedBackgroundColor: UIColor = .tertiarySystemFill
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Self.highlightedBackgroundColor : Self.normalBackgroundColor
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        backgroundColor = Self.normalBackgroundColor
        tintColor = .label
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = min(frame.size.width, frame.size.height) / 2
    }
}
