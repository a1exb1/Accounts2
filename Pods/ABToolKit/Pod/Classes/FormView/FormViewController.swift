//
//  FormViewController.swift
//  topik-ios
//
//  Created by Alex Bechmann on 31/05/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//


import UIKit
import ABToolKit

public enum FormCellType {
    
    case None
    case DatePicker
    case TextField
}

public class FormViewConfiguration {
    
    var labelText: String = ""
    var formCellType = FormCellType.TextField
    var value: AnyObject?
    var identifier: String = ""
    
    
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
}

public protocol FormViewDelegate {
    
    func formViewElements() -> Array<Array<FormViewConfiguration>>
    func formViewElementChanged(identifier: String, value: AnyObject)
}

public class FormViewController: BaseViewController {
    
    var tableView = UITableView(frame: CGRectZero, style: .Grouped)
    var data: Array<Array<FormViewConfiguration>> = []
    var selectedIndexPath: NSIndexPath?
    public var formViewDelegate: FormViewDelegate?
    //var editingObjectToConfiguation: Dictionary<AnyObject, FormViewConfiguration> = []
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView(tableView, delegate: self, dataSource: self)
        reloadForm()
    }
    
    public func reloadForm() {
        
        if let elements = formViewDelegate?.formViewElements() {
            
            data = elements
        }
        
        tableView.reloadData()
    }
    
    override public func setupTableView(tableView: UITableView, delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        super.setupTableView(tableView, delegate: delegate, dataSource: dataSource)
        
        tableView.registerClass(FormViewTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.allowsSelectionDuringEditing = true
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }
}

extension FormViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let configuration:FormViewConfiguration = data[indexPath.section][indexPath.row]
        
        if configuration.formCellType == FormCellType.DatePicker {
            
            if let path = selectedIndexPath {
                
                if indexPath == path {
                    
                    return 100
                }
            }
        }
        
        return 44
    }

    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return data.count
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data[section].count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! FormViewTableViewCell
        let config:FormViewConfiguration = data[indexPath.section][indexPath.row]
        
        cell.delegate = self
        cell.configuation = config
        
        cell.label.text = config.labelText
        cell.textField.text = config.value as! String
        
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedIndexPath = selectedIndexPath != indexPath ? indexPath : nil
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension FormViewController: FormViewCellDelegate {
    
    public func valueDidChange(identifier: String, value: AnyObject) {
        
        formViewDelegate?.formViewElementChanged(identifier, value: value)
    }
}
