//
//  LSColorChipCollectionViewCell.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 1/30/21.
//

import UIKit

class LSColorChipCollectionViewCell: UICollectionViewCell {
    
    var color: UIColor? {
        didSet { contentView.backgroundColor = color }
    }
    
    private static let margin: CGFloat = 16
    private static let halfMargin = margin / 2
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        layer.masksToBounds = false
        
        contentView.layer.cornerRadius = Self.halfMargin
        contentView.layer.borderColor = UIColor.label.cgColor
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .label
        backgroundView.layer.cornerRadius = Self.margin
        backgroundView.layer.borderWidth = Self.halfMargin
        backgroundView.layer.borderColor = UIColor.label.cgColor
        selectedBackgroundView = backgroundView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectedBackgroundView?.frame = contentView.bounds.insetBy(dx: -Self.halfMargin, dy: -Self.halfMargin)
    }
}
