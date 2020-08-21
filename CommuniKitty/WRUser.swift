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
    @NSManaged var profilePhoto: PFFileObject?
    
    @NSManaged var facebookId: String?
    
    var shelter: WRLocation?
    
    var admin: Bool {
        get { return self["admin"] != nil ? self["admin"] as! Bool : false }
        set { self["admin"] = newValue }
    }
    
    //    override static func current() -> WRUser? {
    //        return PFUser.current() as? WRUser
    //    }
    override class func current() -> Self? {
        return PFUser.current() as? Self
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


class User:NSObject, Codable, NSCoding{
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(role, forKey: "role")
        coder.encode(fullName, forKey: "fullName")
        coder.encode(avatarUrl, forKey: "avatarUrl")
        coder.encode(slug, forKey: "slug")
        coder.encode(__typename, forKey: "__typename")
    }
    
    required init?(coder: NSCoder) {
        id = coder.decodeObject(forKey: "id") as? String
        role = coder.decodeObject(forKey: "role") as? String
        fullName = coder.decodeObject(forKey: "fullName") as? String
        avatarUrl = coder.decodeObject(forKey: "avatarUrl") as? String
        slug = coder.decodeObject(forKey: "slug") as? String
        __typename = coder.decodeObject(forKey: "__typename") as? String
    }
    
    var admin: Bool {
       get { return role != nil && role == "admin"}
        set { role = "admin"}
    }
    
    var id: String?
    var role: String?
    var fullName: String?
    var avatarUrl: String?
    var slug: String?
    var __typename: String?
}

class Credential:NSObject, Codable, NSCoding{
    func encode(with coder: NSCoder) {
        coder.encode(authorization, forKey: "authorization")
        coder.encode(tokentype, forKey: "tokentype")
        coder.encode(client, forKey: "client")
        coder.encode(expiry, forKey: "expiry")
        coder.encode(uid, forKey: "uid")
        coder.encode(__typename, forKey: "__typename")
    }
    
    required init?(coder: NSCoder) {
        authorization = coder.decodeObject(forKey: "authorization") as? String
        tokentype = coder.decodeObject(forKey: "tokentype") as? String
        client = coder.decodeObject(forKey: "client") as? String
        expiry = coder.decodeObject(forKey: "expiry") as? String
        uid = coder.decodeObject(forKey: "uid") as? String
        __typename = coder.decodeObject(forKey: "__typename") as? String
    }
    
    var authorization: String?
    var tokentype: String?
    var client: String?
    var expiry: String?
    var uid: String?
    var __typename: String?
}

class SignIn: NSObject, Codable, NSCoding{
    func encode(with coder: NSCoder) {
        coder.encode(user, forKey: "user")
        coder.encode(credential, forKey: "credential")
        coder.encode(__typename, forKey: "__typename")
    }
    
    required init?(coder: NSCoder) {
        user = coder.decodeObject(forKey: "user") as? User
        credential = coder.decodeObject(forKey: "credential") as? Credential
        __typename = coder.decodeObject(forKey: "__typename") as? String
    }
    
    
    var user: User?
    var credential:Credential?
    var __typename: String?
}


