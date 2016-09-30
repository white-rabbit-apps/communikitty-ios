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
    
    /**
     Have the current user meow at this this entry
     
     - Parameters:
     - type: LikeAction enum value of which type of action
     - completionBlock: Block of code to run after like is saved
     */
    func pokeWithBlock(_ type: LikeAction, completionBlock: @escaping (_ result: Bool, _ error: Error?) -> Void) {
        let like = WRLike()
        like.userActedOn = self
        like.actionValue = type
        like.actingUser = WRUser.current()!
        like.saveInBackground { (success: Bool, error: Error?) -> Void in
            completionBlock(success, error)
        }
    }
}
