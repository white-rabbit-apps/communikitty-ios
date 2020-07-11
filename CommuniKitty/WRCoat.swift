//
//  WRCoat.swift
//  White Rabbit
//
//  Created by Michael Bina on 6/11/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Parse

class WRCoat: PFObject, PFSubclassing {
    @NSManaged var name: String?
    @NSManaged var type: String?

    @NSManaged var groupOrder: NSNumber?
    
    @NSManaged var image: PFFileObject?
    
    static func parseClassName() -> String {
        return "Coat"
    }
}
