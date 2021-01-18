//
//  LSParameterStepper.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/19/20.
//

import UIKit

protocol LSParameterStepperDelegate: AnyObject {
    func parameterStepper(_ sender: LSParameterStepper, didChange value: Double)
}

class LSParameterStepper: UIView {
    
    var isSeparatorHidden: Bool {
        set { divider.isHidden = newValue }
        get { divider.isHidden }
    }
    
    var value: Double {
        set {
            stepper.value = newValue
            updateLabel()
        }
        get { stepper.value }
    }
    
    weak var delegate: LSParameterStepperDelegate?
    
    private var label: UILabel!
    private var stepper: UIStepper!
    private var divider: UIView!
    private var name: String!
    private var pluralUnit: String!
    private var precision: Int!
    
    private var singularUnit: String {
        pluralUnit.hasSuffix("s") ? String(pluralUnit.dropLast()) : pluralUnit
    }
    
    private static let padding: CGFloat = 8
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .secondarySystemBackground
        
        addLabel()
        addStepper()
        addDivider()
    }
    
    private func addLabel() {
        label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: topAnchor, constant: Self.padding).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Self.padding).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: Self.padding).isActive = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    private func addStepper() {
        stepper = UIStepper()
        stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
        addSubview(stepper)
        
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.topAnchor.constraint(equalTo: topAnchor, constant: Self.padding).isActive = true
        stepper.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Self.padding).isActive = true
        stepper.leftAnchor.constraint(equalTo: label.rightAnchor, constant: Self.padding).isActive = true
        stepper.rightAnchor.constraint(equalTo: rightAnchor, constant: -Self.padding).isActive = true
        stepper.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    private func addDivider() {
        divider = UIView()
        divider.backgroundColor = .separator
        addSubview(divider)
        
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.leftAnchor.constraint(equalTo: leftAnchor, constant: Self.padding).isActive = true
        divider.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func setParameter(_ value: Double, name: String, step: Double, precision: Int, unit: String = "seconds", minValue: Double = 0, maxValue: Double = Double.infinity) {
        self.name = name
        pluralUnit = unit
        self.precision = precision
        
        stepper.minimumValue = minValue
        stepper.maximumValue = maxValue
        stepper.stepValue = step
        self.value = value
    }
    
    private func updateLabel() {
        let unit = (abs(value) == 1) ? singularUnit : pluralUnit
        label.text = "\(name!): \(String(format: "%.\(precision!)f", stepper.value)) \(unit!)"
    }
    
    @objc func stepperValueChanged() {
        updateLabel()
        delegate?.parameterStepper(self, didChange: stepper.value)
    }
}
