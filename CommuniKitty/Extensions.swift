//
//  Extensions.swift
//  White Rabbit
//
//  Created by Michael Bina on 12/12/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import ParseUI
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
    func showLoader() {
        self.hideLoader()
        let filename = Int.random(lower: 1, upper: 20)
        
        GiFHUD.setGif("gif/" + String(filename) + ".gif")
        GiFHUD.show()
    }
    
    /**
     Hide the GifHUD loader window
     */
    func hideLoader() {
        GiFHUD.dismiss()
    }
    
    /**
     Pop back to the previous view controller in the current UINavigationController
     */
    func goBack() {
        self.navigationController?.popViewController(animated: true)
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
    func close() {
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
    
    func dismissKeyboard() {
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
        
        UIApplication.shared.openURL(NSURL(string: email)! as URL)
    }
    
    /**
     Open a standard alert screen with the given parameters
     
     - Parameters:
     - title: The title text for the alert
     - message: The body text of the alert
     - buttonText: The title of the button
     */
    func displayAlert(title:String, message:String, buttonText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonText, style: UIAlertActionStyle.default, handler: nil))
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
        nav?.backgroundColor = UIColor.mainColor()
        nav?.barTintColor = UIColor.mainColor()
        nav?.tintColor = UIColor.white
        
        nav?.setBackgroundImage(nil, for: .default)
        if var frame = nav?.frame {
            frame.size.height = 45
            nav?.frame = frame
        }
        
        nav?.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Nunito-Black", size: 20)!,  NSForegroundColorAttributeName: UIColor.white]
        
        self.navigationItem.title = title
        
        if(showButton) {
            self.navigationItem.leftBarButtonItem = self.getNavBarItem(imageId: "icon_back", action: #selector(UIViewController.goBack), height: 30, width: 25)
        }
    }
    
    func setUpTransparentNavigationBar() {
        self.setUpTransparentNavigationBar(title: "")
    }
    
    func setUpTransparentNavigationBar(title: String) {
        self.setUpNavigationBar(title: title)
        
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
    
    func setUpNavigationBarImage(image: UIImage, height: CGFloat) {
        self.setUpNavigationBarImage(image: image, height: height, title: "")
    }
    
    func setUpNavigationBarImage(image: UIImage, height: CGFloat, title: String, showButton: Bool = true) {
        let nav = self.navigationController?.navigationBar
        
        nav?.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Nunito-Black", size: 20)!,  NSForegroundColorAttributeName: UIColor.white]
        
        self.navigationItem.title = title
        
        nav?.barStyle = UIBarStyle.blackOpaque
        
        nav!.isTranslucent = false
        nav!.setBackgroundImage(image.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: .default)
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
    
    /**
     Show the create animal form
     */
    func showAddAnimalForm() {
        let animalForm = AnimalFormViewController()
        self.present(UINavigationController(rootViewController: animalForm), animated: true, completion: nil)
    }
    
    func getToastOptions(message: String, type: String, timeToShow: Double) -> [NSObject : AnyObject] {
        var fontSize = 14.0
        if(message.characters.count > 60) {
            fontSize = 12.0
        }
        
        let options: [NSObject : AnyObject] = [
            kCRToastSubtitleTextKey as NSObject: message as AnyObject,
            kCRToastUnderStatusBarKey as NSObject: false as AnyObject,
            kCRToastTimeIntervalKey as NSObject: timeToShow as AnyObject,
            kCRToastNotificationPreferredPaddingKey as NSObject: 15.0 as AnyObject,
            //            kCRToastNotificationPreferredHeightKey: 150.0,
            kCRToastFontKey as NSObject: UIFont.italicSystemFont(ofSize: 16),
            kCRToastSubtitleFontKey as NSObject: UIFont(name: "Nunito-Regular", size: CGFloat(fontSize))!,
//            kCRToastNotificationTypeKey : CRToastType.NavigationBar.rawValue,
//            kCRToastSubtitleTextAlignmentKey: NSTextAlignment.Left.rawValue,
//            kCRToastTextAlignmentKey: NSTextAlignment.Left.rawValue,
//            kCRToastAnimationInTypeKey: CRToastAnimationType.Spring.rawValue,
//            kCRToastAnimationOutTypeKey: CRToastAnimationType.Spring.rawValue,
//            kCRToastAnimationInDirectionKey: CRToastAnimationDirection.Top.rawValue,
//            kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.Top.rawValue
        ]
        
//        let interactionResponder = CRToastInteractionResponder(interactionType: CRToastInteractionType.tap, automaticallyDismiss: false) { (type: CRToastInteractionType) -> Void in
//            CRToastManager.dismissNotification(true)
//        }
//        options[kCRToastInteractionRespondersKey] = Array([interactionResponder])
//        
//        if(type == "error") {
//            options[kCRToastBackgroundColorKey] = UIColor(red: 0.80, green:0.25, blue:0.15, alpha:1.0)
//            
//            options[kCRToastTextKey] = ["Taht dint werk.", "Ruh roh.", "Ar yoo kitten me?"].randomItem()
//            
//            let filename = Int.random(lower: 1, upper: 8)
//            options[kCRToastImageKey] = UIImage(named: "error" + String(filename))
//        } else if(type == "success") {
//            options[kCRToastBackgroundColorKey] = UIColor(red: 0.58, green: 0.77, blue: 0.49, alpha: 1.0)
//            
//            options[kCRToastTextKey] = ["Errrmahgerd!", "Pawesum.", "It werkd.", "Clawesome!"].randomItem()
//            
//            let filename = Int.random(lower: 1, upper: 5)
//            options[kCRToastImageKey] = UIImage(named: "success" + String(filename))
//        } else if(type == "info") {
//            options[kCRToastBackgroundColorKey] = UIColor(red: 98/255, green: 81/255, blue: 255/255, alpha: 1.0)
//            
//            options[kCRToastTextKey] = ["Oh hai."].randomItem()
//            
//            let filename = Int.random(lower: 1, upper: 5)
//            options[kCRToastImageKey] = UIImage(named: "success" + String(filename))
//        }
//        
        
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
    func openExplore() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let exploreView = storyboard.instantiateViewController(withIdentifier: "Explore") as! ExploreViewController
        self.present(UINavigationController(rootViewController: exploreView), animated: true, completion: nil)
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
    func openAnimalDetail(animalObject: WRAnimal, push: Bool, timelineObjectId: String? = nil) {
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
        let editor = CLImageEditor(image: image, delegate: delegate)!
//        let editor = CLImageEditor(image: image, delegate: delegate, forceToCrop: forceCrop)
        
        let stickerTool = editor.toolInfo.subToolInfo(withToolName: "CLStickerTool", recursive: false)
        stickerTool?.optionalInfo["flipHorizontalIconAssetsName"] = "button_stickers"
        stickerTool?.available = true
//        stickerTool.customIcon = "icon_stickers"
        //        stickerTool.optionalInfo["stickerPath"] = "stickers/"
        stickerTool?.optionalInfo["deleteIconAssetsName"] = "button_delete"
        stickerTool?.optionalInfo["resizeIconAssetsName"] = "icon_resize"
        
        let splashTool = editor.toolInfo.subToolInfo(withToolName: "CLSplashTool", recursive: false)
        splashTool?.available = false
        let curveTool = editor.toolInfo.subToolInfo(withToolName: "CLToneCurveTool", recursive: false)
        curveTool?.available = false
        let blurTool = editor.toolInfo.subToolInfo(withToolName: "CLBlurTool", recursive: false)
        blurTool?.available = false
        let drawTool = editor.toolInfo.subToolInfo(withToolName: "CLDrawTool", recursive: false)
        drawTool?.available = false
        let adjustmentTool = editor.toolInfo.subToolInfo(withToolName: "CLAdjustmentTool", recursive: false)
        adjustmentTool?.available = false
        
        let effectTool = editor.toolInfo.subToolInfo(withToolName: "CLEffectTool", recursive: false)
        effectTool?.available = false
        let pixelateFilter = effectTool?.subToolInfo(withToolName: "CLPixellateEffect", recursive: false)
        pixelateFilter?.available = false
        let posterizeFilter = effectTool?.subToolInfo(withToolName: "CLPosterizeEffect", recursive: false)
        posterizeFilter?.available = false
        
        
        let filterTool = editor.toolInfo.subToolInfo(withToolName: "CLFilterTool", recursive: false)
        //        filterTool.optionalInfo["flipHorizontalIconAssetsName"] = "button_filter"
        filterTool?.available = true
//        filterTool.customIcon = "icon_filters"
        let invertFilter = filterTool?.subToolInfo(withToolName: "CLDefaultInvertFilter", recursive: false)
        invertFilter?.available = false
        
        let rotateTool = editor.toolInfo.subToolInfo(withToolName: "CLRotateTool", recursive: false)
        rotateTool?.available = true
        rotateTool?.dockedNumber = -1
//        rotateTool.customIcon = "icon_rotate"
        
        rotateTool?.optionalInfo["rotateIconAssetsName"] = "icon_rotate"
        rotateTool?.optionalInfo["flipHorizontalIconAssetsName"] = "icon_flip_horizontal"
        rotateTool?.optionalInfo["flipVerticalIconAssetsName"] = "icon_flip_vertical"
        
        let textTool = editor.toolInfo.subToolInfo(withToolName: "CLTextTool", recursive: false)
//        textTool.customIcon = "icon_text"
        textTool?.optionalInfo["newTextIconAssetsName"] = "button_add_small"
        textTool?.optionalInfo["editTextIconAssetsName"] = "icon_text_edit"
        textTool?.optionalInfo["deleteIconAssetsName"] = "button_delete"
        textTool?.optionalInfo["fontIconAssetsName"] = "icon_font"
        textTool?.optionalInfo["alignLeftIconAssetsName"] = "icon_align_left"
        textTool?.optionalInfo["alignCenterIconAssetsName"] = "icon_align_center"
        textTool?.optionalInfo["alignRightIconAssetsName"] = "icon_align_right"
        
        let cropTool = editor.toolInfo.subToolInfo(withToolName: "CLClippingTool", recursive: false)
        cropTool?.optionalInfo["flipHorizontalIconAssetsName"] = "button_crop"
        cropTool?.available = true
//        cropTool.customIcon = "icon_crop"
        cropTool?.dockedNumber = -2
        cropTool?.optionalInfo["swapButtonHidden"] = true
        
        cropTool?.optionalInfo["ratios"] = ratios != nil ? ratios : [["value1": 1, "value2": 1]]
        
        // set the custom style for the toolbar
        editor.theme!.toolbarColor = UIColor.mainColor()
        editor.theme!.backgroundColor = UIColor.black
        editor.theme!.toolbarTextColor = UIColor.white
        editor.theme!.toolIconColor = "white"
        editor.theme!.toolbarTextFont = UIFont(name:"Nunito-Regular", size: 16)!
        
        // find the navigation bar in the editor's subviews and set custom style
        var nav = UINavigationBar()
        for subview in editor.view.subviews {
            if subview is UINavigationBar {
                nav = subview as! UINavigationBar
                nav.barStyle = UIBarStyle.default
                nav.backgroundColor = UIColor.mainColor()
                nav.barTintColor = UIColor.mainColor()
                nav.tintColor = UIColor.white
                
                nav.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Nunito-Regular", size: 19)!,  NSForegroundColorAttributeName: UIColor.white]
                
                nav.topItem!.leftBarButtonItem = self.getNavBarItem(imageId: "icon_close", action: #selector(UIViewController.closeEditor), height: 25, width: 25)
                nav.frame = CGRect(x: self.view.frame.size.width, y: nav.frame.origin.y, width: nav.frame.size.width, height: nav.frame.size.height)
                break
            }
        }
        
        editor.modalTransitionStyle = .coverVertical
        
        currentEditor = editor
        
        self.present(editor, animated: false) { () -> Void in
            self.hideLoader()
            UIView.animate(withDuration: 0.2, animations: {
                nav.frame = CGRect(x: 0, y: nav.frame.origin.y, width: nav.frame.size.width, height: nav.frame.size.height)
            })
        }
    }
    
    /**
     Close the currently open instance of CLImageEditor if one is open
     */
    func closeEditor() {
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
                
                completionBlock(true, nil)
                
                let currentInstallation = PFInstallation.current()
                
                currentInstallation.setValue(nil, forKey: "user")
                currentInstallation.saveInBackground { (succeeded, e) -> Void in
                    NSLog("Successfully unregistered for push notifications")
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
    func showImagesBrowser(entries: [WRTimelineEntry], startIndex: Int?, animatedFromView: UIView?, displayUser: Bool = false) {
        var idmImages = Array<SKPhoto>()
        entries.forEach { (entry) -> Void in
            let idmPhoto : SKPhoto = SKPhoto.photoWithImageURL(entry.getImageUrl()!) //, holder: entry)
            idmPhoto.shouldCachePhotoURLImage = true
            idmPhoto.caption = entry.text
//            idmPhoto.commentCount = entry.getCommentCount()
//            idmPhoto.likeCount = entry.getLikeCount()
            idmImages.append(idmPhoto)
        }
        
        var browser: SKPhotoBrowser! = SKPhotoBrowser(photos: idmImages)
        if let originImageView = animatedFromView as? UIImageView {
            if originImageView.image != nil {
                browser = SKPhotoBrowser(originImage: originImageView.image!, photos: idmImages, animatedFromView: originImageView)
            }
        }
        
        if(startIndex != nil) {
            browser.initializePageIndex(startIndex!)
        }
//        browser.displayBackAndForwardButton = false
//        browser.displayCounterLabel = false
//        browser.displayAction = true
//        browser.displayToolbar = true
//        
//        browser.displayCommentButton = true
//        browser.displayLikeButton = true
//        browser.displayMoreButton = true
//        
//        browser.callingViewController = self
//        
//        if(displayUser) {
//            browser.displayUserButton = true
//            browser.updateUserInfoHandler = { (object: NSObject?)->Void in
//                NSLog("comment button pressed")
//                if let entry = object as? WRTimelineEntry {
//                    if let animal = entry.animal {
//                        browser.updateUserName(animal.username!)
//                        
//                        animal.fetchProfilePhoto({ (error, image) in
//                            if image != nil {
//                                browser.updateUserPhoto(image!)
//                            } else {
//                                browser.updateUserPhoto(UIImage(named: "animal_profile_photo_empty")!)
//                            }
//                        })
//                    }
//                }
//            }
//            
//            browser.customUserButtonHandler = { (object: NSObject?)->Void in
//                NSLog("user button pressed")
//                if let entry = object as? WRTimelineEntry {
//                    if let animal = entry.animal {
//                        self.dismissViewControllerAnimated(true, completion: {
//                            self.openAnimalDetail(animal, push: true)
//                        })
//                    }
//                }
//            }
//        }
//        
//        browser.customEntryLoadedHandler = { (object: NSObject?, photo: SKPhotoProtocol?)->Void in
//            if let entry = object as? WRTimelineEntry {
//                entry.isLikedWithBlock({ (result, error) in
//                    NSLog("entry is liked: \(result)")
//                    if(result) {
//                        browser.setLikeButtonImage(UIImage(named: "button_paw_filled")!)
//                        self.setLikeHandlerOn(browser)
//                    } else {
//                        browser.setLikeButtonImage(UIImage(named: "button_paw")!)
//                        self.setLikeHandlerOff(browser)
//                    }
//                })
//            }
//        }
//        
//        browser.customCommentButtonImage = UIImage(named: "button_comments")
//        browser.customCommentButtonHandler = { (object: NSObject?)->Void in
//            NSLog("comment button pressed")
//            if let entry = object as? WRTimelineEntry {
//                self.dismissViewControllerAnimated(true, completion: {
//                    self.openEntryComments(entry, push: false)
//                })
//            }
//        }
//        
//        browser.customLikeButtonImage = UIImage(named: "button_paw")
//        
//        
//        browser.customMoreButtonImage = UIImage(named: "button_more")
//        browser.customMoreButtonHandler = { (object: NSObject?)->Void in
//            NSLog("more button pressed")
//            if let entry = object as? WRTimelineEntry {
//                browser.showMoreActionSheet(entry)
//            }
//        }
//        
//        browser.customShareButtonImage = UIImage(named: "button_share")
//        
//        browser.bounceAnimation = true
//        browser.enableSingleTapDismiss = false
//        
//        browser.displayCustomCloseButton = true
//        browser.customCloseButtonImage = UIImage(named: "icon_close")
//        
        self.present(browser, animated: true, completion: nil)
    }
    
//    func setLikeHandlerOn(browser: SKPhotoBrowser) {
//        browser.customLikeButtonHandler = { (object: NSObject?, photo: SKPhotoProtocol?)->Void in
//            NSLog("like filled button pressed")
//            if let entry = object as? WRTimelineEntry {
//                entry.unlikeWithBlock({ (result, error) in
//                    if(result) {
//                        browser.setLikeButtonImage(UIImage(named: "button_paw")!)
//                        if let skPhoto = photo as? SKPhoto {
//                            skPhoto.likeCount = skPhoto.likeCount - 1
//                        }
//                        self.setLikeHandlerOff(browser)
//                        browser.updateToolbar()
//                    }
//                })
//            }
//        }
//    }
//    
//    func setLikeHandlerOff(browser: SKPhotoBrowser) {
//        browser.customLikeButtonHandler = { (object: NSObject?, photo: SKPhotoProtocol?)->Void in
//            NSLog("like button pressed")
//            if let entry = object as? WRTimelineEntry {
//                let entryCell = EntryCell()
//                entryCell.entryObject = entry
//                
//                browser.showLikeActionSheet(entryCell, completionBlock: { (result, error) in
//                    NSLog("like action completed")
//                    browser.setLikeButtonImage(UIImage(named: "button_paw_filled")!)
//                    if let skPhoto = photo as? SKPhoto {
//                        skPhoto.likeCount = skPhoto.likeCount + 1
//                    }
//                    self.setLikeHandlerOn(browser)
//                    browser.updateToolbar()
//                })
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
        if let originImageView = animatedFromView as? UIImageView {
            browser = SKPhotoBrowser(originImage: originImageView.image!, photos: idmImages, animatedFromView: animatedFromView!)
        }
        
        if(startIndex != nil) {
            browser.initializePageIndex(startIndex!)
        }
//        browser.displayBackAndForwardButton = false
//        browser.displayCounterLabel = false
//        browser.displayAction = false
//        browser.displayToolbar = false
//        
//        browser.bounceAnimation = true
//        browser.enableSingleTapDismiss = false
//        
//        browser.displayCustomCloseButton = true
//        browser.customCloseButtonImage = UIImage(named: "icon_close")
        
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
//        browser.displayBackAndForwardButton = false
//        browser.displayCounterLabel = false
//        browser.displayAction = false
//        browser.displayToolbar = false
//        
//        browser.bounceAnimation = true
//        browser.enableSingleTapDismiss = false
//        
//        browser.displayCustomCloseButton = true
//        browser.customCloseButtonImage = UIImage(named: "icon_close")
//        
        self.present(browser, animated: true, completion: nil)
    }
    
    /**
     Open the given url in the users default web browser
     
     - Parameters:
     - url: The url to open
     */
    func openUrl(url:String!) {
        NSLog("opening url: \(url)")
        
        let url = NSURL(string: url)!
        UIApplication.shared.openURL(url as URL)
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
    
//    func likeEntryWithBlock(type: LikeAction, entryCell: EntryCell, completionBlock: @escaping (_ result: Bool, _ error: NSError?) -> Void) {
//        
//        let like = WRLike()
//        like.entry = entryCell.entryObject!
//        like.actionValue = type
//        like.actingUser = WRUser.current()!
//        like.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//            completionBlock(success, error)
//            entryCell.likeObject = like
//        }
//    }
//    
//    func unlikeEntryWithBlock(entryCell: EntryCell, completionBlock: @escaping (_ result: Bool, _ error: NSError?) -> Void) {
//
//        if let likeObject = entryCell.likeObject {
//            likeObject.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
//                completionBlock(success, error)
//            })
//        }
//    }
//    
//    func isEntryLikedWithBlock(entryCell: EntryCell, completionBlock: @escaping (_ result: Bool, _ error: NSError?) -> Void) {
//        let query = WRLike.query()!
//        query.whereKey("actingUser", equalTo: WRUser.current()!)
//        query.whereKey("entry", equalTo: entryCell.entryObject!)
//        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: Error?) -> Void in
//            completionBlock(result: objects!.count > 0, error: error)
//            if(objects!.count > 0) {
//                entryCell.likeObject = objects![0] as? WRLike
//            }
//        }
//    }
    
    func pokeUserWithBlock(type: LikeAction, userObject: WRUser, completionBlock: @escaping (_ result: Bool, _ error: Error?) -> Void) {
        let like = WRPoke()
        like.userActedOn = userObject
        like.actionValue = type
        like.actingUser = WRUser.current()!
        like.actingUserName = WRUser.current()!.username
        like.saveInBackground { (success: Bool, error: Error?) -> Void in
            completionBlock(success, error)
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
    
    func openDeleteEntryForm(entry: WRTimelineEntry) {
        self.showLoader()
        entry.deleteInBackground(block: { (success : Bool, error : Error?) -> Void in
            if(success) {
                self.hideLoader()
                self.dismiss(animated: true, completion: {
                    if self is SKPhotoBrowser {
                        let browser = self as! SKPhotoBrowser
                        if browser.splitViewController is AnimalTimelineTableViewController {
                            let animalTimeline = browser.splitViewController as! AnimalTimelineTableViewController
                            animalTimeline.loadObjects()
                        }
                    }
                })
            }
        })
    }
    
    func showMoreActionSheet(entry: WRTimelineEntry) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        if entry.isOwnedBy(WRUser.current()!) {
            let editAction = UIAlertAction(title: "Edit", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Editing timeline entry")
                self.openEditEntryForm(entry: entry)
                //            self.editEntry(indexPath)
            })
            
            let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Deleting timeline entry")
                self.openDeleteEntryForm(entry: entry)
            })
            
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
            
            
            optionMenu.addAction(flagAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
//    func showLikeActionSheet(entryCell: EntryCell, completionBlock: @escaping (_ result: Bool, _ error: NSError?) -> Void) {
//        self.showLikeActionSheet(entryCell: entryCell, userObject: nil, completionBlock: completionBlock)
//    }
//    
//    func showLikeActionSheet(entryCell: EntryCell?, userObject: WRUser?, completionBlock: @escaping (_ result: Bool, _ error: NSError?) -> Void) {
//        let optionMenu = UIAlertController(title: nil, message: "Choose Action", preferredStyle: .actionSheet)
//        
//        let meowAction = UIAlertAction(title: "😺 Meow", style: .default, handler: {
//            (alert: UIAlertAction!) -> Void in
//            if(entryCell != nil) {
//                self.likeEntryWithBlock(type: LikeAction.Meow, entryCell: entryCell!, completionBlock: completionBlock)
//            } else if(userObject != nil) {
//                self.pokeUserWithBlock(type: LikeAction.Meow, userObject: userObject!, completionBlock: completionBlock)
//            }
//            self.playASound(soundName: "meow2")
//        })
//        
//        let purrAction = UIAlertAction(title: "😻 Purr", style: .default, handler: {
//            (alert: UIAlertAction!) -> Void in
//            if(entryCell != nil) {
//                self.likeEntryWithBlock(type: LikeAction.Purr, entryCell: entryCell!, completionBlock: completionBlock)
//            } else if(userObject != nil) {
//                self.pokeUserWithBlock(type: LikeAction.Purr, userObject: userObject!, completionBlock: completionBlock)
//            }
//            self.playASound(soundName: "purr1")
//        })
//        
//        let lickAction = UIAlertAction(title: "😽 Lick", style: .default, handler: {
//            (alert: UIAlertAction!) -> Void in
//            if(entryCell != nil) {
//                self.likeEntryWithBlock(type: LikeAction.Lick, entryCell: entryCell!, completionBlock: completionBlock)
//            } else if(userObject != nil) {
//                self.pokeUserWithBlock(type: LikeAction.Lick, userObject: userObject!, completionBlock: completionBlock)
//            }
//            self.playASound(soundName: "lick1")
//        })
//        
//        let headBumpAction = UIAlertAction(title: "😸 Head Bump", style: .default, handler: {
//            (alert: UIAlertAction!) -> Void in
//            if(entryCell != nil) {
//                self.likeEntryWithBlock(type: LikeAction.HeadBump, entryCell: entryCell!, completionBlock: completionBlock)
//            } else if(userObject != nil) {
//                self.pokeUserWithBlock(type: LikeAction.HeadBump, userObject: userObject!, completionBlock: completionBlock)
//            }
//            self.playASound(soundName: "chirp1")
//        })
//        
//        let hissAction = UIAlertAction(title: "😼 Hiss", style: .default, handler: {
//            (alert: UIAlertAction!) -> Void in
//            if(entryCell != nil) {
//                self.likeEntryWithBlock(type: LikeAction.Hiss, entryCell: entryCell!, completionBlock: completionBlock)
//            } else if(userObject != nil) {
//                self.pokeUserWithBlock(type: LikeAction.Hiss, userObject: userObject!, completionBlock: completionBlock)
//            }
//            self.playASound(soundName: "hiss1")
//        })
//        
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
//            (alert: UIAlertAction!) -> Void in
//        })
//        
//        optionMenu.addAction(meowAction)
//        optionMenu.addAction(purrAction)
//        optionMenu.addAction(lickAction)
//        optionMenu.addAction(headBumpAction)
//        optionMenu.addAction(hissAction)
//        optionMenu.addAction(cancelAction)
//        
//        self.present(optionMenu, animated: true, completion: nil)
//    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                self.goBack()
            default:
                break
            }
        }
    }
    
//    func textWasChanged(textField: UITextField) {
//        let val = textField.text
//        let maxLength = 500
//        if (val?.characters.count)! > maxLength {
//            textField.text = val?[0...maxLength]
//        }
//    }
}

extension SKPhotoBrowser {
    
    /**
     Override this function in SKPhotoBrowser to avoid hiding controls while dragging
     */
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    }
}


extension PFQueryTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    public func initEmptyState() {
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
    }
    
    public func emptyDataSetShouldDisplay(scrollView: UIScrollView) -> Bool {
        if(self.isLoading) {
            return false
        } else {
            return true
        }
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
        let activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
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
                        indicator.activityIndicatorViewStyle = activityIndicatorViewStyle
                        
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


//
//extension UIImage {
//    
//    public class func gifWithData(data: NSData) -> UIImage? {
//        // Create source from data
//        guard let source = CGImageSourceCreateWithData(data, nil) else {
//            print("SwiftGif: Source for the image does not exist")
//            return nil
//        }
//        
//        return UIImage.animatedImageWithSource(source: source)
//    }
//    
//    public class func gifWithURL(gifUrl:String) -> UIImage? {
//        // Validate URL
//        guard let bundleURL:NSURL? = NSURL(string: gifUrl)
//            else {
//                print("SwiftGif: This image named \"\(gifUrl)\" does not exist")
//                return nil
//        }
//        
//        // Validate data
//        guard let imageData = NSData(contentsOf: bundleURL! as URL) else {
//            print("SwiftGif: Cannot turn image named \"\(gifUrl)\" into NSData")
//            return nil
//        }
//        
//        return gifWithData(data: imageData)
//    }
//    
//    public class func gifWithName(name: String) -> UIImage? {
//        // Check for existance of gif
//        guard let bundleURL = Bundle.main
//            .url(forResource: name, withExtension: "gif") else {
//                print("SwiftGif: This image named \"\(name)\" does not exist")
//                return nil
//        }
//        
//        // Validate data
//        guard let imageData = NSData(contentsOf: bundleURL) else {
//            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
//            return nil
//        }
//        
//        return gifWithData(data: imageData)
//    }
//    
//    class func delayForImageAtIndex(index: Int, source: CGImageSource!) -> Double {
//        var delay = 0.1
//        
//        // Get dictionaries
//        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
//        let gifProperties: CFDictionary = unsafeBitCast(
//            CFDictionaryGetValue(cfProperties,
//                unsafeAddressOf(kCGImagePropertyGIFDictionary)),
//            to: CFDictionary.self)
//        
//        // Get delay time
//        var delayObject: AnyObject = unsafeBitCast(
//            CFDictionaryGetValue(gifProperties,
//                unsafeAddressOf(kCGImagePropertyGIFUnclampedDelayTime)),
//            to: AnyObject.self)
//        if delayObject.doubleValue == 0 {
//            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
//                unsafeAddressOf(kCGImagePropertyGIFDelayTime)), to: AnyObject.self)
//        }
//        
//        delay = delayObject as! Double
//        
//        if delay < 0.1 {
//            delay = 0.1 // Make sure they're not too fast
//        }
//        
//        return delay
//    }
//    
//    class func gcdForPair(a: Int?, _ b: Int?) -> Int {
//        var a = a
//        var b = b
//        // Check if one of them is nil
//        if b == nil || a == nil {
//            if b != nil {
//                return b!
//            } else if a != nil {
//                return a!
//            } else {
//                return 0
//            }
//        }
//        
//        // Swap for modulo
//        if a! < b! {
//            let c = a
//            a = b
//            b = c
//        }
//        
//        // Get greatest common divisor
//        var rest: Int
//        while true {
//            rest = a! % b!
//            
//            if rest == 0 {
//                return b! // Found it
//            } else {
//                a = b
//                b = rest
//            }
//        }
//    }
//    
//    class func gcdForArray(array: Array<Int>) -> Int {
//        if array.isEmpty {
//            return 1
//        }
//        
//        var gcd = array[0]
//        
//        for val in array {
//            gcd = UIImage.gcdForPair(gcd, val)
//        }
//        
//        return gcd
//    }
//    
//    class func animatedImageWithSource(source: CGImageSource) -> UIImage? {
//        let count = CGImageSourceGetCount(source)
//        var images = [CGImage]()
//        var delays = [Int]()
//        
//        // Fill arrays
//        for i in 0..<count {
//            // Add image
//            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
//                images.append(image)
//            }
//            
//            // At it's delay in cs
//            let delaySeconds = UIImage.delayForImageAtIndex(index: Int(i),
//                                                            source: source)
//            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
//        }
//        
//        // Calculate full duration
//        let duration: Int = {
//            var sum = 0
//            
//            for val: Int in delays {
//                sum += val
//            }
//            
//            return sum
//        }()
//        
//        // Get frames
//        let gcd = gcdForArray(array: delays)
//        var frames = [UIImage]()
//        
//        var frame: UIImage
//        var frameCount: Int
//        for i in 0..<count {
//            frame = UIImage(cgImage: images[Int(i)])
//            frameCount = Int(delays[Int(i)] / gcd)
//            
//            for _ in 0..<frameCount {
//                frames.append(frame)
//            }
//        }
//        
//        // Heyhey
//        let animation = UIImage.animatedImage(with: frames, duration: Double(duration) / 1000.0)
//        
//        return animation
//    }
//    
//}


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
    public class func mainColor() -> UIColor {
        return UIColor(red: 0/255, green: 42/255, blue: 79/255, alpha: 1.0)
    }
    
    public class func secondaryColor() -> UIColor {
        return UIColor.lightGray
    }
    
    public class func linkColor() -> UIColor {
        return UIColor(red: 0/255, green: 94/255, blue: 183/255, alpha: 1.0)
    }
    
    public class func lightOrangeColor() -> UIColor {
        return UIColor(red: 254/255, green: 122/255, blue: 96/255, alpha: 1.0)
    }
    
    public class func lightYellowColor() -> UIColor {
        return UIColor(red: 244/255, green: 166/255, blue: 54/255, alpha: 1.0)
    }
    
    public class func lightGreenColor() -> UIColor {
        return UIColor(red: 163/255, green: 202/255, blue: 123/255, alpha: 1.0)
    }
    
    public class func lightBlueColor() -> UIColor {
        return UIColor(red: 94/255, green: 126/255, blue: 147/255, alpha: 1.0)
    }
    
    public class func lightRedColor() -> UIColor {
        return UIColor(red: 148/255, green: 135/255, blue: 114/255, alpha: 1.0)
    }
    
    public class func lightPinkColor() -> UIColor {
        return UIColor(red: 168/255, green: 183/255, blue: 196/255, alpha: 1.0)
    }
    
    public class func facebookThemeColor() -> UIColor {
        return UIColor(red: 63/255, green: 81/255, blue: 121/255, alpha: 1.0)
    }
    
}

//public extension UITabBar {
//    override public func sizeThatFits(_ size: CGSize) -> CGSize {
//        super.sizeThatFits(size)
//        var sizeThatFits = super.sizeThatFits(size)
//        sizeThatFits.height = 50
//        return sizeThatFits
//    }
//}

public extension Int {
    public static func random(lower: Int , upper: Int) -> Int {
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
    @IBInspectable public var leftSpacer:CGFloat {
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

//public extension Float {
//    // Format a price with currency based on the device locale.
//    var asCurrency: String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.locale = NSLocale.current
//        return formatter.stringFromNumber(NSNumber(self))!
//    }
//}

public extension UIView {
    // Draw a border at the top of a view.
    func drawTopBorderWithColor(color: UIColor, height: CGFloat) {
        let topBorder = CALayer()
        topBorder.backgroundColor = color.cgColor
        topBorder.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: height)
        self.layer.addSublayer(topBorder)
    }
    // adds a label to at center of a view
    public func drawLabel(text : String) {
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
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    subscript(i: Int) -> String {
        guard i >= 0 && i < characters.count else { return "" }
        return String(self[index(startIndex, offsetBy: i)])
    }
    
    subscript(range: Range<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) ?? endIndex))
    }
    
    subscript(range: ClosedRange<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound + 1, limitedBy: endIndex) ?? endIndex))
    }
}

//public extension String {
//    func stringByRemovingOccurrencesOfCharacters(chars: String) -> String {
//        let cs = characters.filter {
//            chars.characters.index(of: $0) == nil
//        }
//        
//        return String(cs)
//    }
//    
//    func replace(target: String, withString: String) -> String {
//        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSString.CompareOptions.LiteralSearch, range: nil)
//    }
//    

//    subscript (i: Int) -> Character {
//        return self[self.startIndex.advancedBy(i)]
//    }
//    
//    subscript (i: Int) -> String {
//        return String(self[i] as Character)
//    }
//    
//    subscript (r: Range<Int>) -> String {
//        let start = startIndex.advancedBy(r.lowerBound)
//        let end = start.advancedBy(r.upperBound - r.lowerBound)
//        return self[start..<end]
//    }
//    
//    func removeCharsFromEnd(count_:Int) -> String {
//        let stringLength = self.characters.count
//        
//        let substringIndex = (stringLength < count_) ? 0 : stringLength - count_
//        
//        return self.substringToIndex(self.startIndex.advancedBy(substringIndex))
//    }
//}

public extension UILabel {
    func resizeHeightToFit(heightConstraint: NSLayoutConstraint) {
        let attributes = [NSFontAttributeName : font]
        numberOfLines = 0
        lineBreakMode = NSLineBreakMode.byWordWrapping
        let rect = text!.boundingRect(with: CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        heightConstraint.constant = rect.height
        setNeedsLayout()
    }
    
    var substituteFontName : String {
        get { return self.font.fontName }
        set { self.font = UIFont(name: newValue, size: self.font.pointSize) }
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
        imageView.contentMode = UIViewContentMode.scaleAspectFill
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
    
    func handleActionBlock(sender: UIButton) {
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
    
    public func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping ()->()) {
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
          
            let width = (UIApplication.shared.keyWindow?.bounds.width)!/CGFloat(numberOfPages)+2 
            
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
