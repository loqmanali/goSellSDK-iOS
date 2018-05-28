//
//  AmountModificator.swift
//  goSellSDK
//
//  Copyright © 2018 Tap Payments. All rights reserved.
//

/// Amount modificator class, used for taxes and doscount models.
@objcMembers public class AmountModificator: NSObject, Codable {
    
    // MARK: - Public -
    // MARK: Properties
    
    /// Amount modificator type.
    public var type: AmountModificatorType
    
    /// Value.
    public var value: Decimal
    
    // MARK: Methods
    
    public init(type: AmountModificatorType, value: Decimal) {
        
        self.type = type
        self.value = value
        
        super.init()
    }
    
    // MARK: - Internal -
    // MARK: Properties
    
    internal var normalizedValue: Decimal {
        
        guard self.type == .percentBased else {
            
            fatalError("normalizedValue should never be called on \(AmountModificator.className) if it's type is not percentBased")
        }
        
        if self.value > 1.0 {
            
            return 0.01 * self.value
        }
        else {
            
            return self.value
        }
    }
    
    // MARK: - Private -
    
    private enum CodingKeys: String, CodingKey {
        
        case type   = "type"
        case value  = "value"
    }
}

// MARK: - NSCopying
extension AmountModificator: NSCopying {
    
    public func copy(with zone: NSZone? = nil) -> Any {
        
        return AmountModificator(type: self.type, value: self.value)
    }
}