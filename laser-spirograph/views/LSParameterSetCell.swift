//
//  LSParameterSetCell.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/18/20.
//

import UIKit

class LSParameterSetCell: UITableViewCell {
    
    var parameterSet: LSParameterSet? {
        didSet {
            guard let parameterSet = parameterSet else { return }
            updateViews(parameterSet)
        }
    }
    
    private var canvas: LSCanvas!
    private var nameLabel: UILabel!
    private var spiralController = LSSpiralController()
    
    private static let padding: CGFloat = 16

    override func awakeFromNib() {
        super.awakeFromNib()

        addCanvas()
        addNameLabel()
        
        spiralController.canvas = canvas
    }

    private func addCanvas() {
        canvas = LSCanvas()
        contentView.addSubview(canvas)
        
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Self.padding).isActive = true
        canvas.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Self.padding).isActive = true
        canvas.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Self.padding).isActive = true
        canvas.widthAnchor.constraint(equalTo: canvas.heightAnchor).isActive = true
    }
    
    private func addNameLabel() {
        nameLabel = UILabel()
        nameLabel.font = .preferredFont(forTextStyle: .body)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 0
        contentView.addSubview(nameLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: canvas.rightAnchor, constant: Self.padding).isActive = true
        nameLabel.topAnchor.constraint(equalTo: canvas.topAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Self.padding).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: canvas.bottomAnchor).isActive = true
    }
    
    private func updateViews(_ parameterSet: LSParameterSet) {
        spiralController.loadParameterSet(parameterSet)
        nameLabel.text = parameterSet.displayName
    }
}
