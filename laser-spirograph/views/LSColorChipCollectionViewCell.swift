//
//  LSColorChipCollectionViewCell.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 1/30/21.
//

import UIKit

enum ColorChipIcon: String {
    case plus
}

class LSColorChipCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    
    var color: UIColor? {
        didSet { contentView.backgroundColor = color }
    }
    
    var icon: ColorChipIcon? {
        didSet { setIcon(named: icon?.rawValue) }
    }
    
    private var iconView: UIImageView?
    
    private static let margin: CGFloat = 16
    private static let halfMargin = margin / 2
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        layer.masksToBounds = false
        
        contentView.layer.cornerRadius = Self.halfMargin
        contentView.layer.borderColor = UIColor.label.cgColor
        
        setSelectedBackgroundView()
        addIconView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectedBackgroundView?.frame = contentView.bounds.insetBy(dx: -Self.halfMargin, dy: -Self.halfMargin)
    }
    
    private func setSelectedBackgroundView() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .label
        backgroundView.layer.cornerRadius = Self.margin
        backgroundView.layer.borderWidth = Self.halfMargin
        backgroundView.layer.borderColor = UIColor.label.cgColor
        selectedBackgroundView = backgroundView
    }
    
    private func addIconView() {
        let iconView = UIImageView()
        iconView.tintColor = .label
        iconView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconView)
        
        iconView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5).isActive = true
        iconView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5).isActive = true
        iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        self.iconView = iconView
    }
    
    // MARK: Icons
    
    private func setIcon(named systemName: String?) {
        guard let systemName = systemName else {
            iconView?.image = nil
            return
        }
        
        iconView?.image = UIImage(systemName: systemName)
    }
}
