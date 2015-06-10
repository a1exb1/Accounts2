//
//  FormViewConfiguration.swift
//  Pods
//
//  Created by Alex Bechmann on 09/06/2015.
//
//

import UIKit

public enum FormCellType {
    
    case None
    case DatePicker
    case TextField
    case TextFieldCurrency
    case Button
}

public class FormViewConfiguration {
    
    var labelText: String = ""
    var formCellType = FormCellType.TextField
    var value: AnyObject?
    var identifier: String = ""
    
    //currency
    var currencyLocale = NSLocale(localeIdentifier: "en_GB")
    
    //button
    var buttonTextColor = UIColor.blueColor()
    
    private convenience init(labelText: String, formCellType: FormCellType, value: AnyObject?, identifier: String) {
        
        self.init()
        self.labelText = labelText
        self.formCellType = formCellType
        self.value = value
        self.identifier = identifier
    }
    
    public class func date(labelText: String, date: NSDate?, identifier: String) -> FormViewConfiguration {
        
        return FormViewConfiguration(labelText: labelText, formCellType: FormCellType.DatePicker, value: date, identifier: identifier)
    }
    
    public class func textField(labelText: String, value: String?, identifier: String) -> FormViewConfiguration {
        
        return FormViewConfiguration(labelText: labelText, formCellType: FormCellType.TextField, value: value, identifier: identifier)
    }
    
    public class func textFieldCurrency(labelText: String, value: String?, identifier: String) -> FormViewConfiguration {
        
        return textFieldCurrency(labelText, value: value, identifier: identifier, locale: nil)
    }
    
    public class func textFieldCurrency(labelText: String, value: String?, identifier: String, locale: NSLocale?) -> FormViewConfiguration {
        
        let config = FormViewConfiguration(labelText: labelText, formCellType: FormCellType.TextFieldCurrency, value: value, identifier: identifier)
        
        if let l = locale {
            
            config.currencyLocale = l
        }
        
        return config
    }
    
    public class func button(buttonText: String, buttonTextColor: UIColor, identifier: String) -> FormViewConfiguration {
        
        let config = FormViewConfiguration(labelText: buttonText, formCellType: FormCellType.Button, value: nil, identifier: identifier)
        config.buttonTextColor = buttonTextColor
        
        return config
    }
    
    public class func normalCell(identifier: String) -> FormViewConfiguration {
        
        return FormViewConfiguration(labelText: "", formCellType: FormCellType.None, value: nil, identifier: identifier)
    }
}