//
//  DashboardWidgets.swift
//  White Rabbit
//
//  Created by Michael Bina on 8/15/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Foundation

//////
// Widget implementations
//////

class UserAnimalsDashboardWidget : DashboardWidget {
    var user: WRUser?
    var deceased: Bool = false
    var foster: Bool = false
    
    override func loadCellData(_ cell: DashboardWidget) {
        self.parentCell = cell
        
        if(self.deceased){
            cell.titleLabel?.text = "My Memorial"
            cell.titleLabel?.backgroundColor = UIColor.lightPinkColor()
        } else if(self.foster) {
            cell.titleLabel?.text = "My Foster Kitties"
            cell.titleLabel?.backgroundColor = UIColor.lightBlueColor()
        } else if(self.user != nil && self.user != WRUser.current()) {
            cell.titleLabel?.text = "\(self.user!.firstName!)'s Kitties"
            cell.titleLabel?.backgroundColor = UIColor.lightOrangeColor()
        } else {
            cell.titleLabel?.text = "My Kitties"
            cell.titleLabel?.backgroundColor = UIColor.lightOrangeColor()
            
            cell.titleButton?.isHidden = false
            cell.titleButton?.removeTarget(self.parentTableView, action: #selector(UIViewController.openExplore), for: .touchUpInside)
            cell.titleButton?.addTarget(self.parentTableView, action: #selector(UIViewController.showAddAnimalForm), for: .touchUpInside)
            
            cell.emptyStateButton?.setImage(UIImage(named: "empty_state_mine"), for: UIControlState())
            cell.emptyStateButton?.removeTarget(self.parentTableView, action: #selector(UIViewController.openExplore), for: .touchUpInside)
            cell.emptyStateButton?.addTarget(self.parentTableView, action: #selector(UIViewController.showAddAnimalForm), for: .touchUpInside)
        }
        
        cell.collectionType = .Animals
        cell.rowContent = .User
        
        cell.sourceArray = self.sourceArray
    }
    
    override func getQuery() -> PFQuery<PFObject> {
        let query = WRAnimal.query()!
        query.order(byDescending: "createdAt")
        var owner = "owners"
        if(self.foster) {
            owner = "fosters"
        }
        
        if(self.user != nil) {
            query.whereKey(owner, equalTo: self.user!)
        } else if(WRUser.current() != nil) {
            query.whereKey(owner, equalTo: WRUser.current()!)
        }
        if(!self.deceased) {
            query.whereKeyDoesNotExist("deceasedDate")
        } else {
            query.whereKeyExists("deceasedDate")
        }
        
        return query
    }
}

class MyAnimalsDashboardWidget : UserAnimalsDashboardWidget {
    override var requiresLogin: Bool { return true }
    
}

class ShelterAnimalsDashboardWidget : DashboardWidget {
    var shelter: WRLocation?
    
    override func loadCellData(_ cell: DashboardWidget) {
        self.parentCell = cell
        
        if(self.shelter != nil) {
            try! self.shelter?.fetchIfNeeded()
            cell.titleLabel?.text = "\(self.shelter!.name!)'s Kitties"
            cell.titleLabel?.backgroundColor = UIColor.lightGreenColor()
        }
        
        cell.titleButton?.isHidden = true
        
        cell.collectionType = .Animals
        cell.rowContent = .Shelter
        
        cell.sourceArray = self.sourceArray
    }
    
    override func getQuery() -> PFQuery<PFObject> {
        let query = WRAnimal.query()!
        query.order(byDescending: "createdAt")
        if(self.shelter != nil) {
            query.whereKey("shelter", equalTo: self.shelter!)
        }
        return query
    }
}


class UserPhotosDashboardWidget : DashboardWidget {
    var user: WRUser?
    
    override func loadCellData(_ cell: DashboardWidget) {
        self.parentCell = cell
        
        if(self.user != nil) {
            cell.titleLabel?.text = "\(self.user!.firstName!)'s Photos"
            cell.titleLabel?.backgroundColor = UIColor.lightBlueColor()

            cell.titleButton?.isHidden = true
        } else {
            cell.titleLabel?.text = "My Photos"
            cell.titleLabel?.backgroundColor = UIColor.lightBlueColor()
            
            cell.emptyStateButton?.setImage(UIImage(named: "empty_state_following"), for: UIControlState())
            cell.emptyStateButton?.removeTarget(self.parentTableView, action: #selector(UIViewController.showAddAnimalForm), for: .touchUpInside)
            cell.emptyStateButton?.addTarget(self.parentTableView, action: #selector(UIViewController.openExplore), for: .touchUpInside)
        }
        
        cell.collectionType = .Photos
        cell.rowContent = .User
        
        cell.sourceArray = self.sourceArray
    }
    
    override func getQuery() -> PFQuery<PFObject> {
        let query = WRTimelineEntry.query()!
        query.order(byDescending: "createdAt")
        query.whereKey("type", equalTo: "image")
        if(self.user != nil) {
            query.whereKey("createdBy", equalTo: self.user!)
        } else {
            query.whereKey("createdBy", equalTo: WRUser.current()!)
        }
        query.includeKey("animal")
        
        return query
    }
}

class PopularAnimalsDashboardWidget : DashboardWidget {
    var includeFeatured = false
    
    override func loadCellData(_ cell: DashboardWidget) {
        self.parentCell = cell
        
        cell.titleLabel?.text = "Popular Kitties"
        cell.titleLabel?.backgroundColor = UIColor.lightOrangeColor()
        
        cell.collectionType = .Animals
        cell.rowContent = .Popular
        
        cell.titleButton?.isHidden = true
        
        cell.sourceArray = self.sourceArray
    }
    
    override func getQuery() -> PFQuery<PFObject> {
        let query = WRAnimal.query()!
        query.order(byDescending: "followerCount")
        
        if(!includeFeatured) {
            query.whereKey("featured", equalTo: false)
        }
        
        return query
    }
}


class FeaturedAnimalsDashboardWidget : DashboardWidget {
    
    override func loadCellData(_ cell: DashboardWidget) {
        self.parentCell = cell
        
        cell.titleLabel?.text = "Featured Kitties"
        cell.titleLabel?.backgroundColor = UIColor.lightRedColor()
        
        cell.collectionType = .Animals
        cell.rowContent = .Featured
        
        cell.titleButton?.isHidden = true
        
        cell.sourceArray = self.sourceArray
    }
    
    override func getQuery() -> PFQuery<PFObject> {
        let query = WRAnimal.query()!
        query.whereKey("featured", equalTo: true)
        
        return query
    }
}

class HashtagPhotosDashboardWidget : DashboardWidget {
    var hashtag: String?
    
    init(hashtag: String) {
        super.init(style: .default, reuseIdentifier: "hashtag")
        self.hashtag = hashtag
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadCellData(_ cell: DashboardWidget) {
        self.parentCell = cell
        
        if let hashtag = self.hashtag {
            cell.titleLabel?.text = "#\(hashtag)"
        }
        cell.titleLabel?.backgroundColor = UIColor.lightGreenColor()
        
        cell.collectionType = .Photos
        cell.rowContent = .Popular
        
        cell.titleButton?.isHidden = true
        
        cell.sourceArray = self.sourceArray
    }
    
    override func getQuery() -> PFQuery<PFObject> {
        let query = WRTimelineEntry.query()!
        query.order(byDescending: "createdAt")
        query.whereKey("type", equalTo: "image")
        query.whereKey("text", contains: "#\(self.hashtag!)")
        
        query.includeKey("animal")
        
        return query
    }
}

class PopularPhotosDashboardWidget : DashboardWidget {
    
    override func loadCellData(_ cell: DashboardWidget) {
        self.parentCell = cell
        
        cell.titleLabel?.text = "Popular Photos"
        cell.titleLabel?.backgroundColor = UIColor.lightGreenColor()
        
        cell.collectionType = .Photos
        cell.rowContent = .Featured
        
        cell.titleButton?.isHidden = true
        
        cell.sourceArray = self.sourceArray
    }
    
    override func getQuery() -> PFQuery<PFObject> {
        let query = WRTimelineEntry.query()!
        query.order(byDescending: "likeCount")
        query.whereKey("type", equalTo: "image")
        
        query.includeKey("animal")
        
        return query
    }
}

class MostCommentedOnPhotosDashboardWidget : DashboardWidget {
    
    override func loadCellData(_ cell: DashboardWidget) {
        self.parentCell = cell
        
        cell.titleLabel?.text = "Most Commented On"
        cell.titleLabel?.backgroundColor = UIColor.lightYellowColor()
        
        cell.collectionType = .Photos
        cell.rowContent = .MostCommentedOn
        
        cell.titleButton?.isHidden = true
        
        cell.sourceArray = self.sourceArray
    }
    
    override func getQuery() -> PFQuery<PFObject> {
        let query = WRTimelineEntry.query()!
        query.order(byDescending: "commentCount")
        query.whereKey("type", equalTo: "image")
        
        query.includeKey("animal")
        
        return query
    }
}


class FeaturedPhotosDashboardWidget : DashboardWidget {
    
    override func loadCellData(_ cell: DashboardWidget) {
        self.parentCell = cell
        
        cell.titleLabel?.text = "Featured Meowments"
        cell.titleLabel?.backgroundColor = UIColor.lightRedColor()
        
        cell.collectionType = .Photos
        cell.rowContent = .Featured
        
        cell.titleButton?.isHidden = true
        
        cell.sourceArray = self.sourceArray
    }
    
    override func getQuery() -> PFQuery<PFObject> {
        let query = WRTimelineEntry.query()!
        query.order(byDescending: "date")
        query.whereKey("type", equalTo: "image")
        
        let animalQuery = WRAnimal.query()!
        animalQuery.whereKey("featured", equalTo: true)
        
        query.whereKey("animal", matchesQuery: animalQuery)
        
        query.includeKey("animal")
        
        return query
    }
}


class FollowingPhotosDashboardWidget : DashboardWidget {
    override var requiresLogin: Bool { return true }
    
    override func loadCellData(_ cell: DashboardWidget) {
        self.parentCell = cell
        
        cell.titleLabel?.text = "Followed Meowments"
        cell.titleLabel?.backgroundColor = UIColor(red:0.35, green:0.50, blue:0.57, alpha:1.00)
        
        cell.collectionType = .Photos
        cell.rowContent = .Following
        
        cell.titleButton?.isHidden = false
        cell.titleButton?.setImage(UIImage(named: "button_search"), for: UIControlState())
        cell.titleButton?.removeTarget(self.parentTableView, action: #selector(UIViewController.showAddAnimalForm), for: .touchUpInside)
        cell.titleButton?.addTarget(self.parentTableView, action: #selector(UIViewController.openExplore), for: .touchUpInside)
        
        cell.emptyStateButton?.setImage(UIImage(named: "empty_state_following"), for: UIControlState())
        cell.emptyStateButton?.removeTarget(self.parentTableView, action: #selector(UIViewController.showAddAnimalForm), for: .touchUpInside)
        cell.emptyStateButton?.addTarget(self.parentTableView, action: #selector(UIViewController.openExplore), for: .touchUpInside)
        
        cell.sourceArray = self.sourceArray
    }
    
    override func getQuery() -> PFQuery<PFObject> {
        let query = WRTimelineEntry.query()!
        query.order(byDescending: "date")
        query.whereKey("type", equalTo: "image")
        
        let followingQuery = WRFollow.query()!
        followingQuery.whereKey("follower", equalTo: WRUser.current()!)
        
        query.whereKey("animal", matchesKey: "following", in: followingQuery)
        
        query.includeKey("animal")
        
        return query
    }
}
