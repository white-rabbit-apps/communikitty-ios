//
//  HomeViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/14/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import BWWalkthrough

class WalkthroughPage : BWWalkthroughViewController {
    
    var lvc : AppDelegate?
    
    @IBAction func closeWalkthrough(sender: AnyObject) {
//        lvc!.changeRootController()
    }
}

class HomeViewController: UIViewController,BWWalkthroughViewControllerDelegate {
    
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var animalsButton: UIButton!
    @IBOutlet weak var locationsButton: UIButton!
    @IBOutlet weak var careButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var imageProfileButton: UIButton!
        
    var mainViewController: UIViewController!
    var locationsViewController: UIViewController!
    var careViewController: UIViewController!
    var aboutViewController: UINavigationController!
    var storeViewController: UIViewController!

    var userFormController: UINavigationController!
    
    var currentUser: WRUser?
    var hasRegisteredForPush = false
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let storeStoryboard = UIStoryboard(name: "Store", bundle: nil)
        storeViewController = storeStoryboard.instantiateViewController(withIdentifier: "ProductsNavigation")
        
        let findStoryboard = UIStoryboard(name: "Locations", bundle: nil)
        locationsViewController = findStoryboard.instantiateViewController(withIdentifier: "LocationsMapView")

        let learnStoryboard = UIStoryboard(name: "Learn", bundle: nil)
        careViewController = learnStoryboard.instantiateViewController(withIdentifier: "CareNavigation")
        
        let aboutStoryboard = UIStoryboard(name: "About", bundle: nil)
        aboutViewController = aboutStoryboard.instantiateViewController(withIdentifier: "AboutNav") as? UINavigationController
        
        userFormController = mainStoryboard.instantiateViewController(withIdentifier: "UserNavigation") as? UINavigationController
        let userForm = self.userFormController.topViewController as! UserFormViewController
        userForm.userObject = self.currentUser
//        userForm.menuController = self

        self.animalsButton.addTarget(self, action: #selector(showView), for: .touchUpInside)
        self.locationsButton.addTarget(self, action: #selector(showView), for: .touchUpInside)
        self.careButton.addTarget(self, action: #selector(showView), for: .touchUpInside)
        self.aboutButton.addTarget(self, action: #selector(showView), for: .touchUpInside)
        self.storeButton.addTarget(self, action: #selector(showView), for: .touchUpInside)
        
        if let user = self.currentUser {
            self.userName.text = (user.firstName)! + " " + (user.lastName)!
            
            if user.profilePhoto != nil {
//                self.imageProfileButton.kf.setImage(with: NSURL(string: userPhoto.url!) as! Resource?, for: .normal, placeholder: UIImage(named: "human_profile_photo_empty"), options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
//                    self.imageProfileButton.imageView?.makeCircular()
//                })
            }
        }
        
        self.imageProfileButton.addTarget(self, action: #selector(HomeViewController.closeAndOpenUserProfile), for: .touchUpInside)
    }
    
    @objc func closeAndOpenUserProfile() {
        slideMenuController()?.closeLeft()
        self.openUserProfile(user: WRUser.current(), push: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.setNeedsUpdateConstraints()

//        self.checkForUser(completionBlock: nil)
    }
    
    @objc func showView(sender: UIButton!) {
        switch sender.currentTitle! {
            case "socialize":
                slideMenuController()?.changeMainViewController(self.mainViewController, close: true)
                break
            case "find":
                slideMenuController()?.changeMainViewController(self.locationsViewController, close: true)
                break
            case "learn":
                slideMenuController()?.changeMainViewController(self.careViewController, close: true)
                break
            case "shop":
                slideMenuController()?.changeMainViewController(self.storeViewController, close: true)
                break
            case "about":
                slideMenuController()?.changeMainViewController(self.aboutViewController, close: true)
                break
            default:
                break
        }
    }
    
    func checkForTransfer() {
        let currentUser = WRUser.current()
        
        let emailQuery = WRAnimalTransfer.query()!
        emailQuery.whereKey("email", equalTo: currentUser!.email!)

        let userQuery = WRAnimalTransfer.query()!
        userQuery.whereKey("invitedUser", equalTo: currentUser!)

        let transferQuery = PFQuery.orQuery(withSubqueries: [emailQuery, userQuery])
        transferQuery.whereKey("status", equalTo: "unaccepted")
        transferQuery.order(byDescending: "createdAt")
        transferQuery.includeKey("animal")
        
        transferQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if(objects != nil && objects!.count > 0) {
                let transferObject = objects![0] as! WRAnimalTransfer
                self.showTransferForm(transferObject: transferObject)
            } else {
                NSLog("No transfers found")
            }
        }
    }
    
    func showTransferForm(transferObject: WRAnimalTransfer) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let acceptForm = storyboard.instantiateViewControllerWithIdentifier("AnimalTransferAccept") as! AnimalTransferAcceptFormViewController
//
//        acceptForm.transferObject = transferObject
//        acceptForm.mainTabsController = self.mainViewController as? MainTabsViewController
//        
//        self.presentViewController(acceptForm, animated: true, completion: nil)
    }
    
    func walkthroughCloseButtonPressed() {
        (AppDelegate.getAppDelegate()).loadMainController()
    }
    
    @IBAction func logout() {
        self.logout { (result, error) in
            if(error == nil) {
//                self.checkForUser(completionBlock: nil)
            } else {
                self.showError(message: error!.localizedDescription)
            }
        }
    }

}
