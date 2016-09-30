//
//  DashboardViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 7/8/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Foundation
import Fusuma
import CLImageEditor


// The types of rows that are supported on the dashboard
enum RowContent {
    case Popular
    case MostCommentedOn
    case Featured
    case Following
    case Mine
    case User
    case Fosters
    case Shelter
}

// The types of content that can be displayed in a dashboard widget collectionView cell
enum CollectionType {
    case Photos
    case Animals
}


//
// DashboardViewController - View controller for the dashboard screen.
//     It contains a DashboardTableViewController for widget and handles the camera.
//
class DashboardViewController: UIViewController, FusumaDelegate, CLImageEditorDelegate {
    
    var pickedImageDate: Date?
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    private var dashboard: DashboardTableViewController!
    
    override func viewDidLoad() {
        // Listen for when MyAnimals is finished loading to update the UI
        NotificationCenter.default.addObserver(self, selector:#selector(finishedGettingMyAnimals), name: NSNotification.Name(rawValue: "NTF_FinishedGettingMyAnimals"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(DashboardViewController.loadDashboard), name: NSNotification.Name(rawValue: "NTF_FinishedCheckingFosters"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(DashboardViewController.loadDashboard), name: NSNotification.Name(rawValue: "NTF_FinishedCheckingDeceased"), object: nil)
    }
    
    /**
     Called when a notification is received that the users animals list is finished downloading
     - hide or show the camera button
     */
    func finishedGettingMyAnimals(notifiation: NSNotification) -> Void {
        
        //if there are no list of Animals yet, check it again after login
        if AppDelegate.getAppDelegate().myAnimalsArray == nil {
            AppDelegate.getAppDelegate().postLogin()
         }
        //check if myAnimalsArray updated after login
        if let animalCount = AppDelegate.getAppDelegate().myAnimalsArray?.count {
        
            if animalCount > 0 {
                self.cameraButton.isHidden = false
            } else {
                self.cameraButton.isHidden = true
            }
        }
    }
    
    /**
     viewWillAppear - Called whenever the view is about to be shown
     */
    override func viewWillAppear(_ animated: Bool) {
        self.setUpMenuBarController(title: "CommuniKitty")
        self.navigationItem.rightBarButtonItem = self.getNavBarItem(imageId: "button_notifications", action: #selector(DashboardViewController.showNotifications), height: 25, width: 20)
        
        if(self.isLoggedIn()) {
            self.navigationItem.leftBarButtonItem = self.getNavBarItem(imageId: "button_settings", action: #selector(DashboardViewController.openUserSettings), height: 25, width: 25)
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
        self.dashboard.refresh(self)
    }
    
    /**
     Show the notifications screen
     */
    func showNotifications() {
        self.checkForUser {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let activityNav = storyboard.instantiateViewController(withIdentifier: "ActivityNavigation") as! UINavigationController
            self.present(activityNav, animated: true, completion: nil)
        }
    }
    
    /**
     Open the camera screen
     */
    @IBAction func takeFusumaPhoto() {
        self.checkForUser {
            self.showLoader()
            let fusuma = FusumaViewController()
            fusuma.delegate = self
            
            fusuma.hasVideo = false
            
            fusuma.transitioningDelegate = self.transitioningDelegate
            fusuma.modalPresentationStyle = .custom
            
            self.present(fusuma, animated: true, completion: {
                self.hideLoader()
            })
        }
    }
    
    /**
     Handle the image that is returned from the camera
        - implements FusumaDelegate
     */
    func fusumaImageSelected(_ image: UIImage, creationDate: Date?) {
        self.pickedImageDate = creationDate
        
        self.modalTransitionStyle = .coverVertical
        self.dismiss(animated: false, completion: { () -> Void in
            self.showEditor(image: image, delegate: self, ratios: [1, 1], fromController: self)
        })
    }
    
    func fusumaImageSelected(_ image: UIImage) {
        self.modalTransitionStyle = .coverVertical
        self.dismiss(animated: false, completion: { () -> Void in
            self.showEditor(image: image, delegate: self, ratios: [1, 1], fromController: self)
        })
    }
    
    
    /**
     Handle the video that is returned from the camera
        - implements FusumaDelegate
     */
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    
    /**
     Handle the user not authorizing access to the camera roll
        - implements FusumaDelegate
     */
    func fusumaCameraRollUnauthorized() {
        print("Camera roll unauthorized")
    }
    
    /**
     Handle the user cancelling on the editor screen
     - implements CLImageEditorDelegate
     */
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        self.dismiss(animated: false, completion: nil)
    }
    
    /**
     Handle the edited image and display the final entry form
     - implements CLImageEditorDelegate
     */
    
    func imageEditor(_ editor: CLImageEditor!, didFinishEdittingWith image: UIImage!) {
        if image != nil {
            let detailScene =  TimelineEntryFormViewController()
            detailScene.type = "image"
            detailScene.image = image
            detailScene.pickedImageDate = self.pickedImageDate as Date?
            
            let nav = UINavigationController(rootViewController: detailScene)
            nav.modalTransitionStyle = .coverVertical
            
            self.dismiss(animated: false) { () -> Void in
                self.present(nav, animated: false, completion: { () -> Void in
                    self.hideLoader()
                })
            }
        } else {
            self.dismiss(animated: false, completion: { () -> Void in
                self.hideLoader()
            })
        }
    }
    
    func loadDashboard() {
        var widgets: [DashboardWidget] = [FeaturedPhotosDashboardWidget(), FollowingPhotosDashboardWidget(), MyAnimalsDashboardWidget()]
        
        if AppDelegate.getAppDelegate().hasFosters {
            let fostersWidget = UserAnimalsDashboardWidget()
            fostersWidget.user = WRUser.current()
            fostersWidget.foster = true
            widgets.append(fostersWidget)
        }
        
        if AppDelegate.getAppDelegate().hasMemorial {
            let memorialWidget = UserAnimalsDashboardWidget()
            memorialWidget.user = WRUser.current()
            memorialWidget.deceased = true
            widgets.append(memorialWidget)
        }
        
        if let shelter = WRUser.current()?.shelter {
            let shelterWidget = ShelterAnimalsDashboardWidget()
            shelterWidget.shelter = shelter
            widgets.append(shelterWidget)
        }
        
        dashboard.widgets = widgets
        dashboard.showRefreshControl = true
        dashboard.parentView = self
        
        self.dashboard.tableView.reloadData()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dashboard = segue.destination as? DashboardTableViewController
            , segue.identifier == "DashboardTableEmbed" {
            
            self.dashboard = dashboard
            
            self.loadDashboard()
        }
    }
}
