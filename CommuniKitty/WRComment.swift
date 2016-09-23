//
//  WRComment.swift
//  White Rabbit
//
//  Created by Michael Bina on 6/11/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Parse

class WRComment: PFObject, PFSubclassing {

    @NSManaged var animal: WRAnimal?
    @NSManaged var entry: WRTimelineEntry?

    @NSManaged var text: String?
    @NSManaged var gifName: String?
    
    static func parseClassName() -> String {
        return "Comment"
    }
}