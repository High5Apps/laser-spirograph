//
//  LSParameterStepperContainer.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/21/20.
//

import UIKit

protocol LSParameterStepperContainerDelegate: AnyObject {
    func parameterStepperContainer(_ sender: LSParameterStepperContainer, didChange value: Double, at index: Int)
}

class LSParameterStepperContainer: UIView {
    
    // MARK: Properties
    
    weak var delegate: LSParameterStepperContainerDelegate?
    
    private var stackView: UIStackView!
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        addStackView()
    }
    
    private func addStackView() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    private func stepper(at index: Int) -> LSParameterStepper {
        stackView.arrangedSubviews[index] as! LSParameterStepper
    }
    
    func addParameterStepper(name: String, step: Double, precision: Int, unit: String = "seconds", minValue: Double = 0, maxValue: Double = Double.infinity) {
        let stepper = LSParameterStepper()
        stepper.setParameter(0, name: name, step: step, precision: precision, unit: unit, minValue: minValue, maxValue: maxValue)
        stepper.isSeparatorHidden = true
        stepper.delegate = self
        
        let stepperIndex = stackView.arrangedSubviews.count
        stepper.tag = stepperIndex
        stackView.addArrangedSubview(stepper)
        
        guard stepperIndex > 0 else { return }
        let previousStepper = self.stepper(at: stepperIndex - 1)
        previousStepper.isSeparatorHidden = false
    }
    
    func setValue(_ value: Double, at index: Int) {
        stepper(at: index).value = value
    }
}

// MARK: LSParameterStepperDelegate

extension LSParameterStepperContainer: LSParameterStepperDelegate {
    
    func parameterStepper(_ sender: LSParameterStepper, didChange value: Double) {
        delegate?.parameterStepperContainer(self, didChange: value, at: sender.tag)
    }
}
