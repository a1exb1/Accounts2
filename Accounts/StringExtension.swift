//
//  StringExtension.swift
//  Accounts
//
//  Created by Alex Bechmann on 12/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

extension String {
    
    func count() -> Int {
        
        return self.utf16Count
    }
}
