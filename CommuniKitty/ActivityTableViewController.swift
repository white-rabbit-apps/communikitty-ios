//
//  TimelineEntryCommentsViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 12/5/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import ParseUI
import ActiveLabel
import SwiftDate

class ActivityViewCell: PFTableViewCell {
    var activityObject: WRActivity?
    
    @IBOutlet weak var activityLabel: ActiveLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var entryPFImage: PFImageView!
    @IBOutlet weak var profilePhotoPFImage: PFImageView!
}

class ActivityTableViewController: PFQueryTableAutoLoadingViewController {
    
    var userObject : WRUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 58
        self.replacePFLoadingView()

        self.initEmptyState()
        
        self.userObject = WRUser.current()!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpModalBar(title: "Cativity")
        
        if(self.objects?.count == 0) {
            self.loadObjects()
        }
    }
    
    func closeView() {
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransition
        transition.subtype = kCATransitionFromTop
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: { _ in })
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage {
        return UIImage(named: "kitteh_faceplant")!
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0), NSForegroundColorAttributeName: UIColor.darkGray]
        
        return NSAttributedString(string: "No cativity yet", attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString {
        let paragraph: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.lightGray, NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: "Follows and Meows will show up here", attributes: attributes)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView, forState state: UIControlState) -> NSAttributedString {
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17.0)]
        
        return NSAttributedString(string: "Get posting!", attributes: attributes)
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView) {
        if self.parent?.parent as? UITabBarController != nil {
//            let tababarController = self.parent?.parent as! MainTabsViewController
//            tababarController.setTabToProfile()
        }
    }
    
    override func queryForTable() -> PFQuery<PFObject> {
        let query = WRActivity.query()!
        query.order(byDescending: "createdAt")
        query.includeKey("actingUser")
        query.includeKey("actingAnimal")
        query.includeKey("animalActedOn")
        query.includeKey("entryActedOn")
        query.includeKey("commentMade")
        query.whereKey("forUser", equalTo: WRUser.current()!)
        return query
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath.row > self.objects!.count - 1 {
            self.loadNextPage()
            return
        }
        
        if let activity = self.object(at: indexPath as IndexPath) as? WRActivity {
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as! ActivityViewCell
            
            let action = activity.actionValue
            if(action == .Follow || action == .Like || action == .Comment) {
                self.entryPhotoPressed(sender: cell.entryPFImage)
            }
        }
    }
    
    @IBAction func profilePhotoButton(gesture: UIGestureRecognizer) {
        
        let button = gesture.view as! PFImageView
        let cell = button.superview!.superview as! ActivityViewCell
        let indexPath = self.tableView.indexPath(for: cell)
        
        let activity = objectAtCell(indexPath: indexPath as IndexPath?) as WRActivity?
        let action = activity!.actionValue
        
        if(action == .Follow || action == .Like || action == .Poke) {
            let actingUser = activity?.actingUser
            
            let userProfile = self.storyboard!.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
            userProfile.currentUser = actingUser
            userProfile.showAsNav = true
            self.navigationController?.pushViewController(userProfile, animated: true)
        } else if(action == .Comment) {
            let actingAnimal = activity!.actingAnimal!
            
            let animalDetail = self.storyboard!.instantiateViewController(withIdentifier: "AnimalDetailView") as! AnimalDetailViewController
            animalDetail.currentAnimalObject = actingAnimal
            
            self.navigationController?.pushViewController(animalDetail, animated: true)
        }
        
    }
    
    @IBAction func entryPhotoPressed(sender: AnyObject) {
        let button = sender as! PFImageView
        let cell = button.superview!.superview as! ActivityViewCell
        let indexPath = self.tableView.indexPath(for: cell)
        
        let activity = objectAtCell(indexPath: indexPath as IndexPath?) as WRActivity?
        let action = activity!.actionValue
        
        if(action == .Follow) {
            let animalActedOn : WRAnimal = activity!.animalActedOn!
            
            let animalDetail = self.storyboard!.instantiateViewController(withIdentifier: "AnimalDetailView") as! AnimalDetailViewController
            animalDetail.currentAnimalObject = animalActedOn
            
            self.navigationController?.pushViewController(animalDetail, animated: true)
        } else if(action == .Like || action == .Comment) {
            let entryActedOn = activity?.entryActedOn
            
            let timelineEntryVC = self.storyboard!.instantiateViewController(withIdentifier: "TimelineEntryDetailView") as! TimelineEntryDetailViewController
            timelineEntryVC.entryObject = entryActedOn
            
            self.navigationController?.pushViewController(timelineEntryVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath as IndexPath) as? ActivityViewCell
        if cell == nil  {
            cell = ActivityViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "CommentCell")
        }

        let activity = object as! WRActivity
        cell!.activityObject = activity
        
        let action = activity.actionValue
        if(action == .Follow) {
            let actingUser = activity.actingUser
            let animalActedOn = activity.animalActedOn
            
            cell!.activityLabel.text = "@\(actingUser!.username!) started following @\(animalActedOn!.username!)"
            
            if let entryImageFile = animalActedOn?.profilePhoto {
                cell!.entryPFImage.file = entryImageFile
                if ((cell!.entryPFImage.file?.isDataAvailable) != nil) {
                    cell!.entryPFImage.loadInBackground()
                }
            }

            cell!.entryPFImage.image = UIImage(named: "blank")

        } else if(action == .Like) {
            let actingUser = activity.actingUser
            let entryActedOn = activity.entryActedOn
            
            var text = ""

            let username = actingUser!.username!
            if let likeAction = LikeAction(rawValue: (activity.likeActionValue?.rawValue)!) {
                switch likeAction {
                case .Meow:
                    text = "@\(username) meowed at your meowment"
                case .HeadBump:
                    text = "@\(username) head bumped your meowment"
                case .Purr:
                    text = "@\(username) purred at your meowment"
                case .Lick:
                    text = "@\(username) licked your meowment"
                case .Hiss:
                    text = "@\(username) hissed at your meowment"
                default:
                    text = "@\(username) liked your meowment"
                }
            } else {
                text = "@\(username) liked your meowment"
            }

            cell!.activityLabel.text = text
            cell!.entryPFImage.image = UIImage(named: "blank")
            if let entryImageFile = entryActedOn?.image {
                cell!.entryPFImage.file = entryImageFile
                if ((cell!.entryPFImage.file?.isDataAvailable) != nil) {
                    cell!.entryPFImage.loadInBackground()
                }
            } else if let entryImageUrl = entryActedOn?.imageUrl {
                URLSession.shared.dataTask(with: NSURL(string: entryImageUrl)! as URL) { (data, response, error) in
                    DispatchQueue.main.async() { () -> Void in
                        guard let data = data , error == nil else { return }
                        let image = UIImage(data: data)
                        cell!.entryPFImage.image = image
                    }
                    }.resume()
            }
        } else if(action == .Poke) {
            let actingUser = activity.actingUser!
            
            var text = ""
            
            let username = actingUser.username!
            if let likeAction = LikeAction(rawValue: (activity.likeActionValue?.rawValue)!) {
                switch likeAction {
                case .Meow:
                    text = "@\(username) meowed at you"
                case .HeadBump:
                    text = "@\(username) head bumped you"
                case .Purr:
                    text = "@\(username) purred at you"
                case .Lick:
                    text = "@\(username) licked you"
                case .Hiss:
                    text = "@\(username) hissed at you"
                default:
                    text = "@\(username) liked you"
                }
            } else {
                text = "@\(username) poked you"
            }
            
            cell!.activityLabel.text = text
            cell!.entryPFImage.image = UIImage(named: "blank")
        } else if(action == .Comment) {
            let actingAnimal = activity.actingAnimal
            let entryActedOn = activity.entryActedOn
            let commentMade = activity.commentMade
            
            cell!.activityLabel.text = "@\(actingAnimal!.username!) commented: \(commentMade!.text!)"
            
            if let entryImageFile = entryActedOn?.image {
                cell!.entryPFImage.file = entryImageFile
                if ((cell!.entryPFImage.file?.isDataAvailable) != nil) {
                    cell!.entryPFImage.loadInBackground()
                }
            } else if let entryImageUrl = entryActedOn?.imageUrl {
                URLSession.shared.dataTask(with: NSURL(string: entryImageUrl)! as URL) { (data, response, error) in
                    DispatchQueue.main.async() { () -> Void in
                        guard let data = data , error == nil else { return }
                        let image = UIImage(data: data)
                        cell!.entryPFImage.image = image
                    }
                    }.resume()
            }
            
        }
        
        self.initActiveLabel(label: cell!.activityLabel)
        
        if let date = activity.createdAt {
            let dateR = DateInRegion(absoluteTime: date, region: Region())
            
            let formatted = dateR.toString(fromDate: DateInRegion(), style: .abbreviated)
            cell!.timeLabel.text = formatted
        }
        
        let profilePhotoTapGesture = UITapGestureRecognizer(target: self, action: #selector(profilePhotoButton))
        cell!.profilePhotoPFImage.addGestureRecognizer(profilePhotoTapGesture)

        if let animalObject = activity.actingAnimal {
            cell!.profilePhotoPFImage.image = UIImage(named: "animal_profile_photo_empty")

            if let profilePhotoFile = animalObject.profilePhoto {
                cell!.profilePhotoPFImage.file = profilePhotoFile
                if ((cell!.profilePhotoPFImage.file?.isDataAvailable) != nil) {
                    cell!.profilePhotoPFImage.load(inBackground: { (image: UIImage?, error: Error?) in
                        cell!.profilePhotoPFImage.image = image?.circle
                    })
                }
            }
        } else if let userObject = activity.actingUser {
            cell!.profilePhotoPFImage.image = UIImage(named: "human_profile_photo_empty")

            if let profilePhotoFile = userObject.profilePhoto {
                profilePhotoFile.getDataInBackground(block: {
                    (imageData: Data?, error: Error?) -> Void in
                    if(error == nil) {
                        let image = UIImage(data:imageData!)
                        cell!.profilePhotoPFImage.image = image?.circle
                    }
                })
            }
        } else {
        }

        return cell
    }
    
    func objectAtCell(indexPath: IndexPath?) -> WRActivity? {
        let cell = tableView.cellForRow(at: indexPath! as IndexPath) as? ActivityViewCell
        let object = cell?.activityObject
        return object
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ActivityToAnimalDetail") {
            let detailScene =  segue.destination as! AnimalDetailViewController
            
            let button = sender as! UIButton
            let view = button.superview!
            let cell = view.superview as! ActivityViewCell
            let indexPath = self.tableView.indexPath(for: cell)
            
            let activityObject = objectAtCell(indexPath: indexPath as IndexPath? as IndexPath?)
            let animalObject = activityObject!.actingAnimal
            
            detailScene.currentAnimalObject = animalObject
        }
    }
    
}
