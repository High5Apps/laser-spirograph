//
//  LSMultisliderView.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/10/20.
//

import UIKit
import VerticalSlider

protocol LSMultisliderViewDelegate: AnyObject {
    func multisliderView(_ sender: LSMultisliderView, didChange value: Float, at index: Int)
}

class LSMultisliderView: UIStackView {
    
    // MARK: Properties
    
    var minValue: Float = 0 { didSet { updateExtremeValues() } }
    var maxValue: Float = 1 { didSet { updateExtremeValues() } }
    
    weak var delegate: LSMultisliderViewDelegate?
        
    private static let sliderCount: Int = 4
    
    // MARK: Initialization
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        axis = .horizontal
        alignment = .fill
        distribution = .equalCentering
        translatesAutoresizingMaskIntoConstraints = false
        
        addSliders()
    }
    
    private func addSliders() {
        for i in 0..<Self.sliderCount {
            let slider = VerticalSlider()
            slider.slider.tag = i
            slider.minimumTrackTintColor = .green
            slider.slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
            addArrangedSubview(slider)
        }
        
        updateExtremeValues()
    }
    
    private func updateExtremeValues() {
        for view in arrangedSubviews {
            guard let slider = (view as? VerticalSlider)?.slider else { continue }
            slider.minimumValue = minValue
            slider.maximumValue = maxValue
        }
    }
    
    // MARK: Value updating
    
    func setValues(_ values: [Double]) {
        for view in arrangedSubviews {
            guard let slider = (view as? VerticalSlider)?.slider else { continue }
            slider.value = Float(values[slider.tag])
        }
    }
    
    // MARK: Value change events
    
    @objc func sliderValueChanged(_ slider: UISlider) {
        delegate?.multisliderView(self, didChange: slider.value, at: slider.tag)
    }
}
