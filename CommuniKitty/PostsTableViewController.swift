//
//  PostsTableViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/19/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import ParseUI
import ActiveLabel
import Device
import SwiftDate

class PostsTableViewCell: EntryCell {
    @IBOutlet weak var usernameLink: UIButton!
    
    @IBOutlet weak var largeImageView: UIImageView!
    @IBOutlet weak var profilePhotoPFImageView: PFImageView!
    @IBOutlet weak var captionLabel: ActiveLabel!
    @IBOutlet weak var timeLabel: UIButton!
    
    @IBOutlet weak var shareToCommentConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentToLikeConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var flagButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var heartFilledButton: UIButton!
    @IBOutlet weak var heartButton: UIButton!    
    
    @IBOutlet weak var commentCountButton: UIButton!
    @IBOutlet weak var likeCountButton: UIButton!
    
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
    func setSpacing() {
        switch Device.size() {
        case .Screen3_5Inch:
            self.shareToCommentConstraint.constant = 54
            self.commentToLikeConstraint.constant = 54
        case .Screen4Inch:
            self.shareToCommentConstraint.constant = 64
            self.commentToLikeConstraint.constant = 64
        case .Screen4_7Inch:
            self.shareToCommentConstraint.constant = 79
            self.commentToLikeConstraint.constant = 79
        case .Screen5_5Inch:
            self.shareToCommentConstraint.constant = 94
            self.commentToLikeConstraint.constant = 94
        default:
            self.shareToCommentConstraint.constant = 64
            self.commentToLikeConstraint.constant = 64
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
}

class PostsNavigation : UINavigationController {
    override func viewDidLoad() {
    }
}


class PostsTableViewController: PFQueryTableAutoLoadingViewController {

    var selectedIndexPath : IndexPath?
    
    var hashtag : String?
    var following : Bool = true
    
    @IBAction func usernamePressed(sender: AnyObject) {
        self.setSelectedIndexPathFromSender(sender: sender)
        self.performSegue(withIdentifier: "PostsToAnimalDetail", sender: sender)
    }
    
    func ProfilePhotoPFImageViewTaped(gestureRecognizer: UITapGestureRecognizer) {
        let tappedImageView = gestureRecognizer.view!
        self.setSelectedIndexPathFromSender(sender: tappedImageView)
        self.performSegue(withIdentifier: "PostsToAnimalDetail", sender: tappedImageView)
    }
    
    @IBAction func commentButtonPressed(sender: AnyObject) {
        self.setSelectedIndexPathFromSender(sender: sender)
        self.performSegue(withIdentifier: "PostsToEntryDetail", sender: sender)
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        self.setSelectedIndexPathFromSender(sender: sender)
        self.showShareActionSheet(sender: sender, indexPath: self.selectedIndexPath!)
    }

    func imageAtCell(indexPath: IndexPath?) -> UIImage? {
        let cell = tableView.cellForRow(at: indexPath!) as? PostsTableViewCell
        let image = cell!.largeImageView.image
        return image
    }
    
    func showShareActionSheet(sender: AnyObject, indexPath: IndexPath?) {
        let image = self.imageAtCell(indexPath: indexPath)!
        let activityVC = UIActivityViewController(activityItems: ["http://ftwtrbt.com", image], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }

    
//    @IBAction func flagButtonPressed(sender: AnyObject) {
//        self.setSelectedIndexPathFromSender(sender: sender)
//        let cell = tableView.cellForRow(at: self.selectedIndexPath!) as? PostsTableViewCell
//
//        self.showShareActionSheet(cell!, flaggedObject: nil)
//    }
//    
//    func handleDoubleTap(gestureRecognizer : UILongPressGestureRecognizer) {
//        let p = gestureRecognizer.location(in: self.tableView)
//        let indexPath = self.tableView.indexPathForRow(at: p)
//        let cell = tableView.cellForRow(at: indexPath!) as? PostsTableViewCell
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
//    
//    
//    @IBAction func heartButtonPressed(sender: AnyObject) {
//        self.setSelectedIndexPathFromSender(sender: sender)
//        let cell = tableView.cellForRowAtIndexPath(self.selectedIndexPath!) as? PostsTableViewCell
//        cell?.setHeartsDisabled()
//        self.showLikeActionSheet(cell!, completionBlock: { (result, error) -> Void in
//            cell?.setEntryLiked()
//            cell?.incrementLikeCount()
//            cell?.setHeartsEnabled()
//        })
//    }
//    
//    @IBAction func heartFilledButtonPressed(sender: AnyObject) {
//        self.setSelectedIndexPathFromSender(sender)
//        let cell = tableView.cellForRowAtIndexPath(self.selectedIndexPath!) as? PostsTableViewCell
//        cell?.setHeartsDisabled()
//        self.unlikeEntryWithBlock(cell!) { (result, error) -> Void in
//            cell?.setEntryUnliked()
//            cell?.decrementLikeCount()
//            cell?.setHeartsEnabled()
//        }
//    }
    
    func objectAtCell(indexPath: IndexPath?) -> PFObject? {
        let cell = tableView.cellForRow(at: indexPath!) as? PostsTableViewCell
        let object = cell?.entryObject
        return object
    }
    
    func setSelectedIndexPathFromSender(sender: AnyObject) {
        let point = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        self.selectedIndexPath = indexPath
    }
            
    override func tableView(_ tableView: UITableView, cellForNextPageAt indexPath: IndexPath) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostsTableViewCell
        cell?.isHidden = true
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initEmptyState()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 550.0
        
        self.replacePFLoadingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(self.hashtag != nil) {
            self.setUpNavigationBar(title: "#\(self.hashtag!)")
        } else {
            self.setUpMenuBarController(title: "Feed")
        }
        if(self.objects?.count == 0) {
            self.loadObjects()
        }
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage {
        return UIImage(named: "cat_black")!
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0), NSForegroundColorAttributeName: UIColor.darkGray]
        
        return NSAttributedString(string: "No posts", attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString {
        let paragraph: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.lightGray, NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: "You're not following any kittehs yet!", attributes: attributes)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView, forState state: UIControlState) -> NSAttributedString {
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17.0)]
        
        return NSAttributedString(string: "Find some to follow", attributes: attributes)
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView) {
        if self.parent?.parent as? UITabBarController != nil {
//            let tababarController = self.parentViewController?.parentViewController as! MainTabsViewController
//            tababarController.setTabToExplore()
        }
    }
    
    override func queryForTable() -> PFQuery<PFObject> {
        let query = WRTimelineEntry.query()!
        query.order(byDescending: "createdAt")
        query.whereKey("type", equalTo: "image")
        if(self.hashtag != nil) {
            query.whereKey("text", contains: "#\(self.hashtag!)")
        } else if(self.following) {
            let followingQuery = WRFollow.query()!
            followingQuery.whereKey("follower", equalTo: WRUser.current()!)
            
            query.whereKey("animal", matchesKey: "following", in: followingQuery)
        }
        query.includeKey("animal")
        return query
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostsTableViewCell
        
        if cell == nil  {
            cell = PostsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "PostCell")
        }
        
        cell!.setSpacing()
        
        let entry = object as! WRTimelineEntry
        cell!.entryObject = entry
        
//        cell!.largeImageView.kf_showIndicatorWhenLoading = true
        if let imageFile = entry.image {
            cell?.largeImageView.kf_setImage(with: URL(string: imageFile.url!)!)
        } else if let imageUrl = entry.imageUrl {
            cell?.largeImageView.kf_setImage(with: URL(string: imageUrl)!)
        }
        cell!.largeImageView.isUserInteractionEnabled = true
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfilePhotoPFImageViewTaped))
        cell!.profilePhotoPFImageView.addGestureRecognizer(tapRecognizer)
        
//        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
//        doubleTapRecognizer.numberOfTapsRequired = 2
//        tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
//        cell!.largeImageView.addGestureRecognizer(doubleTapRecognizer)
        
        if let date = entry.createdAt {
            let dateR = DateInRegion(absoluteTime: date, region: Region())
            let formatted = dateR.toString(fromDate: DateInRegion(), style: .abbreviated)
            
            cell!.timeLabel.setTitle(formatted, for: .normal)
        }
        
        if let text = entry.text {
            cell!.captionLabel.text = text
            cell!.captionLabel.isHidden = false
            
            self.initActiveLabel(label: cell!.captionLabel)
            cell!.captionLabel.handleHashtagTap { (hashtag: String) -> () in
                if(hashtag != self.hashtag) {
                    self.openHashTagFeed(hashtag: hashtag)
                }
            }
        } else {
            cell!.captionLabel.text = ""
            cell!.captionLabel.isHidden = true
        }
        
//        self.isEntryLikedWithBlock(cell!, completionBlock: { (result, error) -> Void in
//            if(result) {
//                cell!.setEntryLiked()
//            } else {
//                cell!.setEntryUnliked()
//            }
//        })
        
        cell!.commentCount = entry.getCommentCount()
        cell!.likeCount = entry.getLikeCount()
        
        if let animalObject = entry.animal {
            cell!.usernameLink.setTitle(animalObject.username, for: .normal)
            
            if let profilePhotoFile = animalObject.profilePhoto {
                cell!.profilePhotoPFImageView.kf_setImage(with: URL(string: profilePhotoFile.url!)!)
                cell!.profilePhotoPFImageView.makeCircular()
            } else {
                cell!.profilePhotoPFImageView.image = UIImage(named: "animal_profile_photo_empty")
            }
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "PostsToAnimalDetail") {
            let detailScene =  segue.destination as! AnimalDetailViewController
            let entry = self.object(at: self.selectedIndexPath)! as! WRTimelineEntry
            detailScene.currentAnimalObject = entry.animal
        } else if(segue.identifier == "PostsToEntryDetail") {
            let detailScene =  segue.destination as! TimelineEntryDetailViewController
            detailScene.entryObject = self.object(at: self.selectedIndexPath) as? WRTimelineEntry
        }

    }
    
}
