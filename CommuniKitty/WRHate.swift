//
//  WRHate.swift
//  White Rabbit
//
//  Created by Michael Bina on 7/7/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Foundation

class WRHate: PFObject, PFSubclassing {
    @NSManaged var text: String?
    
    static func parseClassName() -> String {
        return "Hate"
    }
}