//
//  LocationsTableViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/18/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import ParseUI
import MapKit

class LocationsTableViewCell: PFTableViewCell {
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame.size.height = 200
    }
    
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
}

class LocationsTableViewController: PFQueryTableViewController {
   
    var selectedType: String = "Supplies"
    var mapViewController : LocationsMapViewController?
    var currentLocation : PFGeoPoint?
    var firstClick:Bool = true
    var selectedLocationObject:WRLocation?
    var query:[PFObject] = []
    
    required init(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)!
        
        self.parseClassName = ""//WRLocation.parseClassName()
        self.paginationEnabled = true
        self.pullToRefreshEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
     func dataForTableAndMap() -> PFQuery {
            let query = WRLocation.query()!
            query.whereKey("types", containsString: self.selectedType)
            query.whereKey("animals", containsString: "cats")
            if(self.currentLocation != nil) {
                query.whereKey("geo", nearGeoPoint:self.currentLocation!)
                query.limit = 10
                query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if error == nil {
                        if let objects = objects {
                            print("\(objects.count)")
                            for object in objects {
                                self.query.append(object)
                                let location = Location(locationObject: object as! WRLocation)
                                location.loadImage({ (image:UIImage?) in
                                    self.mapViewController!.addLocationToMap(location)
                                })
                                
                            }
                        }
                    } else {
                        print("There was an error")
                    }
                }

            }
            
            //self.mapViewController!.clearMap()
        
                //

            return query
        }
    
    
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as? LocationsTableViewCell
        if cell == nil  {
            cell = LocationsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "LocationCell")
        }
        
        if self.query.count != 0 {
        let location = self.query[indexPath.row] as! WRLocation

        cell!.name.text = location.name
        
        if let logoFile = location.logo {
            cell!.logo.kf_setImageWithURL(NSURL(string: logoFile.url!)!)
        } else {
            cell!.logo.image = nil
        }
        }

        return cell!
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if firstClick{
            firstClick = false
            let row = Int(indexPath.row)
            let locationObject = self.query[row] as? WRLocation
            self.selectedLocationObject = locationObject
            if locationObject != nil {
            mapViewController!.centerOnLocation(locationObject)
            }
        } else {
            let row = Int(indexPath.row)
            let locationObject = self.query[row] as? WRLocation
            if locationObject == self.selectedLocationObject{
                performSegueWithIdentifier("LocationToLocationDetail", sender: self)
                firstClick = true
            } else {
                let row = Int(indexPath.row)
                let locationObject = self.query[row] as? WRLocation
                self.selectedLocationObject = locationObject
                if locationObject != nil {
                    mapViewController!.centerOnLocation(locationObject)
                }
            }
        }
    }
    
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "LocationToLocationDetail") {

            // Get the new view controller
            let detailScene = segue.destinationViewController as! LocationDetailViewController
            
            // Pass the selected object to the destination view controller.
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let row = Int(indexPath.row)
                let locationObject = objects?[row] as? WRLocation
                detailScene.currentLocationObject = locationObject
                
            }
        }
    }
}
