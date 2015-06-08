//
//  FormViewTextFieldTableViewCell.swift
//  topik-ios
//
//  Created by Alex Bechmann on 31/05/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit

let kPadding: CGFloat = 10

public protocol FormViewCellDelegate {
    
    func valueDidChange(identifier: String, value: AnyObject)
}

public class FormViewTableViewCell: UITableViewCell {

    public var label = UILabel()
    public var textField = UITextField()
    public var configuation = FormViewConfiguration()
    public var delegate: FormViewCellDelegate?
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(label)
        
        textField.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(textField)
        textField.textAlignment = NSTextAlignment.Right
        
        setupLabelConstraints()
        setupTextFieldConstraints()
        
        textField.addTarget(self, action: "textFieldChanged:", forControlEvents: UIControlEvents.EditingChanged)
    }

    // MARK: - Constraints
    
    public func setupLabelConstraints() {
        
        label.addTopConstraint(toView: contentView, relation: .Equal, constant: 0)
        label.addLeftConstraint(toView: contentView, relation: .Equal, constant: kPadding)
        label.addBottomConstraint(toView: contentView, relation: .Equal, constant: 0)
        label.addWidthConstraint(relation: .Equal, constant: 160)
    }
    
    public func setupTextFieldConstraints() {
        
        textField.addTopConstraint(toView: contentView, relation: .Equal, constant: 0)
        textField.addLeftConstraint(toView: label, attribute: NSLayoutAttribute.Right, relation: .Equal, constant: 0)
        textField.addRightConstraint(toView: contentView, relation: .Equal, constant: -kPadding)
        textField.addBottomConstraint(toView: contentView, relation: .Equal, constant: 0)
    }
    
    public func textFieldChanged(textField: UITextField) {
        
        delegate?.valueDidChange(configuation.identifier, value: textField.text)
    }
}
