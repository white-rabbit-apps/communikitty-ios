//
//  WRFollow.swift
//  White Rabbit
//
//  Created by Michael Bina on 6/12/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Parse

class WRFollow: PFObject, PFSubclassing {
    @NSManaged var follower: WRUser?
    @NSManaged var following: WRAnimal?
    
    static func parseClassName() -> String {
        return "Follow"
    }
}