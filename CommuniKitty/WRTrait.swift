//
//  WRTrait.swift
//  White Rabbit
//
//  Created by Michael Bina on 6/12/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Parse

class WRTrait: PFObject, PFSubclassing {
    @NSManaged var name: String?
    
    static func parseClassName() -> String {
        return "Trait"
    }
}