//
//  Extensions.swift
//  White Rabbit
//
//  Created by Michael Bina on 12/12/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import Parse
import CLImageEditor
import SKPhotoBrowser
import DZNEmptyDataSet
import CRToast
import AudioToolbox
import ImageIO
import Contacts
import ActiveLabel
import MessageUI
import PagingMenuController
import AVFoundation


struct SocialMediaUrl {
    static var yelpUrlSuffix = "http://www.yelp.com/biz/"
    static var instagramUrlSuffix = "https://www.instagram.com/"
    static var facebookUrlSuffix = "https://www.facebook.com/"
    static var twitterUrlSuffix = "https://twitter.com/"
}

private var currentPreview: UIImageView?
private var currentEditor: CLImageEditor?


extension UIViewController: MFMessageComposeViewControllerDelegate {
    
    /**
     Play a sound in the app
     
     - Parameters:
     - soundName: The filename of the caf sound to play, i.e. "meow" to play "meow.caf"
     */
    func playASound(soundName: String, vibrate: Bool = true) {
        if let soundURL = Bundle.main.url(forResource: soundName, withExtension: "caf") {
            var mySound: SystemSoundID = 0
            if(vibrate) {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
            AudioServicesPlaySystemSound(mySound);
        }
    }
    
    /**
     Show the GifHUD loader window
     */
    
    func showEmptyCustomView(view:Any, currentUserIsOwner:Bool, vc: UIViewController)  {

        let backImage = UIImageView()
        if currentUserIsOwner {
            let image = UIImage(named: "kitteh_selfie")!
            backImage.image = image
            backImage.sizeToFit()
            let imageWidth = backImage.frame.width
            let imageHeight = backImage.frame.height
            backImage.frame = CGRect(x: screenBounds.width/2-imageWidth/2, y: controllerHeight/4-imageHeight/2, width: imageWidth, height: imageHeight)
        } else {
            let image = UIImage(named: "kitteh_hit")!
            backImage.image = image
            backImage.sizeToFit()
            let imageWidth = backImage.frame.width
            let imageHeight = backImage.frame.height
            backImage.frame = CGRect(x: screenBounds.width/2-imageWidth/2, y: controllerHeight/4-imageHeight/2, width: imageWidth, height: imageHeight)
        }
        (view as AnyObject).addSubview(backImage)
        
        let attr = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0), NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        let label = UILabel(frame:CGRect(x: 15,y: controllerHeight/4+backImage.frame.height-30, width: screenBounds.width-30, height: 20))
        label.textAlignment = .center
        
        if currentUserIsOwner {
            label.attributedText = NSAttributedString(string: "No meowments yet", attributes: attr)
        } else {
            label.frame = CGRect(x: 15,y: controllerHeight/4+backImage.frame.height-60, width: screenBounds.width-30, height: 20)
            label.attributedText = NSAttributedString(string: "No meowments yet", attributes: attr)
        }
        
        (view as AnyObject).addSubview(label)
        
        let par: NSMutableParagraphStyle = NSMutableParagraphStyle()
        par.lineBreakMode = .byWordWrapping
        par.alignment = .center
        let parAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0), NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: par]
        
        let secondLabel = UILabel(frame:CGRect(x: 15,y: controllerHeight/4+backImage.frame.height-30+label.frame.height, width: screenBounds.width-30, height: 40))
        
        if currentUserIsOwner {
            secondLabel.attributedText =  NSAttributedString(string: "Start capturing some of your kitteh’s best meowments.", attributes: parAttributes)
        } else {
            secondLabel.frame = CGRect(x: 15,y: controllerHeight/4+backImage.frame.height-60+label.frame.height, width: screenBounds.width-30, height: 40)
            secondLabel.attributedText = NSAttributedString(string: "This kitteh hasn’t added any meowments yet", attributes: parAttributes)
        }
        secondLabel.numberOfLines = 0
        
        (view as AnyObject).addSubview(secondLabel)
        
        let cameraImage = UIButton()
        
        if currentUserIsOwner {
            cameraImage.setImage(UIImage(named: "arrow_to_button_camera"), for: UIControl.State())
            cameraImage.sizeToFit()
            
            
            let imageWidth = cameraImage.frame.width
            let imageHeight = cameraImage.frame.height
            cameraImage.frame = CGRect(x: screenBounds.width/2-imageWidth/2, y: controllerHeight/4+imageHeight+label.frame.height+secondLabel.frame.height - 90, width: imageWidth, height: imageHeight)
            
            if type(of: view) == UIView.self {
            let viewContr = vc as! AnimalTimelineTableViewController
                cameraImage.addTarget(self, action: #selector(viewContr.tapOnEmptyDataSetButton) , for: .touchUpInside)
            } else if type(of: view) == UICollectionView.self {
                let viewContr = vc as! PhotosCollectionViewController
                cameraImage.addTarget(self, action: #selector(viewContr.tapOnCameraButton) , for: .touchUpInside)
            }
            
        } else {
            cameraImage.setImage(UIImage(named: "button_nudge"), for: UIControl.State())
            cameraImage.sizeToFit()
            let imageWidth = cameraImage.frame.width
            let imageHeight = cameraImage.frame.height
            cameraImage.frame = CGRect(x: screenBounds.width/2-imageWidth/2, y: controllerHeight/4+imageHeight+label.frame.height+secondLabel.frame.height + 30, width: imageWidth, height: imageHeight)
        }
        
        (view as AnyObject).addSubview(cameraImage)
    }
    
    func showLoader() {
//        self.hideLoader()
        
        let filename = Int.random(lower: 1, upper: 20)
//        GiFHUD.setGif("gif/" + String(filename) + ".gif")
//        GiFHUD.show()
    }
    
    /**
     Hide the GifHUD loader window
     */
    func hideLoader() {
//        GiFHUD.dismiss()
    }
    
    /**
     Pop back to the previous view controller in the current UINavigationController
     */
    @objc func goBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    /**
     Pop back to the previous view controller in the current UINavigationController
     and run the given completion block
     
     - Parameters:
     - completion: The block of code to run after the pop back
     */
    func goBackAndRun(completion: @escaping ()->()) {
        self.navigationController?.popViewControllerWithCompletionBlock(completion: completion)
    }
    
    /**
     Close the current view controller
     */
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     Close the current view controller and run the given completion block
     
     - Parameters:
     - completion: The block of code to run after the close
     */
    func closeAndRun(completion: (() -> Void)?) {
        self.dismiss(animated: true) { () -> Void in
            completion!()
        }
    }

    /**
     Get a UIBarButtonItem with the given paramaters
     
     - Parameters:
     - imageId: The resource name in the Assets
     - action: The Selector with the action to run
     - height: The height of the button to be produced
     - width: The width of the button to be produced
     */
    func getNavBarItem(imageId : String, action : Selector, height : CGFloat, width: CGFloat) -> UIBarButtonItem! {
        let bundle =
            
            Bundle(path: "Resources/WhiteRabbitAssets.xcassets")
        let editImage = UIImage(named: imageId, in: bundle, compatibleWith: nil)
        
        let editButton = UIButton(type: .custom)
        editButton.setImage(editImage, for: .normal)
        editButton.frame = CGRect(x: 0, y: 0, width: width, height: height)
        editButton.addTarget(self, action: action, for: .touchUpInside)
        return UIBarButtonItem(customView: editButton)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /**
     Open an email compose screen with the given info
     
     - Parameters:
     - emailAddress: The email address that should be filled in on the email
     - subject: The subject that should be filled in on the email
     - body: The body that should be filled in on the email
     */
    func composeEmail(emailAddress: String, subject: String, body: String) {
        var email: String = "mailto:\(emailAddress)?subject=\(subject)&body=\(body)"
        email = email.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
        
        UIApplication.shared.open(URL(string: email)!, options: [:], completionHandler: nil)
    }
    
    /**
     Open a standard alert screen with the given parameters
     
     - Parameters:
     - title: The title text for the alert
     - message: The body text of the alert
     - buttonText: The title of the button
     */
    func displayAlert(title:String, message:String, buttonText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: buttonText, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     Open a standard alert screen with the given message
     
     - Parameters:
     - message: The body text of the alert
     */
    func displayAlert(message: String) {
        displayAlert(title: "Alert", message: message, buttonText: "OK")
    }
    
    func setUpModalBar(title: String) {
        self.setUpNavigationBar(title: title)
        self.navigationItem.leftBarButtonItem = self.getNavBarItem(imageId: "icon_close", action: #selector(UIViewController.close), height: 30, width: 25)
    }
    
    func setUpTransparentModalBar() {
        self.setUpTransparentModalBar(title: "")
    }
    
    func setUpTransparentModalBar(title: String) {
        self.setUpModalBar(title: title)
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.blackTranslucent
        nav?.isTranslucent = true
        nav?.backgroundColor = UIColor.clear
        nav?.setBackgroundImage(UIImage(), for: .default)
        nav?.shadowImage = UIImage()
        
        if var frame = nav?.frame {
            frame.size.height = 45
            nav?.frame = frame
        }
    }
    
    func setUpNavigationBar() {
        self.setUpNavigationBar(title: "")
    }
    
    func setUpNavigationBar(title: String, showButton: Bool = true) {
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.default
        nav?.isTranslucent = true
        nav?.setBackgroundImage(UIImage(named:"nav_color"), for: .default)
        nav?.shadowImage = UIImage()

        if var frame = nav?.frame {
            frame.size.height = 45
            nav?.frame = frame
        }
        
        nav?.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "Nunito-Black", size: 20)!,  NSAttributedString.Key.foregroundColor: UIColor.white]
        
        self.navigationItem.title = title
        
        if(showButton) {
            self.navigationItem.leftBarButtonItem = self.getNavBarItem(imageId: "icon_back", action: #selector(UIViewController.goBack), height: 30, width: 25)
        }
    }
    
    func setUpTransparentNavigationBar() {
        self.setUpTransparentNavigationBar(title: "")
    }
    
    func setUpTransparentNavigationBar(title: String) {
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.default
        nav?.isTranslucent = true
        nav?.setBackgroundImage(UIImage(named:"nav_transparent"), for: .default)
        nav?.shadowImage = UIImage()

        if var frame = nav?.frame {
            frame.size.height = 45
            nav?.frame = frame
        }
        
        nav?.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "Nunito-Black", size: 20)!,  NSAttributedString.Key.foregroundColor: UIColor.white]
        
        self.navigationItem.title = title
        self.navigationItem.leftBarButtonItem = self.getNavBarItem(imageId: "icon_back", action: #selector(UIViewController.goBack), height: 30, width: 25)

    }
    
    func setUpNavigationBarImage(image: UIImage, height: CGFloat) {
        self.setUpNavigationBarImage(image: image, height: height, title: "")
    }
    
    func setUpNavigationBarImage(image: UIImage, height: CGFloat, title: String, showButton: Bool = true) {
        let nav = self.navigationController?.navigationBar
        
        nav?.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "Nunito-Black", size: 20)!,  NSAttributedString.Key.foregroundColor: UIColor.white]
        
        self.navigationItem.title = title
        
        nav?.barStyle = UIBarStyle.blackOpaque
        
        nav!.isTranslucent = false
        nav!.setBackgroundImage(image.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .stretch), for: .default)
        var frame = nav!.frame
        frame.size.height = height
        nav!.frame = frame
        
        if(showButton) {
            self.navigationItem.leftBarButtonItem = self.getNavBarItem(imageId: "icon_back", action: #selector(UIViewController.goBack), height: 30, width: 25)
        }
    }
    
    func setUpTransparentMenuBar() {
        self.setUpTransparentMenuBar(title: "")
    }
    
    func setUpTransparentMenuBar(title: String) {
        self.setUpMenuBarController(title: title)
        
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.blackTranslucent
        nav?.isTranslucent = true
        nav?.backgroundColor = UIColor.clear
        nav?.setBackgroundImage(UIImage(), for: .default)
        nav?.shadowImage = UIImage()
        
        if var frame = nav?.frame {
            frame.size.height = 45
            nav?.frame = frame
        }
    }
    
    func setUpMenuBarController() {
        self.setUpMenuBarController(title: "")
    }
    
    func setUpMenuBarController(title: String) {
        self.setUpNavigationBar(title: title, showButton: false)
        
//        self.navigationItem.leftBarButtonItem = self.getNavBarItem(imageId: "button_menu", action: #selector(UIViewController.showMenu), height: 20, width: 25)
    }
    
    func setUpMenuBarImageController(image: UIImage, height: CGFloat, title: String) {
        self.setUpNavigationBarImage(image: image, height: height, title: title, showButton: false)
        
//        self.navigationItem.leftBarButtonItem = self.getNavBarItem(imageId: "button_menu", action: #selector(UIViewController.showMenu), height: 20, width: 25)
    }
    
    func setUpMenuBarImageController(image: UIImage, height: CGFloat) {
        self.setUpMenuBarImageController(image: image, height: height, title: "")
    }
    
    func requestForContactsAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void, errorHandler: @escaping (_ authorizationStatus: CNAuthorizationStatus) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            let contactStore = CNContactStore()
            contactStore.requestAccess(for: .contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else {
                    errorHandler(authorizationStatus)
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    
    func composeSMS(phoneNumber: String, body: String) {
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = body
        messageVC.recipients = [phoneNumber]
        messageVC.messageComposeDelegate = self
        
        self.present(messageVC, animated: false, completion: nil)
    }
    
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     Show the slider menu
     */
    func showMenu() {
//        self.slideMenuController()?.openLeft()
    }

func isLoggedIn() -> Bool {
    return WRUser.current() != nil
}

func openUserProfile(user: WRUser? = nil, push: Bool = true) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let userView = storyboard.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
    userView.currentUser = user
    
    if(push) {
        userView.showAsNav = true
        self.navigationController?.pushViewController(userView, animated: true)
    } else {
        userView.showClose = true
        self.present(UINavigationController(rootViewController: userView), animated: true, completion: nil)
    }
}
 
//func showError(message: String) {
//    self.showError(message: message, timeToShow: 3.0)
//}
//
//func showError(message: String, timeToShow: Double) {
//    self.playASound(soundName: "chirp1")
//    
//    let errorMessage = message.capitalized
//    
//    let options = getToastOptions(message: errorMessage, type: "error", timeToShow: timeToShow)
//    CRToastManager.showNotification(options: options, completionBlock: nil)
//}
    
    
//    func getToastOptions(message: String, type: String, timeToShow: Double) -> [AnyHashable : Any] {
//        var fontSize = 14.0
//        if(message.count > 60) {
//            fontSize = 12.0
//        }
//
//        var options = [
//            kCRToastSubtitleTextKey : message,
//            kCRToastUnderStatusBarKey : NSNumber(value: false),
//            kCRToastTimeIntervalKey : NSNumber(value:timeToShow),
//            kCRToastNotificationPreferredPaddingKey: 15 as NSNumber,
//            kCRToastNotificationPreferredHeightKey : 150 as NSNumber,
//            kCRToastFontKey: UIFont.italicSystemFont(ofSize: 16),
//            kCRToastSubtitleFontKey : UIFont(name: "Nunito-Regular", size: CGFloat(fontSize))!,
//            kCRToastNotificationTypeKey  : NSNumber(value:CRToastType.navigationBar.rawValue),
//            kCRToastSubtitleTextAlignmentKey : NSNumber(value:NSTextAlignment.left.rawValue),
//            kCRToastTextAlignmentKey : NSNumber(value:NSTextAlignment.left.rawValue),
//            kCRToastAnimationInTypeKey : NSNumber(value:CRToastAnimationType.spring.rawValue),
//            kCRToastAnimationOutTypeKey : NSNumber(value:CRToastAnimationType.spring.rawValue),
//            kCRToastAnimationInDirectionKey : NSNumber(value:CRToastAnimationDirection.top.rawValue),
//            kCRToastAnimationOutDirectionKey : NSNumber(value:CRToastAnimationDirection.top.rawValue)
//        ] as [AnyHashable : Any]
//
//        if(type == "error") {
////            options[kCRToastBackgroundColorKey] = UIColor.red
////
////            options[kCRToastTextKey] = ["Taht dint werk.", "Ruh roh.", "Ar yoo kitten me?"]
////
////            let filename = Int.random(lower: 1, upper: 8)
////            options[kCRToastImageKey] = UIImage(named: "error" + String(filename))
//        } else if(type == "success") {
////            options[kCRToastBackgroundColorKey] = UIColor.lightGreenColor()
////
////            options[kCRToastTextKey] = ["Errrmahgerd!", "Pawesum.", "It werkd.", "Clawesome!"].randomItem()
////
////            let filename = Int.random(lower: 1, upper: 5)
////            options[kCRToastImageKey] = UIImage(named: "success" + String(filename))
//        } else if(type == "info") {
////            options[kCRToastBackgroundColorKey] = UIColor.lightBlueColor()
////
////            options[kCRToastTextKey] = ["Oh hai."].randomItem()
////
////            let filename = Int.random(lower: 1, upper: 5)
////            options[kCRToastImageKey] = UIImage(named: "success" + String(filename))
//        }
//
//        return options
//    }
    
//    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            switch swipeGesture.direction {
//            case UISwipeGestureRecognizer.Direction.right:
//                self.goBack()
//            default:
//                break
//            }
//        }
//    }
    
    
    
    /**
     Show the create animal form
     */
@objc func showAddAnimalForm() {
        self.checkForUser { 
            let animalForm = AnimalFormViewController()
            self.present(UINavigationController(rootViewController: animalForm), animated: true, completion: nil)
        }
    }
    
    func getToastOptions(message: String, type: String, timeToShow: Double) -> [AnyHashable : Any] {
        var fontSize = 14.0
        if(message.count > 60) {
            fontSize = 12.0
        }
        
        var options = [
            kCRToastSubtitleTextKey : message,
            kCRToastUnderStatusBarKey : NSNumber(value: false),
            kCRToastTimeIntervalKey : NSNumber(value:timeToShow),
            kCRToastNotificationPreferredPaddingKey: 15 as NSNumber,
            kCRToastNotificationPreferredHeightKey : 150 as NSNumber,
            kCRToastFontKey: UIFont.italicSystemFont(ofSize: 16),
            kCRToastSubtitleFontKey : UIFont(name: "Nunito-Regular", size: CGFloat(fontSize))!,
            kCRToastNotificationTypeKey  : NSNumber(value:CRToastType.navigationBar.rawValue),
            kCRToastSubtitleTextAlignmentKey : NSNumber(value:NSTextAlignment.left.rawValue),
            kCRToastTextAlignmentKey : NSNumber(value:NSTextAlignment.left.rawValue),
            kCRToastAnimationInTypeKey : NSNumber(value:CRToastAnimationType.spring.rawValue),
            kCRToastAnimationOutTypeKey : NSNumber(value:CRToastAnimationType.spring.rawValue),
            kCRToastAnimationInDirectionKey : NSNumber(value:CRToastAnimationDirection.top.rawValue),
            kCRToastAnimationOutDirectionKey : NSNumber(value:CRToastAnimationDirection.top.rawValue)
        ] as [AnyHashable : Any]
        
        if(type == "error") {
            options[kCRToastBackgroundColorKey] = UIColor.lightRedColor()
            
            options[kCRToastTextKey] = ["Taht dint werk.", "Ruh roh.", "Ar yoo kitten me?"].randomItem()
            
            let filename = Int.random(lower: 1, upper: 8)
            options[kCRToastImageKey] = UIImage(named: "error" + String(filename))
        } else if(type == "success") {
            options[kCRToastBackgroundColorKey] = UIColor.lightGreenColor()
            
            options[kCRToastTextKey] = ["Errrmahgerd!", "Pawesum.", "It werkd.", "Clawesome!"].randomItem()
            
            let filename = Int.random(lower: 1, upper: 5)
            options[kCRToastImageKey] = UIImage(named: "success" + String(filename))
        } else if(type == "info") {
            options[kCRToastBackgroundColorKey] = UIColor.lightBlueColor()
            
            options[kCRToastTextKey] = ["Oh hai."].randomItem() as Any
            
            let filename = Int.random(lower: 1, upper: 5)
            options[kCRToastImageKey] = UIImage(named: "success" + String(filename))
        }
        
        return options
    }
    
    
    func showInfo(message: String) {
        self.showInfo(message: message, timeToShow: 3.0)
    }
    
    func showInfo(message: String, timeToShow: Double) {
        self.showInfo(message: message, timeToShow: timeToShow, sound: "chirp1")
    }
    
    func showInfo(message: String, timeToShow: Double, sound: String) {
        self.playASound(soundName: sound)
        
        let infoMessage = message.capitalizeFirstLetter()
        
        let options = getToastOptions(message: infoMessage, type: "info", timeToShow: timeToShow)
        CRToastManager.showNotification(options: options, completionBlock: nil)
    }
    
    func showError(message: String) {
        self.showError(message: message, timeToShow: 3.0)
    }
    
    func showError(message: String, timeToShow: Double) {
        self.playASound(soundName: "chirp1")
        
        let errorMessage = message.capitalizeFirstLetter()
        
        let options = getToastOptions(message: errorMessage, type: "error", timeToShow: timeToShow)
        CRToastManager.showNotification(options: options, completionBlock: nil)
    }
    
    func showSuccess(message: String) {
        self.showSuccess(message: message, timeToShow: 3.0)
    }
    
    func showSuccess(message: String, timeToShow: Double) {
        self.playASound(soundName: "meow1")
        
        let successMessage = message.capitalizeFirstLetter()
        
        let options = getToastOptions(message: successMessage, type: "success", timeToShow: timeToShow)
        CRToastManager.showNotification(options: options, completionBlock: nil)
    }
    
    func showShareActionSheet(image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: ["http://www.communikitty.com", image], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
//    func showFlagActionSheet(entryCell: EntryCell?, flaggedObject: PFObject?) {
//        var objectToFlag = flaggedObject
//        if objectToFlag == nil {
//            objectToFlag = entryCell!.entryObject!
//        }
//        
//        let optionMenu = UIAlertController(title: nil, message: "Flag as", preferredStyle: .actionSheet)
//        
//        let inappropriateAction = UIAlertAction(title: "Inappropriate", style: .default, handler: {
//            (alert: UIAlertAction!) -> Void in
//            self.flagItem(flaggedObject: objectToFlag!, type: .Inappropriate)
//        })
//        
//        let spamAction = UIAlertAction(title: "Spam", style: .default, handler: {
//            (alert: UIAlertAction!) -> Void in
//            self.flagItem(flaggedObject: objectToFlag!, type: .Spam)
//        })
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
//            (alert: UIAlertAction!) -> Void in
//        })
//        
//        optionMenu.addAction(inappropriateAction)
//        optionMenu.addAction(spamAction)
//        optionMenu.addAction(cancelAction)
//        
//        self.present(optionMenu, animated: true, completion: nil)
//    }
    
    func flagItem(flaggedObject: PFObject, type: FlagType) {
        let flag = WRFlag()
        
        if let flaggedObject = flaggedObject as? WRTimelineEntry {
            flag.entry = flaggedObject
        } else if let flaggedObject = flaggedObject as? WRComment {
            flag.comment = flaggedObject
        }
        flag.typeValue = type
        flag.reportedBy = WRUser.current()
        
        self.showLoader()
        flag.saveInBackground { (success: Bool, error: Error?) -> Void in
            self.hideLoader()
            if(success) {
                self.showSuccess(message: "Thanks for letting us know!  We'll take a look right away.")
            } else {
                self.showError(message: error!.localizedDescription)
            }
        }
    }
    
    func initActiveLabel(label:ActiveLabel) {
        let linkColor = UIColor.linkColor()
        
        label.hashtagColor = linkColor
        label.mentionColor = linkColor
        
//        label.mentionColor = true
//        label.hashtagColor = false
//        label.mentionRemoveAt = true
        
        label.handleHashtagTap(self.openHashTagFeed)
        label.handleMentionTap(self.openUsername)
    }
    
    func openHashTagFeed(hashtag:String) -> () {
        let postsView = self.storyboard?.instantiateViewController(withIdentifier: "PostsView") as! PostsTableViewController
        postsView.hashtag = hashtag
        self.navigationController?.pushViewController(postsView, animated: true)
    }
    
    /**
     Open a screen for a user profile or animal detail screen by username
     
     - Parameters:
     - username: The username of the user or animal to open
     */
    func openUsername(username: String) -> () {
        let animalQuery = WRAnimal.query()!
        animalQuery.whereKey("username", equalTo: username)
        
        animalQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if(objects!.count > 0) {
                let animal = objects![0] as? WRAnimal
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let animalView = storyboard.instantiateViewController(withIdentifier: "AnimalDetailView") as! AnimalDetailViewController
                animalView.currentAnimalObject = animal
                self.navigationController?.pushViewController(animalView, animated: true)
            } else {
                let userQuery = WRUser.query()!
                userQuery.whereKey("username", equalTo: username)
                
                userQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
                    if(objects!.count > 0) {
                        let user = objects![0] as! WRUser
                        let userProfile = self.storyboard?.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
                        userProfile.showAsNav = true
                        userProfile.currentUser = user
                        self.navigationController?.pushViewController(userProfile, animated: true)
                    } else {
                        self.showError(message: "No one with that username.")
                    }
                }
            }
        }
    }
    
    /**
     Open the user profile screen for the current user
     */
//    func openUserProfile(user: WRUser? = nil, push: Bool = true) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let userView = storyboard.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
//        userView.currentUser = user
//
//        if(push) {
//            userView.showAsNav = true
//            self.navigationController?.pushViewController(userView, animated: true)
//        } else {
//            userView.showClose = true
//            self.present(UINavigationController(rootViewController: userView), animated: true, completion: nil)
//        }
//    }
    
    /**
     Open a user profile screen for the given user username
     
     - Parameters:
     - username: The username of the user to open
     */
    func openUserProfileByUsername(username: String) -> () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let userView = storyboard.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
        userView.username = username
        userView.showClose = true
        
        self.present(UINavigationController(rootViewController: userView), animated: true, completion: nil)
    }
    
    /**
     Open the explore screen
 */
    @objc func openExplore() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let exploreView = storyboard.instantiateViewController(withIdentifier: "Explore") as! ExploreViewController
//        exploreView.showAsNav = true
//        
//        if let nav = self.navigationController {
//            nav.pushViewController(UINavigationController(rootViewController: exploreView), animated: true)
//        } else {
        let navVc = UINavigationController(rootViewController: exploreView)
        navVc.modalPresentationStyle = .overFullScreen
            self.present(navVc, animated: true, completion: nil)
//        }
    }
    
    /**
     Open an animal detail screen for the given animal username
     
     - Parameters:
     - username: The username of the animal to open
     */
    func openAnimalDetailByUsername(username: String) -> () {
        self.openAnimalDetailByUsername(username: username, push: false)
    }
    
    /**
     Open an animal detail screen for the given animal username
     
     - Parameters:
     - username: The username of the animal to open
     - push: True if you'd like to show the screen by push on the navigation controller, False for cover
     */
    func openAnimalDetailByUsername(username: String, push: Bool) -> () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let animalView = storyboard.instantiateViewController(withIdentifier: "AnimalDetailView") as! AnimalDetailViewController
        animalView.username = username
        
        if(push) {
            self.navigationController?.pushViewController(animalView, animated: true)
        } else {
            animalView.showClose = true
            self.present(UINavigationController(rootViewController: animalView), animated: true, completion: nil)
        }
    }
    
    /**
     Open an animal detail screen for the given animals
     
     - Parameters:
     - animalObject: The WRAnimal object for the animal to open
     - push: True if you'd like to show the screen by push on the navigation controller, False for cover
     */
    func `openAnimalDetail`(animalObject: AnyObject, push: Bool, timelineObjectId: String? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let animalView = storyboard.instantiateViewController(withIdentifier: "AnimalDetailView") as! AnimalDetailViewController
        animalView.currentAnimalObject = animalObject
        animalView.timelineObjectId = timelineObjectId
        
        if(push) {
            self.navigationController?.pushViewController(animalView, animated: true)
        } else {
            animalView.showClose = true
            self.present(UINavigationController(rootViewController: animalView), animated: true, completion: nil)
        }
    }
    
    /**
     Open an entry comments screen for the given entry
     
     - Parameters:
     - animalObject: The WRAnimal object for the animal to open
     - push: True if you'd like to show the screen by push on the navigation controller, False for cover
     */
    func openEntryComments(entryObject: WRTimelineEntry, push: Bool) {
        let commentsView = self.storyboard?.instantiateViewController(withIdentifier: "TimelineEntryDetailView") as! TimelineEntryDetailViewController
        commentsView.entryObject = entryObject
        
        if(push) {
            self.navigationController?.pushViewController(commentsView, animated: true)
        } else {
            commentsView.showClose = true
            self.present(UINavigationController(rootViewController: commentsView), animated: true, completion: nil)
        }
    }
    
    @objc func openUserSettings() {
        self.checkForUser {
            
            let userSettingsVC = UserFormViewController()
            
            userSettingsVC.userObject = WRUser.current()
            
            self.present(UINavigationController(rootViewController: userSettingsVC), animated: true, completion: nil)
        }
    }
    
//    func isLoggedIn() -> Bool {
//        return WRUser.current() != nil
//    }
    
    func checkForUser(completionBlock: @escaping () -> Void) {
        
        if (GraphQLServiceManager.sharedManager.getUSer() != nil) {
//
//            self.checkForTransfer()
            completionBlock()
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Navigate to the LoginViewController
            let lvc = storyboard.instantiateViewController(withIdentifier: "lvc") as! LoginViewController
            lvc.completionBlock = completionBlock
            //            lvc.menuController = self
            lvc.modalPresentationStyle = .fullScreen
            self.present(lvc, animated: true, completion: nil)
        }
    }
    
    func getImageThumbnailFrame(image: UIImage, index: Int, parentFrame: CGRect, previewWidth: Int, previewPadding: Int) -> CGRect {
        let extra = ((index + 1) * (previewPadding / 2))
        var minX:CGFloat = CGFloat(((index * previewWidth) + extra))
        var width = CGFloat(previewWidth)
        let fullHeight = parentFrame.height - CGFloat(previewPadding)
        var height = image.size.height / (image.size.width / CGFloat(width))
        var minY = CGFloat(previewPadding / 2) + ((fullHeight - height) / 2)
        
        if(height > fullHeight) {
            height = parentFrame.height - CGFloat(previewPadding)
            width = image.size.width / (image.size.height / height)
            minY = CGFloat(previewPadding / 2)
            minX = CGFloat(minX) + ((CGFloat(previewWidth) - width) / 2)
        }
        
        return CGRect(x: CGFloat(minX), y: CGFloat(minY), width: CGFloat(width), height: CGFloat(height))
    }
    
    /**
     Open the given image in the Instagram app with the given caption prefilled and ready to be uploaded
     
     - Parameters:
     - image: The image to open in Instagram
     - caption: The caption to prefill in Instagram
     */
    func openInInstagram(image: UIImage, caption: String?) {
        let instagramURL = NSURL(string: "instagram://app")
        
        if(UIApplication.shared.canOpenURL(instagramURL! as URL)) {
            let documentsFolderPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
            let fullPath = (documentsFolderPath as NSString).appendingPathComponent("insta.igo")
//            UIImagePNGRepresentation(image)!.writeToFile(fullPath, atomically: true)
            let rect = CGRect(x: 0, y: 0, width: 0, height: 0)
            
            var docController = UIDocumentInteractionController()
            
            docController.uti = "com.instagram.exclusivegram"
            let igImageHookFile = NSURL(string: "file://\(fullPath)")
            docController = UIDocumentInteractionController(url: igImageHookFile! as URL)
            
            // unfortunately this doesn't work anymore
            docController.annotation = NSDictionary(object: caption!, forKey:"InstagramCaption" as NSCopying)
            
            UIPasteboard.general.string = caption!
            
            self.showSuccess(message: "Tap 'Copy to Instagram' to finish sharing.  Your caption has been copied to the clipboard.", timeToShow: 15)
            docController.presentOpenInMenu(from: rect, in: self.view, animated: true)
        } else {
            self.showError(message: "Please install the Instagram app to share on Instagram.")
        }
    }
    
    
    /**
     Open an instance of CLImageEditor with the given image
     
     - Parameters:
     - image: The UIImage that should be edited
     - delegate: The CLImageEditorDelegate implementation that should be called on completion
     - ratios: The ratios that should be allowed for the crop tool
     - fromController: The UIViewController from which this is being opened
     - forceCrop: Boolean value to force CropView opening
     */
    func showEditor(image : UIImage, delegate: CLImageEditorDelegate, ratios: [Int]?, fromController: UIViewController, forceCrop: Bool = false) {
        let editor = CLImageEditor(image: image, delegate: delegate)
        
        let stickerTool = editor?.toolInfo.subToolInfo(withToolName: "CLStickerTool", recursive: false)
        stickerTool?.available = true
//        stickerTool?.customIcon = "icon_stickers"
        stickerTool?.iconImagePath = "icon_stickers"
//        stickerTool?.optionalInfo["stickerPath"] = "stickers/"
        stickerTool?.optionalInfo["deleteIconAssetsName"] = "button_delete"
        stickerTool?.optionalInfo["resizeIconAssetsName"] = "icon_resize"
        
        let splashTool = editor?.toolInfo.subToolInfo(withToolName: "CLSplashTool", recursive: false)
        splashTool?.available = false
        let curveTool = editor?.toolInfo.subToolInfo(withToolName: "CLToneCurveTool", recursive: false)
        curveTool?.available = false
        let blurTool = editor?.toolInfo.subToolInfo(withToolName: "CLBlurTool", recursive: false)
        blurTool?.available = false
        let drawTool = editor?.toolInfo.subToolInfo(withToolName: "CLDrawTool", recursive: false)
        drawTool?.available = false
        let adjustmentTool = editor?.toolInfo.subToolInfo(withToolName: "CLAdjustmentTool", recursive: false)
        adjustmentTool?.available = false
        
        let effectTool = editor?.toolInfo.subToolInfo(withToolName: "CLEffectTool", recursive: false)
        effectTool?.available = false
        let pixelateFilter = effectTool?.subToolInfo(withToolName: "CLPixellateEffect", recursive: false)
        pixelateFilter?.available = false
        let posterizeFilter = effectTool?.subToolInfo(withToolName: "CLPosterizeEffect", recursive: false)
        posterizeFilter?.available = false
        
        
        let filterTool = editor?.toolInfo.subToolInfo(withToolName: "CLFilterTool", recursive: false)
        //        filterTool.optionalInfo["flipHorizontalIconAssetsName"] = "button_filter"
        filterTool?.available = true
//        filterTool?.customIcon = "icon_filters"
        let invertFilter = filterTool?.subToolInfo(withToolName: "CLDefaultInvertFilter", recursive: false)
        invertFilter?.available = false
        
        let rotateTool = editor?.toolInfo.subToolInfo(withToolName: "CLRotateTool", recursive: false)
        rotateTool?.available = true
        rotateTool?.dockedNumber = -1
//        rotateTool?.customIcon = "icon_rotate"
        
        rotateTool?.optionalInfo["rotateIconAssetsName"] = "icon_rotate"
        rotateTool?.optionalInfo["flipHorizontalIconAssetsName"] = "icon_flip_horizontal"
        rotateTool?.optionalInfo["flipVerticalIconAssetsName"] = "icon_flip_vertical"
        
        let textTool = editor?.toolInfo.subToolInfo(withToolName: "CLTextTool", recursive: false)
//        textTool?.customIcon = "icon_text"
        textTool?.optionalInfo["newTextIconAssetsName"] = "button_add_small"
        textTool?.optionalInfo["editTextIconAssetsName"] = "icon_text_edit"
        textTool?.optionalInfo["deleteIconAssetsName"] = "button_delete"
        textTool?.optionalInfo["fontIconAssetsName"] = "icon_font"
        textTool?.optionalInfo["alignLeftIconAssetsName"] = "icon_align_left"
        textTool?.optionalInfo["alignCenterIconAssetsName"] = "icon_align_center"
        textTool?.optionalInfo["alignRightIconAssetsName"] = "icon_align_right"
        
        let cropTool = editor?.toolInfo.subToolInfo(withToolName: "CLClippingTool", recursive: false)
        cropTool?.optionalInfo["flipHorizontalIconAssetsName"] = "button_crop"
        cropTool?.available = true
//        cropTool?.customIcon = "icon_crop"
        cropTool?.dockedNumber = -2
        cropTool?.optionalInfo["swapButtonHidden"] = true
        
        var ratiosValue = [["value1": 1, "value2": 1]]
        
        if (ratios != nil) {
            ratiosValue = [["value1": ratios![0], "value2": ratios![1]]]
        }
        
        cropTool?.optionalInfo["ratios"] = ratiosValue
        
        // set the custom style for the toolbar
        editor?.theme!.toolbarColor = UIColor.mainColor()
        editor?.theme!.backgroundColor = UIColor.black
        editor?.theme!.toolbarTextColor = UIColor.white
        editor?.theme!.toolIconColor = "white"
        editor?.theme!.toolbarTextFont = UIFont(name:"Nunito-Regular", size: 16)!
        
        // find the navigation bar in the editor's subviews and set custom style
        var nav = UINavigationBar()
        for subview in (editor?.view.subviews)! {
            if subview is UINavigationBar {
                nav = subview as! UINavigationBar
                nav.barStyle = UIBarStyle.default
                nav.backgroundColor = UIColor.mainColor()
                nav.barTintColor = UIColor.mainColor()
                nav.tintColor = UIColor.white
                
                nav.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "Nunito-Regular", size: 19)!,  NSAttributedString.Key.foregroundColor: UIColor.white]
                
                nav.topItem!.leftBarButtonItem = self.getNavBarItem(imageId: "icon_close", action: #selector(UIViewController.closeEditor), height: 25, width: 25)
                nav.frame = CGRect(x: self.view.frame.size.width, y: nav.frame.origin.y, width: nav.frame.size.width, height: nav.frame.size.height)
                break
            }
        }
        
        editor?.modalTransitionStyle = .coverVertical
        
        currentEditor = editor
        
        self.present(editor!, animated: false) { () -> Void in
            self.hideLoader()
            UIView.animate(withDuration: 0.2, animations: {
                nav.frame = CGRect(x: 0, y: nav.frame.origin.y, width: nav.frame.size.width, height: nav.frame.size.height)
            })
        }
    }
    
    /**
     Close the currently open instance of CLImageEditor if one is open
     */
    @objc func closeEditor() {
        if(currentEditor != nil) {
            // currentEditor!.delegate.imageEditorDidCancel!(currentEditor)
            for subview in currentEditor!.view.subviews {
                if subview is UINavigationBar {
                    let navigationBar = subview as! UINavigationBar
                    UIView.animate(withDuration: 0.2, animations: {
                        navigationBar.frame = CGRect(x: self.view.frame.size.width, y: navigationBar.frame.origin.y, width: navigationBar.frame.size.width, height: navigationBar.frame.size.height)
                        }, completion: { Bool in
                            //currentEditor!.delegate.imageEditorDidCancel!(currentEditor)
                            self.dismiss(animated: false, completion: nil)
                    })
                    break
                }
            }
        }
    }
    
    
    /**
     Log the current user out and then run the given function
     
     - Parameters:
     - completionBlock: The function to run on completion of logout
     */
    func logout(completionBlock: @escaping (_ result: Bool, _ error: Error?) -> Void) {
        self.showLoader()
        PFUser.logOutInBackground() { (error: Error?) -> Void in
            self.hideLoader()
            if error != nil {
                NSLog("logout fail: \(error)")
                completionBlock(false, error!)
            } else {
                let appDelegate = AppDelegate.getAppDelegate()
                appDelegate.myAnimalsArray = nil
                appDelegate.myAnimalsWithDeceasedArray = nil
                appDelegate.hasFosters = false
                appDelegate.hasMemorial = false
                appDelegate.hasRegisteredForPush = false
                
                completionBlock(true, nil)
                
                if let currentInstallation = PFInstallation.current() {
                    currentInstallation.setValue(nil, forKey: "user")
                    currentInstallation.saveInBackground { (succeeded, e) -> Void in
                        NSLog("Successfully unregistered for push notifications")
                    }
                }
                
            }
        }
    }
    
    /**
     Open an image browser with the given timeline entries
     
     - Parameters:
     - entries: An array of WRTimelineEntry objects whose photos should be shown in a gallery
     - startIndex: the index of the photo to start the slideshow at
     - animatedFromView: the UIView or subclass object from which to animate to the gallery
     */
    func showImagesBrowser(entries: [AnyObject], startIndex: Int?, animatedFromView: UIView?, displayUser: Bool = false, vc:UIViewController = UIViewController()) {
        var idmImages = Array<SKPhoto>()
        entries.forEach { (entry) -> Void in
            if let imageUrl = entry["thumbnailUrl"] as? String {
            let idmPhoto : SKPhoto = SKPhoto.photoWithImageURL(imageUrl)//, holder: entry)
            idmPhoto.shouldCachePhotoURLImage = true
            idmPhoto.caption = entry.text
            //m
//            idmPhoto.commentCount = entry.getCommentCount()
//            idmPhoto.likeCount = entry.getLikeCount()
            idmImages.append(idmPhoto)
            }
        }

        var browser: SKPhotoBrowser! = SKPhotoBrowser(photos: idmImages)
        if let originImageView = animatedFromView as? UIImageView {
            if originImageView.image != nil {
                //m
//                browser = SKPhotoBrowser(originImage: originImageView.image!, photos: idmImages, animatedFromView: originImageView)
                browser = SKPhotoBrowser(photos: idmImages)
            }
        }

        if(startIndex != nil) {
            browser.initializePageIndex(startIndex!)
        }
        //m
//        SKPhotoBrowserOptions.displayToolbar = false
        SKPhotoBrowserOptions.displayAction = true
        SKPhotoBrowserOptions.displayDeleteButton = false

//        if(displayUser) {
//            //m
////            SKPhotoBrowserOptions.displayUserButton = true
//
//            SKPhotoBrowserOptions.handleUserButtonPressed = { (object: NSObject?)->Void in
//                NSLog("user button pressed")
//                if let entry = object as? WRTimelineEntry {
//                    if let animal = entry.animal {
//                        self.dismiss(animated: true, completion: {
//                            self.openAnimalDetail(animalObject: animal, push: true)
//                        })
//                    }
//                }
//            }
//        }

//        SKPhotoBrowserOptions.handleEntryLoaded = { (object: NSObject?, photo: SKPhotoProtocol?)->Void in
//            if let entry = object as? WRTimelineEntry {
//
//                if let animal = entry.animal {
//                    try! animal.fetchIfNeeded()
//
//                    browser.updateUserName(animal.username!)
//
//                    animal.fetchProfilePhoto({ (error, image) in
//                        if image != nil {
//                            browser.updateUserButton(image!.circle)
//                        } else {
//                            browser.updateUserButton(UIImage(named: "animal_profile_photo_empty")!)
//                        }
//                    })
//                }
//
//                if entry.commentCount != nil {
//                    browser.updateCommentCount(entry.commentCount!)
//                }
//                if entry.likeCount != nil {
//                    browser.updateLikeCount(entry.likeCount!)
//                }
//
//                if self.isLoggedIn() {
//                    entry.isLikedWithBlock({ (likeObject, error) in
//                        NSLog("entry is liked: \(likeObject)")
//                        if(likeObject != nil) {
//
//                            switch(likeObject!.actionValue!) {
//                            case .Meow:
//                                browser.updateLikeButton(UIImage(named: "emoji_meow")!)
//                            case .Hiss:
//                                browser.updateLikeButton(UIImage(named: "emoji_hiss")!)
//                            case .Purr:
//                                browser.updateLikeButton(UIImage(named: "emoji_purr")!)
//                            case .HeadBump:
//                                browser.updateLikeButton(UIImage(named: "emoji_headbump")!)
//                            case .Lick:
//                                browser.updateLikeButton(UIImage(named: "emoji_lick")!)
//                            default:
//                                browser.updateLikeButton(UIImage(named: "emoji_meow")!)
//                            }
//                            self.setLikeHandlerOn(browser: browser)
//                        } else {
//                            browser.updateLikeButton(UIImage(named: "button_paw")!)
//                            self.setLikeHandlerOff(browser: browser)
//                        }
//                    })
//                } else {
//                    self.setLikeHandlerOff(browser: browser)
//                }
//            }
//        }
        
        //m
//        SKPhotoBrowserOptions.customCloseButtonImage = UIImage(named: "icon_close")
//
//        SKPhotoBrowserOptions.displayCommentButton = true
//        SKPhotoBrowserOptions.customCommentButtonImage = UIImage(named: "emoji_comment")
//        SKPhotoBrowserOptions.handleCommentButtonPressed = { (object: NSObject?)->Void in
//            NSLog("comment button pressed")
//            if let entry = object as? WRTimelineEntry {
//                self.dismiss(animated: true, completion: {
//                    self.openEntryComments(entryObject: entry, push: false)
//                })
//            }
//        }
//
//        SKPhotoBrowserOptions.displayLikeButton = true
//        SKPhotoBrowserOptions.customLikeButtonImage = UIImage(named: "button_paw")
//
//        SKPhotoBrowserOptions.customUserButtonDefaultImage = UIImage(named: "animal_profile_photo_empty")
//
//        SKPhotoBrowserOptions.displayShareButton = true
//        SKPhotoBrowserOptions.customShareButtonImage = UIImage(named: "button_share")
//        SKPhotoBrowserOptions.handleShareButtonPressed = { (object: NSObject?, image: UIImage)->Void in
//            NSLog("share button pressed")
//            browser.showShareActionSheet(image: image)
//        }
//
//
//        if(self.isLoggedIn()) {
//            SKPhotoBrowserOptions.displayMoreButton = true
//            SKPhotoBrowserOptions.customMoreButtonImage = UIImage(named: "button_more")
//            SKPhotoBrowserOptions.handleMoreButtonPressed = { (object: NSObject?)->Void in
//                NSLog("more button pressed")
//                if let entry = object as? WRTimelineEntry {
//                    browser.showMoreActionSheet(entry: entry, vc:vc)
//                }
//            }
//        }

//        SKPhotoBrowserOptions.autoHideControls = false
        self.present(browser, animated: true, completion: nil)
    }
    
//    func setLikeHandlerOn(browser: SKPhotoBrowser) {
//        SKPhotoBrowserOptions.handleLikeButtonPressed = { (object: NSObject?, photo: SKPhotoProtocol?)->Void in
//            NSLog("like filled button pressed")
//            browser.checkForUser {
//                if let entry = object as? WRTimelineEntry {
//                    entry.unlikeWithBlock({ (result, error) in
//                        if(result) {
//                            browser.updateLikeButton(UIImage(named: "button_paw")!)
//
//                            if let skPhoto = photo as? SKPhoto {
//                                skPhoto.likeCount = skPhoto.likeCount - 1
//                                browser.updateLikeCount(skPhoto.likeCount as NSNumber)
//                            }
//                            self.setLikeHandlerOff(browser: browser)
//                            //                        browser.updateToolbar()
//                        }
//                    })
//                }
//            }
//        }
//    }
    
//    func setLikeHandlerOff(browser: SKPhotoBrowser) {
//        SKPhotoBrowserOptions.handleLikeButtonPressed = { (object: NSObject?, photo: SKPhotoProtocol?)->Void in
//            NSLog("like button pressed")
//            browser.checkForUser {
//                if let entry = object as? WRTimelineEntry {
//                    browser.showLikeActionSheet(entry: entry, completionBlock: { (likeObject, error) in
//                        NSLog("like action completed")
//
//                        if(likeObject != nil) {
//                            switch(likeObject!.actionValue!) {
//                            case .Meow:
//                                browser.updateLikeButton(UIImage(named: "emoji_meow")!)
//                            case .Hiss:
//                                browser.updateLikeButton(UIImage(named: "emoji_hiss")!)
//                            case .Purr:
//                                browser.updateLikeButton(UIImage(named: "emoji_purr")!)
//                            case .HeadBump:
//                                browser.updateLikeButton(UIImage(named: "emoji_headbump")!)
//                            case .Lick:
//                                browser.updateLikeButton(UIImage(named: "emoji_lick")!)
//                            default:
//                                browser.updateLikeButton(UIImage(named: "emoji_meow")!)
//                            }
//                            if let skPhoto = photo as? SKPhoto {
//                                skPhoto.likeCount = skPhoto.likeCount + 1
//                                browser.updateLikeCount(skPhoto.likeCount as NSNumber)
//                            }
//                        }
//                        self.setLikeHandlerOn(browser: browser)
//                    })
//                }
//            }
//        }
//    }
    
    
    /**
     Open an image browser with the given images
     
     - Parameters:
     - images: An array of UIImage objects that should be shown in a gallery
     - startIndex: the index of the photo to start the slideshow at
     - animatedFromView: the UIView or subclass object from which to animate to the gallery
     */
    func showImagesBrowser(images: [UIImage], startIndex: Int?, animatedFromView: UIView?) {
        var idmImages = Array<SKPhoto>()
        images.forEach { (image) -> Void in
            let idmPhoto : SKPhoto = SKPhoto.photoWithImage(image)
            idmPhoto.shouldCachePhotoURLImage = true
            idmImages.append(idmPhoto)
        }
        
        var browser: SKPhotoBrowser! = SKPhotoBrowser(photos: idmImages)
//        if let originImageView = animatedFromView as? UIImageView {
            browser = SKPhotoBrowser(photos: idmImages)
//        }
        
        if(startIndex != nil) {
            browser.initializePageIndex(startIndex!)
        }
        
        self.present(browser, animated: true, completion: nil)
    }
    
    /**
     Open an image browser with the given image urls
     
     - Parameters:
     - images: An array of String urls pointing to the images to be shown
     - startIndex: the index of the photo to start the slideshow at
     - animatedFromView: the UIView or subclass object from which to animate to the gallery
     */
    func showImagesBrowser(imageUrls: [String?], startIndex: Int?, animatedFromView: UIView?) {
        var idmImages = Array<SKPhoto>()
        imageUrls.forEach { (imageUrl) -> Void in
            let idmPhoto : SKPhoto = SKPhoto.photoWithImageURL(imageUrl!)
            idmPhoto.shouldCachePhotoURLImage = true
            idmImages.append(idmPhoto)
        }
        
        var browser: SKPhotoBrowser! = SKPhotoBrowser(photos: idmImages)
        if let originImageView = animatedFromView as? UIImageView {
            browser = SKPhotoBrowser(originImage: originImageView.image!, photos: idmImages, animatedFromView: animatedFromView!)
        }
        
        if(startIndex != nil) {
            browser.initializePageIndex(startIndex!)
        }

        self.present(browser, animated: true, completion: nil)
    }
    
    /**
     Open the given url in the users default web browser
     
     - Parameters:
     - url: The url to open
     */
    func openUrl(url:String!) {
        NSLog("opening url: \(url)")
        
        UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
    }
    
    /**
     Open the given app link if the user has the app installed or the url if they dont
     
     - Parameters:
     - appLink: The url to open
     - webUrl: The url to open if the app isn't installed
     */
    func openAppLinkOrWebUrl(appLink: String!, webUrl: String!) {
        if(UIApplication.shared.canOpenURL(NSURL(string: appLink)! as URL)) {
            openUrl(url: appLink)
        } else {
            openUrl(url: webUrl)
        }
    }
    
    func openEditEntryForm(entry: WRTimelineEntry) {
        let entryFormView = TimelineEntryFormViewController()
        //        entryFormView.image = entry.image
        
        entry.fetchImage({ (error, image) in
            entryFormView.image = image
            
            entryFormView.animalObject = entry.animal!
            entryFormView.entryObject = entry
            
            self.present(UINavigationController(rootViewController: entryFormView), animated: true, completion: nil)
        })
    }
    
    func openDeleteEntryForm(entry: WRTimelineEntry, vc: UIViewController) {
        self.showLoader()
        entry.deleteInBackground(block: { (success : Bool, error : Error?) -> Void in
            if(success) {
                self.hideLoader()
                self.dismiss(animated: true, completion: {
                  if self is SKPhotoBrowser {
                    if type(of: vc) == AnimalTimelineTableViewController.self {
                        let animalTimeline = vc as! AnimalTimelineTableViewController
                        animalTimeline.animalImagesRepository?.loadAllImages()
                        animalTimeline.loadObjects()
                    } else if type(of: vc) == PhotosCollectionViewController.self {
                        let photoCollection = vc as! PhotosCollectionViewController
                        photoCollection.animalImagesRepository?.loadAllImages()
                        photoCollection.collectionView?.reloadData()
                        photoCollection.animalTimelineController?.loadObjects()
                    }
                    }
                })
            }
        })
    }
    
    func showMoreActionSheet(entry: WRTimelineEntry, vc: UIViewController) {
        let optionMenu = UIAlertController(title: nil, message: "Meowment Action", preferredStyle: .actionSheet)
        
        if entry.isOwnedBy(WRUser.current()!) {
            let editAction = UIAlertAction(title: "Edit", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Editing timeline entry")
                self.openEditEntryForm(entry: entry)
//                            self.editEntry(indexPath)
            })
            editAction.setValue(UIImage(named: "icon_edit_profile")!.withRenderingMode(.alwaysOriginal), forKey: "image")
            
            let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Deleting timeline entry")
                self.openDeleteEntryForm(entry: entry, vc: vc)
            })
            deleteAction.setValue(UIImage(named: "button_delete")!.withRenderingMode(.alwaysOriginal), forKey: "image")
            
//            let profilePhotoAction = UIAlertAction(title: "Set as Profile Photo", style: .Default, handler: {
//                (alert: UIAlertAction!) -> Void in
//                print("Setting profile photo")
//                //            self.setProfilePhoto(self.imageAtCell(indexPath)!)
//            })
//            
//            let coverPhotoAction = UIAlertAction(title: "Set as Cover Photo", style: .Default, handler: {
//                (alert: UIAlertAction!) -> Void in
//                print("Setting cover photo")
//                //            self.setCoverPhoto(self.imageAtCell(indexPath)!)
//            })
//            
            optionMenu.addAction(editAction)
            optionMenu.addAction(deleteAction)
            //            optionMenu.addAction(profilePhotoAction)
            //            optionMenu.addAction(coverPhotoAction)
        } else {
            let flagAction = UIAlertAction(title: "Flag", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Flagging timeline entry")
                //            self.editEntry(indexPath)
            })
            flagAction.setValue(UIImage(named: "button_flag")!.withRenderingMode(.alwaysOriginal), forKey: "image")
            
            optionMenu.addAction(flagAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func showLikeActionSheet(entry: WRTimelineEntry, completionBlock: @escaping (_ likeObject: WRLike?, _ error: Error?) -> Void) {
        let optionMenu = UIAlertController(title: nil, message: "Choose An Emeowji", preferredStyle: .actionSheet)
        
        let meowAction = UIAlertAction(title: "Meow", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            entry.likeWithBlock(.Meow, completionBlock: completionBlock)
            self.playASound(soundName: "meow2")
        })
        meowAction.setValue(UIImage(named: "emoji_meow")!.withRenderingMode(.alwaysOriginal), forKey: "image")
        
        let purrAction = UIAlertAction(title: "Purr", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            entry.likeWithBlock(.Purr, completionBlock: completionBlock)
            self.playASound(soundName: "purr1")
        })
        purrAction.setValue(UIImage(named: "emoji_purr")!.withRenderingMode(.alwaysOriginal), forKey: "image")

        let lickAction = UIAlertAction(title: "Lick", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            entry.likeWithBlock(.Lick, completionBlock: completionBlock)
            self.playASound(soundName: "lick1")
        })
        lickAction.setValue(UIImage(named: "emoji_lick")!.withRenderingMode(.alwaysOriginal), forKey: "image")
        
        let headBumpAction = UIAlertAction(title: "Head Bump", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            entry.likeWithBlock(.HeadBump, completionBlock: completionBlock)
            self.playASound(soundName: "chirp1")
        })
        headBumpAction.setValue(UIImage(named: "emoji_headbump")!.withRenderingMode(.alwaysOriginal), forKey: "image")
        
        let hissAction = UIAlertAction(title: "Hiss", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            entry.likeWithBlock(.Hiss, completionBlock: completionBlock)
            self.playASound(soundName: "hiss1")
        })
        hissAction.setValue(UIImage(named: "emoji_hiss")!.withRenderingMode(.alwaysOriginal), forKey: "image")
        
        
        let cancelAction = UIAlertAction(title: "Clawncel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(meowAction)
        optionMenu.addAction(purrAction)
        optionMenu.addAction(lickAction)
        optionMenu.addAction(headBumpAction)
        optionMenu.addAction(hissAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                self.goBack()
            default:
                break
            }
        }
    }
    
    @objc func textWasChanged(textField: UITextField) {
        let val = textField.text
        let maxLength = 500
        if (val?.count)! > maxLength {
            textField.text = val?[0...maxLength]
        }
    }
}

extension PFQueryTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    public func initEmptyState() {
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
    }
    
    func replacePFLoadingView(verticalOffset:CGFloat=0) {
        
        // go through all of the subviews until you find a PFLoadingView subclass
        for currentView in self.view.subviews {
            
            if NSStringFromClass(currentView.classForCoder) == "PFLoadingView" {
                
                // find and remove the loading label and loading activity indicator inside the PFLoadingView subviews
                for loadingViewSubview in currentView.subviews {
                    if loadingViewSubview is UILabel {
                        let label:UILabel = loadingViewSubview as! UILabel
                        label.removeFromSuperview()
                    }
                    
                    if loadingViewSubview is UIActivityIndicatorView {
                        let indicator:UIActivityIndicatorView = loadingViewSubview as! UIActivityIndicatorView
                        indicator.removeFromSuperview()
                    }
                }
                
                let customIndicator = CustomActivityIndicator(parentView: currentView.superview!, verticalOffset: verticalOffset)
                currentView.addSubview(customIndicator)
            }
        }
    }
    
    func stylePFLoadingView() {
        let activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        
        // go through all of the subviews until you find a PFLoadingView subclass
        for view in self.view.subviews {
            if NSStringFromClass(view.classForCoder) == "PFLoadingView" {
                // find the loading label and loading activity indicator inside the PFLoadingView subviews
                for loadingViewSubview in view.subviews {
                    if loadingViewSubview is UILabel {
                        let label:UILabel = loadingViewSubview as! UILabel
                        let frame = label.frame
                        label.frame = CGRect(x: frame.midX, y: frame.midY, width: 100, height: 20)
                    }
                    
                    if loadingViewSubview is UIActivityIndicatorView {
                        let indicator:UIActivityIndicatorView = loadingViewSubview as! UIActivityIndicatorView
                        indicator.style = activityIndicatorViewStyle
                        
                    }
                }
            }
        }
    }
}

extension UIImageView {
    func makeCircular() {
        self.clipsToBounds = true
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = self.frame.size.width / 2
    }
    
    func makeSquare() {
        self.frame = bounds
        self.clipsToBounds = false
        self.layer.borderWidth = 0.0
        self.layer.cornerRadius = 0
    }
}

public extension UIApplicationDelegate {
    func initializeWhiteRabbitCommon() {
        self.initializeParse()
        self.initializeUI()
    }
    
    func initializeParse() {
        Parse.enableLocalDatastore()
        PFUser.enableRevocableSessionInBackground()
        
        Parse.initialize(with: ParseClientConfiguration(block: { (configuration: ParseMutableClientConfiguration) -> Void in
            configuration.applicationId = "IWr9xzTirLbjXH80mbTCtT9lWB73ggQe3PhA6nPg"
            configuration.clientKey = "Yxdst3hz76abMoAwG7FLh0NwDmPvYHFDUPao9WJJ"
            configuration.server = "http://www.whiterabbitapps.net/api"
        }))
    }
    
    func initializeUI() {
        UILabel.appearance().substituteFontName = "Nunito-Regular"
        UITabBar.appearance().barTintColor = UIColor.mainColor()
        UITabBar.appearance().tintColor = UIColor.white
    }
}

public extension UIColor {
    class func mainColor() -> UIColor {
        return UIColor(red: 0/255, green: 42/255, blue: 79/255, alpha: 1.0)
    }
    
    class func secondaryColor() -> UIColor {
        return UIColor.lightGray
    }
    
    class func linkColor() -> UIColor {
        return UIColor(red: 0/255, green: 94/255, blue: 183/255, alpha: 1.0)
    }
    
    class func lightOrangeColor() -> UIColor {
        return UIColor(red: 254/255, green: 122/255, blue: 96/255, alpha: 1.0)
    }
    
    class func lightYellowColor() -> UIColor {
        return UIColor(red: 244/255, green: 166/255, blue: 54/255, alpha: 1.0)
    }
    
    class func lightGreenColor() -> UIColor {
        return UIColor(red: 163/255, green: 202/255, blue: 123/255, alpha: 1.0)
    }
    
    class func lightBlueColor() -> UIColor {
        return UIColor(red: 94/255, green: 126/255, blue: 147/255, alpha: 1.0)
    }
    
    class func lightRedColor() -> UIColor {
        return UIColor(red: 148/255, green: 135/255, blue: 114/255, alpha: 1.0)
    }
    
    class func lightPinkColor() -> UIColor {
        return UIColor(red: 168/255, green: 183/255, blue: 196/255, alpha: 1.0)
    }
    
    class func facebookThemeColor() -> UIColor {
        return UIColor(red: 63/255, green: 81/255, blue: 121/255, alpha: 1.0)
    }
    
}

public extension Int {
    static func random(lower: Int , upper: Int) -> Int {
        let limit = UInt32(upper - lower + 1)
        return lower + Int(arc4random_uniform(limit))
    }
}

public extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
    
    func forEach(doThis: (_ element: Element) -> Void) {
        for e in self {
            doThis(e)
        }
    }
    
    func slice(args: Int...) -> Array {
        var s = args[0]
        var e = self.count - 1
        if args.count > 1 { e = args[1] }
        
        if e < 0 {
            e += self.count
        }
        
        if s < 0 {
            s += self.count
        }
        
        let count = (s < e ? e-s : s-e)+1
        let inc = s < e ? 1 : -1
        var ret = Array()
        
        var idx = s
        for _ in 0..<count  {
            ret.append(self[idx])
            idx += inc
        }
        return ret
    }
}

public extension Dictionary {
    mutating func merge<K, V>(dictionaries: Dictionary<K, V>...) {
        for dict in dictionaries {
            for (key, value) in dict {
                self.updateValue(value as! Value, forKey: key as! Key)
            }
        }
    }
}

public extension UITextField {
    @IBInspectable var leftSpacer:CGFloat {
        get {
            if let l = leftView {
                return l.frame.size.width
            } else {
                return 0
            }
        } set {
            leftViewMode = .always
            leftView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
        }
    }
}

extension DateFormatter {
    /**
     Formats a date as the time since that date (e.g., “Last week, yesterday, etc.”).
     
     - Parameter from: The date to process.
     - Parameter numericDates: Determines if we should return a numeric variant, e.g. "1 month ago" vs. "Last month".
     
     - Returns: A string with formatted `date`.
     */
    func timeSince(from: Date, numericDates: Bool = false) -> String {
        let calendar = Calendar.current
        let now = NSDate()
        let earliest = now.earlierDate(from as Date)
        let latest = earliest == now as Date ? from : now as Date
        let components = calendar.dateComponents([.year, .weekOfYear, .month, .day, .hour, .minute, .second], from: earliest, to: latest as Date)
        
        var result = ""
        
        if components.year! >= 2 {
            result = "\(components.year!) years ago"
        } else if components.year! >= 1 {
            if numericDates {
                result = "1 year ago"
            } else {
                result = "Last year"
            }
        } else if components.month! >= 2 {
            result = "\(components.month!) months ago"
        } else if components.month! >= 1 {
            if numericDates {
                result = "1 month ago"
            } else {
                result = "Last month"
            }
        } else if components.weekOfYear! >= 2 {
            result = "\(components.weekOfYear!) weeks ago"
        } else if components.weekOfYear! >= 1 {
            if numericDates {
                result = "1 week ago"
            } else {
                result = "Last week"
            }
        } else if components.day! >= 2 {
            result = "\(components.day!) days ago"
        } else if components.day! >= 1 {
            if numericDates {
                result = "1 day ago"
            } else {
                result = "Yesterday"
            }
        } else if components.hour! >= 2 {
            result = "\(components.hour!) hours ago"
        } else if components.hour! >= 1 {
            if numericDates {
                result = "1 hour ago"
            } else {
                result = "An hour ago"
            }
        } else if components.minute! >= 2 {
            result = "\(components.minute!) minutes ago"
        } else if components.minute! >= 1 {
            if numericDates {
                result = "1 minute ago"
            } else {
                result = "A minute ago"
            }
        } else if components.second! >= 3 {
            result = "\(components.second!) seconds ago"
        } else {
            result = "Just now"
        }
        
        return result
    }
    
    func timeSinceShortened(from: Date) -> String {
        let calendar = Calendar.current
        let now = NSDate()
        let earliest = now.earlierDate(from as Date)
        let latest = earliest == now as Date ? from : now as Date
        let components = calendar.dateComponents([.year, .weekOfYear, .month, .day, .hour, .minute, .second], from: earliest, to: latest as Date)
        
        var result = ""
        
        if components.year! >= 1 {
            result = "\(components.year!)y"
        } else if components.month! >= 1 {
            result = "\(components.month!)mo"
        } else if components.weekOfYear! >= 1 {
            result = "\(components.weekOfYear!)w"
        } else if components.day! >= 1 {
            result = "\(components.day!)d"
        } else if components.hour! >= 1 {
            result = "\(components.hour!)h"
        } else if components.minute! >= 1 {
            result = "\(components.minute!)min"
        } else if components.second! >= 3 {
            result = "\(components.second!)sec"
        } else {
            result = "Just now"
        }
        
        return result
    }

}

public extension UIView {
    // Draw a border at the top of a view.
    func drawTopBorderWithColor(color: UIColor, height: CGFloat) {
        let topBorder = CALayer()
        topBorder.backgroundColor = color.cgColor
        topBorder.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: height)
        self.layer.addSublayer(topBorder)
    }
    // adds a label to at center of a view
    func drawLabel(text : String) {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 30)
        label.textColor = UIColor.white
        label.textAlignment = .center
        self.addSubview(label)
    }
}

public extension UIStoryboard {
    static var mainStoryboard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
}

public extension String {
    func capitalizeFirstLetter() -> String {
        let first = String(self.prefix(1)).capitalized
        let other = String(self.dropFirst())
        return first + other
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    subscript(i: Int) -> String {
        guard i >= 0 && i < self.count else { return "" }
        return String(self[index(startIndex, offsetBy: i)])
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
//    subscript(range: Range<Int>) -> String {
//        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
//        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) ?? endIndex))
//    }
//
//    subscript(range: ClosedRange<Int>) -> String {
//        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
//        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound + 1, limitedBy: endIndex) ?? endIndex))
//    }
}

public extension UILabel {
    func resizeHeightToFit(heightConstraint: NSLayoutConstraint) {
        let attributes = [NSAttributedString.Key.font : font]
        numberOfLines = 0
        lineBreakMode = NSLineBreakMode.byWordWrapping
        let rect = text!.boundingRect(with: CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
        heightConstraint.constant = rect.height
        setNeedsLayout()
    }
    
    var substituteFontName : String {
        get { return self.font.fontName }
        //m
//        set { self.font = UIFont(name: newValue, size: self.font.pointSize) }
        set { self.font = UIFont.systemFont(ofSize: 14.0) }
    }
}

public extension UIImage {
    class func imageWithImage(image: UIImage, scaledToScale scale: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, true, scale)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = .high
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    var circle: UIImage {
        let square = size.width < size.height ? CGSize(width: size.width, height: size.width) : CGSize(width: size.height, height: size.height)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = square.width/50
        imageView.layer.borderColor = UIColor.white.cgColor.copy(alpha: 0.75)
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}

var ActionBlockKey: UInt8 = 0
public typealias BlockButtonActionBlock = (_ sender: UIButton) -> Void

public class ActionBlockWrapper : NSObject {
    var block : BlockButtonActionBlock
    init(block: @escaping BlockButtonActionBlock) {
        self.block = block
    }
}

public extension UIButton {
    func setActionBlock(block: @escaping BlockButtonActionBlock) {
        objc_setAssociatedObject(self, &ActionBlockKey, ActionBlockWrapper(block: block), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(self, action: #selector(handleActionBlock), for: .touchUpInside)
    }
    
    @objc func handleActionBlock(sender: UIButton) {
        let wrapper = objc_getAssociatedObject(self, &ActionBlockKey) as! ActionBlockWrapper
        wrapper.block(sender)
    }
}

public extension UINavigationController {
    func popViewControllerWithCompletionBlock(completion: @escaping ()->()) {
        CATransaction.begin()
        self.popViewController(animated: true)
        CATransaction.setCompletionBlock(completion)
        CATransaction.commit()
    }
    
    func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}

class UIStoryboardSegueFromTop: UIStoryboardSegue {
    override func perform() {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: 0, y: -src.view.frame.size.height)
        
        UIView.animate(withDuration: 1.0, animations: {
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
            
        }) { (Finished) in
            src.present(dst, animated: false, completion: nil)
        }
    }
}


//
//
////public struct for PagingMenuOptions
//public struct PagingMenuOptions: PagingMenuControllerCustomizable {
//    var pagingControllers:[UIViewController]
//    var menuOptions: MenuViewCustomizable
//    init(pagingControllers:[UIViewController], menuOptions: MenuViewCustomizable){
//        self.pagingControllers = pagingControllers
//        self.menuOptions = menuOptions
//    }
//    public var componentType: ComponentType {
//        return .all(menuOptions: menuOptions, pagingControllers: pagingControllers)
//    }
//}
//
////public struct for custom Menu Item
//public struct MenuItemCustom: MenuItemViewCustomizable {
//    public var horizontalMargin: CGFloat {
//        return 0
//    }
//    var titleLabel: String = ""
//    var imageName:String = ""
//    var imageFrame = CGRect(x: 50, y: 12, width: 25, height: 25)
//    var labelFrame = CGRect(x: 85, y: 0, width: 100, height: 50)
//    var isTextType = false
//    
//    //set the number of Pages for width of the Menu View
//    var numberOfPages:Int = 1
//    var viewHeight:CGFloat = CGFloat(50)
//    init (title:String, imageName:String){
//        self.titleLabel = title
//        self.imageName = imageName
//    }
//    
//    init (title:String){
//        self.titleLabel = title
//        self.isTextType = true
//    }
//    
//    public var displayMode: MenuItemDisplayMode {
//        if isTextType{
//            let text = MenuItemCustom(text: titleLabel, color: UIColor.lightGray, selectedColor: UIColor.white, font: UIFont(name: "Nunito-Regular", size: 14)!, selectedFont: UIFont(name: "Nunito-Regular", size: 14)!)
//            
//            return .text(title:text)
//        } else {
//            let imageView = UIImageView(frame: imageFrame)
//            let image = UIImage(named: imageName)
//            imageView.image = image
//            imageView.backgroundColor = UIColor.clear
//            
//            let title = UILabel(frame: labelFrame)
//            title.text = titleLabel
//            title.font = UIFont(name: "Nunito-Regular", size: 14)
//            title.textColor = UIColor.gray
//            title.backgroundColor = UIColor.clear
//            
//            let width = (UIApplication.shared.keyWindow?.bounds.width)!/CGFloat(numberOfPages)+2 ?? UIScreen.main.bounds.width/CGFloat(numberOfPages)+2
//            
//            let bottomImageView = UIImageView(frame: CGRect(x: 0, y: 49, width: width, height: 1))
//            bottomImageView.backgroundColor = UIColor.lightGray
//            
//            let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: viewHeight))
//            view.addSubview(imageView)
//            view.addSubview(title)
//            view.addSubview(bottomImageView)
//            return .custom(view: view)
//        }
//    }
//}


//public struct for PagingMenuOptions
public struct PagingMenuOptions: PagingMenuControllerCustomizable {
    var pagingControllers:[UIViewController]
    var menuOptions: MenuViewCustomizable
    init(pagingControllers:[UIViewController], menuOptions: MenuViewCustomizable){
        self.pagingControllers = pagingControllers
        self.menuOptions = menuOptions
    }
    public var componentType: ComponentType {
        return .all(menuOptions: menuOptions, pagingControllers: pagingControllers)
    }
}

//public struct for custom Menu Item
public struct MenuItemCustom: MenuItemViewCustomizable {
    public var horizontalMargin: CGFloat {
        return 0
    }
    var titleLabel: String = ""
    var imageName:String = ""
    var imageFrame = CGRect(x: 50, y: 12, width: 25, height: 25)
    var labelFrame = CGRect(x: 85, y: 0, width: 100, height: 50)
    var isTextType = false
    
    //set the number of Pages for width of the Menu View
    var numberOfPages:Int = 1
    var viewHeight:CGFloat = CGFloat(50)
    init (title:String, imageName:String){
        self.titleLabel = title
        self.imageName = imageName
    }
    
    init (title:String){
        self.titleLabel = title
        self.isTextType = true
    }
    
    public var displayMode: MenuItemDisplayMode {
        if isTextType{
            let text = MenuItemText(text: titleLabel, color: .lightGray, selectedColor: .white, font: UIFont(name: "Nunito-Regular", size: 14)!, selectedFont: UIFont(name: "Nunito-Regular", size: 14)!)
            
            return .text(title:text)
        } else {
            let imageView = UIImageView(frame: imageFrame)
            let image = UIImage(named: imageName)
            imageView.image = image
            imageView.backgroundColor = .clear
            
            let title = UILabel(frame: labelFrame)
            title.text = titleLabel
            title.font = UIFont(name: "Nunito-Regular", size: 14)
            title.textColor = .gray
            title.backgroundColor = .clear
          
            let width = UIScreen.main.bounds.width/CGFloat(numberOfPages)+2
            
            let bottomImageView = UIImageView(frame: CGRect(x: 0, y: 49, width: width, height: 1))
            bottomImageView.backgroundColor = UIColor.lightGray
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: viewHeight))
            view.addSubview(imageView)
            view.addSubview(title)
            view.addSubview(bottomImageView)
            return .custom(view: view)
        }
    }
 }

extension UITableViewCell {
    var cellActionButtonLabel: UILabel? {
        superview?.subviews
            .filter { String(describing: $0).range(of: "UISwipeActionPullView") != nil }
            .flatMap { $0.subviews }
            .filter { String(describing: $0).range(of: "UISwipeActionStandardButton") != nil }
            .flatMap { $0.subviews }
            .compactMap { $0 as? UILabel }.first
    }
}
