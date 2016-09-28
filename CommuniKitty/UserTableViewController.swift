//
//  UserTableViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 12/5/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import ParseUI
import Contacts

class UserViewCell: PFTableViewCell {
    var userObject: WRUser?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePhotoButton: UIButton!
    @IBOutlet weak var usernameButton: UIButton!
}

class UserInviteViewCell: PFTableViewCell {
    var contact : CNContact?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePhotoButton: UIButton!
    
    @IBAction func mailPressed(_ sender: AnyObject) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let email = self.contact?.emailAddresses.first!.value as! String
            
            topController.composeEmail(emailAddress: email, subject: "Check out White Rabbit!", body: "Behold the best kitteh app ever created: http://www.whiterabbitapps.net")
        }
    }
    
    @IBAction func smsPressed(_ sender: AnyObject) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
//            let phoneNumber = self.contact?.phoneNumbers.first!.value as! CNPhoneNumber
//            
//            topController.composeSMS(phoneNumber.stringValue, body: "Check out White Rabbit! http://www.whiterabbitapps.net")
        }
    }
    
    @IBOutlet weak var smsButton: UIButton!
    @IBOutlet weak var mailButton: UIButton!
}

class UserTableViewController: PFQueryTableViewController {
    
    var myContacts : [CNContact]?
    var facebookFriendIds : [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.replacePFLoadingView()

        self.getFacebookFriends()
        
//        self.tableView.rowHeight = UITableViewAutomaticDimension
//        self.tableView.estimatedRowHeight = 160.0
    }
    
    func getContactsEmailsArray() -> [String] {
        var emails = [String]()
        if self.myContacts != nil {
            for contact in self.myContacts! {
                let emailAddresses = contact.emailAddresses
                for addressLabeledValue in emailAddresses {
                    emails.append(addressLabeledValue.value as String)
                }
            }
        }
        return emails
    }
    
    func getFacebookFriends() {
        let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil)
//        fbRequest?.start(completionHandler: { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
//            if error == nil {
//                var resultIds = [String]()
//                let resultVals = result.object(forKey: "data") as! NSArray
//                
//                for result in resultVals {
//                    resultIds.append(result.value(forKey: "id") as! String)
//                }
//                
//                self.facebookFriendIds = resultIds
//                
//                self.loadObjects()
//                self.hideLoader()
//                
//                print("Friends are : \(resultIds)")
//            } else {
//                print("Error Getting Friends \(error)");
//            }
//        })
    }
    
    
    
    func filterInvitableContacts() {
        self.myContacts = self.myContacts?.filter({ (contact: CNContact) -> Bool in
            return (contact.givenName != "") && (contact.emailAddresses.count > 0 || contact.phoneNumbers.count > 0)
        })
        self.myContacts?.sort(by: { $0.givenName.localizedCaseInsensitiveCompare($1.givenName) == ComparisonResult.orderedAscending })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpModalBar(title: "Contacts")
    }
    
    override func objectsWillLoad() {
        super.objectsWillLoad()
        self.showLoader()
    }
    
    override func objectsDidLoad(_ error: Error?) {
        super.objectsDidLoad(error)
        self.hideLoader()
    }
    
    override func queryForTable() -> PFQuery<PFObject> {
        let emailsArray = getContactsEmailsArray()
        let emailQuery = WRUser.query()!
        emailQuery.whereKey("email", containedIn: emailsArray)

        if self.facebookFriendIds != nil {
            let facebookQuery = WRUser.query()!
            facebookQuery.whereKey("facebookId", containedIn: self.facebookFriendIds!)
            
            let query = PFQuery.orQuery(withSubqueries: [emailQuery, facebookQuery])
            query.order(byDescending: "createdAt")

            return query
        } else {
            emailQuery.order(byDescending: "createdAt")
            return emailQuery
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.objects!.count
        case 1:
            if self.myContacts != nil {
                return self.myContacts!.count
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "On CommuniKitty"
        case 1:
            return "Invite to CommuniKitty"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userObject = objectAtCell(indexPath)
        
        if((indexPath as IndexPath).section == 0) {            
            self.openUserProfile(user: userObject, push: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {

        if((indexPath as IndexPath).section == 0) {
            var cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserViewCell
            if cell == nil  {
                cell = UserViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "UserCell")
            }
            
            let user = object as! WRUser
            cell!.userObject = user
            
            let firstName = user.firstName
            let lastName = user.lastName
            cell!.nameLabel.text = "\(firstName!) \(lastName!)"
            
            if let username = user.username {
                cell!.usernameButton.setTitle(username, for: UIControlState())
            }
            
            cell!.profilePhotoButton.setImage(UIImage(named: "human_profile_photo_empty"), for: UIControlState())
            if let profilePhotoFile = user.profilePhoto {
                profilePhotoFile.getDataInBackground(block: {
                    (imageData: Data?, error: Error?) -> Void in
                    if(error == nil) {
                        let image = UIImage(data:imageData!)
                        cell!.profilePhotoButton.setImage(image?.circle, for: UIControlState())
                    }
                })
            }
            
            return cell
        } else {

            var cell = tableView.dequeueReusableCell(withIdentifier: "UserInviteCell", for: indexPath) as? UserInviteViewCell
            if cell == nil  {
                cell = UserInviteViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "UserInviteCell")
            }
            
            if self.myContacts != nil {

                let contact = self.myContacts![(indexPath as IndexPath).row]
                
                cell!.contact = contact
                
                cell!.nameLabel.text = "\(contact.givenName) \(contact.familyName)"
                
                if let image = contact.thumbnailImageData {
                    cell!.profilePhotoButton.setImage(UIImage(data: image)?.circle, for: UIControlState())
                } else {
                    cell!.profilePhotoButton.setImage(UIImage(named: "human_profile_photo_empty"), for: UIControlState())
                }
                
                if(contact.emailAddresses.count > 0) {
                    cell!.mailButton.isHidden = false
                } else {
                    cell!.mailButton.isHidden = true
                }
                
                if(contact.phoneNumbers.count > 0) {
                    cell!.smsButton.isHidden = false
                } else {
                    cell!.smsButton.isHidden = true
                }
            }

            return cell
        }
    }
    
    override func object(at indexPath: IndexPath?) -> WRUser? {
        if((indexPath as IndexPath?)?.section == 0) {
            return super.object(at: indexPath) as? WRUser
        } else {
            return nil
        }
    }
    
    func objectAtCell(_ indexPath: IndexPath?) -> WRUser? {
        if (indexPath as IndexPath?)?.section == 0 {
            let cell = tableView.cellForRow(at: indexPath!) as? UserViewCell
            let object = cell?.userObject
            return object
        } else {
            return nil
        }
    }
    
}
