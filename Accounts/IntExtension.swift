//
//  IntExtension.swift
//  Accounts
//
//  Created by Alex Bechmann on 25/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

extension Double {
    
    func toDecimalString(decimals: Int) -> String {
        return String(format: "%.\(decimals)f", self)
    }
}
