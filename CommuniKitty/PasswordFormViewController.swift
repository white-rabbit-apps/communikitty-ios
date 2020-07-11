//
//  UserSettingsViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 11/6/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import Eureka

class PasswordFormViewController : FormViewController {
    
    let PASSWORD_TAG = "password"
    let PASSWORD_CONFIRM_TAG = "passwordConfirm"
    
    var userObject : WRUser?
    var settingsForm : UserFormViewController?
    
    func generateForm() {
        form +++ Section("Password") { section  in
            //section.color   = UIColor.lightOrangeColor()
        }
        <<< PasswordRow(PASSWORD_TAG) {
            $0.title = "Current Password"
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "form_password")
        }
        <<< PasswordRow(PASSWORD_TAG) {
            $0.title = "New Password"
        }.cellSetup { cell, row in
            cell.imageView?.image = UIImage(named: "form_password")
        }
        <<< PasswordRow(PASSWORD_CONFIRM_TAG) {
            $0.title = "Confirm New Password"
        }.cellSetup { cell, row in
            cell.imageView?.image = UIImage(named: "form_password")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.generateForm()
        self.setUpMenuBarController()
        
        self.navigationItem.title = "Change Password"
        self.navigationItem.leftBarButtonItem = self.getNavBarItem(imageId: "icon_close", action: #selector(PasswordFormViewController.cancel), height: 25, width: 25)

        self.navigationItem.rightBarButtonItem = self.getNavBarItem(imageId: "icon_save", action: #selector(PasswordFormViewController.savePassword), height: 20, width: 25)
    }
    
    @objc func savePassword() {
        let user = self.userObject!
        
        let passwordValue = self.form.rowBy(tag: self.PASSWORD_TAG)?.baseValue as? String
        let passwordConfirmValue = self.form.rowBy(tag: self.PASSWORD_CONFIRM_TAG)?.baseValue as? String
        if passwordValue != passwordConfirmValue {
            self.showError(message: "Passwords must match.")
            return
        } else if passwordValue != nil {
            user.password = passwordValue!
        }
        
        self.showLoader()
        user.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
            if success {
                self.dismiss(animated: true, completion: nil)
                self.settingsForm!.showSuccess(message: "Password changed successfully.")
            } else {
                print("%@", error!)
                self.showError(message: error!.localizedDescription)
            }
            self.hideLoader()
        })

    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

}
