//
//  BreedsTable.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/17/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import ParseUI
import Eureka

class BreedsTableViewCell: PFTableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
}

open
class BreedsTableViewController: PFQueryTableViewController, TypedRowControllerType, UISearchBarDelegate {
    /// A closure to be called when the controller disappears.
    public var onDismissCallback: ((UIViewController) -> ())?


    @IBOutlet weak var searchBar: UISearchBar!
    
    open var row: RowOf<Breed>!
    open var completionCallback : ((UIViewController) -> ())?
    
    internal var selectedIndexPath: IndexPath?
    
    func isSelectable() -> Bool {
        return self.row != nil
    }
    
    override open func objectsWillLoad() {
        super.objectsWillLoad()
        self.showLoader()
    }
    
    override open func objectsDidLoad(_ error: Error?) {
        super.objectsDidLoad(error)
        self.hideLoader()
    }
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    convenience internal init(_ callback: @escaping (UIViewController) -> ()){
        self.init(nibName: nil, bundle: nil)
        completionCallback = callback
    }
    
    required public init(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)!
        
        self.parseClassName = "Breed"
        self.paginationEnabled = false
        self.pullToRefreshEnabled = false
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(!isSelectable()) {
            self.setUpMenuBarController(title: "Breeds")
        } else {
            self.setUpNavigationBar(title: "Breeds")
        }

//        tableView.reloadData()
//        self.searchBar.delegate = self
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        if(!isSelectable()) {
            self.setUpMenuBarController(title: "Breeds")
        } else {
            self.setUpNavigationBar(title: "Breeds")
        }
    }
    
    func showSearch() {
        if (self.searchBar.isHidden) {
            self.searchBar.isHidden = false
        } else {
            self.searchBar.isHidden = true
        }
    }
    
    open func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Force reload of table data
        self.loadObjects()
    }
    
    open func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        self.loadObjects()
    }
    
    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        self.loadObjects()
    }
    
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Clear any search criteria
        searchBar.text = ""
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        self.loadObjects()
    }
    
    override open func queryForTable() -> PFQuery<PFObject> {
        let query = WRBreed.query()!
//        if searchBar.text != "" {
//            query.whereKey("name", containsString: searchBar.text!)
//        }
        query.order(byAscending: "name")
        return query
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "BreedCell", for: indexPath) as? BreedsTableViewCell
        
        if cell == nil  {
            cell = BreedsTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "BreedCell")
        }
        
        let breed = object as! WRBreed
        
        // Extract values from the PFObject to display in the table cell
        cell!.name.text = breed.name
        
        if let imageFile = breed.image {
//            cell!.thumbnailImage.kf_showIndicatorWhenLoading = true
            cell!.thumbnailImage.kf_setImage(with: URL(string: imageFile.url!)!, placeholder: nil)
        } else {
            cell!.thumbnailImage.image = nil
        }
        
        if(self.isSelectable()) {
            cell!.accessoryType = .detailButton
        } else {
            cell!.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        if(isSelectable()) {
            self.selectedIndexPath = indexPath
            self.performSegue(withIdentifier: "BreedTableToBreedDetail", sender: tableView)
        }
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appDelegate = AppDelegate.getAppDelegate()
        
        if(isSelectable()) {
            let breedObject = object(at: indexPath) as! WRBreed
            let name = breedObject.name!
            row.value = appDelegate.breedByName![name]
            completionCallback?(self)
        } else {
            self.selectedIndexPath = indexPath
            self.performSegue(withIdentifier: "BreedTableToBreedDetail", sender: tableView)
        }
    }
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        if(segue.identifier == "BreedTableToBreedDetail") {
            let detailScene = segue.destination as! BreedDetailViewController
            
            if let indexPath = self.selectedIndexPath {
                let row = Int((indexPath as IndexPath).row)
                let breedObject = objects?[row] as! WRBreed
                
                detailScene.currentBreedObject = breedObject
            }
        }
    }
}
