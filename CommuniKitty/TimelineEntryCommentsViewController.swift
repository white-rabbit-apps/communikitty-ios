//
//  TimelineEntryCommentsViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 12/5/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import ParseUI
import ActiveLabel
import BGTableViewRowActionWithImage
import Device

class TimelineEntryCommentViewCell: PFTableViewCell {
    var commentObject: WRComment?
    
    @IBOutlet weak var commentLabel: ActiveLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profilePhotoButton: UIButton!
    @IBOutlet weak var usernameButton: UIButton!
    
}

class TimelineEntryCommentGifViewCell: PFTableViewCell {
    var commentObject: WRComment?
    
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profilePhotoButton: UIButton!
    @IBOutlet weak var usernameButton: UIButton!
}

class TimelineEntryCommentsViewController: PFQueryTableViewController {
    
    var entryObject : WRTimelineEntry?
    var isLoadFirstTime = false
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var commentLabel: ActiveLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profilePhotoButton: UIButton!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var headerImageView: UIImageView!
    
    @IBOutlet weak var commentLabelBottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.replacePFLoadingView()
        
        isLoadFirstTime = true
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 160.0
        
        headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 440)
        self.tableView.tableHeaderView = headerView
        self.loadHeaderViewCellData()
    }
    
    
    
    func loadHeaderViewCellData() {
        self.commentLabel.text = entryObject?.text
        
        // 67 is the sum of profileButton width(40) 
        // and trailing/leading spacing(11 for profileButton and 2*8 for label).
        let width = UIScreen.main.bounds.width - 67
        let labelHeight =  (entryObject?.text?.heightWithConstrainedWidth(width: width, font: UIFont(name: "HelveticaNeue", size: 17)!))
        
//        self.headerImageView.kf_showIndicatorWhenLoading = true
        if let imageFile = entryObject?.image {
            self.headerImageView.kf_setImage(with: URL(string: imageFile.url!)!, placeholder: nil, options: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            })
        } else if let imageUrl = entryObject?.imageUrl {
            self.headerImageView.kf_setImage(with: URL(string: imageUrl)!, placeholder: nil, options: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            })
        }
        
        if let date = entryObject?.createdAt {
            let formatted = DateFormatter().timeSince(from: date, numericDates: true)
            self.timeLabel.text = formatted
        }
        
        let animalObject = entryObject?.animal
        animalObject?.fetchIfNeededInBackground(block: { (result: PFObject?, error: Error?) -> Void in
            self.usernameButton.setTitle(animalObject!.username, for: .normal)
            
            if let profilePhotoFile = animalObject!.profilePhoto {
                profilePhotoFile.getDataInBackground(block: {
                    (imageData: Data?, error: Error?) -> Void in
                    if(error == nil) {
                        let image = UIImage(data:imageData!)
                        self.profilePhotoButton.setImage(image?.circle, for: .normal)
                    }
                })
            } else {
                self.profilePhotoButton.setImage(UIImage(named: "animal_profile_photo_empty"), for: .normal)
            }
        })
        //updating headerView height depending on the label height
        switch Device.size() {
        case .Screen4_7Inch:
            if labelHeight != nil {
                headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 420 + labelHeight!)
            }
        case .Screen5_5Inch:
            if labelHeight != nil{
                headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 440 + labelHeight!)
            } else {
                headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 460)
            }
        default:
            if labelHeight != nil{
                headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 420 + labelHeight!)
            }
        }
    }
    
    
    
    @IBAction func tapHeaderViewUsername(sender: AnyObject) {
        self.performSegue(withIdentifier: "TimelineEntryDetailToAnimalDetail", sender: self)
    }
    
    override func queryForTable() -> PFQuery<PFObject> {
        let query = WRComment.query()!
        
        query.order(byAscending: "createdAt")
        query.includeKey("entry")
        query.includeKey("animal")
        if(self.entryObject != nil) {
            query.whereKey("entry", equalTo: entryObject!)
        }
        return query
    }
    
    func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        if isLoadFirstTime == false {
            let index = self.tableView.numberOfRows(inSection: 0)
            if index > 0 {
                let indextPath = IndexPath(row: index-1, section: 0)
                self.tableView.scrollToRow(at: indextPath, at: .bottom, animated: true)
            } else {
                let indextPath = IndexPath(row: 0, section: 0)
                self.tableView.scrollToRow(at: indextPath, at: .bottom, animated: true)
            }
        }
        isLoadFirstTime = false
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let cell = tableView.cellForRow(at: indexPath as IndexPath) as? TimelineEntryCommentViewCell
        
        let animal = entryObject!.animal
        let owners = animal?.owners
        let fosters = animal?.fosters
        let comment = cell!.commentObject
        let commenter = comment!.animal
        let commenterUsername = commenter!.username
        
        var currentUserIsOwner = false
        var currentUserIsCommenter = false
        
        // Find out if the logged in user is the owner of the animal that the entry is for
        for owner in owners! {
            if (!currentUserIsOwner) {
                currentUserIsOwner = (WRUser.current()?.objectId == owner.objectId)
            }
        }
        for foster in fosters! {
            if (!currentUserIsOwner) {
                currentUserIsOwner = (WRUser.current()?.objectId == foster.objectId)
            }
        }
        
        // Find out if the logged in user is an owner of the animal who made the comment
        for animalName in AppDelegate.getAppDelegate().myAnimalsArray! {
            if animalName.lowercased() == commenterUsername {
                currentUserIsCommenter = true
                break
            } else {
                currentUserIsCommenter = false
            }
        }
        
        let removeRowAction = BGTableViewRowActionWithImage.rowAction(with: .normal, title: "Remove", titleColor: UIColor.black, backgroundColor: UIColor.white, image: UIImage(named: "button_delete")!, forCellHeight: UInt((cell?.frame.height)!)) { action, index in
            self.removeComment(indexPath: indexPath as IndexPath)
        }
        
        let flagRowAction = BGTableViewRowActionWithImage.rowAction(with: .normal, title: "Flag", titleColor: UIColor.black, backgroundColor: UIColor.white, image: UIImage(named: "button_flag")!, forCellHeight: UInt((cell?.frame.height)!)) { action, index in
//            self.showFlagActionSheet(entryCell: nil, flaggedObject: self.objectAtCell(indexPath: indexPath as IndexPath)!)
            self.tableView.setEditing(false, animated: true)
        }
        
        if(currentUserIsCommenter) {
            return [removeRowAction!]
        } else if(currentUserIsOwner) {
            return [removeRowAction!, flagRowAction!]
        } else {
            return [flagRowAction!]
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        
        let comment = object as? WRComment
        
        if let gifName = comment?.gifName {
            var cell: TimelineEntryCommentGifViewCell? = tableView.dequeueReusableCell(withIdentifier: "CommentGifCell", for: indexPath as IndexPath) as? TimelineEntryCommentGifViewCell
            if cell == nil  {
                cell = TimelineEntryCommentGifViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "CommentGifCell")
            }
            
            cell!.commentObject = comment
            
//            cell!.gifImageView.image = UIImage.gifWithName(name: "gif/\(gifName)")
            
            if let date = comment?.createdAt {
                let formatted = DateFormatter().timeSince(from: date, numericDates: true)
                cell!.timeLabel.text = formatted
            }
            
            let animalObject = comment?.animal
            cell!.usernameButton.setTitle(animalObject!.username, for: .normal)
            
            if let profilePhotoFile = animalObject!.profilePhoto {
                profilePhotoFile.getDataInBackground(block: {
                    (imageData: Data?, error: Error?) -> Void in
                    if(error == nil) {
                        let image = UIImage(data:imageData!)
                        cell!.profilePhotoButton.setImage(image?.circle, for: .normal)
                    }
                })
            }
            
            return cell
        } else {
            var cell: TimelineEntryCommentViewCell? = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath as IndexPath) as? TimelineEntryCommentViewCell
            
            if cell == nil  {
                cell = TimelineEntryCommentViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "CommentCell")
            }
            
            cell!.commentObject = comment
            cell!.commentLabel.text = comment?.text
            
            self.initActiveLabel(label: cell!.commentLabel)
            
            if let date = comment?.createdAt {
                let formatted = DateFormatter().timeSince(from: date, numericDates: true)
                cell!.timeLabel.text = formatted
            }
            
            let animalObject = comment?.animal
            cell!.usernameButton.setTitle(animalObject!.username, for: .normal)
            
            if let profilePhotoFile = animalObject!.profilePhoto {
                profilePhotoFile.getDataInBackground(block: {
                    (imageData: Data?, error: Error?) -> Void in
                    if(error == nil) {
                        let image = UIImage(data:imageData!)
                        cell!.profilePhotoButton.setImage(image?.circle, for: .normal)
                    }
                })
            }
            
            return cell
        }
    }
    
    func removeComment(indexPath: IndexPath) {
        let comment = objectAtCell(indexPath: indexPath)
        comment?.deleteInBackground(block: { (success: Bool, error: Error?) -> Void in
            if(error == nil) {
                self.tableView.setEditing(false, animated: true)
                self.loadObjects()
            } else {
                self.showError(message: error!.localizedDescription)
            }
        })
    }
    
    func objectAtCell(indexPath: IndexPath?) -> WRComment? {
        let cell = tableView.cellForRow(at: indexPath! as IndexPath) as? TimelineEntryCommentViewCell
        let object = cell?.commentObject
        return object
    }
    
    @IBAction func usernameTapped(sender: AnyObject) {
        self.performSegue(withIdentifier: "CommentToAnimalDetail", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "CommentToAnimalDetail") {
            let detailScene =  segue.destination as! AnimalDetailViewController
            
            let button = sender as! UIButton
            let view = button.superview!
            let cell = view.superview as! TimelineEntryCommentViewCell
            let indexPath = self.tableView.indexPath(for: cell)
            
            let commentObject = objectAtCell(indexPath: indexPath as IndexPath?)
            let animalObject = commentObject!.animal
            
            detailScene.currentAnimalObject = animalObject
        } else if(segue.identifier == "TimelineEntryDetailToAnimalDetail") {
            let detailView = segue.destination as! AnimalDetailViewController
            
            let animalObject = self.entryObject?.animal
            detailView.currentAnimalObject = animalObject
        }
    }
}


extension String {
    
    /**
     Function to get the string height with defined width and font
     
     - Parameters:
     - width: CGFloat.
     - font: UIFont.
     
     - returns: CGFloat
     */
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}
