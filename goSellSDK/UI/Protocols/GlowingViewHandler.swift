//
//  GlowingViewHandler.swift
//  goSellSDK
//
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import struct   CoreGraphics.CGBase.CGFloat
import class    CoreGraphics.CGColor.CGColor
import class    QuartzCore.CAAnimation.CABasicAnimation
import class    QuartzCore.CALayer.CALayer
import struct   TapAdditionsKit.TypeAlias
import class    UIKit.UIColor.UIColor
import class    UIKit.UIView.UIView

/// Glowing View Handler protocol.
@objc internal protocol GlowingViewHandler: NSObjectProtocol {
    
    /// View to which glowing animation will be added.
    var glowingView: UIView { get }
    
    /// Glow color.
    @objc optional var glowColor: UIColor { get }
    
    /// Glow radius.
    @objc optional var glowRadius: CGFloat { get }
}

/// Always Glowing View Handler protocol.
@objc internal protocol AlwaysGlowingViewHandler: GlowingViewHandler {
    
    /// Standart glow color.
    var standartGlowColor: UIColor { get }
    
    /// Standart glow radius.
    @objc optional var standartGlowRadius: CGFloat { get }
}

// MARK: - Glowing implementation
internal extension GlowingViewHandler {
    
    // MARK: - Internal -
    // MARK: Methods
    
    internal func prepareForGlowing() {
        
        self.glowingView.layer.shadowOffset = .zero
        
        if let alwaysGlowingSelf = self as? AlwaysGlowingViewHandler {
            
            alwaysGlowingSelf.prepareForGlowing()
        }
        else {
            
            self.glowingView.layer.shadowOpacity = 0.0
            self.glowingView.layer.shadowColor = self.glowColorToApply.cgColor
            self.glowingView.layer.shadowRadius = self.glowRadiusToApply
        }
    }
    
    internal func setGlowing(_ glowing: Bool) {
        
        if glowing {
            
            self.startGlowing()
        }
        else {
            
            self.stopGlowing()
        }
    }
    
    internal func startGlowing() {
        
        let animations = self.createRequiredAnimations(true)
        
        animations.forEach { let animationKey = ($0.0.keyPath ?? "glow") + "Animation"; self.glowingView.layer.add($0.0, forKey: animationKey) }
        animations.forEach { $0.1() }
    }
    
    internal func stopGlowing() {
        
        let animations = self.createRequiredAnimations(false)
        
        animations.forEach { let animationKey = ($0.0.keyPath ?? "glow") + "Animation"; self.glowingView.layer.add($0.0, forKey: animationKey) }
        animations.forEach { $0.1() }
    }
    
    // MARK: - Fileprivate -
    
    fileprivate typealias AnimationWithLayerModificationClosure = (CABasicAnimation, TypeAlias.ArgumentlessClosure)
    
    // MARK: Properties
    
    fileprivate var glowColorToApply: UIColor {
        
        return self.glowColor ?? GlowingCellConstants.defaultGlowColor
    }
    
    fileprivate var glowRadiusToApply: CGFloat {
        
        return self.glowRadius ?? GlowingCellConstants.defaultGlowRadius
    }
    
    // MARK: Methods
    
    fileprivate func createRequiredAnimations(_ startGlowing: Bool) -> [AnimationWithLayerModificationClosure] {
        
        if let alwaysGlowingSelf = self as? AlwaysGlowingViewHandler {
            
            return alwaysGlowingSelf.createRequiredAnimations(startGlowing)
        }
        else {
            
            return [self.createShadowOpacityAnimation(startGlowing)]
        }
    }
    
    fileprivate func createAnimation<PropertyType>(for keyPath: ReferenceWritableKeyPath<CALayer, PropertyType>, from fromValue: PropertyType, to toValue: PropertyType, on theLayer: CALayer) -> AnimationWithLayerModificationClosure {
        
        let keypathString               = NSExpression(forKeyPath: keyPath).keyPath
        
        let animation                   = CABasicAnimation(keyPath: keypathString)
        animation.fromValue             = fromValue
        animation.toValue               = toValue
        animation.duration              = GlowingCellConstants.glowAnimationDuration
        animation.isRemovedOnCompletion = true
        
        let layerModificationClosure: TypeAlias.ArgumentlessClosure = { [weak theLayer] in
            
            theLayer?[keyPath: keyPath] = toValue
        }
        
        return (animation, layerModificationClosure)
    }
    
    // MARK: - Private -
    // MARK: Methods
    
    private func createShadowOpacityAnimation(_ startGlowing: Bool) -> AnimationWithLayerModificationClosure {
        
        let keyPath             = \CALayer.shadowOpacity
        let fromValue: Float    = self.glowingView.layer.presentation()?.shadowOpacity ?? (startGlowing ? 0.0 : 1.0)
        let toValue:   Float    = startGlowing ? 1.0 : 0.0
        
        return self.createAnimation(for: keyPath, from: fromValue, to: toValue, on: self.glowingView.layer)
    }
}

// MARK: - Always glowing implementation
extension AlwaysGlowingViewHandler {
    
    // MARK: - Internal -
    // MARK: Methods
    
    internal func prepareForGlowing() {
        
        self.glowingView.layer.shadowOpacity = 1.0
        self.glowingView.layer.shadowColor = self.standartGlowColor.cgColor
        self.glowingView.layer.shadowRadius = self.standartGlowRadiusToApply
    }
    
    // MARK: - Fileprivate -
    // MARK: Methods
    
    fileprivate func createRequiredAnimations(_ startGlowing: Bool) -> [GlowingViewHandler.AnimationWithLayerModificationClosure] {
        
        return [
        
            self.createShadowRadiusAnimation(startGlowing),
            self.createShadowColorAnimation(startGlowing)
        ]
    }
    
    // MARK: - Private -
    // MARK: Properties
    
    private var standartGlowRadiusToApply: CGFloat {
        
        return self.standartGlowRadius ?? self.glowRadiusToApply
    }
    
    // MARK: Methods
    
    private func createShadowRadiusAnimation(_ startGlowing: Bool) -> GlowingViewHandler.AnimationWithLayerModificationClosure {
        
        let keyPath     = \CALayer.shadowRadius
        let fromValue   = self.glowingView.layer.presentation()?.shadowRadius ?? (startGlowing ? self.standartGlowRadiusToApply : self.glowRadiusToApply)
        let toValue     = startGlowing ? self.glowRadiusToApply : self.standartGlowRadiusToApply
        
        return self.createAnimation(for: keyPath, from: fromValue, to: toValue, on: self.glowingView.layer)
    }
    
    private func createShadowColorAnimation(_ startGlowing: Bool) -> GlowingViewHandler.AnimationWithLayerModificationClosure {
        
        let keyPath = \CALayer.shadowColor
        let fromValue: CGColor? = self.glowingView.layer.presentation()?.shadowColor ?? (startGlowing ? self.standartGlowColor : self.glowColorToApply).cgColor
        let toValue: CGColor? = (startGlowing ? self.glowColorToApply : self.standartGlowColor).cgColor
        
        return self.createAnimation(for: keyPath, from: fromValue, to: toValue, on: self.glowingView.layer)
    }
}

private struct GlowingCellConstants {
    
    fileprivate static let glowAnimationDuration: TimeInterval = 0.3
    
    fileprivate static let defaultGlowColor: UIColor = .hex("#2ACE00FF")!
    fileprivate static let defaultGlowRadius: CGFloat = 3.0
    
    @available(*, unavailable) private init() {}
}