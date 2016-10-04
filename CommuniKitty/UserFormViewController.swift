//
//  UserSettingsViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 11/6/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import Eureka
import ParseFacebookUtilsV4

class UserFormViewController : FormViewController {
    
    let FIRST_NAME_TAG = "firstName"
    let LAST_NAME_TAG = "lastName"
    let EMAIL_TAG = "email"
    let PASSWORD_TAG = "password"
    let PASSWORD_CONFIRM_TAG = "passwordConfirm"
    let USERNAME_TAG = "username"
    let SHELTER_TAG = "shelter"
    let ADMIN_TAG = "admin"
    
    let FACEBOOK_TAG = "facebook"
    let TWITTER_TAG = "twitter"
    
    var userObject : WRUser?
//    var menuController : HomeViewController?
    
    let permissions = ["public_profile", "email", "user_location", "user_friends"]
    
    func isEditMode() -> Bool {
        return (self.userObject != nil)
    }
    
    
    func generateForm() {        
        form +++ Section("Info") { section  in
            section.color   = UIColor.lightOrangeColor()
        }
            <<< NameRow(FIRST_NAME_TAG) {
                $0.title = "First Name"
                if self.isEditMode() {
                    $0.value = self.userObject?.object(forKey: self.FIRST_NAME_TAG) as? String
                }
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_first_name")
                }
            <<< NameRow(LAST_NAME_TAG) {
                $0.title = "Last Name"
                if self.isEditMode() {
                    $0.value = self.userObject?.object(forKey: self.LAST_NAME_TAG) as? String
                }
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_last_name")
            }
            <<< EmailRow(EMAIL_TAG) {
                $0.title = "Email"
                if self.isEditMode() {
                    $0.value = self.userObject?.object(forKey: self.EMAIL_TAG) as? String
                }
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_email")
            }
            <<< NameRow(USERNAME_TAG) {
                $0.title = "Username"
                if self.isEditMode() {
                    $0.value = self.userObject?.object(forKey: self.USERNAME_TAG) as? String
                }
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_username")
            }
            
            
        if(!self.isEditMode()) {
            form +++ Section("Password") { section  in
                section.color   = UIColor.lightYellowColor()
            }
                <<< PasswordRow(PASSWORD_TAG) {
                    $0.title = "Password"
                    if self.isEditMode() {
                        $0.value = self.userObject?.object(forKey: self.PASSWORD_TAG) as? String
                    }
                    }.cellSetup { cell, row in
                        cell.imageView?.image = UIImage(named: "form_password")
                }
                <<< PasswordRow(PASSWORD_CONFIRM_TAG) {
                    $0.title = "Confirm Password"
                    if self.isEditMode() {
                        $0.value = self.userObject?.object(forKey: self.PASSWORD_CONFIRM_TAG) as? String
                    }
                    }.cellSetup { cell, row in
                        cell.imageView?.image = UIImage(named: "form_password")
                }
        }

//            <<< PushRow<String>(SHELTER_TAG) {
//                $0.title = "Shelter"
//                $0.options = appDelegate.sheltersArray!
//                $0.isHidden = .Function(["admin"], { form -> Bool in
//                    return self.isEditMode() && !(self.userObject?.valueForKey(self.ADMIN_TAG) as! Bool)
//                })
//                if self.isEditMode() {
//                    let shelterObject = self.userObject?.objectForKey(self.SHELTER_TAG) as? PFObject
//                    if(shelterObject != nil) {
//                        $0.value = shelterObject!.objectForKey("name") as? String
//                    }
//                }
//        }
        
        if(self.isEditMode()) {
            
            form +++ Section("Connections") { section  in
                section.color   = UIColor.lightGreenColor()
            }
                <<< ButtonRow(FACEBOOK_TAG) {
                    if(PFFacebookUtils.isLinked(with: WRUser.current()!)) {
                        $0.title = "Disconnect Facebook"
                    } else {
                        $0.title = "Connect to Facebook"
                    }
                }.onCellSelection { cell, row in
                    NSLog("Connecting to Facebook")
                    if(PFFacebookUtils.isLinked(with: WRUser.current()!)) {
                        self.disconnectFacebook()
                    } else {
                        self.connectFacebook()
                    }
                }
        
            var infoDict: [AnyHashable: Any] = Bundle.main.infoDictionary!
            let appVersion: String = (infoDict["CFBundleShortVersionString"] as! String)
            let buildNumber: String = (infoDict["CFBundleVersion"] as! String)

            form +++ Section("Account") { section  in
                section.color   = UIColor.lightBlueColor()
            }
                <<< ButtonRow("password") {
                        $0.title = "Change Password"
                    }.onCellSelection { cell, row in
                        NSLog("Deleting user")
                        self.showChangePasswordForm()
                    }
//                <<< ButtonRow("remove") {
//                        $0.title = "Delete Account"
//                        // $0.isHidden = .Function(["admin"], { form -> Bool in
//                        //     return !(self.userObject?.valueForKey(self.ADMIN_TAG) as! Bool)
//                        // })
//                    }.onCellSelection { cell, row in
//                        NSLog("Deleting user")
//                        self.removeUser()
//                    }
                <<< ButtonRow("logout") { $0.title = "Log Out" }.onCellSelection { cell, row in print("Cell was selected")
                    self.logout()
                }
        
            form +++ Section("About") { section  in
                section.color   = UIColor.lightPinkColor()
            }
                <<< ButtonRow("about") { $0.title = "About CommuniKitty" }.onCellSelection { cell, row in
                    self.openAboutScreen()
            }
            
            form +++ Section(header: "", footer: "v\(appVersion) (\(buildNumber))")
            
        }
    
    
    }

    func logout() {
        AppDelegate.getAppDelegate().postLogout()
        self.logout(completionBlock: { (result, error) in
            if(error == nil) {
                self.dismiss(animated: true, completion: {
//                    AppDelegate.getAppDelegate().postLogout()
                })
            } else {
                self.showError(message: error!.localizedDescription)
            }
        })
    }

    func openAboutScreen() {
        let aboutStoryboard = UIStoryboard(name: "About", bundle: nil)
        let aboutView = aboutStoryboard.instantiateViewController(withIdentifier: "AboutView") as! AboutViewController
        
        self.present(UINavigationController(rootViewController: aboutView), animated: true, completion: nil)
    }
    
    func connectFacebook() {
        PFFacebookUtils.facebookLoginManager().loginBehavior = FBSDKLoginBehavior.systemAccount
        
        self.showLoader()
        PFFacebookUtils.linkUser(inBackground: WRUser.current()!, withReadPermissions: self.permissions) { (success: Bool, error: Error?) -> Void in
            self.hideLoader()
            if success {
                self.saveUserDataFromFacebook()
                let row = self.form.rowBy(tag: self.FACEBOOK_TAG)
                row?.title = "Disconnect Facebook"
                row?.updateCell()
                self.showSuccess(message: "Successfully connected to Facebook")
            } else if (error != nil) {
                self.showError(message: error!.localizedDescription)
            }
        }
    }
    
    func saveUserDataFromFacebook() {
        let fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,name,first_name,last_name,gender"])
        _ = fbRequest?.start(completionHandler: { (FBSDKGraphRequestConnection, result, error) -> Void in
            
            if (error == nil && result != nil) {
                let facebookData = result as! NSDictionary //FACEBOOK DATA IN DICTIONARY
                let fbId = (facebookData.object(forKey: "id") as? String)
//                let first_name = (facebookData.objectForKey("first_name") as? String)
//                let last_name = (facebookData.objectForKey("last_name") as? String)
//                let email = (facebookData.objectForKey("email") as? String)?.lowercaseString
//                let username = first_name! + last_name!
                
                let user = WRUser.current()!

                user.facebookId = fbId
                
                if(user.profilePhoto == nil) {
                    if let url = URL(string: "https://graph.facebook.com/\(fbId!)/picture?width=300&height=300") {
                        if let data = try? Data(contentsOf: url){
                            
                            let fileName:String = fbId! + ".jpg"
                            let imageFile:PFFile = PFFile(name: fileName, data: data)!
                            
                            user.profilePhoto = imageFile
                        }
                    }
                }
                
                user.saveInBackground(block: {
                    (success: Bool, error: Error?) -> Void in
                    if(success) {
                        self.showSuccess(message: "Saved new user data from Facebook")
                    } else {
                        self.showError(message: error!.localizedDescription)
                    }
                })
            }
        })
    }
    
    func disconnectFacebook() {
        self.showLoader()
        PFFacebookUtils.unlinkUser(inBackground: WRUser.current()!) { (success: Bool, error: Error?) -> Void in
            self.hideLoader()
            if success {
                let row = self.form.rowBy(tag: self.FACEBOOK_TAG)
                row?.title = "Connect to Facebook"
                row?.updateCell()
                self.showSuccess(message: "Successfully disconnected from Facebook")
            } else if (error != nil) {
                self.showError(message: error!.localizedDescription)
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.generateForm()
        
        self.setUpNavigationBar()
        
        self.navigationItem.leftBarButtonItem = self.getNavBarItem(imageId: "icon_close", action: #selector(UserFormViewController.cancel), height: 25, width: 25)
        
        if !self.isEditMode() {
            self.navigationItem.title = "New User"
            self.navigationItem.leftBarButtonItem = self.getNavBarItem(imageId: "icon_close", action: #selector(UserFormViewController.cancel), height: 25, width: 25)

        } else {
            self.navigationItem.title = "Settings"
        }
        
        self.navigationItem.rightBarButtonItem = self.getNavBarItem(imageId: "icon_save", action: #selector(UserFormViewController.saveUser), height: 20, width: 25)
    }

    
    func saveUser() {
        let appDelegate = AppDelegate.getAppDelegate()

        var user = WRUser()
        let wasEditMode = self.isEditMode()
        if self.isEditMode() {
            user = self.userObject!
        }
        
        if let firstNameValue = self.form.rowBy(tag: self.FIRST_NAME_TAG)?.baseValue as? String {
            user.setObject(firstNameValue.trim(), forKey: FIRST_NAME_TAG)
        }
        if let lastNameValue = self.form.rowBy(tag: self.LAST_NAME_TAG)?.baseValue as? String {
            user.setObject(lastNameValue.trim(), forKey: LAST_NAME_TAG)
        }
        var usernameValue = self.form.rowBy(tag: self.USERNAME_TAG)?.baseValue as? String
        if usernameValue != nil {
            if usernameValue![0] == "@" {
                usernameValue = String(usernameValue!.characters.dropFirst())
            }

            user.setObject(usernameValue!.lowercased().trim(), forKey: USERNAME_TAG)
        }
        let emailValue = self.form.rowBy(tag: self.EMAIL_TAG)?.baseValue as? String
        if emailValue != nil {
            user.setObject(emailValue!.lowercased().trim(), forKey: EMAIL_TAG)
//            user.setObject(emailValue!, forKey: USERNAME_TAG)
        }
        let passwordValue = self.form.rowBy(tag: self.PASSWORD_TAG)?.baseValue as? String
        let passwordConfirmValue = self.form.rowBy(tag: self.PASSWORD_CONFIRM_TAG)?.baseValue as? String
        if passwordValue != passwordConfirmValue {
            self.showError(message: "Passwords must match.")
            return
        } else if passwordValue != nil {
            user.setObject(passwordValue!, forKey: PASSWORD_TAG)
        }
        
        if let shelterValue = self.form.rowBy(tag: self.SHELTER_TAG)?.baseValue as? String {
            let shelter = appDelegate.shelterByName![shelterValue]
            user.setObject(shelter!, forKey: SHELTER_TAG)
        }
        
        if(wasEditMode) {
            self.showLoader()
            user.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
                if success {
                    self.showSuccess(message: "User info saved.")

                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showError(message: error!.localizedDescription)
                }
                self.hideLoader()
            })
        } else {
            self.showLoader()
            user.signUpInBackground(block: { (success: Bool, error: Error?) -> Void in
                if success {
                    WRUser.logInWithUsername(inBackground: emailValue!.lowercased(), password: passwordValue!, block: { (user: PFUser?, error: Error?) -> Void in
                        self.dismiss(animated: true, completion: nil)
                        let appDelegate = AppDelegate.getAppDelegate()
                        appDelegate.loadMainController()
                    })
                    NSLog("signed up")
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print("%@", error!)
                    self.showError(message: error!.localizedDescription)
                }
                self.hideLoader()
            })
        }
    }
    
    func removeUser() {
        let refreshAlert = UIAlertController(title: "Remove?", message: "All data will be lost.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Do it", style: .default, handler: { (action: UIAlertAction!) in
            self.showLoader()
            self.userObject!.deleteInBackground(block: { (success: Bool, error: Error?) -> Void in
                self.hideLoader()
                self.showSuccess(message: "Deleted. KTHXBAI.")
                self.logout()
            })
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func showChangePasswordForm() {
        NSLog("showing change password form")
        
        let nav = UINavigationController()
        let passwordForm = PasswordFormViewController()
        passwordForm.userObject = self.userObject
        passwordForm.settingsForm = self
        nav.viewControllers = [passwordForm]
        
        self.present(nav, animated: true, completion: nil)
    }
    
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

}
