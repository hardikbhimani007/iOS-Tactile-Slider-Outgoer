//
//  TactileSliderLayerRenderer.swift
//  TactileSlider
//
//  Created by Dale Price on 1/26/19.
//

import UIKit

@available(iOS 9, *)
@available(tvOS, unavailable)
@available(macOS, unavailable)
internal class TactileSliderLayerRenderer {
    
    private static var valueChangeTimingFunction = CAMediaTimingFunction(name: .default)
    
    weak var tactileSlider: TactileSlider?
    
    var trackBackground: UIColor = .darkGray {
        didSet {
            trackLayer.backgroundColor = trackBackground.cgColor
        }
    }
    
    var outlineSize: CGFloat = 1 {
        didSet {
            updateOutlineLayer()
        }
    }
    
    var thumbTint: UIColor = .white {
        didSet {
            applyThumbFillColor()
        }
    }
    
    /// When set to at least two colors, the thumb is drawn with a linear gradient; the second stop position follows the slider value so the blend updates as the user drags.
    var gradientTintColors: [UIColor]? = nil {
        didSet {
            configureGradientTintMode()
        }
    }
    
    var cornerRadius: CGFloat = 10 {
        didSet {
            updateMaskAndOutlineLayerPath()
        }
    }
    
    var grayedOut: Bool = false {
        didSet {
            updateGrayedOut()
        }
    }
    
    var popUp: Bool = false {
        didSet(oldValue) {
            if oldValue != popUp {
                updatePopUp()
            }
        }
    }
    
    let trackLayer = CALayer()
    let thumbLayer = CAShapeLayer()
    let thumbGradientLayer = CAGradientLayer()
    let thumbMaskLayer = CAShapeLayer()
    let maskLayer = CAShapeLayer()
    let outlineLayer = CAShapeLayer()
    let thumbOutlineLayer = CAShapeLayer()
    
    init() {
        trackLayer.backgroundColor = trackBackground.cgColor
        thumbLayer.fillColor = thumbTint.cgColor
        thumbLayer.masksToBounds = true
        thumbGradientLayer.isHidden = true
        thumbMaskLayer.fillColor = UIColor.white.cgColor
        thumbMaskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.fillColor = UIColor.white.cgColor
        maskLayer.backgroundColor = UIColor.clear.cgColor
        trackLayer.mask = maskLayer
        trackLayer.masksToBounds = true
        outlineLayer.backgroundColor = nil
        outlineLayer.fillColor = nil
        thumbOutlineLayer.backgroundColor = nil
        
        updateOutlineLayer(updateBounds: false)
        updateOutlineColors()
    }
    
    internal func setupLayers() {
        trackLayer.insertSublayer(thumbGradientLayer, at: 0)
        trackLayer.addSublayer(thumbLayer)
        trackLayer.addSublayer(outlineLayer)
        thumbLayer.addSublayer(thumbOutlineLayer)
    }
    
    private func updateThumbLayerPath() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let rectPath = CGPath(rect: CGRect(x: 0, y: 0, width: thumbLayer.bounds.width, height: thumbLayer.bounds.height), transform: nil)
        thumbLayer.path = rectPath
        thumbMaskLayer.path = rectPath
        
        updateThumbOutlineLayerPath()
        
        CATransaction.commit()
    }
    
    private func updateThumbOutlineLayerPath() {
        guard let slider = tactileSlider else {
            return
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let edgeInsets: UIEdgeInsets
        switch (slider.vertical, slider.reverseValueAxis) {
        case (false, false):
            edgeInsets = UIEdgeInsets(top: 0, left: thumbLayer.bounds.width - outlineSize, bottom: 0, right: -1)
        case (false, true):
            edgeInsets = UIEdgeInsets(top: 0, left: -1, bottom: 0, right: thumbLayer.bounds.width - outlineSize)
        case (true, false):
            edgeInsets = UIEdgeInsets(top: -1, left: 0, bottom: thumbLayer.bounds.height - outlineSize, right: 0)
        case (true, true):
            edgeInsets = UIEdgeInsets(top: thumbLayer.bounds.height - outlineSize, left: 0, bottom: -1, right: 0)
        }
        
        let baseRect = CGRect(x: 0, y: 0, width: thumbLayer.bounds.width, height: thumbLayer.bounds.height)
        let insetRect = baseRect.inset(by: edgeInsets)
        thumbOutlineLayer.path = CGPath(rect: insetRect, transform: nil)
        
        CATransaction.commit()
    }
    
    private func updateMaskAndOutlineLayerPath() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let maskRect = CGRect(x: 0, y: 0, width: maskLayer.bounds.width, height: maskLayer.bounds.height)
        let maskPath = UIBezierPath(roundedRect: maskRect, cornerRadius: cornerRadius).cgPath
        maskLayer.path = maskPath
        outlineLayer.path = maskPath
        
        CATransaction.commit()
    }
    
    internal func updateOutlineColors() {
        let color: CGColor?
        if let slider = tactileSlider {
            color = slider.finalOutlineColor?.cgColor
        } else {
            color = nil
        }
        
        outlineLayer.strokeColor = color
        thumbOutlineLayer.fillColor = color
    }
    
    private func updateOutlineLayer(updateBounds: Bool = true) {
        outlineLayer.lineWidth = outlineSize * 2
        if updateBounds { updateThumbOutlineLayerPath() }
    }
    
    private func updateGrayedOut() {
        let alpha: Float = grayedOut ? 0.6 : 1
        trackLayer.opacity = alpha
    }
    
    private func updatePopUp() {
        CATransaction.begin()
        
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
        CATransaction.setAnimationDuration(0.1)
        
        let zPosition: CGFloat = popUp ? 1.025 : 1
        trackLayer.transform = CATransform3DScale(CATransform3DIdentity, zPosition, zPosition, zPosition)
        
        CATransaction.commit()
    }
    
    internal func updateBounds(_ bounds: CGRect) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.bounds = bounds
        trackLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        maskLayer.bounds = trackLayer.bounds
        maskLayer.position = trackLayer.position
        outlineLayer.bounds = trackLayer.bounds
        outlineLayer.position = trackLayer.position
        updateMaskAndOutlineLayerPath()
        
        thumbGradientLayer.bounds = trackLayer.bounds
        thumbGradientLayer.position = trackLayer.position
        
        thumbLayer.bounds = trackLayer.bounds
        thumbLayer.position = trackLayer.position
        thumbMaskLayer.bounds = trackLayer.bounds
        thumbMaskLayer.position = trackLayer.position
        thumbOutlineLayer.bounds = trackLayer.bounds
        thumbOutlineLayer.position = trackLayer.position
        updateThumbLayerPath()
        
        if (gradientTintColors?.count ?? 0) >= 2 {
            updateGradientAxisPoints()
        }
        
        if let value = tactileSlider?.value {
            setValue(value)
        }
        
        CATransaction.commit()
    }
    
    internal func setValue(_ value: Float, animated: Bool = false) {
        CATransaction.begin()
        
        if animated {
            CATransaction.setAnimationTimingFunction(Self.valueChangeTimingFunction)
        } else {
            CATransaction.setDisableActions(true)
        }
        
        let valueAxisOffset = tactileSlider!.valueAxisFrom(CGPoint(x: thumbLayer.bounds.width, y: thumbLayer.bounds.height), accountForDirection: true)
        let valueAxisAmount = tactileSlider!.positionForValue(value)
        let reverseOffset = (tactileSlider!.reverseValueAxis && !tactileSlider!.vertical) || (!tactileSlider!.reverseValueAxis && tactileSlider!.vertical)
        let position = tactileSlider!.pointOnSlider(valueAxisPosition: valueAxisAmount - (reverseOffset ? 0 : valueAxisOffset), offAxisPosition: 0)
        
        let translate = CATransform3DTranslate(CATransform3DIdentity, position.x, position.y, 0)
        thumbLayer.transform = translate
        thumbMaskLayer.transform = translate
        
        updateThumbGradientLocations(for: value)
        
        CATransaction.commit()
    }
    
    internal func updateResolvedGradientColors() {
        guard gradientTintColors != nil else {
            return
        }
        applyGradientColorsFromTraitCollection()
    }
    
    private func configureGradientTintMode() {
        let enabled = (gradientTintColors?.count ?? 0) >= 2
        thumbGradientLayer.isHidden = !enabled
        if enabled {
            thumbGradientLayer.mask = thumbMaskLayer
            applyGradientColorsFromTraitCollection()
            updateGradientAxisPoints()
            if let value = tactileSlider?.value {
                updateThumbGradientLocations(for: value)
            }
        } else {
            thumbGradientLayer.mask = nil
        }
        applyThumbFillColor()
    }
    
    private func applyThumbFillColor() {
        let enabled = (gradientTintColors?.count ?? 0) >= 2
        if enabled {
            thumbLayer.fillColor = UIColor.clear.cgColor
        } else {
            thumbLayer.fillColor = thumbTint.cgColor
        }
    }
    
    private func applyGradientColorsFromTraitCollection() {
        guard let colors = gradientTintColors, colors.count >= 2 else {
            return
        }
        let pair = Array(colors.prefix(2))
        let traits = tactileSlider?.traitCollection
        thumbGradientLayer.colors = pair.map { color in
            if #available(iOS 13.0, *), let traits = traits {
                return color.resolvedColor(with: traits).cgColor
            }
            return color.cgColor
        }
    }
    
    private func updateGradientAxisPoints() {
        guard let slider = tactileSlider else {
            thumbGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            thumbGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            return
        }
        switch (slider.vertical, slider.reverseValueAxis) {
        case (false, false):
            thumbGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            thumbGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        case (false, true):
            thumbGradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
            thumbGradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
        case (true, false):
            thumbGradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
            thumbGradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        case (true, true):
            thumbGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            thumbGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        }
    }
    
    private func updateThumbGradientLocations(for value: Float) {
        guard (gradientTintColors?.count ?? 0) >= 2, let slider = tactileSlider else {
            return
        }
        let span = slider.maximum - slider.minimum
        let normalized = span != 0 ? CGFloat((value - slider.minimum) / span) : 0
        let clamped = max(0.001, min(1, normalized))
        thumbGradientLayer.locations = [0, NSNumber(value: Double(clamped))]
    }
}
