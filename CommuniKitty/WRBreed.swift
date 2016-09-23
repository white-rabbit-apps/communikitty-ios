//
//  WRBreed.swift
//  White Rabbit
//
//  Created by Michael Bina on 6/8/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Parse

class WRBreed: PFObject, PFSubclassing {
    @NSManaged var name: String?
    @NSManaged var otherNames: [String]?
//    @NSManaged var description: String?

    @NSManaged var coat: String?
    @NSManaged var type: String?
    @NSManaged var originCountry: String?
    
    @NSManaged var activity: String?
    @NSManaged var vocalization: String?
    @NSManaged var attentionNeed: String?
    @NSManaged var groomingFrequency: String?
    @NSManaged var sheddingFrequency: String?
    @NSManaged var maxLifeExpectancy: NSNumber?
    @NSManaged var minLifeExpectancy: NSNumber?
    @NSManaged var maxWeightLbs: NSNumber?
    @NSManaged var minWeightLbs: NSNumber?

    @NSManaged var wikipediaUrl: String?
    
    @NSManaged var image: PFFile?

    var hypoallergenic: Bool? {
        get { return self["lapCat"] as? Bool }
        set { self["lapCat"] = newValue }
    }
    
    var lapCat: Bool? {
        get { return self["lapCat"] as? Bool }
        set { self["lapCat"] = newValue }
    }
    
    static func parseClassName() -> String {
        return "Breed"
    }
}