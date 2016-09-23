//
//  WRFlag.swift
//  White Rabbit
//
//  Created by Michael Bina on 6/12/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Parse

enum FlagType:String {
    case Inappropriate = "inappropriate"
    case Spam = "spam"
}

class WRFlag: PFObject, PFSubclassing {
    
    @NSManaged var reportedBy: WRUser!
    @NSManaged var entry: WRTimelineEntry?
    @NSManaged var comment: WRComment?
    
    @NSManaged fileprivate var type: String!
    var typeValue: FlagType? {
        get {
            return FlagType(rawValue: self.type!)!
        }
        set {
            self.type = newValue!.rawValue
        }
    }
    static func parseClassName() -> String {
        return "Flag"
    }
}
