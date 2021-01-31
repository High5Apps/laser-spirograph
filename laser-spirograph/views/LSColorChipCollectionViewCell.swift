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
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        contentView.layer.cornerRadius = 8
    }
}
