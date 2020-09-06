//
//  AnimalTimelineTableViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/30/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import Parse
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
    
    var indexPath: IndexPath?
    var parentTable: AnimalTimelineTableViewController?
    var type: String?
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, type: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

class AnimalTimelineTableViewController: UITableViewController, CLImageEditorDelegate, FusumaDelegate, ImagesLoadedHandler {

    var animalObject : [String:Any]?
    var stories: [[String:Any]] = []
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
    var isFistImageAdded: Bool = false
    
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
        let screenSize: CGRect = UIScreen.main.bounds
        self.tableView.rowHeight = screenSize.width + 15
        self.initGestureRecognizers()
    }
    
    func loadObjects(){
        if( GraphQLServiceManager.sharedManager.getUSer() == nil) {
            return
        }
        
        if let slug = animalObject?["slug"] as? String {
           let params = ["animalSlug": slug] as [String : Any]
            let url =  self.queryForTable()
            GraphQLServiceManager.sharedManager.createGraphQLRequestWith(query: url, variableParam: params, success: { (response) in
             
                guard let dataToParse = response else {
                    return
                }
                do {
                    let data = try JSONSerialization.jsonObject(with: dataToParse, options: .mutableLeaves)
                    if let stories = ((data as? [String:Any])?["data"] as? [String:Any])?["animalStories"] as? [[String:Any]]{
                      
                            self.stories = stories
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                    }
                    
                } catch let error {
                    print(error.localizedDescription)
                }
                
            }) { (error) in
                
                print(error.userInfo["errorMessage"] as? String ?? error.localizedDescription)
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
        setEmptyDataSetCustomView()
    }
    
    
    var imagesLoaded:Bool = false
    
    /**
     Scrolls the timeline to the image with object at self.timelineObjectId
     
     - Parameters:
     - objects: An array of the objects to scroll to
     */
    @objc func scrollToIndexPathForEntity(objects: [PFObject]?) {
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
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
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
    @objc func handlePress(gestureRecognizer : UILongPressGestureRecognizer) {
        let p = gestureRecognizer.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        let cell = tableView.cellForRow(at: indexPath!) as? AnimalTimelineTableViewCell
        
        if (indexPath == nil) {
            NSLog("tap on table view but not on a row");
        } else {
            let object = self.objectAtCell(indexPath: indexPath)!
            
            let index = self.imageIndexById![object.objectId!]
            
            self.showImagesBrowser(entries: imageEntries!, startIndex: index, animatedFromView: cell!.timelineImageView, displayUser: false, vc: self)
        }
    }
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

    
//    func imageEditor(_ editor: CLImageEditor!, didFinishEdittingWith image: UIImage!) {
//        NSLog("got new image")
//        let imageFile = PFFileObject(data: image.jpegData(compressionQuality: 0.5)!)
//        
//        if let object = self.animalObject {
//            if self.isEditingProfile {
//                object.setValue(imageFile, forKey: "profilePhoto")
//            } else if self.isEditingCover {
//                object.setValue(imageFile, forKey: "coverPhoto")
//            } else if self.isAddingFirstImage{
//                if image != nil {
//                    let detailScene =  TimelineEntryFormViewController()
//                    detailScene.type = "image"
//                    detailScene.image = image
//                    detailScene.pickedImageDate = self.pickedImageDate as Date?
//                    detailScene.animalObject = self.animalObject
//                    detailScene.isFromTimelineController = true
//                    detailScene.animalTimelineTableVC = self
//                    detailScene.animalDetailController = self.animalDetailController
//                    
//                    let nav = UINavigationController(rootViewController: detailScene)
//                    nav.modalTransitionStyle = .coverVertical
//                    
//                    self.dismiss(animated: false) { () -> Void in
//                        self.present(nav, animated: false, completion: { () -> Void in
//                            self.hideLoader()
//                        })
//                    }
//                } else {
//                    self.dismiss(animated: false, completion: { () -> Void in
//                        self.hideLoader()
//                    })
//                }
//
//                
//            }
//            self.showLoader()
//            object.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
//                NSLog("finished saving profile photo")
//                if success {
//                    self.dismiss(animated: false, completion: nil)
//                } else {
//                    self.showError(message: error!.localizedDescription)
//                }
//                self.hideLoader()
//            })
//        }
//        self.isEditingProfile = false
//        self.isEditingCover = false
//        self.isAddingFirstImage = false
//    }
    
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
    
    @objc func tapOnEmptyDataSetButton(){
        if currentUserIsOwner {
            self.takeFusumaPhoto()
        } else {
        }
    }
    
    func setEmptyDataSetCustomView(){
        if self.imagesLoaded && self.imageIndexById?.count == 0 {
            for subview in self.view.subviews {
                if type(of: subview) == UIView.self {
                subview.removeFromSuperview()
                }
            }
            let customView = UIView(frame:CGRect(x:0, y:0, width:  self.view.frame.size.width, height:   self.view.frame.size.height))
            self.showEmptyCustomView(view: customView, currentUserIsOwner: currentUserIsOwner, vc: self)
            self.view.addSubview(customView)
            self.tableView.reloadData()
        } else if self.imagesLoaded && self.imageIndexById?.count != 0 {
            if self.isFistImageAdded {
                for subview in self.view.subviews{
                    if type(of: subview) == UIView.self {
                        subview.removeFromSuperview()
                    }
                }
                self.tableView.reloadData()
                self.isFistImageAdded = false
            } else {
                self.tableView.reloadData()
            }
        }

    }


    func takeFusumaPhoto() {
        let fusuma = FusumaViewController()
        
        fusuma.delegate = self
        
//        fusuma.modeOrder = .cameraFirst
        
        fusuma.transitioningDelegate = transitioningDelegate
        fusuma.modalPresentationStyle = .custom
        
        present(fusuma, animated: true, completion: nil)
        
    }
    
    /**
     Handle the image that is returned from the camera
     - implements FusumaDelegate
     */
    var pickedImageDate: Date?
    func fusumaImageSelected(_ image: UIImage, creationDate: Date?) {
        self.pickedImageDate = creationDate
        
        self.modalTransitionStyle = .coverVertical
        self.dismiss(animated: false, completion: { () -> Void in
            self.isAddingFirstImage = true
//            self.showEditor(image: image, delegate: self, ratios: [1, 1], fromController: self)
        })
    }
    
    public func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        self.modalTransitionStyle = .coverVertical
        self.dismiss(animated: false, completion: { () -> Void in
            self.isAddingFirstImage = true
//            self.showEditor(image: image, delegate: self, ratios: [1, 1], fromController: self)
        })
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
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
        return false
//            self.animalObject?.deceasedDate != nil
    }
    
    func queryForTable() -> String {
        return GETANIMALTIMELINE
    }
    
    func loadIndexPaths() {
        for row in 0 ..< tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            let object = objectAtCell(indexPath: indexPath)
            self.indexPathByEntryId[object!.objectId!] = indexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stories.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimalTimelineCell", for: indexPath) as? AnimalTimelineTableViewCell
        
        cell!.indexPath = indexPath
        cell!.parentTable = self

        let entry = stories[indexPath.row]
//        cell!.entryObject = entry
        
        cell!.timelineImageView.isHidden = true
        cell!.timelineImageView.kf.indicatorType = .activity
       if let imageUrl = entry["thumbnailUrl"] as? String{
            cell!.timelineImageView.kf.setImage(with: URL(string: imageUrl)!, placeholder: nil, options: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            })
            cell!.timelineImageView.isHidden = false
        } else {
            cell!.timelineImageView.isHidden = true
        }
        
//        if entry.isInstagramImage() {
//            cell!.instagramButton.isHidden = false
//        } else {
            cell!.instagramButton.isHidden = true
//        }

            cell!.eventTextLabel.text = entry["title"] as? String
            cell!.eventTextLabel.isHidden = false
            
            cell!.captionLabel.text = entry["body"] as? String
            cell!.captionLabel.isHidden = false
            
            cell!.largeIcon.isHidden = true
//            switch entry["title"] as? String {
//                case "medical":
//                    cell!.largeIcon.image = UIImage(named: "timeline_medical")
//                    cell!.largeIcon.isHidden = false
//                    break
//                case "adopted":
//                    cell!.largeIcon.image = UIImage(named: "timeline_adopted")
//                    cell!.largeIcon.isHidden = false
//                    break
//                case "fostered":
//                    cell!.largeIcon.image = UIImage(named: "timeline_foster")
//                    cell!.largeIcon.isHidden = false
//                    break
//                case "birth":
//                    cell!.largeIcon.image = UIImage(named: "timeline_born")
//                    cell!.largeIcon.isHidden = false
//                    break
//                case "birthday":
//                    cell!.largeIcon.image = UIImage(named: "timeline_birthday")
//                    cell!.largeIcon.isHidden = false
//                    break
//                case "image":
//                    // cell!.captionLabel.handleHashtagTap(self.openHashTagFeed)
//                    // cell!.captionLabel.handleMentionTap(self.openUsername)
//
//                    cell!.captionLabel.text = text
//                    if(text != "") {
//                        cell!.captionLabel.isHidden = false
//                    }
//                    cell!.eventTextLabel.isHidden = true
//                    break
//                default:
//                    cell!.largeIcon.image = UIImage()
//                    cell!.largeIcon.isHidden = true
//                    break
//            }

        

//        if let actingUser = entry.actingUser {
//            actingUser.fetchIfNeededInBackground(block: { (object: PFObject?, error: Error?) -> Void in
//                cell!.locationButton.titleLabel?.textAlignment = .center
//                let firstName = actingUser["firstName"] as! String
//                let lastName = actingUser["lastName"] as! String
//                cell!.locationButton.setTitle("\(firstName) \(lastName)", for: .normal)
//
//                cell!.locationButton.setActionBlock(block: { (sender) -> Void in
//                    self.openUsername(username: actingUser["username"] as! String)
//                })
//
//                cell!.locationButton.isHidden = false
//            })
//        } else if let location = entry.location {
//            location.fetchIfNeededInBackground(block: { (object: PFObject?, error: Error?) -> Void in
//                cell!.locationButton.titleLabel?.textAlignment = .center
//                cell!.locationButton.setTitle(location.name, for: .normal)
//                cell!.locationButton.isHidden = false
//            })
//        } else {
            cell!.locationButton.setTitle("", for: .normal)
//        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        if let dateString = entry["date"] as? String, let date = dateFormatter.date(from: dateString)  {
            
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
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlePress))
            cell!.addGestureRecognizer(tapRecognizer)
            
//            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
//            doubleTapRecognizer.numberOfTapsRequired = 2
//            tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
//            cell!.addGestureRecognizer(doubleTapRecognizer)
//        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !preventAnimation.contains(indexPath) {
            preventAnimation.insert(indexPath)
//            TipInCellAnimator.animate(cell)
        }
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let object = self.objectAtCell(indexPath: indexPath)!
//        let index = self.imageIndexById![object.objectId!]
//        
//        self.showImagesBrowser(entries: imageEntries!, startIndex: index, animatedFromView: nil, displayUser: false)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "TimelineToEntryDetail") {
            let detailScene =  segue.destination as! TimelineEntryDetailViewController
//            detailScene.entryObject = self.object(at: self.selectedIndexPath) as? WRTimelineEntry
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        NSLog("Clearing Kingfisher cache")
        KingfisherManager.shared.cache.clearMemoryCache()
    }
    
}
