//
//  TimelineEntryFormViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 11/20/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

//import ImageRow
import Eureka
import Parse


class TimelineEntryFormViewController: FormViewController {
    var animalDetailController : AnimalDetailViewController?
    var animalTimelineTableVC: AnimalTimelineTableViewController?
    
    var image : UIImage?
    var animalObject : WRAnimal?
    var entryObject : WRTimelineEntry?
    var pickedImageDate : Date?
    var isDetailScreenOpen = false
    var isFromTimelineController = false
    
    var type : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isDetailScreenOpen = true
        let appDelegate = AppDelegate.getAppDelegate()
        
        if self.animalObject == nil {
            if (appDelegate.myAnimalsArray?.count ?? 0) > 0 {
                self.animalObject = appDelegate.myAnimalByName![appDelegate.myAnimalsArray![0]]
            }
        }
        
        self.setUpModalBar(title: "Meowment Details")
        self.navigationItem.rightBarButtonItem = self.getNavBarItem(imageId: "icon_save", action: #selector(TimelineEntryFormViewController.saveImageData), height: 20, width: 25)

        self.generateForm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let navigationBar = self.navigationController?.navigationBar
        navigationBar!.frame = CGRect(x: self.view.frame.size.width, y: navigationBar!.frame.origin.y, width: navigationBar!.frame.size.width, height: navigationBar!.frame.size.height)
        UIView.animate(withDuration: 0.2, animations: {
            navigationBar!.frame = CGRect(x: 0, y: navigationBar!.frame.origin.y, width: navigationBar!.frame.size.width, height: navigationBar!.frame.size.height)
        })
    }
    
    func isEditMode() -> Bool {
        return self.entryObject != nil
    }
    
    
    func generateForm() {
        let appDelegate = AppDelegate.getAppDelegate()
        
        form +++ Section("Info") { section  in
            //section.color   = UIColor.lightOrangeColor()
        }
            <<< ActionSheetRow<String>("animal") {
                $0.title = "Kitty"
                $0.options = appDelegate.myAnimalsWithDeceasedArray!
                if let animalObject = self.animalObject {
                    $0.value = animalObject.name
                }
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_cat")
            }
            <<< DateRow("date") {
                $0.title = "Date"
                if(isEditMode()) {
                    $0.value = self.entryObject?.date
                } else {
                    $0.value = self.pickedImageDate != nil ? self.pickedImageDate : Date()
                }
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_date")
                    row.maximumDate = Date()
            }
//            <<< ImageRow("photo") {
//                $0.title = "Photo"
//                $0.disabled = true
//                $0.value = self.image
//            }.cellSetup { cell, row in
//                cell.imageView?.image = UIImage(named: "form_photo")
//                cell.height = { 100 }
//            }
            <<< TextAreaRow("text") {
                $0.title = "Kapshun"
                $0.placeholder = "Enter kapshun here..."
                $0.onChange({ (row: TextAreaRow) -> () in
                    let val = row.baseValue as? String
                    let maxLength = 500
                    if (val?.count)! > maxLength {
                        row.cell!.textView.text = val?[0...maxLength]
                    }
                })
                if(isEditMode()) {
                    $0.value = self.entryObject?.text
                }
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "form_caption")
                cell.textView.keyboardType = .twitter
                cell.textView.autocorrectionType = UITextAutocorrectionType.no
            }
        
        if(!isEditMode()) {
            form +++ Section("Share") { section  in
                //section.color   = UIColor.lightYellowColor()
            }
                <<< SwitchRow("facebook") {
                    $0.title = "Share to Facebook"
                    }.cellSetup { cell, row in
                        cell.imageView?.image = UIImage(named: "form_social_facebook")
                    }.onChange { [weak self] row in
                        if row.value ?? true {
                            self?.requestFacebookPublishPermission()
                        }
                }
                //                <<< SwitchRow("twitter") {
                //                    $0.title = "Share to Twitter"
                //                }.cellSetup { cell, row in
                //                    cell.imageView?.image = UIImage(named: "form_twitter")
                //                }
                <<< SwitchRow("instagram") {
                    $0.title = "Copy for Instagram"
                    }.cellSetup { cell, row in
                        cell.imageView?.image = UIImage(named: "form_social_instagram")
            }
        }
    }
    
    func requestFacebookPublishPermission() {
        let token = AccessToken.current
        if token == nil || !(token?.hasGranted(permission: "publish_actions"))! {
            PFFacebookUtils.facebookLoginManager().loginBehavior = LoginBehavior.browser
            PFFacebookUtils.linkUser(inBackground: WRUser.current()!, withPublishPermissions: ["publish_actions"], block: { (success: Bool, error: Error?) -> Void in
                
                //                let user = PFUser.currentUser()!
                //                user.setValue(FBSDKAccessToken.currentAccessToken().tokenString, forKey: "fbPublishToken")
                //                user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                //                    if success {
                //                        self.showSuccess("You are authorized to post to Facebook.")
                //                    } else {
                //                        self.showError("Error linking to Facebook.")
                //                    }
                //                })
                
            })
        }
    }
    
    @objc func saveImageData() {
        let appDelegate = AppDelegate.getAppDelegate()
        
        var timelineEntry = WRTimelineEntry()
        if(isEditMode()) {
            timelineEntry = self.entryObject!
        }
        
        if let animalName = self.form.rowBy(tag: "animal")?.baseValue as? String {
            let animalObject = appDelegate.myAnimalWithDeceasedByName![animalName]
            timelineEntry.animal = animalObject
        } else if self.animalObject != nil {
            timelineEntry.animal = self.animalObject
        } else {
            self.showError(message: "Wich kitteh iz it for?")
            return
        }
        
        let imageValue = self.form.rowBy(tag: "photo")?.baseValue as? UIImage
        if imageValue != nil {
            
            
            //let imageDimageValue = imageValue!.jpegDatatcompressionQuality: lue!, 0.5)
            let fileName:String = (String)(WRUser.current()!.objectId!) + "-" + (String)(Date().description.replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: ":", with: "-").replacingOccurrences(of: "+", with: "~")) + ".jpg"
            let imageData = imageValue?.pngData()
            let imageFile:PFFileObject = PFFileObject(name: fileName, data: imageData!)!
            
            timelineEntry.image = imageFile
        }
        
        if let textValue = self.form.rowBy(tag: "text")?.baseValue as? String {
            timelineEntry.text = textValue
        }
        if let dateValue = self.form.rowBy(tag: "date")?.baseValue as? Date {
            timelineEntry.date = dateValue
        }
        
        if let locationValue = self.form.rowBy(tag: "location")?.baseValue as? String {
            var location = appDelegate.vetByName![locationValue]
            if(location == nil) {
                location = appDelegate.shelterByName![locationValue]
            }
            timelineEntry.location = location!
        }
        
        timelineEntry.createdBy = WRUser.current()
        if self.type != "" {
            timelineEntry.type = self.type
        } else {
            timelineEntry.type = "image"
        }
        
        var shareToFacebook = false
        //        var shareToTwitter = false
        var shareToInstagram = false
        if(type != "medical") {
            if let fbVal = self.form.rowBy(tag: "facebook")?.baseValue as? Bool {
                shareToFacebook = fbVal
            }
            timelineEntry["shareToFacebook"] = shareToFacebook
            
            //            if let twitterVal = self.form.rowBy(tag: "twitter")?.baseValue as? Bool {
            //                shareToTwitter = twitterVal
            //            }
            //            timelineEntry["shareToTwitter"] = shareToTwitter
            
            if let instaVal = self.form.rowBy(tag: "instagram")?.baseValue as? Bool {
                shareToInstagram = instaVal
            }
        }
        
        self.showLoader()
        timelineEntry.saveInBackground { (success: Bool, error: Error?) -> Void in
            self.hideLoader()
            if(success) {
                
                self.closeView({ () in
                    // Open the animal detail controller for the selected animal
                    let newAnimal = timelineEntry.animal
                    
                    if self.isFromTimelineController{
                        if(self.animalDetailController != nil) {
                            self.isFromTimelineController = false
                            self.animalTimelineTableVC?.isFistImageAdded = true
                            self.animalDetailController!.loadAnimal()
                        }
                        
                    } else{
                        if var topController = UIApplication.shared.keyWindow?.rootViewController {
                            while let presentedViewController = topController.presentedViewController {
                                topController = presentedViewController
                            }
                            let child = UIApplication.topViewController()
                            child?.openAnimalDetail(animalObject: newAnimal!, push: true, timelineObjectId: timelineEntry.objectId!)
                        }
                    }
                    
                    if shareToInstagram {
                        var caption = timelineEntry.text
                        caption = (caption == nil) ? "" : caption
                        caption = caption! + " (on @whiterabbitapps)"
                    
                        if(self.animalDetailController != nil) {
                            self.animalDetailController!.openInInstagram(image: imageValue!, caption: caption)
                        } else {
                            AppDelegate.getAppDelegate().dashboardViewController?.openInInstagram(image: imageValue!, caption: caption)
                        }
                    }
                })
                
                // if there is no animal profile open
                if self.isDetailScreenOpen == false {
                    let newAnimal = timelineEntry.animal!
                    newAnimal.accessibilityValue = "0"
                    newAnimal.accessibilityLabel = timelineEntry.objectId!
                    
                    // Open the animal profile for the new animal
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "NTF_ShowAnimalDetailViewController"), object:newAnimal)
                }
                
            } else {
                self.showError(message: error!.localizedDescription)
                self.cancelEdit()
            }
        }
    }
    
    func cancelEdit() {
        self.closeView(nil)
        isDetailScreenOpen = false
    }
    
    func closeView(_ completionBlock: (() -> Void)?) {
        self.dismiss(animated: false) { () -> Void in
            if(completionBlock != nil) {
                completionBlock!()
            }
            if (self.animalDetailController != nil) {
                self.animalDetailController!.reloadTimeline()
            }
        }
    }
}

extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}
