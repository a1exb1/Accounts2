//
//  Formatter.swift
//  Accounts
//
//  Created by Alex Bechmann on 10/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit

class Formatter: NSObject {
   
    class func formatCurrencyAsString(value: Double) -> String {
        
        return "£\(value.toStringWithDecimalPlaces(2))"
    }
    
}
