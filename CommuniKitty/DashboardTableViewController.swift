//
//  DashboardTableViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 8/15/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import UIKit

//
// DashboardTableViewController - Table view where each row is a dashboard widget
//          - 
//
class DashboardTableViewController: UITableViewController {
    
    var showRefreshControl : Bool = false
    var widgets : [DashboardWidget] = []
    var parentView : UIViewController?
    
    /**
     viewDidLoad - Called whenever the view is loaded for the first time
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 180
        
        if (self.showRefreshControl) {
            // Add a pull to refresh control for the table view
            refreshControl = UIRefreshControl()
            refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
            refreshControl!.addTarget(self, action: #selector(DashboardTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)
            tableView.addSubview(refreshControl!) // not required when using UITableViewController
        }
        
        self.refresh(self)
    }
    
    /**
     Refresh the dashboard data
     */
    func refresh(_ sender:AnyObject) {
        // Code to refresh table view
        
        if let dashboard = self.parentView as? DashboardViewController {
            dashboard.loadDashboard()
        }
        
        for widget in self.widgets {
            widget.reloadData()
        }

        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    /**
     The number of sections of widgets that should be shown
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     The number of widgets that should be shown in each section
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.widgets.count
    }
    
    /**
     Render each cell of the tableView
     - Each cell is another dashboard widget made up of a DashboardCell and is of a type in the RowContent enum
     - Perhaps a lot of the rendering functionality needs to be moved from this method
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardCell", for: indexPath) as! DashboardWidget
        
        cell.parentTableView = self
        
        cell.emptyStateButton?.isHidden = true
        cell.emptyStateButton?.setImage(UIImage(named: "blank"), for: UIControlState())
        
        cell.parent = self.parentView
        
        let widget = widgets[(indexPath as IndexPath).row]
        widget.loadCellData(cell)
        
        cell.infiniteScrollHandler = {
            widget.loadData(widget.nextPage)
        }
        
        if(widget.firstLoad && WRUser.current() != nil) {
            widget.firstLoad = false
            widget.loadData(widget.nextPage)
        }
        
        cell.collectionView?.delegate = cell
        cell.collectionView?.dataSource = cell
        
        cell.collectionView?.reloadData()
        cell.collectionView?.reloadInputViews()
        cell.showAppropriateView()
        
        return cell
    }
}

//
// DashboardWidget - A single widget on the dashboard screen
//
class DashboardWidget: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate {
    
    // The label for the header bar
    @IBOutlet weak var titleLabel : UILabel?
    
    // The button that is shown on the right side of the header bar
    @IBOutlet weak var titleButton : UIButton?
    
    // The button with an empty state image that is shown when theres no data
    @IBOutlet weak var emptyStateButton : UIButton?
    
    // The collectionView that shows the data cells for this dashboard widget
    @IBOutlet weak var collectionView : UICollectionView?
    
    // The a pointer to the parent dashboard that this cell is enclosed within
    var parent: UIViewController?
    
    // The source data that should be displayed in each cell of this widget
    // Each collectionType expects a different kind of object:
    //    - .Animals: Array<WRAnimal>
    //    - .Photos: Array<WRTimelineEntry>
    var sourceArray: [AnyObject]! = [AnyObject!]()
    
    // The type of cells that should be displayed in this widget [.Animals, .Photos]
    var collectionType : CollectionType = .Animals
    
    // The specific type of dashboard widget this [.Mine, .Featured, .Following, .Fosters, .Shelter]
    var rowContent : RowContent = .Mine
    
    // A function to be run when the user has scrolled to a certain point in the collectionView
    var infiniteScrollHandler: ()->Void = {}
    
    var parentTableView: UITableViewController?
    
    // the number of photos to display on paged widgets
    var photosPerPage : Int = 20
    
    // the next page that should be loaded for these paged widgets
    var nextPage : Int = 1
    
    // whether or not the paged widget is currently loading more data
    var currentlyLoading : Bool = false
    
    var firstLoad : Bool = true
    var requiresLogin: Bool { return false }
    
    var parentCell : DashboardWidget?
    
    /**
     Hide or show the empty state and collectionView, as needed.
     */
    func showAppropriateView() {
        let numberOfItems = self.collectionView?.numberOfItems(inSection: 0)
        if numberOfItems! > 0 {
            self.collectionView?.isHidden = false
            self.emptyStateButton?.isHidden = true
        } else {
            self.collectionView?.isHidden = true
            self.emptyStateButton?.isHidden = false
        }
    }
    
    /**
     The number of cells that should be displayed in the collectionView
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sourceArray.count
    }
    
    /**
     The number of sections that should be in the collectionView
     */
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
     cellForItemAtIndexPath - handle when one of the collectionView items has been tapped
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionType == .Photos) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoThumbnailCell", for: indexPath) as! PhotoThumbnailCell
            cell.loadData(sourceArray[(indexPath as IndexPath).row] as! PFObject)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnimalThumbnailCell", for: indexPath) as! AnimalThumbnailCell
            cell.loadData(sourceArray[(indexPath as IndexPath).row] as! PFObject)
            return cell
        }
    }
    
    /**
     didSelectItemAtIndexPath - handle when one of the collectionView items has been tapped
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(collectionType == .Photos) {
            // open an image browser with the selected image shown first
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoThumbnailCell", for: indexPath) as! PhotoThumbnailCell
            
            let entries = sourceArray as! [WRTimelineEntry]
            
            self.parent?.showImagesBrowser(entries: entries, startIndex: (indexPath as IndexPath).row, animatedFromView: cell.thumbnailImage!, displayUser: true)
        } else {
            // open the detail screen for the animal selected
            let animal = sourceArray[(indexPath as IndexPath).row] as! WRAnimal
            self.parent?.openAnimalDetail(animalObject: animal, push: true)
        }
    }
    
    /**
     Scroll handler to run the infiniteScrollHandler function when the user has scrolled
     to a certain point horizontally
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let contentWidth = scrollView.contentSize.width
        if offsetX + 500 > contentWidth - scrollView.frame.size.width {
            self.infiniteScrollHandler()
        }
    }
    
    func reloadData() {
        self.sourceArray = [AnyObject!]()
        self.nextPage = 1
        self.currentlyLoading = false
        self.loadData(self.nextPage)
    }
    
    func refresh() {
        self.parentCell?.sourceArray = self.sourceArray
        self.parentCell?.collectionView?.reloadData()
        self.parentCell?.parentTableView?.tableView.reloadData()
    }
    
    /**
     Load the featured photos from the server
     */
    func loadData(_ page: Int) {
        if(self.requiresLogin && WRUser.current() == nil) {
            return
        }
        
        if(!self.currentlyLoading) {
            self.currentlyLoading = true
            
            let query = self.getQuery()
            query.limit = self.photosPerPage
            query.skip = (page - 1) * self.photosPerPage
            
            query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
                for object in objects! {
                    self.sourceArray.append(object)
                }
                
                self.nextPage += 1
                self.currentlyLoading = false
                self.refresh()
                
                if(objects!.count < self.photosPerPage) {
                    self.currentlyLoading = true
                }
            }
        }
    }
    
    func getQuery() -> PFQuery<PFObject> {
        preconditionFailure("This method must be overridden")
    }
    
    func loadCellData(_ cell: DashboardWidget) {
        preconditionFailure("This method must be overridden")
    }
}



//
// DashboardCollectionViewCell - A protocol for dashboard collectionView cells
//
protocol DashboardCollectionViewCell {
    
    // load the data from the object into the cell
    func loadData(_ object: PFObject)
}


//
// PhotoThumbnailCell - A collectionView cell with a photo entry thumbnail
//
class PhotoThumbnailCell: UICollectionViewCell, DashboardCollectionViewCell {
    @IBOutlet weak var thumbnailImage : UIImageView?
    
    override func layoutSubviews() {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    // object should be a WRTimelineEntry object
    func loadData(_ object: PFObject) {
        if let entry = object as? WRTimelineEntry {
            
            if let imageFile = entry.image {
                self.thumbnailImage!.kf_setImage(with: URL(string: imageFile.url!))
            } else if let imageUrl = entry.imageUrl {
                self.thumbnailImage!.kf_setImage(with: URL(string: imageUrl))
            }
        }
    }
}


//
// AnimalThumbnailCell - A collectionView cell with an animal profile thumbnail
//
class AnimalThumbnailCell: UICollectionViewCell, DashboardCollectionViewCell {
    @IBOutlet weak var nameLabel : UILabel?
    @IBOutlet weak var thumbnailImage : UIImageView?
    
    override func layoutSubviews() {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    // object should be a WRAnimal object
    func loadData(_ object: PFObject) {
        if let animal = object as? WRAnimal {
            self.nameLabel?.text = animal.name
            self.nameLabel?.textColor = UIColor.black
            self.nameLabel?.highlightedTextColor = UIColor.black
            
            let placeholderImage = UIImage(named: "animal_profile_photo_empty")
            
            self.thumbnailImage!.makeSquare()
            self.thumbnailImage!.isHidden = true
            
            self.thumbnailImage?.image = nil
            if let profilePhoto = animal.profilePhoto {
//                self.thumbnailImage!.kf_showIndicatorWhenLoading = true
                self.thumbnailImage!.kf_setImage(with: URL(string: profilePhoto.url!), placeholder: placeholderImage, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
                    self.thumbnailImage!.frame = CGRect(x: 0, y: 0, width: 90, height: 90)
                    self.thumbnailImage!.makeCircular()
                    self.thumbnailImage!.isHidden = false
                })
            } else {
                self.thumbnailImage?.image = placeholderImage
                self.thumbnailImage!.isHidden = false
            }
        }
    }
}
