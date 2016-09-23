//
//  WRProduct.swift
//  White Rabbit
//
//  Created by Michael Bina on 6/12/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Parse

class WRProduct: PFObject, PFSubclassing {
    @NSManaged var name: String?
    @NSManaged var price: NSNumber?
    
    @NSManaged var manufacturerName: String?

    @NSManaged var color: String?
    @NSManaged var size: String?

    @NSManaged var mainPhoto: PFFile?
    
    static func parseClassName() -> String {
        return "Product"
    }
}