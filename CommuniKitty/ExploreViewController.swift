//
//  ExploreViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 12/2/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import Contacts


class ExploreViewController: UIViewController {
    
    var showAsNav : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(self.showAsNav) {
            self.setUpNavigationBar(title: "Prowl")
        } else {
            self.setUpModalBar(title: "Prowl")
        }
            
        self.navigationItem.rightBarButtonItem = self.getNavBarItem(imageId: "button_contacts", action: #selector(ExploreViewController.getContacts), height: 25, width: 25)

        self.view.setNeedsUpdateConstraints()
    }
    
    func getContacts() {
        self.showLoader()
        
        requestForContactsAccess(completionHandler: { (accessGranted) -> Void in
            if accessGranted {
                // Fetch contacts from address book
                let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactThumbnailImageDataKey, CNContactPhoneNumbersKey]
                let containerId = CNContactStore().defaultContainerIdentifier()
                let predicate: NSPredicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
                
                do {
                    let myContacts = try CNContactStore().unifiedContacts(matching: predicate, keysToFetch: keysToFetch as [CNKeyDescriptor])
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.showUsersView(myContacts)
                    })
                } catch _ {
                    self.showError(message: "Error retrieving contacts")
                }
            }
            }) { (authorizationStatus) -> Void in
                if authorizationStatus == .notDetermined || authorizationStatus == .denied {
                    DispatchQueue.main.async(execute: { () -> Void in
                        let message = "Please allow the app to access your contacts through the Settings app."
                        self.hideLoader()
                        self.showError(message: message)
                    })
                }
        }
    }
    
    func showUsersView() {
        let usersViewController = self.storyboard?.instantiateViewController(withIdentifier: "UsersNav") as! UINavigationController
        
        self.present(usersViewController, animated: true) { () -> Void in
            self.hideLoader()
        }
    }
    
    func showUsersView(_ contacts: [CNContact]) {
        let usersViewController = self.storyboard?.instantiateViewController(withIdentifier: "UsersNav") as! UINavigationController
        
        let userTable = usersViewController.topViewController as! UserTableViewController
        userTable.myContacts = contacts
        userTable.filterInvitableContacts()
        
        self.present(usersViewController, animated: true) { () -> Void in
            self.hideLoader()
        }
    }
    
    func showSearch() {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dashboard = segue.destination as? DashboardTableViewController
            , segue.identifier == "DashboardTableEmbed" {
            
            let prowlWidgets = [FeaturedAnimalsDashboardWidget(), PopularAnimalsDashboardWidget(), PopularPhotosDashboardWidget(), MostCommentedOnPhotosDashboardWidget()]
            
            dashboard.widgets = prowlWidgets
            dashboard.parentView = self
        }
    }
}
