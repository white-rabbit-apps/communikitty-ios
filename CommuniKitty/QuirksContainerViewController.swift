//
//  QuirksContainerViewController.swift
//  CommuniKitty
//
//  Created by Alina Chernenko on 9/29/16.
//  Copyright © 2016 White Rabbit Apps. All rights reserved.
//

import Parse
import Eureka

class QuirksContainerViewCell: PFTableViewCell{
    
    @IBOutlet weak var objectTextLabel: UILabel!
    
}

class QuirksContainerViewController: PFQueryTableViewController {
    
    var quirksViewController: QuirksSelectorViewController?

    override init(style: UITableView.Style, className: String!) {
        super.init(style: style, className: className)
    }
    
    required  init(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)!
        
        self.parseClassName = ""
        self.paginationEnabled = false
        self.pullToRefreshEnabled = false
    }
    
    
    override  func viewDidLoad() {
        super.viewDidLoad()
    }
    
     override func objectsDidLoad(_ error: Error?) {
        super.objectsDidLoad(error)
        
    }
    
    //query for table depending on form tag
    override  func queryForTable() -> PFQuery<PFObject> {
        
        switch (quirksViewController?.navTitle)! {
        case "Loves":
            let query = WRLove.query()!
            return query
        case "Hates":
            let query = WRHate.query()!
            return query
        default:
            return WRLove.query()!
        }
        
    }
    
    // gets the option to choose from table and loads the value in the textField
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (quirksViewController?.navTitle)!  {
        case "Loves":
            let currObject = object(at: indexPath as IndexPath) as! WRLove
            let text = currObject.text
            self.quirksViewController?.textField.text = text
        case "Hates":
            let currObject = object(at: indexPath as IndexPath) as! WRHate
            let text = currObject.text
            self.quirksViewController?.textField.text = text
        default:
            print("No Objects to load")
        }
        
    }
}
