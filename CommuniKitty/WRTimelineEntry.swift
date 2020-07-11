//
//  WRTimelineEntry.swift
//  White Rabbit
//
//  Created by Michael Bina on 6/10/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Parse

class WRTimelineEntry: PFObject, PFSubclassing {
    
    @NSManaged var animal: WRAnimal?

    @NSManaged var createdBy: WRUser?
    @NSManaged var actingUser: WRUser?
    
    @NSManaged var image: PFFileObject?
    @NSManaged var video: PFFileObject?
    @NSManaged var imageUrl: String?
    
    @NSManaged var type: String?
    @NSManaged var text: String?

    @NSManaged var likeCount: NSNumber?
    
    @NSManaged var commentCount: NSNumber?
    
    @NSManaged var date: Date?

    @NSManaged var instagramId: String?

    @NSManaged var location: WRLocation?
    
    open var currentUserLikeEntry: WRLike?
    
//    @NSManaged var shareToFacebook: Bool?
//    @NSManaged var shareToTwitter: Bool?
    
    internal func getCommentCount() -> Int {
        return (self.commentCount != nil ? self.commentCount!.intValue : 0)
    }

    internal func getLikeCount() -> Int {
        return (self.likeCount != nil ? self.likeCount!.intValue : 0)
    }
    
    /**
     Have the current user like this entry
     
     - Parameters:
     - type: LikeAction enum value of which type of action
     - completionBlock: Block of code to run after like is saved
     */
    func likeWithBlock(_ type: LikeAction, completionBlock: @escaping (_ likeObject: WRLike?, _ error: Error?) -> Void) {
        let like = WRLike()
        like.entry = self
        like.actionValue = type
        like.actingUser = WRUser.current()!
        like.saveInBackground { (success: Bool, error: Error?) -> Void in
            self.currentUserLikeEntry = like
            completionBlock(like, error)
        }
    }
    
    /**
     Have the current user unlike this entry
     
     - Parameters:
     - completionBlock: Block of code to run after like is removed
     */
    func unlikeWithBlock(_ completionBlock: @escaping (_ result: Bool, _ error: Error?) -> Void) {
        if let likeObject = self.currentUserLikeEntry {
            likeObject.deleteInBackground(block: { (success: Bool, error: Error?) -> Void in
                self.currentUserLikeEntry = nil
                completionBlock(success, error)
            })
        } else {
            self.isLikedWithBlock({ (result, error) in
                self.unlikeWithBlock(completionBlock)
            })
        }
    }
    
    /**
     Check if the current user has liked this entry
     
     - Parameters:
     - completionBlock: Block of code to run after like is found
     */
    func isLikedWithBlock(_ completionBlock: @escaping (_ likeObject: WRLike?, _ error: Error?) -> Void) {
        let query = WRLike.query()!
        query.whereKey("actingUser", equalTo: WRUser.current()!)
        query.whereKey("entry", equalTo: self)
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if(error == nil) {
                if(objects!.count > 0) {
                    self.currentUserLikeEntry = objects![0] as? WRLike
                }
                completionBlock(self.currentUserLikeEntry, error)
            }
        }
    }
    
    internal func isImage() -> Bool {
        return (self.type == "image")
    }

    internal func isLocalImage() -> Bool {
        return (self.type == "image" && self.image != nil)
    }
    
    internal func isRemoteImage() -> Bool {
        return (self.type == "image" && self.imageUrl != nil)
    }
    
    internal func isInstagramImage() -> Bool {
        return (self.type == "image" && self.instagramId != nil)
    }
    
    internal func isVideo() -> Bool {
        return (self.type == "video")
    }
    
    internal func isOwnedBy(_ user: WRUser) -> Bool {
        try! self.animal?.fetchIfNeeded()
        
        let owners = self.animal?.owners
        for owner in owners! {
            if user.objectId == owner.objectId {
                return true
            }
        }
        return false
    }
    
    internal func getImageUrl() -> String? {
        if let imageFile = self.image {
            return imageFile.url!
        } else if let imageUrl = self.imageUrl {
            return imageUrl
        }
        return nil
    }
    
    internal func fetchImage(_ completion: @escaping (_ error: Error?, _ image: UIImage?) -> Void) {
        if let image = self.image {
            image.getDataInBackground(block: {
                (imageData: Data?, error: Error?) -> Void in
                if let image = UIImage(data:imageData!) {
                    completion(nil, image)
                } else if let error = error {
                    completion(error, nil)
                }
            })
        } else if let imageUrl = self.imageUrl {
            URLSession.shared.dataTask(with: URL(string: imageUrl)!, completionHandler: { (data, response, error) in
                DispatchQueue.main.async { () -> Void in
                    guard let imageData = data , error == nil else { return }
                    if let image = UIImage(data:imageData) {
                        completion(nil, image)
                    } else if let error = error {
                        completion(error as Error?, nil)
                    }
                }
                }) .resume()
        } else {
            completion(nil, nil)
        }
    }

    
    
    static func parseClassName() -> String {
        return "AnimalTimelineEntry"
    }
}
