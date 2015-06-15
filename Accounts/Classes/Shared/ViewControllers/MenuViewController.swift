//
//  MenuViewController.swift
//  Accounts
//
//  Created by Alex Bechmann on 07/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import ABToolKit
import SwiftyUserDefaults

private let kCurrencySection = 0
private let kCompresJSONSettingsSection = 1
private let kLogoutSection = 2

private let kCurrencyIndexPath = NSIndexPath(forRow: 0, inSection: kCurrencySection)

private let kCompresJSONEncryptIndexPath = NSIndexPath(forItem: 0, inSection: kCompresJSONSettingsSection)
private let kCompresJSONCompressIndexPath = NSIndexPath(forItem: 1, inSection: kCompresJSONSettingsSection)
private let kAcceptEncodingIndexPath = NSIndexPath(forItem: 2, inSection: kCompresJSONSettingsSection)

private let kLogoutIndexPath = NSIndexPath(forRow: 0, inSection: kLogoutSection)


class MenuViewController: ACBaseViewController {

    var tableView = UITableView(frame: CGRectZero, style: .Grouped)
    let data = [
        [kCurrencyIndexPath],
        [kCompresJSONEncryptIndexPath, kCompresJSONCompressIndexPath, kAcceptEncodingIndexPath],
        [kLogoutIndexPath]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView(tableView, delegate: self, dataSource: self)
        
        addCloseButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return data.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueOrCreateReusableCellWithIdentifier("Cell", requireNewCell: { (identifier) -> (UITableViewCell) in
            
            return UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        })
        
        setupTableViewCellAppearance(cell)
        
        if indexPath == kCurrencyIndexPath {
            
            cell.textLabel?.text = "Currency"
            cell.detailTextLabel?.text = Defaults[kCurrencySettingKey].string
            cell.accessoryType = .DisclosureIndicator
        }
        
        else if indexPath == kLogoutIndexPath {
            
            cell.textLabel?.text = "Logout"
            cell.detailTextLabel?.text = "Logged in as \(kActiveUser.Username)"
        }
        
        if indexPath.section == kCompresJSONSettingsSection {
            
            let settings = Settings.getCompresJSONSettings()
            
            if indexPath == kCompresJSONEncryptIndexPath {
                
                cell.textLabel?.text = "Use CompresJSON Encryption"
                cell.detailTextLabel?.text = "\(settings.compresJSONEncrypt)"
            }
            if indexPath == kCompresJSONCompressIndexPath {
                
                cell.textLabel?.text = "Use CompresJSON Compression"
                cell.detailTextLabel?.text = "\(settings.compresJSONCompress)"
            }
            if indexPath == kAcceptEncodingIndexPath {
                
                cell.textLabel?.text = "Accept encoding"
                cell.detailTextLabel?.text = "\(settings.acceptEncoding)"
            }
            
            cell.accessoryType = .DisclosureIndicator
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath == kCurrencyIndexPath {
            
            let v = SelectCurrencyViewController()
            navigationController?.pushViewController(v, animated: true)
        }
        if indexPath == kLogoutIndexPath {
            
            UIAlertController.showAlertControllerWithButtonTitle("Logout", confirmBtnStyle: UIAlertActionStyle.Destructive, message: "Are you sure you want to logout?", completion: { (response) -> () in
                
                if response == AlertResponse.Confirm {
                    
                    kActiveUser.logout()
                    
                    let v = UIStoryboard.initialViewControllerFromStoryboardNamed("Login")
                    self.presentViewController(v, animated: true, completion: nil)
                }
            })
        }
        
        if indexPath.section == kCompresJSONSettingsSection {
            
            let settings = Settings.getCompresJSONSettings()
            
            if indexPath == kCompresJSONEncryptIndexPath {
                
                let v = BoolSettingViewController(identifier: kCompresJSONSettingsKeys.compresJSONEncryptKey, currentValue: settings.compresJSONEncrypt, title: "Use CompresJSON Encryption")
                v.delegate = self
                navigationController?.pushViewController(v, animated: true)
            }
            if indexPath == kCompresJSONCompressIndexPath {
                
                let v = BoolSettingViewController(identifier: kCompresJSONSettingsKeys.compresJSONCompressKey, currentValue: settings.compresJSONCompress, title: "Use CompresJSON Compression")
                v.delegate = self
                navigationController?.pushViewController(v, animated: true)
            }
            if indexPath == kAcceptEncodingIndexPath {
                
                navigationController?.pushViewController(AcceptEncodingSettingViewController(), animated: true)
            }
        }
    }
}

extension MenuViewController: BoolSettingDelegate {
    
    func didSelectBoolWithIdentifier(identifier: String, value: Bool) {
        
        if identifier == kCompresJSONSettingsKeys.compresJSONEncryptKey {
            
            Settings.setCompresJSONEncryption(value)
        }
        
        if identifier == kCompresJSONSettingsKeys.compresJSONCompressKey {
            
            Settings.setCompresJSONCompression(value)
        }
        
        tableView.reloadData()
    }
}