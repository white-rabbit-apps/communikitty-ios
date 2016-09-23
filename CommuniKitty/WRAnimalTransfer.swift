//
//  WRTransfer.swift
//  White Rabbit
//
//  Created by Michael Bina on 6/11/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Parse

enum TransferType:String {
    case Foster = "Foster"
    case CoOwner = "Co-Owner"
    case Adopter = "Adopter"
}

enum TransferStatus:String {
    case Accepted = "accepted"
    case Unaccepted = "unaccepted"
    case Rejected = "rejected"
    case Error = "error"
}

class WRAnimalTransfer: PFObject, PFSubclassing {
    @NSManaged var name: String?
    @NSManaged var note: String?
    @NSManaged var email: String?
    
    @NSManaged fileprivate var status: String?
    var statusValue: TransferStatus? {
        get {
            return self.status != nil ? TransferStatus(rawValue: self.status!)! : nil
        }
        set {
            self.status = newValue!.rawValue
        }
    }
    
    @NSManaged fileprivate var type: String?
    var typeValue: TransferType? {
        get {
            return self.type != nil ? TransferType(rawValue: self.type!)! : nil
        }
        set {
            self.type = newValue!.rawValue
        }
    }
    
    @NSManaged var actingUser: WRUser?
    @NSManaged var invitedUser: WRUser?
    @NSManaged var acceptedByUser: WRUser?
    @NSManaged var acceptedAt: Date?
    @NSManaged var errorMessage: String?
    
    @NSManaged var animal: WRAnimal?
    
    static func parseClassName() -> String {
        return "AnimalTransfer"
    }
}
