//
//  WRLove.swift
//  White Rabbit
//
//  Created by Alina Chernenko on 7/7/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Parse

class WRLove: PFObject, PFSubclassing {
    @NSManaged var text: String?
    
    static func parseClassName() -> String {
        return "Love"
    }
}
