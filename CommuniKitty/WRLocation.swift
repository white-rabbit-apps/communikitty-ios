//
//  WRLocation.swift
//  White Rabbit
//
//  Created by Michael Bina on 6/8/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Parse

class WRLocation: PFObject, PFSubclassing {
    @NSManaged var name: String?
    @NSManaged var short_name: String?
    @NSManaged var address: String?
    @NSManaged var city: String?
    @NSManaged var state: String?
    @NSManaged var zip: String?

    @NSManaged var phone: String?
    @NSManaged var email: String?
    @NSManaged var website: String?

    @NSManaged var animals: [String]?
    @NSManaged var types: [String]?

    @NSManaged var geo: PFGeoPoint?

    @NSManaged var logo: PFFileObject?
    
    @NSManaged var instagramId: String?
    @NSManaged var instagramPlaceId: String?
    @NSManaged var twitterId: String?
    @NSManaged var pinterestId: String?
    @NSManaged var youtubeUrl: String?
    @NSManaged var facebookPageId: String?
    @NSManaged var yelpBusinessId: String?
    @NSManaged var googlePlaceId: String?
    
    static func parseClassName() -> String {
        return "Location"
    }
}
