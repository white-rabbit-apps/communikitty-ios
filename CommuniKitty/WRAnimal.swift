//
//  Animal.swift
//  White Rabbit
//
//  Created by Michael Bina on 6/8/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Parse

class WRAnimal: PFObject, PFSubclassing {
    @NSManaged var owners: [WRUser]?
    @NSManaged var fosters: [WRUser]?
    
    @NSManaged var name: String?
    @NSManaged var username: String?
    @NSManaged var gender: String?
    @NSManaged var intro: String?
    
    @NSManaged var breed: WRBreed?
    @NSManaged var coat: WRCoat?
    
    @NSManaged var birthDate: Date?
    @NSManaged var deceasedDate: Date?
    
    @NSManaged var coverPhoto: PFFileObject?
    @NSManaged var profilePhoto: PFFileObject?

    var shelter: WRLocation?

    @NSManaged var loves: [String]?
    @NSManaged var hates: [String]?

    @NSManaged var traits: [WRTrait]?
    
    @NSManaged var instagramUsername: String?
    @NSManaged var twitterUsername: String?
    @NSManaged var youtubeUsername: String?
    @NSManaged var facebookPageId: String?
    
    var featured: Bool {
        get { return self["featured"] != nil ? self["featured"] as! Bool : false }
        set { self["featured"] = newValue }
    }

    var adoptable: Bool {
        get { return self["adoptable"] != nil ? self["adoptable"] as! Bool : false }
        set { self["adoptable"] = newValue }
    }

    
    static func parseClassName() -> String {
        return "Animal"
    }
    
    internal func fetchProfilePhoto(_ completion: @escaping (_ error: Error?, _ image: UIImage?) -> Void) {
        if let image = self.profilePhoto {
            image.getDataInBackground(block: {
                (imageData: Data?, error: Error?) -> Void in
                if(imageData != nil) {
                    if let image = UIImage(data:imageData!) {
                        completion(nil, image)
                    } else if let error = error {
                        completion(error, nil)
                    }
                } else {
                    completion(nil, UIImage(named: "animal_profile_photo_empty"))
                }
            })
        } else {
            completion(nil, nil)
        }
    }
}
