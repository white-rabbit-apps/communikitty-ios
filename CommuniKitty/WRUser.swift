//
//  WRUser.swift
//  White Rabbit
//
//  Created by Michael Bina on 6/12/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Parse

class WRUser: PFUser {
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var profilePhoto: PFFile?

    @NSManaged var facebookId: String?

    @NSManaged var shelter: WRLocation?

    var admin: Bool {
        get { return self["admin"] != nil ? self["admin"] as! Bool : false }
        set { self["admin"] = newValue }
    }
    
    override static func current() -> WRUser? {
        return PFUser.current() as? WRUser
    }
}
