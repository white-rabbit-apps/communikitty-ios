//
//  AnimalDetailViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/20/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

//import TagListView
import CLImageEditor
import PagingMenuController
import MobileCoreServices
import Fusuma
import Photos

private struct MenuOptions: MenuViewCustomizable {
    var displayMode: MenuDisplayMode
    
    var backgroundColor = UIColor.white
    var selectedBackgroundColor = UIColor(colorLiteralRed: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 248/255.0)
    
    var focusMode: MenuFocusMode {
        return .underline(height: 2.0, color: UIColor.black, horizontalPadding: 0.0, verticalPadding: 0.0)
    }
    
    var itemsOptions: [MenuItemViewCustomizable]
    init(itemsOptions: [MenuItemViewCustomizable], displayMode: MenuDisplayMode){
        self.itemsOptions = itemsOptions
        self.displayMode = displayMode
    }
}

class AnimalDetailViewController: UIViewController, CLImageEditorDelegate, PagingMenuControllerDelegate, FusumaDelegate ,UIScrollViewDelegate{
    
    public func fusumaImageSelected(_ image: UIImage) {

    }

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var profileThumb: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var socialView: UIView!
    
    @IBOutlet weak var coverOverlay: UIView!
    @IBOutlet weak var adoptableLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followerCountButton: UIButton!
    @IBOutlet weak var followerView: UIStackView!
    
    @IBOutlet weak var adoptedStackView: UIStackView!
    
    @IBOutlet weak var timelineView: UIView!
    @IBOutlet weak var shelterButton: UIButton!
    @IBOutlet weak var shrinkScrollView: UIScrollView!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileThumbTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileThumbCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var socialViewBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabelLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabelCenterXConstraint: NSLayoutConstraint!
    
    var shrunkHeaderAvatarXOffset: CGFloat!
    let shrunkHeaderAvatarScaleFactor:CGFloat = 50
    let shrunkHeaderShorterHeight:CGFloat = 50
    
    
    var currentAnimalObject : WRAnimal?
    var breedObject : WRBreed?
    var shelterObject : WRLocation?
    var username : String?
    var timelineObjectId : String?
    
    var currentUserIsOwner = false
    var currentUserIsFoster = false
    var currentUserIsShelterCaregiver = false
    var showClose = false
    
//    var animalTableController : AnimalsTableViewController?
    
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    var aboutViewController : AnimalAboutViewController?
    var timelineTableController : AnimalTimelineTableViewController?
//    var medicalViewController : MedicalViewController?
    var photosCollectionViewController: PhotosCollectionViewController?
    var animalImagesRepository: AnimalImagesRepository?
    
    var instagramUsername : String?
    
    var pickedImageDate : Date?
    
    var isSettingProfilePhoto : Bool = false
    var isSettingCoverPhoto : Bool = false
    
    var isFollowing : Bool = false
    var followObject : WRFollow?
    var firstLoad = true
    
    fileprivate var pagingControllers: [UIViewController]?
    
    override func viewDidLoad() {
        if(self.currentAnimalObject != nil) {
            self.loadAnimal()
        } else if(self.username != nil) {
            self.loadAnimalFromUsername()
        }
        super.viewDidLoad()
        
        self.timelineView.isHidden = false
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let coverTapGesture = UITapGestureRecognizer(target: self, action: #selector(AnimalDetailViewController.respondToCovertTapGesture(_:)))
        
        self.coverPhoto.addGestureRecognizer(coverTapGesture)
        
        self.timelineTableController?.tableView.isScrollEnabled = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstLoad {
            firstLoad = false
            shrunkHeaderAvatarXOffset = self.coverPhoto.bounds.size.height - (shrunkHeaderShorterHeight + 20)
            containerViewHeightConstraint.constant = self.shrinkScrollView.bounds.size.height + shrunkHeaderAvatarXOffset
            self.shrinkScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: containerViewHeightConstraint.constant)
        } else {
            shrunkHeaderAvatarXOffset = self.coverPhoto.bounds.size.height - (shrunkHeaderShorterHeight + 20)
            //removing extra space
            containerViewHeightConstraint.constant = self.shrinkScrollView.bounds.size.height + shrunkHeaderAvatarXOffset - 64
            self.shrinkScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: containerViewHeightConstraint.constant)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.setNeedsUpdateConstraints()
        
        if(showClose) {
            self.setUpTransparentModalBar()
        } else {
            self.setUpTransparentNavigationBar()
        }
        
        // setting scrollViewTopConstraint constant to correct value on second loading
        if !firstLoad {
            self.scrollViewTopConstraint.constant = -64
        }
    }
    
    
    //value for checking if the offset was negative
    var negativeValue = false
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        var offset = scrollView.contentOffset.y
        
        if offset == 0 {
            setLabelAttributesToDefault()
        }
        
        //if the offset was negative then continue adding 64
        if offset > 0 && negativeValue {
            offset = offset + 64
        }
        
        if offset <= -64 || offset < 0 {
            if !firstLoad {
                self.scrollViewTopConstraint.constant = -64
            }
            
            negativeValue = true
            offset = offset + 64
        }
        
        //set the scale factore for the profile picture thumb icon
        let avatarScaleFactor = (min(shrunkHeaderAvatarScaleFactor, offset)) / profileThumb.bounds.height / 1.4 // Slow down the animation
        profileThumb.transform = CGAffineTransform(scaleX: 1.0 - avatarScaleFactor, y: 1.0 - avatarScaleFactor)
        
        // Set the transparency of elements that shouldn't show in the shrunken header
        if(shrunkHeaderAvatarXOffset != nil) {
            let offsetOpacity = (100 - (offset * (100 / shrunkHeaderAvatarXOffset))) / 100
            
            self.followerView.alpha = offsetOpacity
            self.genderLabel.alpha = offsetOpacity
            self.adoptedStackView.alpha = offsetOpacity
            
            if offset < shrunkHeaderAvatarXOffset {
                self.timelineTableController?.tableView.isScrollEnabled = false
                self.aboutViewController?.scrollView.isScrollEnabled = false
                self.photosCollectionViewController?.collectionView?.isScrollEnabled = false
                self.followerView.isHidden = false
                self.genderLabel.isHidden = false
                self.adoptedStackView.isHidden = false
            } else {
                self.timelineTableController?.tableView.isScrollEnabled = true
                self.aboutViewController?.scrollView.isScrollEnabled = true
                self.photosCollectionViewController?.collectionView?.isScrollEnabled = true
                self.followerView.isHidden = true
                self.genderLabel.isHidden = true
                self.adoptedStackView.isHidden = true
            }
            
            //set minumum distance of 70 from the left of screen for scaled profile thumb icon
            let avtarCenterConstraint = (offset * (self.view.center.x - 70)) / shrunkHeaderAvatarXOffset
            profileThumbCenterXConstraint.constant = -avtarCenterConstraint
            socialViewBottomContraint.constant = -offset
            
        }
        
        
        //keed distance of 96 form the top of the screen for the name label
        if offset >= (shrunkHeaderShorterHeight + 20) {
            nameLabelTopConstraint.constant = offset + (96 - (shrunkHeaderShorterHeight + 20))
            nameLabelCenterXConstraint.isActive = false
            nameLabelLeadingSpaceConstraint.constant = 100
            nameLabelTrailingConstraint.constant = 40
            nameLabel.textAlignment = NSTextAlignment.center
        } else if negativeValue{
            setLabelAttributesToDefault()
        }
        
        
        //keep distance of 20 from the top of the screen for the profile thumb icon
        if offset >= 20 {
            profileThumbTopConstraint.constant = offset + 4
        } else {
            profileThumbTopConstraint.constant = 20
        }
    }
    
    //setting nameLabel attributes to default
    func setLabelAttributesToDefault(){
        nameLabelTopConstraint.constant = 101
        nameLabelLeadingSpaceConstraint.constant = 20
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabelCenterXConstraint.isActive = true
        nameLabelTrailingConstraint.constant = 20
        nameLabel.textAlignment = NSTextAlignment.center
    }
    
    @IBAction func followButtonPressed(_ sender: AnyObject) {
        self.followButton.isEnabled = false
        
        if(isFollowing) {
            self.stopFollowing({ () -> () in
                self.followButton.isEnabled = true
                self.followButton.setImage(UIImage(named: "button_follow"), for: UIControlState())
                self.isFollowing = false
                self.loadFollowerCount()
            })
        } else {
            self.playASound(soundName: "chirp1")
            self.startFollowing({ () -> () in
                self.followButton.isEnabled = true
                self.followButton.setImage(UIImage(named: "button_following"), for: UIControlState())
                self.isFollowing = true
                self.loadFollowerCount()
            })
        }
    }
    
    func loadFollow(_ completion: @escaping ()->()) {
        let followQuery = WRFollow.query()!
        followQuery.whereKey("following", equalTo: self.currentAnimalObject!)
        followQuery.whereKey("follower", equalTo: WRUser.current()!)
        
        self.followButton.isEnabled = false
        followQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if(error == nil) {
                if(objects!.count > 0) {
                    let follow = objects![0] as! WRFollow
                    self.followObject = follow
                    self.followButton.setImage(UIImage(named: "button_following"), for: UIControlState())
                    self.isFollowing = true
                } else {
                    self.followButton.setImage(UIImage(named: "button_follow"), for: UIControlState())
                    self.isFollowing = false
                }
                self.followButton.isEnabled = true
                completion()
            }
        }
        
    }
    
    func loadFollowerCount() {
        let followQuery = WRFollow.query()!
        followQuery.whereKey("following", equalTo: self.currentAnimalObject!)
        
        followQuery.countObjectsInBackground { (count: Int32, error: Error?) in
            if (error == nil) {
                self.followerCountButton.setTitle("\(count)", for: UIControlState())
                self.followerView.isHidden = false
            }
        }
    }
    
    func startFollowing(_ completion: @escaping ()->()) {
        let follow = WRFollow()
        
        follow.following = self.currentAnimalObject!
        follow.follower = WRUser.current()!
        
        follow.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
            if error == nil {
                self.followObject = follow
                completion()
            } else {
                self.showError(message: error!.localizedDescription)
            }
        })
    }
    
    func stopFollowing(_ completion: @escaping ()->()) {
        if(self.followObject != nil) {
            self.followObject?.deleteInBackground(block: { (success: Bool, error: Error?) -> Void in
                if(error == nil) {
                    completion()
                } else {
                    self.showError(message: error!.localizedDescription)
                }
            })
        } else {
            self.loadFollow({ () -> () in
                self.stopFollowing(completion)
            })
        }
    }
    
    func loadAnimalFromUsername() {
        let animalQuery = WRAnimal.query()!
        if(self.username != nil) {
            animalQuery.whereKey("username", equalTo: self.username!)
        }
        animalQuery.includeKey("owners")
        animalQuery.includeKey("fosters")
        animalQuery.includeKey("breed")
        animalQuery.includeKey("coat")
        animalQuery.includeKey("shelter")
        animalQuery.includeKey("love")
        self.showLoader()
        
        var animalObject : PFObject? = nil
        do {
            animalObject = try animalQuery.getFirstObject() as PFObject
        } catch {
            print("Error")
        }
        
        if animalObject != nil {
            let animal = animalObject as? WRAnimal
            
            self.currentAnimalObject = animal
            self.loadAnimal()
            
            self.aboutViewController?.animalObject = animal
            self.aboutViewController?.loadAnimal()
            
            self.timelineTableController?.animalObject = animal
            if(self.timelineObjectId != nil) {
                self.timelineTableController?.timelineObjectId = self.timelineObjectId
                self.timelineObjectId = nil
            }
            self.timelineTableController?.loadObjects()
        }
        
        self.hideLoader()
    }
    
    func reloadTimeline() {
        if self.timelineTableController != nil {
            self.timelineTableController!.loadObjects()
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
        
        let cropRatioHeight = self.isSettingProfilePhoto ? 1 : 2
        
        self.dismiss(animated: false, completion: { () -> Void in
            self.showEditor(image: image, delegate: self, ratios: [cropRatioHeight, 1], fromController: self)
        })
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        print("Camera roll unauthorized")
    }
    
    func scrollTimelineToEntry(_ entryId: String) {
        self.timelineTableController?.scrollToEntry(entryId: entryId)
    }
    
    func imageEditor(_ editor: CLImageEditor!, didFinishEdittingWith image: UIImage!) {
        if(self.isSettingProfilePhoto || self.isSettingCoverPhoto) {
            self.dismiss(animated: false) { () -> Void in
                self.setProfilePhoto(image)
                self.isSettingProfilePhoto = false
                self.isSettingCoverPhoto = false
            }
        } else {
            let nav = self.navigationController?.storyboard?.instantiateViewController(withIdentifier: "TimelineEntryFormNavigation") as! UINavigationController
            let detailScene =  nav.topViewController as! TimelineEntryFormViewController
            detailScene.animalObject = self.currentAnimalObject
            detailScene.animalDetailController = self
            detailScene.type = "image"
            detailScene.image = image
            detailScene.pickedImageDate = self.pickedImageDate
            
            self.dismiss(animated: false) { () -> Void in
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func profileImagePressed(_ sender: AnyObject) {
        if(currentUserIsOwner || currentUserIsShelterCaregiver) {
            self.isSettingProfilePhoto = true
            self.takeFusumaPhoto()
        }
    }
    
    func respondToCovertTapGesture(_ gesture: UIGestureRecognizer) {
        if(currentUserIsOwner || currentUserIsShelterCaregiver) {
            self.isSettingCoverPhoto = true
            self.takeFusumaPhoto()
        }
    }
    
    func setProfilePhoto(_ image: UIImage!) {
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let fileName:String = (String)(WRUser.current()!.username!) + ".jpg"
        let imageFile:PFFile = PFFile(name: fileName, data: imageData!)!
        
        if isSettingCoverPhoto {
            self.currentAnimalObject!.coverPhoto = imageFile
        } else {
            self.currentAnimalObject!.profilePhoto = imageFile
        }
        
        self.showLoader()
        self.currentAnimalObject!.saveInBackground { (success: Bool, error: Error?) -> Void in
            self.hideLoader()
            if(success) {
                self.loadAnimal()
            } else {
                self.showError(message: error!.localizedDescription)
            }
        }
    }
    
    func showEditAminalView() {
        let editScene =  AnimalFormViewController()
        editScene.detailController = self
//        editScene.animalTableController = self.animalTableController
        editScene.animalObject = self.currentAnimalObject
        
        self.present(UINavigationController(rootViewController: editScene), animated: true, completion: nil)
    }
    
    func checkOwner() {
        if(self.currentAnimalObject == nil && self.username != nil) {
            self.loadAnimalFromUsername()
        }
        
        if(self.currentAnimalObject != nil) {
            let owners = currentAnimalObject!["owners"] as? [PFUser]
            let fosters = currentAnimalObject!["fosters"] as? [WRUser]
            let currentUser = WRUser.current()
            
            if owners != nil {
                for owner in owners! {
                    if (!currentUserIsOwner) {
                        currentUserIsOwner = (currentUser?.objectId == owner.objectId)
                    }
                }
            }
            
            if fosters != nil {
                for foster in fosters! {
                    if (!currentUserIsFoster) {
                        currentUserIsFoster = (currentUser?.objectId == foster.objectId)
                    }
                }
            }
            
            let currentUserShelter = currentUser?.shelter
            let animalShelter = self.currentAnimalObject!.shelter
            
            if(currentUserShelter != nil && animalShelter != nil) {
                currentUserIsShelterCaregiver = (currentUserShelter!.objectId == animalShelter!.objectId)
            }
        }
        
        if(self.timelineTableController != nil) {
            self.timelineTableController!.currentUserIsOwner = currentUserIsOwner || currentUserIsShelterCaregiver || currentUserIsFoster
            self.timelineTableController!.tableView.reloadEmptyDataSet()
        }
    }
    
    func loadAnimal() {
        if let animal = currentAnimalObject {
            if(self.timelineObjectId != nil) {
                self.timelineTableController?.timelineObjectId = self.timelineObjectId
                self.timelineObjectId = nil
            }
            self.animalImagesRepository!.loadAllImages()
            self.loadFollowerCount()
            
            self.checkOwner()
            
            if(WRUser.current() == nil) {
            } else if(currentUserIsOwner || currentUserIsFoster) {
                self.followButton.isHidden = true
            } else {
                self.loadFollow({ () -> () in
                })
            }
            
            if(currentUserIsOwner || currentUserIsShelterCaregiver || currentUserIsFoster) {
                self.navigationItem.rightBarButtonItem = self.getNavBarItem(imageId: "icon_edit_profile", action: #selector(AnimalDetailViewController.showEditAminalView), height: 25, width: 25)
            }
            
            
            
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.text = animal.name
            
            genderLabel.text = animal.gender
            let deceasedDate = animal.deceasedDate
            if let birthDate = animal.birthDate {
                var ageString = getAgeString(birthDate as Date, deceasedDate: deceasedDate as Date?)
                if deceasedDate == nil {
                    ageString = ageString + " " + genderLabel.text!.lowercased()
                }
                genderLabel.text = ageString
                
            }
            
            if let coverPhotoFile = animal.coverPhoto {
                self.coverPhoto.kf_setImage(with: URL(string: coverPhotoFile.url!)!)
                self.coverOverlay.isHidden = false
            } else {
                self.coverPhoto.image = nil
                self.coverOverlay.isHidden = true
            }
            
            if let profilePhotoFile = animal.profilePhoto {
                self.profileThumb.imageView?.makeCircular()
                self.profileThumb.kf_setImage(with: URL(string: profilePhotoFile.url!)!, for: UIControlState())
            } else {
                self.profileThumb.imageView?.image = UIImage(named: "animal_profile_photo_empty")!
            }
            
            self.shelterObject = animal.shelter
            if self.shelterObject != nil {
                self.shelterObject?.fetchIfNeededInBackground(block: { (locationObject: PFObject?, error: Error?) -> Void in
                    let adoptable = animal.adoptable
                    self.shelterButton.setTitle(self.shelterObject!.name, for: UIControlState())
                    if adoptable {
                        self.adoptableLabel.text = "Adoptable through:"
                    } else {
                        self.adoptableLabel.text = "Adopted through:"
                    }
                })
            } else {
                shelterButton.isHidden = true
            }
            
            if(animal.instagramUsername == nil) {
                instagramButton.isHidden = true
            } else {
                instagramButton.isHidden = false
            }
            
            if(animal.facebookPageId == nil) {
                facebookButton.isHidden = true
            } else {
                facebookButton.isHidden = false
            }
            
            if(animal.twitterUsername == nil) {
                twitterButton.isHidden = true
            } else {
                twitterButton.isHidden = false
            }
            
            if (instagramButton.isHidden && facebookButton.isHidden && twitterButton.isHidden) {
                socialView.isHidden = true
            } else {
                socialView.isHidden = false
            }
            
        }
    }
    
    func getAgeString(_ birthDate: Date, deceasedDate: Date?) -> String {
        let now = Date()
        let calendar = Calendar.current
        var ageString = ""
        
        if (deceasedDate != nil) {
            let ageComponents = (calendar as NSCalendar).components(.year, from: birthDate)
            let ageDeathComponents = (calendar as NSCalendar).components(.year, from: deceasedDate!)
            ageString = (ageComponents.year?.description)! + " - " + (ageDeathComponents.year?.description)!
        } else {
            let ageComponents = (calendar as NSCalendar).components(.year,
                                                    from: birthDate,
                                                    to: now,
                                                    options: [])
            
            if ageComponents.year! < 2 {
                let ageComponentsMonth = (calendar as NSCalendar).components(.month,
                                                             from: birthDate,
                                                             to: now,
                                                             options: [])
                
                ageString = ageComponentsMonth.month!.description + " month old"
            } else {
                ageString = ageComponents.year!.description + " year old"
            }
        }
        
        return ageString
    }
    
    @IBAction func openInstagramProfile(_ sender: AnyObject) {
        let instagramUsername = self.currentAnimalObject?.instagramUsername
        
        let instagramAppLink = "instagram://user?username=" + instagramUsername!
        let instagramWebLink = SocialMediaUrl.instagramUrlSuffix + instagramUsername!
        
        openAppLinkOrWebUrl(appLink: instagramAppLink, webUrl: instagramWebLink)
    }
    
    @IBAction func openFacebookProfile(_ sender: AnyObject) {
        let facebookId = self.currentAnimalObject?.facebookPageId
        
        let facebookAppLink = "fb://page?id=" + facebookId!
        let facebookWebLink = SocialMediaUrl.facebookUrlSuffix + facebookId!
        
        openAppLinkOrWebUrl(appLink: facebookAppLink, webUrl: facebookWebLink)
    }
    
    @IBAction func openTwitterProfile(_ sender: AnyObject) {
        let twitterUsername = self.currentAnimalObject?.twitterUsername
        
        let twitterAppLink = "twitter://user?screen_name=" + twitterUsername!
        let twitterWebLink = SocialMediaUrl.twitterUrlSuffix + twitterUsername!
        
        openAppLinkOrWebUrl(appLink: twitterAppLink, webUrl: twitterWebLink)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "AnimalToBreedDetail") {
            let detailScene = segue.destination as! BreedDetailViewController
            detailScene.currentBreedObject = self.breedObject
        } else if(segue.identifier == "AnimalDetailToLocation") {
            let locationViewController = segue.destination as! LocationDetailViewController
            locationViewController.currentLocationObject = self.shelterObject
        }  else if(segue.identifier == "AnimalDetailProfileTabsEmbed") {
            self.checkOwner()
            
            let animalImagesRepository = AnimalImagesRepository(animalObject: self.currentAnimalObject!)
            self.animalImagesRepository = animalImagesRepository
            
            let timelineViewController = self.storyboard?.instantiateViewController(withIdentifier: "AnimalTimelineTable") as! AnimalTimelineTableViewController
            self.timelineTableController = timelineViewController
            self.timelineTableController!.animalObject = self.currentAnimalObject
            self.timelineTableController!.animalDetailController = self
            self.timelineTableController!.animalImagesRepository = animalImagesRepository
            
            let aboutViewController = self.storyboard?.instantiateViewController(withIdentifier: "AnimalAbout") as! AnimalAboutViewController
            self.aboutViewController = aboutViewController
            self.aboutViewController!.currentUserIsOwner = (currentUserIsOwner || currentUserIsShelterCaregiver)
            self.aboutViewController!.animalObject = self.currentAnimalObject
            self.aboutViewController!.animalDetailController = self
            self.aboutViewController!.animalTimelineViewController = self.timelineTableController
            
            
            let photosViewController = self.storyboard?.instantiateViewController(withIdentifier: "AnimalPhotos") as! PhotosCollectionViewController
            self.photosCollectionViewController = photosViewController
            self.photosCollectionViewController!.animalTimelineController = self.timelineTableController
            self.photosCollectionViewController!.animalImagesRepository = animalImagesRepository
            
            self.timelineTableController?.photosCollectionViewController = self.photosCollectionViewController
            
            let viewControllers = [self.aboutViewController!, self.timelineTableController!, self.photosCollectionViewController!] as [Any]
            
            //            if(currentUserIsOwner || currentUserIsShelterCaregiver) {
            //                let medicalViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Medical") as! MedicalViewController
            //                self.medicalViewController = medicalViewController
            //                medicalViewController.animalObject = self.currentAnimalObject
            ////                self.aboutViewController!.animalDetailController = self
            //
            //                viewControllers.append(medicalViewController)
            //            }
            var pageTimeline = MenuItemCustom(title:"Timeline",imageName: "tab_icon_timeline")
            pageTimeline.numberOfPages = viewControllers.count
            pageTimeline.imageFrame = CGRect(x: 20, y: 12, width: 25, height: 25)
            pageTimeline.labelFrame = CGRect(x: 55, y: 0, width: 100, height: 50)
            
            var pageAbout = MenuItemCustom(title:"About",imageName: "tab_icon_about")
            pageAbout.numberOfPages = viewControllers.count
            pageAbout.imageFrame = CGRect(x: 25, y: 12, width: 25, height: 25)
            pageAbout.labelFrame = CGRect(x: 60, y: 0, width: 100, height: 50)
            
            var photosTab = MenuItemCustom(title:"Photos",imageName: "tab_icon_photos")
            photosTab.numberOfPages = viewControllers.count
            photosTab.imageFrame = CGRect(x: 20, y: 12, width: 25, height: 25)
            photosTab.labelFrame = CGRect(x: 55, y: 0, width: 100, height: 50)
            
            let menuOptions = MenuOptions(itemsOptions: [pageAbout, pageTimeline, photosTab], displayMode: .segmentedControl)
            
            let options = PagingMenuOptions(pagingControllers: viewControllers as! [UIViewController], menuOptions: menuOptions)
            let profileTabs = segue.destination as! PagingMenuController
            profileTabs.setup(options)
            
            if(self.currentAnimalObject?.deceasedDate != nil) {
                //aboutViewController.setInPast()
            }
        } else if(segue.identifier == "AnimalDetailTimelineEmbed") {
            let animalTimeline = segue.destination as! AnimalTimelineTableViewController
            animalTimeline.animalObject = self.currentAnimalObject
            animalTimeline.animalDetailController = self
            self.timelineTableController = animalTimeline
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.translatesAutoresizingMaskIntoConstraints = true
    }
}


protocol ImagesLoadedHandler : AnyObject {
    func imagesLoaded(_ objects: [PFObject]?, imageIndexById: [String : Int]? , imageEntries:[WRTimelineEntry]?)
    
}

open class AnimalImagesRepository {
    var animalObject: WRAnimal?
    var arrayOfSubscribers: [ImagesLoadedHandler] = [ImagesLoadedHandler]()
    
    init (animalObject: WRAnimal){
        self.animalObject = animalObject
    }
    
    /**
     Function subscribe the subscribers
     
     - Parameters:
     - subscriber:ImagesLoadedHandler
     */
    
    func subscribeLoadAll(_ subscriber:ImagesLoadedHandler){
        self.arrayOfSubscribers.append(subscriber)
    }
    
    /**
     Function to unsubscribe the subscriber
     
     - Parameters:
     - subscriber:ImagesLoadedHandler
     */
    
    func unsubscribe(_ subscriber:ImagesLoadedHandler){
        let index = self.arrayOfSubscribers.index(where: { (sub: ImagesLoadedHandler) -> Bool in
            return (subscriber as AnyObject?) === sub
        })!
            
            if index >= 0
        {
        
            self.arrayOfSubscribers.remove(at: index)
        }
        
    
    }
    
    /**
     Function to delete the image
     
     - Parameters:
     - object:PFObject? - object to delete
     - complHandler:()->() for adding more logic after deletion
     */
    func deleteImage(_ object:PFObject?, complHandler:@escaping ()->()){
        object?.deleteInBackground(block: { (success : Bool, error : Error?) -> Void in
            if(success) {
                complHandler()
                self.loadAllImages()
            }
        })
    }
    
    /**
     Function to load all images for current animal object and call subscribers ImageLoaded method
     */
    func loadAllImages () {
        let query : PFQuery = WRTimelineEntry.query()!
        query.whereKey("animal", equalTo: self.animalObject!)
        query.whereKey("type", equalTo: "image")
        query.order(byDescending: "date")
        query.limit = 1000
        var imageEntries: [WRTimelineEntry]?
        var imageIndexById : [String : Int]?
        
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            imageIndexById = [String : Int]()
            
            imageEntries = objects! as? [WRTimelineEntry]
            
            for (index, object) in objects!.enumerated() {
                imageIndexById![object.objectId!] = index

            }
            
            if self.arrayOfSubscribers.count != 0 {
                for subscriber in self.arrayOfSubscribers{
                    subscriber.imagesLoaded(objects, imageIndexById: imageIndexById, imageEntries: imageEntries)
                }
            }
        }
    }
}
