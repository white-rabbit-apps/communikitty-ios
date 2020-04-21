//
//  CoatsTable.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/17/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import ParseUI
import Eureka

class CoatsTableViewCell: PFTableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
}

open
class CoatsTableViewController: PFQueryTableViewController, TypedRowControllerType {
    /// A closure to be called when the controller disappears.
    public var onDismissCallback: ((UIViewController) -> ())?

    
    open var row: RowOf<Coat>!
    open var completionCallback : ((UIViewController) -> ())?
    
    override open func objectsWillLoad() {
        super.objectsWillLoad()
        self.showLoader()
    }
    
    override open func objectsDidLoad(_ error: Error?) {
        super.objectsDidLoad(error)
        self.hideLoader()
    }
    
    override init(style: UITableView.Style, className: String!) {
        super.init(style: style, className: className)
    }
    
    convenience internal init(_ callback: @escaping (UIViewController) -> ()){
        self.init(nibName: nil, bundle: nil)
        completionCallback = callback
    }
    
    required public init(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)!
        
        self.parseClassName = "Coat"
        self.paginationEnabled = false
        self.pullToRefreshEnabled = false
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setUpNavigationBar(title: "Coats")
        
        tableView.reloadData()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.replacePFLoadingView()
        
        self.setUpNavigationBar(title: "Coats")
    }
    
    override open func queryForTable() -> PFQuery<PFObject> {
        let query = WRCoat.query()!
        query.order(byAscending: "groupOrder")
        query.limit = 300
        return query
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "CoatCell", for: indexPath) as? CoatsTableViewCell
        
        if cell == nil  {
            cell = CoatsTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CoatCell")
        }
        
        let coat = object as! WRCoat
        
        // Extract values from the PFObject to display in the table cell
        cell!.name.text = coat.name
        
        if let imageFile = coat.image {
            imageFile.getDataInBackground(block: {
                (imageData: Data?, error: Error?) -> Void in
                if(error == nil) {
                    let image = UIImage(data:imageData!)
                    cell!.thumbnailImage.image = image
                }
            })
        } else {
            cell!.thumbnailImage.image = nil
        }
        
        return cell
    }
    
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appDelegate = AppDelegate.getAppDelegate()
        
        let cell = tableView.cellForRow(at: indexPath) as? CoatsTableViewCell
        let name = cell!.name.text!
        
        row.value = appDelegate.coatByName![name]
        completionCallback?(self)
    }
    
}
