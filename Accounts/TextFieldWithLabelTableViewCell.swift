//
//  TextFieldWithLabelTableViewCell.swift
//  Accounts
//
//  Created by Alex Bechmann on 20/04/2015.
//  Copyright (c) 2015 Ustwo. All rights reserved.
//

import UIKit

class TextFieldWithLabelTableViewCell: UITableViewCell {

    var label = UILabel()
    var textField = UITextField()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupCell()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell() {
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.label.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(self.label)

        self.label.addTopConstraint(toView: self.contentView, relation: .Equal, constant: 0)
        self.label.addLeftConstraint(toView: self.contentView, relation: .Equal, constant: 15)
        self.label.addBottomConstraint(toView: self.contentView, relation: .Equal, constant: 0)
        self.label.addWidthConstraint(relation: .Equal, constant: 100)
        
        self.textField.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(self.textField)
        
        self.textField.addTopConstraint(toView: self.contentView, relation: .Equal, constant: 0)
        self.textField.addLeftConstraint(toView: self.label, attribute: .Right, relation: .Equal, constant: 15)
        self.textField.addRightConstraint(toView: self.contentView, relation: .Equal, constant: -15)
        self.textField.addBottomConstraint(toView: self.contentView, relation: .Equal, constant: 0)
    }
    
}
