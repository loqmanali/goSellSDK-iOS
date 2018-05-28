//
//  PayButton.swift
//  goSellSDK
//
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import protocol TapAdditionsKit.ClassProtocol
import class UIKit.UIView.UIView

public protocol PayButtonProtocol: ClassProtocol {
    
    var isEnabled: Bool { get set }
}

internal extension PayButtonProtocol where Self: UIView {
    
    var view: UIView {
        
        return self
    }
}