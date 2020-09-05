//
//  UserSettingsViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 11/6/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import Eureka

class ForgotPasswordFormViewController : FormViewController {
    let EMAIL_TAG = "email"

    var loginController : LoginViewController?
    
    func generateForm() {        
        form +++ Section("Your Info") { section  in
            //section.color   = UIColor.lightOrangeColor()
        }
            <<< EmailRow(EMAIL_TAG) {
                $0.title = "Email"
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_email")
                }
        
        form +++ Section("")
            <<< ButtonRow("transfer") { $0.title = "Email Link" }.onCellSelection { cell, row in
                self.saveForgotPassword()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.generateForm()
        self.setUpMenuBarController()
        
        self.navigationItem.title = "Change Password"
        self.navigationItem.leftBarButtonItem = self.getNavBarItem(imageId: "icon_close", action: #selector(ForgotPasswordFormViewController.cancel), height: 25, width: 25)
    }

    func saveForgotPassword() {
        if let emailValue = self.form.rowBy(tag: self.EMAIL_TAG)?.baseValue as? String {
//            WRUser.requestPasswordResetForEmail(inBackground: emailValue)
            self.requestPasswordReset(email: emailValue)
           
        } else {
            self.showError(message: "Please enter your email address")
        }
    }
    
    
    func requestPasswordReset( email: String){
        let params = ["email": email] as [String : Any]
          let url =  FORGETPASSWORD
          self.view.endEditing(true)
        self.showLoader()
          GraphQLServiceManager.sharedManager.createGraphQLRequestWith(query: url, variableParam: params, success: { (response) in
            self.hideLoader()
              guard let dataToParse = response else {
                  return
              }
              do {
                  let data = try JSONSerialization.jsonObject(with: dataToParse, options: .mutableLeaves)
                 if let userData = ((data as? [String:Any])?["data"] as? [String:Any])?["forgotEmail"] as? [String:Any]{
                    print(userData)
                    self.dismiss(animated: true, completion: { () -> Void in
                        self.loginController?.showSuccess(message: userData["message"] as? String ?? "")
                    })
                  }
                 
              } catch let error {
                  print(error.localizedDescription)
              }
              
          }) { (error) in
            self.hideLoader()
            self.showSuccess(message: error.userInfo["errorMessage"] as? String ?? error.localizedDescription)
          }
      }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
