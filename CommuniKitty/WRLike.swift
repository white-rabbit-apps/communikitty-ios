//
//  WRLike.swift
//  White Rabbit
//
//  Created by Michael Bina on 6/12/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Parse

class WRLike: PFObject, PFSubclassing {

    @NSManaged var actingUser: WRUser?
    @NSManaged var userActedOn: WRUser?
    @NSManaged var entry: WRTimelineEntry?
    
    @NSManaged fileprivate var action: String?
    var actionValue: LikeAction? {
        get {
            return self.action != nil ? LikeAction(rawValue: self.action!)! : nil
        }
        set {
            self.action = newValue!.rawValue
        }
    }
    
    static func parseClassName() -> String {
        return "Like"
    }
}
