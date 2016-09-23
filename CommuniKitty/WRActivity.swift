//
//  WRActivity.swift
//  White Rabbit
//
//  Created by Michael Bina on 6/11/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import Parse

enum Action:String {
    case Comment = "comment"
    case Follow = "follow"
    case Poke = "poke"
    case Like = "like"
}

enum LikeAction:String {
    case Meow = "meow"
    case Purr = "purr"
    case Lick = "lick"
    case HeadBump = "bump"
    case Hiss = "hiss"
    case Scratch = "scratch"
}

class WRActivity: PFObject, PFSubclassing {
    
    @NSManaged var forUser: WRUser?

    @NSManaged var actingUser: WRUser?
    @NSManaged var actingUserName: String?
    @NSManaged var actingAnimal: WRAnimal?
    @NSManaged var actingAnimalName: String?
    
    @NSManaged var commentMade: WRComment?
    @NSManaged var commentMadeText: String?
    
    @NSManaged var entryActedOn: WRTimelineEntry?
    @NSManaged var animalActedOn: WRAnimal?
    @NSManaged var animalActedOnName: String?

    @NSManaged fileprivate var action: String?
    var actionValue: Action? {
        get {
            return self.action != nil ? Action(rawValue: self.action!)! : nil
        }
        set {
            self.action = newValue!.rawValue
        }
    }
    
    @NSManaged fileprivate var likeAction: String?
    var likeActionValue: LikeAction? {
        get {
            return self.likeAction != nil ? LikeAction(rawValue: self.likeAction!)! : nil
        }
        set {
            self.likeAction = newValue!.rawValue
        }
    }
    
    static func parseClassName() -> String {
        return "Activity"
    }
}
