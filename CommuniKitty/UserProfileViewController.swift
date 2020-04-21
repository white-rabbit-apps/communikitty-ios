//
//  UserProfileViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 12/2/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import PagingMenuController
import CLImageEditor
import Fusuma


class UserProfileViewController: UIViewController, CLImageEditorDelegate, FusumaDelegate {
    var username: String?
    var currentUser: WRUser?
    var currentUserIsOwner : Bool = false
    
    var showAsNav : Bool = false
    var showClose : Bool = false
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userProfilePhotoButton: UIButton!
    @IBOutlet weak var actionPawButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    var pagingMenu: PagingMenuController?
    
    var showFoster: Bool = false
    var showMemorial: Bool = false
    var showShelter: Bool = false
    
    var pickedImageDate:Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.mainColor()
        
        if(self.currentUser == nil && self.username == nil) {
            self.currentUser = WRUser.current()
            self.currentUserIsOwner = true
            self.loadUser()
        } else if (self.currentUser != nil) {
            self.loadUser()
        } else if (self.username != nil) {
            self.loadUserFromUsername()
        }
        
        if(!self.currentUserIsOwner) {
            self.actionPawButton.isHidden = false
            self.settingsButton.isHidden = true
        } else {
            self.actionPawButton.isHidden = true
            self.settingsButton.isHidden = true
        }
    }
    
    func loadUserFromUsername() {
        let userQuery = WRUser.query()!
        if(self.username != nil) {
            userQuery.whereKey("username", equalTo: self.username!)
        }
        self.showLoader()
        userQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if(error == nil) {
                let user = objects![0] as! WRUser
                self.currentUser = user
                self.loadUser()
                self.hideLoader()
            }
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.setNeedsUpdateConstraints()
        
        if(self.showAsNav) {
            self.setUpTransparentNavigationBar()
        } else if(self.showClose) {
            self.setUpTransparentModalBar()
        } else {
            self.setUpTransparentMenuBar()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "UserProfileToSettings") {
            let userNav = segue.destination as! UINavigationController
            let userForm = userNav.topViewController as! UserFormViewController

            userForm.userObject = WRUser.current()
        } else if let dashboard = segue.destination as? DashboardTableViewController
            , segue.identifier == "DashboardTableEmbed" {
            
            var widgets = [DashboardWidget]()
            
            let usersWidget = UserAnimalsDashboardWidget()
            usersWidget.user = self.currentUser
            widgets.append(usersWidget)

//            let photosWidget = UserPhotosDashboardWidget()
//            photosWidget.user = self.currentUser
//            widgets.append(photosWidget)
            
            dashboard.widgets = widgets
            dashboard.parentView = self
            
            dashboard.tableView.contentInset = UIEdgeInsets(top: -8, left: 0, bottom: 0, right: 0)
        }
    }
    
    func loadUser() {
        if(currentUser?.firstName == nil) {
            return
        }
        
        self.nameLabel.text = (currentUser?.firstName)! + " " + (currentUser?.lastName)!
        
        if currentUserIsOwner {
            self.userProfilePhotoButton.setImage(UIImage(named: "human_profile_photo_empty_add"), for: UIControl.State())
        }
        
        self.userProfilePhotoButton.imageView!.contentMode = UIView.ContentMode.scaleAspectFit
        let imageFile = currentUser?.profilePhoto
        if imageFile != nil {
            imageFile!.getDataInBackground(block: { (imageData: Data?, error: Error?) in
                if(error == nil) {
                    let image = UIImage(data:imageData!)
                    self.userProfilePhotoButton.setImage(image?.circle, for: UIControl.State())
                }
            })
        }

    }
    
    
    @IBAction func profileImagePressed(_ sender: AnyObject) {
        if(currentUserIsOwner) {
            self.takeFusumaPhoto()
        } else {
//            self.showLikeActionSheet(entryCell: nil, userObject: self.currentUser, completionBlock: { (result, error) -> Void in
//                if result {
//                    self.showSuccess(message: "We'll let 'em know!")
//                } else if (error != nil) {
//                    self.showError(message: error!.localizedDescription)
//                }
//            })
        }
    }
    
    func takeFusumaPhoto() {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        
        fusuma.transitioningDelegate = transitioningDelegate
        fusuma.modalPresentationStyle = .custom
        
        present(fusuma, animated: true, completion: nil)
    }
        
    // Return the image which is selected from camera roll or is taken via the camera.
    func fusumaImageSelected(_ image: UIImage, creationDate: Date?) {
         self.pickedImageDate = creationDate
        
        self.modalTransitionStyle = .coverVertical
        
        self.dismiss(animated: false, completion: { () -> Void in
            self.showEditor(image: image, delegate: self, ratios: [1, 1], fromController: self)
        })
    }
    
    public func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        self.modalTransitionStyle = .coverVertical
        
        self.dismiss(animated: false, completion: { () -> Void in
            self.showEditor(image: image, delegate: self, ratios: [1, 1], fromController: self)
        })
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
    }

    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        print("Camera roll unauthorized")
        let alert = UIAlertController(title: "Access Requested", message: "Saving image needs to access your photo album", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)

            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func fusumaDismissedWithImage(_ image: UIImage) {
        print("Called just after dismissed FusumaViewController")
    }
    
    func fusumaClosed() {
        print("Called when the close button is pressed")
    }
    
    func imageEditor(_ editor: CLImageEditor!, didFinishEdittingWith image: UIImage!) {
        self.dismiss(animated: false) { () -> Void in
            self.setProfilePhoto(image)
        }
    }
    
    func setProfilePhoto(_ image: UIImage!) {
        let imageData = image.jpegData(compressionQuality: 0.5)
        let fileName:String = (String)(WRUser.current()!.username!) + "-" + (String)(Date().description.replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: ":", with: "-").replacingOccurrences(of: "+", with: "~")) + ".jpg"
        let imageFile:PFFile = PFFile(name: fileName, data: imageData!)!
        
        self.currentUser!.profilePhoto = imageFile
        
        self.showLoader()
        self.currentUser!.saveInBackground { (success: Bool, error: Error?) -> Void in
            self.hideLoader()
            if(success) {
                self.loadUser()
            } else {
                self.showError(message: error!.localizedDescription)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
    }
}
