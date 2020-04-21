//
//  AppDelegate.swift
//  CommuniKitty
//
//  Created by Michael Bina on 9/20/16.
//  Copyright © 2016 White Rabbit Apps. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4
import SlideMenuControllerSwift
import Eureka
import Device
import BWWalkthrough
import Fusuma
import Hoko
import UserNotifications
import Instabug
import GooglePlaces
import GooglePlacesRow

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var dashboardViewController: DashboardViewController?
    var dashboardNavViewController: UINavigationController?
    
    var myAnimalsArray: [String]?
    var myAnimalByName: [String: WRAnimal]?
    var myAnimalsWithDeceasedArray: [String]?
    var myAnimalWithDeceasedByName: [String: WRAnimal]?
    
    var traitsArray: [String]?
    var traitByName: [String: WRTrait]?
    var sheltersArray: [String]?
    var shelterByName: [String: WRLocation]?
    var vetsArray: [String]?
    var vetByName: [String: WRLocation]?
    var lovesArray: [String]?
    var hatesArray: [String]?
    
    var breedsArray: [Breed]?
    var breedByName: [String: Breed]?
    var coatsArray: [Coat]?
    var coatByName: [String: Coat]?
    var coatImagesByName: [String: UIImage]?
    
    var hasMemorial: Bool = false
    var hasFosters: Bool = false
    var hasRegisteredForPush = false
    
    public static func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initializeLibraries(launchOptions: launchOptions as [NSObject : AnyObject]?)
        
        if(WRUser.current() != nil) {
            self.postLogin()
        }
        
        initializeView()
        loadMainController()
        
        loadBackgroundData()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url as URL?,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func initializeUI() {
        UILabel.appearance().substituteFontName = "Nunito-Regular"
        UITabBar.appearance().barTintColor = UIColor.mainColor()
        UITabBar.appearance().tintColor = .white
    }
    
    func configureParse(serverUrl: String) {
        Parse.enableLocalDatastore()
        PFUser.enableRevocableSessionInBackground()
        
        Parse.initialize(with: ParseClientConfiguration(block: { (configuration: ParseMutableClientConfiguration) -> Void in
            configuration.applicationId = "IWr9xzTirLbjXH80mbTCtT9lWB73ggQe3PhA6nPg"
            configuration.clientKey = "Yxdst3hz76abMoAwG7FLh0NwDmPvYHFDUPao9WJJ"
            configuration.server = serverUrl
        }))
        
        WRActivity.registerSubclass()
        WRAnimal.registerSubclass()
        WRAnimalTransfer.registerSubclass()
        WRBreed.registerSubclass()
        WRCoat.registerSubclass()
        WRComment.registerSubclass()
        WRFlag.registerSubclass()
        WRFollow.registerSubclass()
        WRLike.registerSubclass()
        WRLocation.registerSubclass()
        WRPoke.registerSubclass()
        WRProduct.registerSubclass()
        WRTimelineEntry.registerSubclass()
        WRTrait.registerSubclass()
        WRLove.registerSubclass()
        WRHate.registerSubclass()
        WRUser.registerSubclass()
    }
    
    func loadBackgroundData() {
        DispatchQueue.main.async() { [unowned self] in
            self.loadBreeds()
            self.loadCoats()
            self.loadShelters()
            self.loadTraits()
            self.loadLoves()
            self.loadHates()
            NSLog("Finished loading background data")
        }
    }
    
    func initializeLibraries(launchOptions: [NSObject: AnyObject]?) {
        #if DEVELOPMENT
            let SERVER_URL = "http://whiterabbitapps-dev.herokuapp.com/api/"
        #else
            let SERVER_URL = "http://api.communikitty.com/"
        #endif
        
        
        self.configureParse(serverUrl: SERVER_URL)
        self.registerUris()
        self.initializeUI()
        
        DispatchQueue.main.async {
            GMSPlacesClient.provideAPIKey("AIzaSyB02jXQAR8Zw1ZMA62Jgr8BUQysN10nE74")
//            GooglePlacesRow.provideApiKey("AIzaSyBSUv9V99TBfnXNtRW2FC3pyTgRpAwuKCc")
            PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
            //        PFTwitterUtils.initializeWithConsumerKey("C16iyeaMoc91iPOQnBTnQkXgm", consumerSecret: "gvedI21p7UaJxEJKxyTttbkUydE37cnq3RBSUFB86erwjHAkt1")
            //            self.client = CDAClient(spaceKey:"8mu31kgi73w0", accessToken:"3bd31581398aa28d0b9c05aa86573763aa4dfd4119eb020625cd0989fee99836")
            if Device.type() != .simulator {
                Instabug.start(withToken: "b97c87481a11e4f5469722434cef6a24", invocationEvent: IBGInvocationEvent.screenshot)
                Instabug.setColorTheme(.light)
                Instabug.setCrashReportingEnabled(true)
                //                Fabric.with([Crashlytics.self, Answers.self])
            }
        }
    }
    
    func initializeView() {
        let font = UIFont(name: "Nunito-Regular", size: 16)
        NameRow.defaultCellUpdate = { cell, row in
            cell.textField.font = font
        }
        EmailRow.defaultCellUpdate = { cell, row in
            cell.textField.font = font
        }
        PasswordRow.defaultCellUpdate = { cell, row in
            cell.textField.font = font
        }
        TwitterRow.defaultCellUpdate = { cell, row in
            cell.textField.font = font
        }
        TextAreaRow.defaultCellUpdate = { cell, row in
            cell.textView.font = font
        }
        GooglePlacesTableRow.defaultCellUpdate = { cell, row in
            cell.textField.font = font
        }
        fusumaBackgroundColor = UIColor.mainColor()
        fusumaCheckImage = UIImage(named: "icon_next")
        fusumaCloseImage = UIImage(named: "icon_close")
        
//        fusumaAlbumImage = UIImage(named: "icon_library")
//        fusumaCameraImage = UIImage(named: "icon_camera")
//        fusumaVideoImage = UIImage(named: "icon_video")
        
        fusumaFlashOnImage = UIImage(named: "icon_flash_on")
        fusumaFlashOffImage = UIImage(named: "icon_flash_off")
        fusumaFlipImage = UIImage(named: "icon_camera_flip")
        fusumaShotImage = UIImage(named: "button_shutter")
        fusumaVideoStartImage = UIImage(named: "button_video_start")
        fusumaVideoStopImage = UIImage(named: "button_video_stop")
        
        fusumaCameraRollTitle = "Photo Library"
        fusumaCameraTitle = "Catmera"
        fusumaVideoTitle = "Video"
        
//        fusumaTintIcons = false
    }
    
    /**
     Ask the user to authorize the ability to receive push notifications
     */
    func registerForPushNotifications() {
        if Device.type() == .simulator {
        } else {
            print("registering for push notifications")
            DispatchQueue.main.async {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                    // Enable or disable features based on authorization
                }
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    /**
     Called when the user accepts the ability to receive push notifications
     */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        if let currentInstallation = PFInstallation.current() {
            currentInstallation.setDeviceTokenFrom(deviceToken)
            currentInstallation.setValue(WRUser.current(), forKey: "user")
            currentInstallation.saveInBackground { (succeeded, e) -> Void in
                NSLog("Successfully registered for push notifications")
            }
        }
    }
    
    /**
     Called when the user rejects the ability to receive push notifications or there is a failure
     */
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register for notifications: \(error)")
    }
    
    /**
     Called when the user receives a push notification while the app is open
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("didReceiveRemoteNotification")
        
        let state = application.applicationState
        
        if (state == .inactive || state == .background) {
            // App was inactive or in the background when the notification was received
            
            if let uri = userInfo["uri"] as? String {
                print("has uri: " + uri)
                Hoko.deeplinking().handleOpen(URL(string: uri))
            }
        } else {
            // App was already running
            // Show a notification
            
            if let aps = userInfo["aps"] as? NSDictionary {
                if let alert = aps["alert"] as? NSDictionary {
                    if let message = alert["message"] as? String {
                        self.showNotification(message: message)
                    }
                } else if let alert = aps["alert"] as? String {
                    let sound = aps["sound"] as? String
                    if sound != nil {
                        let soundName = sound!.replacingOccurrences(of: ".caf", with: "")
                        self.showNotification(message: alert, sound: soundName)
                    } else {
                        self.showNotification(message: alert)
                    }
                }
            }
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        return Hoko.deeplinking().continue(userActivity, restorationHandler:restorationHandler)
    }
    
    
    /**
     Register uris for deeplink handling
     */
    func registerUris() {
        Hoko.setup(withToken: "1436b52b748b9fefe50829b051d95f57212c6303")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        Hoko.deeplinking().mapRoute("moment/:id", toTarget: {
            (deeplink: HOKDeeplink) -> Void in
            if let momentId = deeplink.routeParameters?["id"] {
                
                let query = PFQuery(className: "AnimalTimelineEntry")
                query.includeKey("animal")
                query.whereKey("objectId", equalTo: momentId)
                
                let entryObject = try? query.getFirstObject()
                
                if(entryObject != nil) {
                    let entryView = storyboard.instantiateViewController(withIdentifier: "TimelineEntryDetailView") as! TimelineEntryDetailViewController
                    entryView.entryObject = entryObject as? WRTimelineEntry
                    entryView.showClose = true
                    
                    //                    HOKNavigation.pushViewController(UINavigationController(rootViewController: entryView), animated: true)
                    self.pushViewControllerOnTop(view: UINavigationController(rootViewController: entryView))
                }
            }
        })
        
        Hoko.deeplinking().mapRoute("cat/:username", toTarget: {
            (deeplink: HOKDeeplink) -> Void in
            if let catUsername = deeplink.routeParameters?["username"] {
                let animalView = storyboard.instantiateViewController(withIdentifier: "AnimalDetailView") as! AnimalDetailViewController
                animalView.username = catUsername
                animalView.showClose = true
                
                self.loadMainController()
                
                //                HOKNavigation.pushViewController(UINavigationController(rootViewController: animalView), animated: true)
                self.pushViewControllerOnTop(view: UINavigationController(rootViewController: animalView))
            }
        })
        
        Hoko.deeplinking().mapRoute("human/:username", toTarget: {
            (deeplink: HOKDeeplink) -> Void in
            if let humanUsername = deeplink.routeParameters?["username"] {
                
                let userView = storyboard.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
                userView.username = humanUsername
                userView.showClose = true
                
                //                HOKNavigation.pushViewController(UINavigationController(rootViewController: userView), animated: true)
                self.pushViewControllerOnTop(view: UINavigationController(rootViewController: userView))
            }
        })
        
        Hoko.deeplinking().mapRoute("notifications", toTarget: {
            (deeplink: HOKDeeplink) -> Void in
            let activityNav = storyboard.instantiateViewController(withIdentifier: "ActivityNavigation") as! UINavigationController
            //            HOKNavigation.pushViewController(activityNav, animated: true)
            self.pushViewControllerOnTop(view: activityNav)
        })
    }
    
    func pushViewControllerOnTop(view: UIViewController) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            // topController should now be your topmost view controller
            topController.present(view, animated: true, completion: nil)
        }
    }
    
    
    func postLogin() {
        if self.myAnimalsArray == nil {
            self.loadMyAnimals()
        }

        if(!self.hasRegisteredForPush) {
            self.registerForPushNotifications()
            self.hasRegisteredForPush = true
        }
        
        Instabug.setUserEmail((WRUser.current()?.email)!)
//        self.refreshDashboard()
    }
    
    func postLogout() {
        self.myAnimalsArray = nil
        self.myAnimalByName = nil
        self.myAnimalsWithDeceasedArray = nil
        self.myAnimalWithDeceasedByName = nil
        
        self.refreshDashboard()
    }
    
    func refreshDashboard() {
        if let dashboardVC = dashboardViewController {
            dashboardVC.refreshOnNextLoad = true
            if let dashboard = dashboardVC.dashboard {
                dashboard.refresh(dashboardVC)
            }
        }
    }
    
    func loadMainController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
//        let homeController = storyboard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
//        homeController.checkForUser(populate: false)
        
//        let dahsboardNavController = storyboard.instantiateViewController(withIdentifier: "DashboardNav") as! UINavigationController
        
        let dashboard = storyboard.instantiateViewController(withIdentifier: "Dashboard") as! DashboardViewController
        let dahsboardNavController = UINavigationController(rootViewController: dashboard)

        
//        homeController.mainViewController = dahsboardNavController
        self.dashboardNavViewController = dahsboardNavController
        self.dashboardViewController = dashboard
//        self.dashboardViewController = dashboardNavViewController?.topViewController as? DashboardViewController
        
        // set the width and scale of the slide menu
//        SlideMenuOptions.contentViewScale = 1
//        SlideMenuOptions.leftViewWidth = 240
//        
//        // create the slide menu
//        let slideMenuController = SlideMenuController(mainViewController: dashboardNavViewController!, leftMenuViewController: homeController)
//        
//        let walkthroughStoryboard = UIStoryboard(name: "Walkthrough", bundle: nil)
//        
//        let walkthrough = walkthroughStoryboard.instantiateViewController(withIdentifier: "walk") as! BWWalkthroughViewController
//        let page_zero = walkthroughStoryboard.instantiateViewController(withIdentifier: "walk0") as! WalkthroughPage
//        let page_one = walkthroughStoryboard.instantiateViewController(withIdentifier: "walk1")
//        let page_two = walkthroughStoryboard.instantiateViewController(withIdentifier: "walk2")
//        let page_three = walkthroughStoryboard.instantiateViewController(withIdentifier: "walk3")
//        let page_four = walkthroughStoryboard.instantiateViewController(withIdentifier: "walk4")
//        page_zero.lvc = self
//        
//        // Attach the pages to the master
//        walkthrough.delegate = homeController
//        walkthrough.addViewController(page_one)
//        walkthrough.addViewController(page_two)
//        walkthrough.addViewController(page_three)
//        walkthrough.addViewController(page_four)
//        walkthrough.addViewController(page_zero)
//        
//        let userDefaults = UserDefaults.standardUserDefaults
//        
//        if !userDefaults.boolForKey("walkthroughPresented") {
//            self.window?.rootViewController = walkthrough
//            userDefaults.setBool(true, forKey: "walkthroughPresented")
//            userDefaults.synchronize()
//        } else {
//        }
        
//        let window = UIWindow(frame: UIScreen.main.bounds)
//        window.rootViewController = dahsboardNavController
//        window.makeKeyAndVisible()
    }
    
    
    
    ///
    /// Data Loaders
    /// ==========
    ///
    
    /**
     Load all animals that the current user is an owner or foster of.
     Do not include deceased animals.
     */
    func loadMyAnimals() {
        self.hasMemorial = false
        self.hasFosters = false
        self.checkFosters()
        
        let ownerQuery = WRAnimal.query()!
        ownerQuery.whereKey("owners", equalTo: WRUser.current()!)
        
        let fosterQuery = WRAnimal.query()!
        fosterQuery.whereKey("fosters", equalTo: WRUser.current()!)
        
        let animalQuery = PFQuery.orQuery(withSubqueries: [ownerQuery, fosterQuery])
        animalQuery.whereKeyDoesNotExist("deceasedDate")
        animalQuery.includeKey("breed")
        animalQuery.includeKey("coat")
        animalQuery.includeKey("shelter")
        animalQuery.includeKey("owners")
        animalQuery.includeKey("love")
        
        self.myAnimalsArray = [String]()
        self.myAnimalByName = [String:WRAnimal]()
        
        animalQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                for object in objects! {
                    let animal = object as! WRAnimal
                    let name = animal.name
                    if name != nil {
                        self.myAnimalsArray?.append(name!)
                        self.myAnimalByName![name!] = object as? WRAnimal
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NTF_FinishedGettingMyAnimals"), object:objects)
                
            } else {
                print("Error: %@", error!)
            }
        }
        
        self.loadMyAnimalsWithDeceased()
        //        self.loadMyShelterAnimals()
    }
    
    func loadMyShelterAnimals() {
        if let shelter = WRUser.current()?.shelter {
            
            let animalQuery = WRAnimal.query()!
            animalQuery.whereKey("shelter", equalTo: shelter)
            animalQuery.whereKey("adoptable", equalTo: true)
            animalQuery.whereKeyDoesNotExist("deceasedDate")
            animalQuery.includeKey("breed")
            animalQuery.includeKey("coat")
            animalQuery.includeKey("shelter")
            animalQuery.includeKey("owners")
            animalQuery.includeKey("love")
            
            animalQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
                if error == nil {
                    for object in objects! {
                        let animal = object as! WRAnimal
                        let name = animal.name
                        if name != nil {
                            self.myAnimalsArray?.append(name!)
                            self.myAnimalByName![name!] = object as? WRAnimal
                            self.myAnimalsWithDeceasedArray?.append(name!)
                            self.myAnimalWithDeceasedByName![name!] = object as? WRAnimal
                        }
                    }
                } else {
                    print("Error: %@", error!)
                }
            }
        }
    }
    
    func checkFosters() {
        let animalQuery = WRAnimal.query()!
        animalQuery.whereKey("fosters", equalTo: WRUser.current()!)
        
        animalQuery.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                if objects!.count > 0 {
                    self.hasFosters = true
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NTF_FinishedCheckingFosters"), object:objects)
                }
            } else {
                print("Error: %@", error!)
            }
        }
    }
    
    func loadMyAnimalsWithDeceased() {
        let ownerQuery = WRAnimal.query()!
        ownerQuery.whereKey("owners", equalTo: WRUser.current()!)
        
        let fosterQuery = WRAnimal.query()!
        fosterQuery.whereKey("fosters", equalTo: WRUser.current()!)
        
        let animalQuery = PFQuery.orQuery(withSubqueries: [ownerQuery, fosterQuery])
        animalQuery.includeKey("breed")
        animalQuery.includeKey("coat")
        animalQuery.includeKey("shelter")
        animalQuery.includeKey("owners")
        animalQuery.includeKey("love")
        
        self.myAnimalsWithDeceasedArray = [String]()
        self.myAnimalWithDeceasedByName = [String:WRAnimal]()
        
        animalQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                if objects!.count > self.myAnimalsArray!.count {
                    self.hasMemorial = true
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NTF_FinishedCheckingDeceased"), object:objects)
                }
                
                for object in objects! {
                    let animal = object as? WRAnimal
                    let name = animal?.name
                    if name != nil {
                        self.myAnimalsWithDeceasedArray?.append(name!)
                        self.myAnimalWithDeceasedByName![name!] = animal
                    }
                }
            } else {
                print("Error: %@", error!)
            }
        }
    }
    
    
    func loadTraits() {
        let traitQuery = WRTrait.query()!
        self.traitsArray = [String]()
        self.traitByName = [String:WRTrait]()
        
        traitQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                for object in objects! {
                    let trait = object as! WRTrait
                    let name = trait.name
                    if name != nil {
                        self.traitsArray?.append(name!)
                        self.traitByName![name!] = trait
                    }
                }
            } else {
                print("Error: %@", error!)
            }
        }
    }
    
    func loadLoves() {
        let loveQuery = WRLove.query()!
        self.lovesArray = [String]()
        
        loveQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                for object in objects! {
                    let love = object as! WRLove
                    let name = love.text
                    if name != nil {
                        //                        let loveObject = Love(object: love, text: name!)
                        self.lovesArray?.append(name!)
                        //                        self.lovesByName![name!] = love
                        self.lovesArray?.append(name!)
                        
                    }
                }
            } else {
                print("Error: %@", error!)
            }
        }
    }
    
    func loadHates() {
        let hateQuery = WRHate.query()!
        self.hatesArray = [String]()
        
        hateQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                for object in objects! {
                    let hate = object as! WRHate
                    let name = hate.text
                    if name != nil {
                        self.hatesArray?.append(name!)
                    }
                }
            } else {
                print("Error: %@", error!)
            }
        }
    }
    
    /**
     Load all shelters.
     TODO - Remove this since the number of shelters is growing quickly
     */
    func loadShelters() {
        let sheltersQuery = WRLocation.query()!
        sheltersQuery.whereKey("type", equalTo: "shelter")
        sheltersQuery.limit = 10
        
        self.sheltersArray = [String]()
        self.shelterByName = [String:WRLocation]()
        
        sheltersQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                for object in objects! {
                    let shelter = object as! WRLocation
                    
                    let name = shelter.name
                    if name != nil {
                        self.sheltersArray?.append(name!)
                        self.shelterByName![name!] = shelter
                    }
                }
            } else {
                print("Error: %@", error!)
            }
        }
    }
    
    func loadBreeds() {
        let breedQuery = WRBreed.query()!
        breedQuery.limit = 500
        self.breedsArray = [Breed]()
        self.breedByName = [String:Breed]()
        
        breedQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                for object in objects! {
                    let breedObject = object as! WRBreed
                    
                    if breedObject.name != nil {
                        var breedImage = UIImage(named: "animal_profile_photo_empty")
                        if let imageFile = object["image"] as? PFFile {
                            imageFile.getDataInBackground(block: {
                                (imageData: Data?, error: Error?) -> Void in
                                if(error == nil) {
                                    let image = UIImage(data:imageData!)
                                    breedImage = image
                                    
                                    let breed = Breed(object: breedObject, name: breedObject.name!, image: breedImage!)
                                    self.breedsArray?.append(breed)
                                    self.breedByName![breed.name!] = breed
                                }
                            })
                        }
                    }
                }
            } else {
                print("Error: %@", error!)
            }
        }
    }
    
    func loadCoats() {
        let coatQuery = WRCoat.query()!
        coatQuery.limit = 300
        self.coatsArray = [Coat]()
        self.coatByName = [String:Coat]()
        self.coatImagesByName = [String:UIImage]()
        
        coatQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                for object in objects! {
                    let coatObject = object as! WRCoat
                    
                    let name = coatObject.name
                    
                    if name != nil {
                        var image = UIImage(named: "blank")
                        if let imageFile = coatObject.image {
                            imageFile.getDataInBackground(block: {
                                (imageData: Data?, error: Error?) -> Void in
                                if(error == nil) {
                                    self.coatImagesByName![name!] = UIImage(data:imageData!)
                                    image = UIImage(data:imageData!)
                                    
                                    let coat = Coat(object: coatObject, name: name!, image: image!)
                                    
                                    self.coatsArray?.append(coat)
                                    self.coatByName![name!] = coat
                                }
                            })
                        }
                    }
                }
            } else {
                print("Error: %@", error!)
            }
        }
    }
    
    
    
    ///
    /// Notifications
    /// ==========
    ///
    func showNotification(message: String) {
        self.showNotification(message: message, sound: "chirp1")
    }
    
    func showNotification(message: String, sound: String) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            // topController should now be your topmost view controller
            topController.showInfo(message: message, timeToShow: 4.0, sound: sound)
        }
    }

    
}

