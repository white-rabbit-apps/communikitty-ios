//
//  LoginViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/14/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import ParseFacebookUtilsV4
//import ParseTwitterUtils


class LoginViewController: UIViewController, UITextFieldDelegate {
    let permissions = ["public_profile", "email", "user_location", "user_friends"]

//    var menuController: HomeViewController?
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var viewWasMoved: Bool = false
    var activeTextField: UITextField!
    
    var completionBlock: () -> Void
    
    required init?(coder aDecoder: NSCoder) {
        self.completionBlock = {}
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        
        if activeTextField != nil {
            if viewWasMoved == false {
                self.viewWasMoved = true
                self.view.frame.origin.y -= keyboardSize!.height/2
            }
        } else {
            self.viewWasMoved = false
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if (self.viewWasMoved){
            if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y += keyboardSize.height/2
                self.viewWasMoved = false
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userDefaults = UserDefaults.standard

        if !userDefaults.bool(forKey: "walkthroughPresented") {
            showWalkthrough()
            
            userDefaults.set(true, forKey: "walkthroughPresented")
            userDefaults.synchronize()
        }
    }
    
    @IBAction func showForgotPasswordForm() {
        let nav = UINavigationController()
        let forgotPasswordForm = ForgotPasswordFormViewController()
        forgotPasswordForm.loginController = self
        nav.viewControllers = [forgotPasswordForm]
        
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func closeView() {
        self.close()
    }
    
    @IBAction func showWalkthrough(){
        // Get view controllers and build the walkthrough
        let userDefaults = UserDefaults.standard
        userDefaults.set(false, forKey: "walkthroughPresented")
        userDefaults.synchronize()
        
        (AppDelegate.getAppDelegate()).loadMainController()
    }
    
    func walkthroughPageDidChange(_ pageNumber: Int) {
    }
    
    @IBAction func walkthroughCloseButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if (textField === usernameField)
        {
            textField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        } else if(textField == passwordField) {
            passwordField.resignFirstResponder()
            passwordField.endEditing(true)
            self.loginWithUsername(self)
        }
        return true
    }
    
    @IBAction func loginWithUsername(_ sender: AnyObject) {
        self.loginWithEmail()
    }
    
    func loginWithEmail() {
        self.showLoader()
        let query: PFQuery = WRUser.query()!
        let usernameValue = usernameField.text!.lowercased().trim()
        query.whereKey("email", equalTo: usernameValue)
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if objects != nil && objects!.count > 0 {
                let object: PFObject = objects![0]
                let username: String = (object["username"] as! String)
                
                WRUser.logInWithUsername(inBackground: username, password: self.passwordField.text!) { (user: PFUser?, error: Error?) -> Void in
                    self.hideLoader()
                    if error != nil {
                        self.showError(message: error!.localizedDescription)
                    } else if user != nil {
                        self.view.endEditing(true)
                        self.goToHome()
                        self.closeAndRun(completion: {
                            self.completionBlock()
                            AppDelegate.getAppDelegate().postLogin()
                        })
                    }
                }
                
            } else {
                let email = self.usernameField.text!.lowercased()
                WRUser.logInWithUsername(inBackground: email, password: self.passwordField.text!) { (user: PFUser?, error: Error?) -> Void in
                    self.hideLoader()
                    if error != nil {
                        self.showError(message: error!.localizedDescription)
                    } else if user != nil {
                        self.view.endEditing(true)
                        self.goToHome()
                        self.closeAndRun(completion: {
                            self.completionBlock()
                            AppDelegate.getAppDelegate().postLogin()
                        })
                    }
                }
            }
        }
        
    }
    
    @IBAction func loginWithFacebook(_ sender: UIButton) {
        self.loginWithFacebook()
    }
    
    func loginWithFacebook() {
        self.showLoader()
        PFFacebookUtils.facebookLoginManager().loginBehavior = FBSDKLoginBehavior.systemAccount
        
        PFFacebookUtils.logInInBackground(withReadPermissions: self.permissions) { (user: PFUser?, error: Error?) in
            self.hideLoader()
            if error != nil {
                self.showError(message: error!.localizedDescription)
            } else if user!.isNew {
                NSLog("User signed up and logged in through Facebook! \(user!.username)")
                self.saveUserDataFromFacebook()
            } else {
                NSLog("User logged in through Facebook! \(user!.username)")
                self.closeAndRun(completion: {
                    self.completionBlock()
                    AppDelegate.getAppDelegate().postLogin()
                })
//                self.goToHome()
                //                self.saveUserDataFromFacebook()
            }
        }
        
    }
    
//    @IBAction func loginWithTwitter(_ sender: UIButton) {
//        PFTwitterUtils.logIn { (user: PFUser?, error: Error?) -> Void in
//            if(error != nil) {
//                self.showError(message: error!.localizedDescription)
//            }
//            
//            if let user = user {
//                if user.isNew {
//                    NSLog("User signed up and logged in with Twitter.")
//                    self.goToHome()
//                } else {
//                    NSLog("Existing user logged in with Twitter.")
//                    self.goToHome()
//                }
//            } else {
//                NSLog("Uh oh. The user cancelled the Twitter login.")
//            }
//        }
//    }
//    
//    func saveUserDataFromTwitter(user: PFUser) {
//        let currentUser = user //PFUser.currentUser()!
//        
//        if PFTwitterUtils.isLinkedWithUser(currentUser) {
//            
//            let screenName = PFTwitterUtils.twitter()?.screenName!
//            
//            let requestString = ("https://api.twitter.com/1.1/users/show.json?screen_name=" + screenName!)
//            
//            let verify: NSURL = NSURL(string: requestString)!
//            let request: NSMutableURLRequest = NSMutableURLRequest(URL: verify)
//            PFTwitterUtils.twitter()?.signRequest(request)
//            
//            var response: NSURLResponse?
//            var error: NSError?
//            var data: NSData?
//            var result: NSDictionary?
//            do {
//                data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
//                result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
//            } catch _ {
//                NSLog("Error getting data from twitter")
//            }
//            
//            if error == nil {
//                let names: String! = result?.objectForKey("name") as! String
//                
//                let separatedNames: [String] = names.componentsSeparatedByString(" ")
//                
//                currentUser.setValue(separatedNames.first!, forKey: "firstName")
//                currentUser.setValue(separatedNames.last!, forKey: "lastName")
//                
////                let urlString = result?.objectForKey("profile_image_url_https") as! String
////                let hiResUrlString = urlString.stringByReplacingOccurrencesOfString("_normal", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
////                
////                let twitterPhotoUrl = NSURL(string: hiResUrlString)
////                let imageData = NSData(contentsOfURL: twitterPhotoUrl!)
////                let twitterImage: UIImage! = UIImage(data:imageData!)
//                
//                
//                currentUser.saveInBackgroundWithBlock({
//                    (success: Bool, error: NSError?) -> Void in
//                    if(success) {
//                        NSLog("success saving user info from twitter")
//                    } else {
//                        NSLog("error saving user info from twitter: \(error)")
//                    }
//                })
//            }
//        }
//    }
    
    func saveUserDataFromFacebook() {
        
        let fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,name,first_name,last_name,gender"])
        _ = fbRequest?.start(completionHandler: { (FBSDKGraphRequestConnection, result, error) -> Void in
            
            if (error == nil && result != nil) {
                let facebookData = result as! NSDictionary //FACEBOOK DATA IN DICTIONARY
                let fbId = (facebookData.object(forKey: "id") as? String)
                let first_name = (facebookData.object(forKey: "first_name") as? String)
                let last_name = (facebookData.object(forKey: "last_name") as? String)
                let email = (facebookData.object(forKey: "email") as? String)?.lowercased()
                let username = first_name!.lowercased() + last_name!.lowercased()
                
                let user = WRUser.current()!
                
                let userQuery = WRUser.query()!
                userQuery.whereKey("email", equalTo: email!)
                userQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) -> Void in
                    
                    if (objects?.count)! > 0 {
                        // delete the user that was created as part of Parse's Facebook login
                        user.deleteInBackground(block: { (success: Bool, error: Error?) -> Void in
                            if success {
                                
                                self.showError(message: "You already created an account by email.  Please login and connect your account in settings.")
                                
//                                PFFacebookUtils.linkUserInBackground(oldUser, withReadPermissions: self.permissions, block: { (success: Bool, error: NSError?) -> Void in
//                                    if success {
//                                        self.loginWithFacebook()
//                                    } else {
//                                        self.showError(error!.localizedDescription)
//                                    }
//                                })
                            }
                        })
                    } else {
                        user.email = email
                        user.firstName = first_name
                        user.lastName = last_name
                        user.username = username
                        user.facebookId = fbId
                        user.admin = false
                        
                        if let url = URL(string: "https://graph.facebook.com/\(fbId!)/picture?width=300&height=300") {
                            if let data = try? Data(contentsOf: url){
                                
                                let fileName:String = fbId! + ".jpg"
                                let imageFile:PFFile = PFFile(name: fileName, data: data)!
                                
                                user.profilePhoto = imageFile
                            }
                        }
                        
                        user.saveInBackground(block: {
                            (success: Bool, error: Error?) -> Void in
                            if(success) {
                                NSLog("success saving user info from facebook")
                                self.goToHome()
                            } else {
                                self.showError(message: error!.localizedDescription)
                            }
                        })
                    }
                })
            }
        })
    }
    
    func goToHome() {
        let appDelegate = AppDelegate.getAppDelegate()
        appDelegate.loadMainController()
        self.playASound(soundName: "purr1", vibrate: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
