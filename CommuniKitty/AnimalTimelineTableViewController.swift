//
//  AnimalTimelineTableViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/30/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import ParseUI
import CLImageEditor
import ActiveLabel
import Device
import SKPhotoBrowser
import Fusuma

struct ImageWithInfo {
    var imageUrl:String?
    var caption:String?
    var numberOfComments:Int?
    var numberOfLikes:Int?
}

class EntryCell : PFTableViewCell {
    var entryObject : WRTimelineEntry?
    var likeObject : WRLike?

    var isLiked : Bool = false
}

class AnimalTimelineTableViewCell: EntryCell {
    
    @IBOutlet weak var eventTextLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var captionLabel: ActiveLabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var timelineImageView: UIImageView!
    @IBOutlet weak var largeIcon: UIImageView!
    
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var heartFilledButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!

    @IBOutlet weak var commentCountButton: UIButton!
    @IBOutlet weak var likeCountButton: UIButton!
    
    @IBOutlet weak var shareToCommentConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentToLikeConstraint: NSLayoutConstraint!
    
    var indexPath: IndexPath?
    var parentTable: AnimalTimelineTableViewController?
    var type: String?
    
    var likeCount:Int = 0 {
        didSet {
            self.likeCountButton.setTitle("\(likeCount)", for: .normal)
        }
    }
    var commentCount:Int = 0 {
        didSet {
            self.commentCountButton.setTitle("\(commentCount)", for: .normal)
        }
    }
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?, type: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.hideAllButtons()

        self.type = type
        if self.type == "image" {
            self.showAllButtons()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setSpacing() {
        switch Device.size() {
            case .Screen3_5Inch:
                self.shareToCommentConstraint.constant = 24
                self.commentToLikeConstraint.constant = 24
            case .Screen4Inch:
                self.shareToCommentConstraint.constant = 44
                self.commentToLikeConstraint.constant = 44
            case .Screen4_7Inch:
                self.shareToCommentConstraint.constant = 64
                self.commentToLikeConstraint.constant = 64
            case .Screen5_5Inch:
                self.shareToCommentConstraint.constant = 74
                self.commentToLikeConstraint.constant = 74
            default:
                self.shareToCommentConstraint.constant = 44
                self.commentToLikeConstraint.constant = 44
        }
    }

    func showAllButtons() {
        self.heartButton.isHidden = false
        self.commentButton.isHidden = false
        self.shareButton.isHidden = false
        self.flagButton.isHidden = false
        self.moreButton.isHidden = false
        self.likeCountButton.isHidden = false
        self.commentCountButton.isHidden = false
    }
    
    func hideAllButtons() {
        self.heartButton.isHidden = true
        self.heartFilledButton.isHidden = true
        self.commentButton.isHidden = true
        self.shareButton.isHidden = true
        self.flagButton.isHidden = true
        self.moreButton.isHidden = true
        self.likeCountButton.isHidden = true
        self.commentCountButton.isHidden = true
    }
    
    func incrementLikeCount() {
        self.isLiked = true
        self.likeCount = self.likeCount + 1
    }

    func decrementLikeCount() {
        if self.likeCount > 0 {
            self.isLiked = false
            self.likeCount = self.likeCount - 1
        }
    }
    
    func setHeartsDisabled() {
        self.heartButton.isEnabled = false
        self.heartFilledButton.isEnabled = false
    }

    func setHeartsEnabled() {
        self.heartButton.isEnabled = true
        self.heartFilledButton.isEnabled = true
    }
    
    func setEntryLiked() {
        self.isLiked = true
        self.heartButton.isHidden = true
        self.heartFilledButton.isHidden = false
    }

    func setEntryUnliked() {
        self.isLiked = false
        self.heartButton.isHidden = false
        self.heartFilledButton.isHidden = true
    }
        
//    @IBAction func heartButtonPressed(sender: AnyObject) {
//        self.setHeartsDisabled()
//        parentTable?.showLikeActionSheet(entryCell: self, completionBlock: { (result, error) -> Void in
//            self.setEntryLiked()
//            self.incrementLikeCount()
//            self.setHeartsEnabled()
//        })
//    }
//    
//    @IBAction func heartFilledButtonPressed(sender: AnyObject) {
//        self.setHeartsDisabled()
//        parentTable?.unlikeEntryWithBlock(entryCell: self, completionBlock: { (result, error) -> Void in
//            self.setEntryUnliked()
//            self.decrementLikeCount()
//            self.setHeartsEnabled()
//        })
//    }
//    
//    @IBAction func commentButtonPressed(sender: AnyObject) {
//        parentTable!.selectedIndexPath = self.indexPath!
//        parentTable!.performSegue(withIdentifier: "TimelineToEntryDetail", sender: self)
//    }
//    
//    @IBAction func shareButtonPressed(sender: AnyObject) {
//        parentTable!.showShareActionSheet(sender: sender, indexPath: self.indexPath!)
//    }
//    
//    @IBAction func flagButtonPressed(sender: AnyObject) {
//        if self.flagButton.isEnabled {
//            parentTable!.showFlagActionSheet(entryCell: self, flaggedObject: nil)
//        }
//    }
//    
//    @IBAction func moreButtonPressed(sender: AnyObject) {
//        if self.moreButton.isEnabled {
//            parentTable!.showMoreActionSheet(sender: sender, indexPath: self.indexPath!)
//        }
//    }
}

class AnimalTimelineTableViewController: PFQueryTableViewController, CLImageEditorDelegate, FusumaDelegate, ImagesLoadedHandler {

    var animalObject : WRAnimal?
    var animalDetailController : AnimalDetailViewController?
    var photosCollectionViewController: PhotosCollectionViewController?
    var timelineObjectId : String?
    var animalImagesRepository:AnimalImagesRepository?{
        didSet{
            animalImagesRepository?.subscribeLoadAll(self)
        }
    }
    
    var isEditingProfile : Bool = false
    var isEditingCover : Bool = false
    var isAddingFirstImage: Bool = false
    
    var currentUserIsOwner : Bool = false
    
    var selectedIndexPath : IndexPath?
    var indexPathByEntryId: [String: IndexPath] = [String:IndexPath]()
    var preventAnimation = Set<IndexPath>()
    
    var imageEntries: [WRTimelineEntry]?
    var imageIndexById : [String : Int]?
    
    
    deinit {
        animalImagesRepository?.unsubscribe(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.replacePFLoadingView(verticalOffset: self.tableView.rowHeight/3)
        self.animalImagesRepository?.loadAllImages()
        let screenSize: CGRect = UIScreen.main.bounds
        self.tableView.rowHeight = screenSize.width + 15
        
        self.initEmptyState()
        
        self.initGestureRecognizers()
    }
    
    override func viewDidLayoutSubviews() {
        
        if self.imagesLoaded && self.imageIndexById?.count == 0{
            switch Device.size() {
            case .Screen4_7Inch:
                self.view.frame.size.height = 430
            case .Screen5_5Inch:
                self.view.frame.size.height = 500
            default:
                self.view.frame.size.height = 430
            }
        }
        
    }
    
    /**
     Loads imageEntries and imageIndexById. Conforms ImagesLoadedHandler protocol
     
     - Parameters:
     - objects: An array of the objects to scroll to
     - imageIndexById: [String : Int]? - adds the dictionary after images loading
     - imageEntries:[WRTimelineEntry]? - adds the entries after image loading
     */
    
    func imagesLoaded(_ objects: [PFObject]?, imageIndexById: [String : Int]? , imageEntries:[WRTimelineEntry]?){
        self.imageIndexById = imageIndexById ?? [String : Int]()
        self.imageEntries = imageEntries ?? [WRTimelineEntry]()
        self.perform(#selector(scrollToIndexPathForEntity), with: objects, afterDelay: 0.5)
        self.imagesLoaded = true
        self.viewDidLayoutSubviews()
    }
    
    var imagesLoaded:Bool = false
    
    /**
     Scrolls the timeline to the image with object at self.timelineObjectId
     
     - Parameters:
     - objects: An array of the objects to scroll to
     */
    func scrollToIndexPathForEntity(objects: [PFObject]?) {
        if (self.timelineObjectId != nil) {
            for (index, object) in objects!.enumerated(){
                if object.objectId == self.timelineObjectId {
                    var scrollIndex = index
                    if self.animalDeceased() {
                         scrollIndex += 1
                    }
                    if scrollIndex < tableView.numberOfRows(inSection: 0) {
                        let indexPath = IndexPath(row: scrollIndex, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
                    self.timelineObjectId = nil
                    break
                }
            }
        }
    }
    
    func initGestureRecognizers() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }

//    func handleDoubleTap(gestureRecognizer : UILongPressGestureRecognizer) {
//        let p = gestureRecognizer.location(in: self.tableView)
//        let indexPath = self.tableView.indexPathForRowAtPoint(p)
//        let cell = tableView.cellForRowAtIndexPath(indexPath!) as? AnimalTimelineTableViewCell
//
//        if (indexPath == nil) {
//            NSLog("tap on table view but not on a row");
//        } else if (!(cell!.isLiked)) {
//            cell?.setHeartsDisabled()
//            self.showLikeActionSheet(cell!, completionBlock: { (result, error) -> Void in
//                cell?.setEntryLiked()
//                cell?.incrementLikeCount()
//                cell?.setHeartsEnabled()
//            })
//        }
//    }
//    
//    func handlePress(gestureRecognizer : UILongPressGestureRecognizer) {
//        let p = gestureRecognizer.locationInView(self.tableView)
//        let indexPath = self.tableView.indexPathForRowAtPoint(p)
//        let cell = tableView.cellForRowAtIndexPath(indexPath!) as? AnimalTimelineTableViewCell
//        
//        if (indexPath == nil) {
//            NSLog("tap on table view but not on a row");
//        } else {
//            let object = self.objectAtCell(indexPath)!
//            
//            let index = self.imageIndexById![object.objectId!]
//            
//            self.showImagesBrowser(imageEntries!, startIndex: index, animatedFromView: cell!.timelineImageView, displayUser: false)
//        }
//    }
//    
//    func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer) {
//        let p = gestureRecognizer.locationInView(self.tableView)
//        let indexPath = self.tableView.indexPathForRowAtPoint(p)
//        
//        if (indexPath == nil) {
//            NSLog("long press on table view but not on a row");
//        } else if (gestureRecognizer.state == .began) {
//            NSLog("long press on table view at row %d", indexPath!.row);
//        } else {
//            NSLog("gestureRecognizer.state = %d", gestureRecognizer.state.rawValue);
//        }
//        
//        self.showMoreActionSheet(sender: self, indexPath: indexPath)
//    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y <= 0 ) {
            self.tableView.isScrollEnabled = false;
        } else {
            self.tableView.isScrollEnabled = true;
        }
    }
    
    
    func showMoreActionSheet(sender: AnyObject, indexPath: IndexPath?) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)

        let editAction = UIAlertAction(title: "Edit", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Editing timeline entry")
            self.editEntry(indexPath: indexPath)
        })
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Deleting timeline entry")
            self.deleteEntry(indexPath: indexPath)
        })
        
        let profilePhotoAction = UIAlertAction(title: "Set as Profile Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Setting profile photo")
            self.setProfilePhoto(image: self.imageAtCell(indexPath: indexPath)!)
        })

        let coverPhotoAction = UIAlertAction(title: "Set as Cover Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Setting cover photo")
            self.setCoverPhoto(image: self.imageAtCell(indexPath: indexPath)!)
        })

        
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(editAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(profilePhotoAction)
        optionMenu.addAction(coverPhotoAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func showShareActionSheet(sender: AnyObject, indexPath: IndexPath?) {
        let image = self.imageAtCell(indexPath: indexPath)!
        let activityVC = UIActivityViewController(activityItems: ["http://ftwtrbt.com", image], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func imageAtCell(indexPath: IndexPath?) -> UIImage? {
        let cell = tableView.cellForRow(at: indexPath!) as? AnimalTimelineTableViewCell
        let image = cell!.timelineImageView.image
        return image
    }
    
    func objectAtCell(indexPath: IndexPath?) -> WRTimelineEntry? {
        let cell = tableView.cellForRow(at: indexPath!) as? AnimalTimelineTableViewCell
        let object = cell?.entryObject
        return object
    }
    
    func scrollToEntry(entryId: String) {
        self.loadIndexPaths()
        let indexPath = self.indexPathByEntryId[entryId]
        self.scrollToIndexPath(indexPath: indexPath)
    }
    
    func scrollToIndexPath(indexPath: IndexPath?) {
        self.tableView.scrollToRow(at: indexPath!, at: .bottom, animated: true)
    }

    func editEntry(indexPath: IndexPath?) {
        let object = self.object(at: indexPath)
        let entry = object as! WRTimelineEntry

        let entryFormView = TimelineEntryFormViewController()
        entryFormView.image = self.imageAtCell(indexPath: indexPath)
        entryFormView.animalObject = self.animalObject
        entryFormView.entryObject = entry
        entryFormView.animalDetailController = self.animalDetailController
        
        self.present(UINavigationController(rootViewController: entryFormView), animated: true, completion: nil)
    }
    
    func deleteEntry(indexPath: IndexPath?) {
        let object = self.object(at: indexPath)
        self.showLoader()
        self.animalImagesRepository?.deleteImage(object, complHandler: {
            self.hideLoader()
            self.loadObjects()
        })
    }
    
    func imageEditor(_ editor: CLImageEditor!, didFinishEdittingWith image: UIImage!) {
        NSLog("got new image")
        let imageFile = PFFile(data: UIImageJPEGRepresentation(image, 0.5)!)
        
        if let object = self.animalObject {
            if self.isEditingProfile {
                object.setValue(imageFile, forKey: "profilePhoto")
            } else if self.isEditingCover {
                object.setValue(imageFile, forKey: "coverPhoto")
            } else if self.isAddingFirstImage{
                if image != nil {
                    let detailScene =  TimelineEntryFormViewController()
                    detailScene.type = "image"
                    detailScene.image = image
                    detailScene.pickedImageDate = self.pickedImageDate as Date?
                    detailScene.animalObject = self.animalObject
                    detailScene.isFromTimelineController = true
                    detailScene.animalDetailController = self.animalDetailController
                    
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
            self.showLoader()
            object.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
                NSLog("finished saving profile photo")
                if success {
                    self.dismiss(animated: false, completion: nil)
                    self.animalDetailController?.loadAnimal()
                    self.animalImagesRepository?.loadAllImages()
                } else {
                    self.showError(message: error!.localizedDescription)
                }
                self.hideLoader()
            })
        }
        self.isEditingProfile = false
        self.isEditingCover = false
        self.isAddingFirstImage = false
    }
    
    func setCoverPhoto(image : UIImage) {
        self.isEditingCover = true
        self.showEditor(image: image, delegate: self, ratios: [2, 1], fromController: self, forceCrop: true)
    }

    func setProfilePhoto(image : UIImage) {
        self.isEditingProfile = true
        self.showEditor(image: image, delegate: self, ratios: [1, 1], fromController: self)
    }
    
    func incrementIndexPath(indexPath: IndexPath) -> IndexPath? {
        var nextIndexPath: IndexPath?
        let nextRow = indexPath.row - 1
        let currentSection = indexPath.section
        
        nextIndexPath = IndexPath(row: nextRow, section: currentSection)
        
        return nextIndexPath
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage {
        if currentUserIsOwner {
            return UIImage(named: "kitteh_selfie")!
        } else {
            return UIImage(named: "kitteh_hit")!
        }
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0), NSForegroundColorAttributeName: UIColor.darkGray]
        
        if currentUserIsOwner {
            return NSAttributedString(string: "No meowments yet", attributes: attributes)
        } else {
            return NSAttributedString(string: "No meowments yet", attributes: attributes)
        }
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString {
        let paragraph: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.lightGray, NSParagraphStyleAttributeName: paragraph]
        
        if currentUserIsOwner {
            return NSAttributedString(string: "Start capturing some of your kitteh’s best meowments.", attributes: attributes)
        } else {
            return NSAttributedString(string: "This kitteh hasn’t added any meowments yet", attributes: attributes)
        }
    }
    
    func buttonImageForEmptyDataSet(scrollView: UIScrollView, forState state: UIControlState) -> UIImage? {
        if currentUserIsOwner {
            return UIImage(named: "arrow_to_button_camera")
        } else {
            return UIImage(named: "button_nudge")
        }
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView) {
        if currentUserIsOwner {
            self.takeFusumaPhoto()
        } else {
        }
    }
    
    func takeFusumaPhoto() {
        let fusuma = FusumaViewController()
        
        fusuma.delegate = self
        
        fusuma.modeOrder = .CameraFirst
        
        fusuma.transitioningDelegate = transitioningDelegate
        fusuma.modalPresentationStyle = .custom
        
        present(fusuma, animated: true, completion: nil)
        
    }
    
    /**
     Handle the image that is returned from the camera
     - implements FusumaDelegate
     */
    var pickedImageDate: NSDate?
    func fusumaImageSelected(image: UIImage, creationDate: NSDate?) {
        self.pickedImageDate = creationDate
        
        self.modalTransitionStyle = .coverVertical
        self.dismiss(animated: false, completion: { () -> Void in
            self.isAddingFirstImage = true
            self.showEditor(image: image, delegate: self, ratios: [1, 1], fromController: self)
        })
    }
    
    public func fusumaImageSelected(_ image: UIImage) {
        self.modalTransitionStyle = .coverVertical
        self.dismiss(animated: false, completion: { () -> Void in
            self.isAddingFirstImage = true
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
    
    func animalDeceased() -> Bool {
        return self.animalObject?.deceasedDate != nil
    }
    
    override func queryForTable() -> PFQuery<PFObject> {
        let query = WRTimelineEntry.query()!
        
        query.order(byDescending: "date")
        if self.animalDeceased() {
            query.order(byAscending: "date")
        }
        query.includeKey("shelter")
        query.includeKey("animal")
        if(self.animalObject != nil) {
            query.whereKey("animal", equalTo: animalObject!)
        } else {
            query.whereKeyDoesNotExist("animal")
        }
        
        return query
    }
    
    func loadIndexPaths() {
        for row in 0 ..< tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            let object = objectAtCell(indexPath: indexPath)
            self.indexPathByEntryId[object!.objectId!] = indexPath
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "AnimalTimelineCell", for: indexPath) as? AnimalTimelineTableViewCell
        if cell == nil  {
            cell = AnimalTimelineTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "AnimalTimelineCell", type: object?["type"] as! String)
        }
        
        cell!.indexPath = indexPath
        cell!.parentTable = self

        let entry = object as! WRTimelineEntry
        cell!.entryObject = entry
        
        cell!.setSpacing()
        
        
        if(entry.isImage()) {
            cell!.showAllButtons()

            if(currentUserIsOwner) {
                cell!.moreButton.isHidden = false
                cell!.moreButton.isEnabled = true
                cell!.flagButton.isHidden = true
                cell!.flagButton.isEnabled = false
            } else {
                cell!.moreButton.isHidden = true
                cell!.moreButton.isEnabled = false
                cell!.flagButton.isHidden = false
                cell!.flagButton.isEnabled = true
            }
            
//            self.isEntryLikedWithBlock(cell!, completionBlock: { (result, error) -> Void in
//                if(result) {
//                    cell!.setEntryLiked()
//                } else {
//                    cell!.setEntryUnliked()
//                }
//            })
            
            cell!.commentCount = entry.getCommentCount()
            cell!.likeCount = entry.getLikeCount()
        } else {
            cell!.hideAllButtons()
        }
        
        cell!.timelineImageView.isHidden = true
        if let imageFile = entry.image {
            cell!.timelineImageView.kf_setImage(with: URL(string: imageFile.url!)!, placeholder: nil, options: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            })
            cell!.timelineImageView.isHidden = false
        } else if let imageUrl = entry.imageUrl {
            cell!.timelineImageView.kf_setImage(with: URL(string: imageUrl)!, placeholder: nil, options: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            })
            cell!.timelineImageView.isHidden = false
        } else {
            cell!.timelineImageView.isHidden = true
        }
        
        if entry.isInstagramImage() {
            cell!.instagramButton.isHidden = false
        } else {
            cell!.instagramButton.isHidden = true
        }

        if let text = entry.text {
            cell!.eventTextLabel.text = text
            cell!.eventTextLabel.isHidden = false
            
            cell!.captionLabel.text = ""
            cell!.captionLabel.isHidden = true
            
            cell!.largeIcon.isHidden = true
            switch entry.type! {
                case "medical":
                    cell!.largeIcon.image = UIImage(named: "timeline_medical")
                    cell!.largeIcon.isHidden = false
                    break
                case "adopted":
                    cell!.largeIcon.image = UIImage(named: "timeline_adopted")
                    cell!.largeIcon.isHidden = false
                    break
                case "fostered":
                    cell!.largeIcon.image = UIImage(named: "timeline_foster")
                    cell!.largeIcon.isHidden = false
                    break
                case "birth":
                    cell!.largeIcon.image = UIImage(named: "timeline_born")
                    cell!.largeIcon.isHidden = false
                    break
                case "birthday":
                    cell!.largeIcon.image = UIImage(named: "timeline_birthday")
                    cell!.largeIcon.isHidden = false
                    break
                case "image":
                    // cell!.captionLabel.handleHashtagTap(self.openHashTagFeed)
                    // cell!.captionLabel.handleMentionTap(self.openUsername)
                    
                    cell!.captionLabel.text = text
                    if(text != "") {
                        cell!.captionLabel.isHidden = false
                    }
                    cell!.eventTextLabel.isHidden = true
                    break
                default:
                    cell!.largeIcon.image = UIImage()
                    cell!.largeIcon.isHidden = true
                    break
            }

        } else {
            cell!.captionLabel.text = ""
            cell!.captionLabel.isHidden = true
            cell!.eventTextLabel.isHidden = true
        }

        if let actingUser = entry.actingUser {
            actingUser.fetchIfNeededInBackground(block: { (object: PFObject?, error: Error?) -> Void in
                cell!.locationButton.titleLabel?.textAlignment = .center
                let firstName = actingUser["firstName"] as! String
                let lastName = actingUser["lastName"] as! String
                cell!.locationButton.setTitle("\(firstName) \(lastName)", for: .normal)
            
                cell!.locationButton.setActionBlock(block: { (sender) -> Void in
                    self.openUsername(username: actingUser["username"] as! String)
                })
                
                cell!.locationButton.isHidden = false
            })
        } else if let location = entry.location {
            location.fetchIfNeededInBackground(block: { (object: PFObject?, error: Error?) -> Void in
                cell!.locationButton.titleLabel?.textAlignment = .center
                cell!.locationButton.setTitle(location.name, for: .normal)
                cell!.locationButton.isHidden = false
            })
        } else {
            cell!.locationButton.setTitle("", for: .normal)
        }
        
        if let date = entry.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
            cell!.monthLabel.text = dateFormatter.string(from: date).uppercased()

            dateFormatter.dateFormat = "dd"
            cell!.dayLabel.text = dateFormatter.string(from: date)

            dateFormatter.dateFormat = "yyyy"
            cell!.yearLabel.text = dateFormatter.string(from: date)
        }
        
//        if entry.isImage() {
//            if currentUserIsOwner {
//                let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
//                gestureRecognizer.minimumPressDuration = 1.0
//                cell!.addGestureRecognizer(gestureRecognizer)
//            }
//            
//            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlePress))
//            cell!.addGestureRecognizer(tapRecognizer)
//            
//            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
//            doubleTapRecognizer.numberOfTapsRequired = 2
//            tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
//            cell!.addGestureRecognizer(doubleTapRecognizer)
//        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !preventAnimation.contains(indexPath) {
            preventAnimation.insert(indexPath)
//            TipInCellAnimator.animate(cell)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "TimelineToEntryDetail") {
            let detailScene =  segue.destination as! TimelineEntryDetailViewController

            detailScene.entryObject = self.object(at: self.selectedIndexPath) as? WRTimelineEntry
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        NSLog("Clearing Kingfisher cache")
        KingfisherManager.shared.cache.clearMemoryCache()
    }
    
}
