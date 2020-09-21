//
//  LocationsMapViewController.swift
//  CommuniKitty
//
//  Created by Michael Bina on 9/15/20.
//  Copyright © 2020 White Rabbit Apps. All rights reserved.
//
import MapKit
import BTNavigationDropdownMenu

enum SelectedType: String {
    case Hospital = "hospital"
    case Rescue = "rescue"
    case Shelter = "shelter"
    case Vet = "vet"
    case Sitting = "sitting"
    case Boarding = "boarding"
    case Supplies = "supplies"
    case Grooming = "grooming"
    case Cafe = "cafe"
}

class LocationsMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var currentLocationView: UIView!
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var showListView: UIView!
    @IBOutlet weak var showListButton: UIButton!
    @IBOutlet weak var triangleImage: UIImageView!
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterLabel: UILabel!
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var filterBoardView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var currentLocation : PFGeoPoint?
    let locationManager = CLLocationManager()
    var isSearchFieldOpen : Bool = false
    var isListOpen : Bool = false
    var isFilterBoardOpen : Bool = false
    
    var selectedType = SelectedType.Supplies

    var visibleMapRect: MKMapRect?
    var arrayOfLocationsToShow: [Location] = []
    
    var locationsTableController: LocationsTableViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpMenuBarController("Find")
    }
    
    
    override func viewDidLayoutSubviews() {
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = UIBezierPath(roundedRect: showListView.bounds, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSize(width: 15, height: 15)).CGPath
        self.showListView.layer.mask = maskLayer

        self.showListView.layer.shadowOpacity = 0.7
        self.showListView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.showListView.layer.shadowRadius = 5.0
        self.showListView.layer.shadowColor = UIColor.lightGrayColor().CGColor
        
        self.showListButton.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        
        if UIScreen.mainScreen().bounds.width > 400 && !isSearchFieldOpen {
            self.searchViewTrailingConstraint.constant = 329
        }
    }
    
    
     func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        
        if fullyRendered {
            NSLog("# annotations: \(mapView.annotations.count). # locations: \(arrayOfLocationsToShow.count)")
        
        //checking if there is more than one current location
        if mapView.annotations.count < 2 {
            let alertController = UIAlertController(title: nil, message: "No results found in this region", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.hidden = true
        filterBoardView.hidden = true
        self.searchTextField.delegate = self
        self.loadingIndicator.hidden = true
        self.selectedType = SelectedType.Supplies
        
        self.currentLocationView.layer.shadowOpacity = 0.7
        self.currentLocationView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.currentLocationView.layer.shadowRadius = 5.0
        self.currentLocationView.layer.shadowColor = UIColor.lightGrayColor().CGColor

        self.searchView.layer.shadowOpacity = 0.7
        self.searchView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.searchView.layer.shadowRadius = 5.0
        self.searchView.layer.shadowColor = UIColor.lightGrayColor().CGColor
        
        self.showListButton.setTitle("Show List", forState: .Normal)
        self.showListButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 15)

        self.filterView.layer.shadowOpacity = 0.7
        self.filterView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.filterView.layer.shadowRadius = 5.0
        self.filterView.layer.shadowColor = UIColor.lightGrayColor().CGColor
        
        self.filterBoardView.layer.shadowOpacity = 0.7
        self.filterBoardView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.filterBoardView.layer.shadowRadius = 5.0
        self.filterBoardView.layer.shadowColor = UIColor.lightGrayColor().CGColor
        
        Answers.logCustomEventWithName("Location Map Opened", customAttributes: nil)

        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                NSLog("got geolocation")
                
//                self.locationsTableController?.currentLocation = geoPoint
//                self.locationsTableController?.dataForTableAndMap()
                
                self.currentLocation = geoPoint
                self.visibleMapRect = self.mapView.visibleMapRect
                
                
                let center = CLLocationCoordinate2D(latitude: (geoPoint?.latitude)!, longitude: (geoPoint?.longitude)!)

                let regionRadius: CLLocationDistance = 5000
                let region = MKCoordinateRegionMakeWithDistance(center, regionRadius * 1.0, regionRadius * 1.0)
                
                self.mapView.setRegion(region, animated: true)
                
                self.populateLocations()
                
            }
        }
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
 
    }
    
    
    /**
     * Called when 'search' key pressed.
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if isSearchFieldOpen{
            isSearchFieldOpen = false
            self.currentLocationView.hidden = false
            self.searchViewTrailingConstraint.constant = 315
            self.searchView.subviews.last?.removeFromSuperview()
            searchTextField.hidden = true
            searchFieldViewTapped()
        }
        self.searchTextField.text = nil
        return true
    }
    
    /**
     * Called when the user clicks on the view (outside the UITextField).
     */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        if isSearchFieldOpen{
            isSearchFieldOpen = false
            self.currentLocationView.hidden = false
            self.searchViewTrailingConstraint.constant = 315
            self.searchView.subviews.last?.removeFromSuperview()
            searchTextField.hidden = true
        }
        
        if isFilterBoardOpen{
            isFilterBoardOpen = false
            filterBoardView.hidden = true
            if isListOpen && isSearchFieldOpen{
                self.searchTextField.hidden = false
            }

        }

        
    }
    
    
    // return user to his current location
    @IBAction func refreshLocation(sender: AnyObject) {
        let center = CLLocationCoordinate2D(latitude: (self.currentLocation?.latitude)!, longitude: (self.currentLocation?.longitude)!)
        
        let regionRadius: CLLocationDistance = 5000
        let region = MKCoordinateRegionMakeWithDistance(center, regionRadius * 1.0, regionRadius * 1.0)
        
        self.mapView.setRegion(region, animated: true)
        
        self.searchNewLocation = nil
        self.arrayOfLocationsToShow = []
        self.clearMap()
        populateLocations()
    }
    
    //function for center the map on selected location from the table
    func centerOnLocation(location:WRLocation?){
        
        let center = CLLocationCoordinate2D(latitude: (location?.geo?.latitude)!, longitude: (location?.geo?.longitude)!)
        
        let regionRadius: CLLocationDistance = 5000
        let region = MKCoordinateRegionMakeWithDistance(center, regionRadius * 1.0, regionRadius * 1.0)
        
        self.mapView.setRegion(region, animated: true)
        
        for annotation in self.mapView.annotations{
            
                let annotationCoordinate = annotation.coordinate
                if let locationCoordinate = location!.geo {
                    if annotationCoordinate.latitude == locationCoordinate.latitude{
                        if annotationCoordinate.longitude == locationCoordinate.longitude {
                             self.mapView.selectAnnotation(annotation, animated: true)
                        }
                    }
            }
        }
        
    }
    
    
    func animateTheAnnotation(annotationView:MKAnnotationView){
        UIView.animateWithDuration(0.5, delay: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations:{() in
            // Animate squash
            }, completion:{(Bool) in
                UIView.animateWithDuration(0.05, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{() in
                    annotationView.transform = CGAffineTransformMakeScale(1.2, 1.2)
                    
                    }, completion: {(Bool) in
                        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{() in
                            annotationView.transform = CGAffineTransformIdentity
                            }, completion: nil)
                })
                
        })

    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.visibleMapRect = mapView.visibleMapRect
        
        let newCenter = mapView.centerCoordinate
        
        let newCenterGeoPoint  = PFGeoPoint(latitude: newCenter.latitude, longitude: newCenter.longitude)
        
        self.searchNewLocation = newCenterGeoPoint
        
        populateLocations(true)
       
        
        for annotation in mapView.annotations {
    
            
        let location = annotation.coordinate
            
        //checking if the location is from visible map area
        //if it's from the visible area and hidden, then show this location
        if MKMapRectContainsPoint(mapView.visibleMapRect, MKMapPointForCoordinate(location)){
            let annotationView = mapView.viewForAnnotation(annotation)
            if annotationView?.hidden == true {
                annotationView?.hidden = false
                animateTheAnnotation(annotationView!)
                
            }
            
        } else {
            //hide the location which is not in visible area
            let annotationView = mapView.viewForAnnotation(annotation)
            if annotationView?.hidden == false {
                annotationView?.hidden = true
            }
        }

        }
        
    }
    
    
    @IBAction func filterButtonTap(sender: AnyObject) {
        if !isFilterBoardOpen{
            filterBoardView.hidden = false
            isFilterBoardOpen = true
            if isListOpen && isSearchFieldOpen{
            self.searchTextField.hidden = true
            }
        } else {
            isFilterBoardOpen = false
            filterBoardView.hidden = true
            if isListOpen && isSearchFieldOpen{
            self.searchTextField.hidden = false
            }
        }
    }
    
    @IBAction func searchTap(sender: AnyObject) {
        
        if !isSearchFieldOpen{
        isSearchFieldOpen = true
        self.currentLocationView.hidden = true
        self.searchViewTrailingConstraint.constant = 0
        
            
            let searchImage = UIImageView()
            
            if UIScreen.mainScreen().bounds.width > 400{
                searchImage.frame = CGRectMake(334,5,35,35)
            } else {
                searchImage.frame = CGRectMake(303,5,35,35)
            }
        searchImage.image = UIImage(named: "icon_current_location")
            searchImage.userInteractionEnabled = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LocationsMapViewController.searchFieldViewTapped))
            searchImage.addGestureRecognizer(tapGesture)
            
            searchView.addSubview(searchImage)
            searchTextField.hidden = false
            searchTextField.becomeFirstResponder()
   
        } else {
            isSearchFieldOpen = false
            self.currentLocationView.hidden = false
            self.searchViewTrailingConstraint.constant = 315
            self.searchView.subviews.last?.removeFromSuperview()
            searchTextField.hidden = true
            self.searchNewLocation = nil
        }
        
    }
    
    
    //update the map after changing the selected type
    func refreshLocations(){
        if self.searchNewLocation != nil {
            self.arrayOfLocationsToShow = []
            self.clearMap()
            populateLocations(true)
        }
        else {
            self.clearMap()
            populateLocations()
        }
    }
    
    
    @IBAction func showListTap(sender: AnyObject) {
        
        if !isListOpen{
            self.showListButton.setTitle("Hide List", forState: .Normal)
            isListOpen = true
            mapViewHeightConstraint.constant = 420
            self.tableView.hidden = false
            self.triangleImage.image = UIImage(CGImage: (UIImage(named: "icon_expand")?.CGImage)!, scale: 1.0, orientation: .DownMirrored)
            
        }
        else {
            isListOpen = false
            self.showListButton.setTitle("Show List", forState: .Normal)
            mapViewHeightConstraint.constant = 736
            self.triangleImage.image = UIImage(named: "icon_expand")
        }
        
    }
    
    
    @IBAction func rescueButtonTap(sender: AnyObject) {
        let rescueButton = sender as! UIButton
        changeTheFilter(rescueButton)
    }
    
    @IBAction func shelterButtonTap(sender: AnyObject) {
        let shelterButton = sender as! UIButton
        changeTheFilter(shelterButton)
       
    }
    
    @IBAction func boardingButtonTap(sender: AnyObject) {
        let boardingButton = sender as! UIButton
        changeTheFilter(boardingButton)
    }
    
    @IBAction func vetButtonTap(sender: AnyObject) {
        let vetButton = sender as! UIButton
        changeTheFilter(vetButton)
    }
    
    @IBAction func suppliesButtonTap(sender: AnyObject) {
        let suppliesButton = sender as! UIButton
        changeTheFilter(suppliesButton)
    }
    
    
    @IBAction func sittingButtonTap(sender: AnyObject) {
        let sittingButton = sender as! UIButton
        changeTheFilter(sittingButton)
    }
    
    @IBAction func groomingButtonTap(sender: AnyObject) {
        let groomingButton = sender as! UIButton
        changeTheFilter(groomingButton)
    }
    
    @IBAction func hospitalButtonTap(sender: AnyObject) {
        let hospitalButton = sender as! UIButton
        changeTheFilter(hospitalButton)
    }
    
    
    @IBAction func cafeButtonTap(sender: AnyObject) {
        let cafeButton = sender as! UIButton
        changeTheFilter(cafeButton)
    }
    
    func changeTheFilter(sender: UIButton){
        self.filterBoardView.hidden = true
        self.isFilterBoardOpen = false
        
        switch sender.tag {
        case 0:
            self.filterButton.setImage(UIImage(named: "icon_location_type_emergency"), forState: .Normal)
            self.filterLabel.text = "Hospital"
            self.selectedType = SelectedType.Hospital
        case 1:
            self.filterButton.setImage(UIImage(named: "icon_location_type_rescue"), forState: .Normal)
            self.filterLabel.text = "Rescue"
            self.selectedType = SelectedType.Rescue
        case 2:
            self.filterButton.setImage(UIImage(named: "icon_location_type_shelter"), forState: .Normal)
            self.filterLabel.text = "Shelter"
            self.selectedType = SelectedType.Shelter
        case 3:
            self.filterButton.setImage(UIImage(named: "icon_location_type_vet"), forState: .Normal)
            self.filterLabel.text = "Vet"
           self.selectedType = SelectedType.Vet
        case 4:
            self.filterButton.setImage(UIImage(named: "icon_location_type_sitting"), forState: .Normal)
            self.filterLabel.text = "Sitting"
            self.selectedType = SelectedType.Sitting
        case 5:
            self.filterButton.setImage(UIImage(named: "icon_location_type_boarding"), forState: .Normal)
            self.filterLabel.text = "Boarding"
            self.selectedType = SelectedType.Boarding
        case 6:
            self.filterButton.setImage(UIImage(named: "icon_location_type_supplies"), forState: .Normal)
            self.filterLabel.text = "Supplies"
            self.selectedType = SelectedType.Supplies
        case 7:
            self.filterButton.setImage(UIImage(named: "icon_location_type_grooming"), forState: .Normal)
            self.filterLabel.text = "Grooming"
            self.selectedType = SelectedType.Grooming
        case 8:
            self.filterButton.setImage(UIImage(named: "icon_location_type_cafe"), forState: .Normal)
            self.filterLabel.text = "Cafe"
            self.selectedType = SelectedType.Cafe
        default: "No such button"
        }
        if isListOpen && isSearchFieldOpen{
            self.searchTextField.hidden = false
        }
        refreshLocations()

    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        self.loadingIndicator.hidden = true

    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKindOfClass(MKUserLocation) else {
            return nil
        }
        
        let reuseId = "pin"
        
        var annotationView: MKAnnotationView?
        
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        
        else {
            
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            av.canShowCallout = false
            annotationView = av
            
        }
        
        let locationAnnotation = annotation as! Location
        
        if locationAnnotation.image != nil{
            if locationAnnotation.image?.image != nil{
                let customView = customAnnotationView(frame: CGRectMake(0, 0, 33, 48), objImage: (locationAnnotation.image?.image)!)
                customView.canShowCallout = false
                
                annotationView = customView
                
                let location = locationAnnotation.coordinate
                
                if MKMapRectContainsPoint(self.visibleMapRect!, MKMapPointForCoordinate(location)){
                    annotationView?.hidden = false
                } else {
                    annotationView?.hidden = true
                }
            }
        }
        
        return annotationView!
        
    }

    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation {
            // Don't proceed with custom callout
            return
        }
        
        let objectAnnotation = view.annotation as! Location
        
        let iconView = UIImageView(frame: CGRectMake(2, 2, 29, 29))
        iconView.image = objectAnnotation.image?.image
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = iconView.frame.width/2
        iconView.backgroundColor = UIColor.whiteColor()
        
        let annotationLabel = UILabel()
        annotationLabel.text = objectAnnotation.title
        let labelSize = self.estimatedLabelSize(annotationLabel)
        annotationLabel.frame = CGRectMake(36, 5, ceil(labelSize.width)+10, 25)
        
        let arrowImage = UIImageView(frame: CGRectMake(38+annotationLabel.frame.width, 10, 15, 15))
        arrowImage.image = UIImage(named: "icon_row_arrow")
        
        let annotationViewWidth = iconView.frame.width + annotationLabel.frame.width + arrowImage.frame.width + 14
        
        let calloutView = CustomCalloutView(frame: CGRectMake(0, 0, annotationViewWidth, 34), rightImage: iconView, calloutLabel: annotationLabel, calloutArrow: arrowImage)
        calloutView.backgroundColor = UIColor.whiteColor()
        calloutView.layer.cornerRadius = 10
        calloutView.layer.borderColor = UIColor.redColor().CGColor
        calloutView.layer.borderWidth = 1

        self.currentView = view
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LocationsMapViewController.openLocationDetail))
        tapGesture.numberOfTapsRequired = 1
        calloutView.addGestureRecognizer(tapGesture)
        
        view.addSubview(calloutView)
    }

 
    var currentView: MKAnnotationView?
    
    func openLocationDetail() {
        performSegueWithIdentifier("MapToLocationDetail", sender: self.currentView)
    }
    
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var searchNewLocation: PFGeoPoint?
    
    func searchFieldViewTapped(){
        var text = String()
        if !(self.searchTextField.text?.isEmpty)! {
            text = self.searchTextField.text!
            
            localSearchRequest = MKLocalSearchRequest()
            localSearchRequest.naturalLanguageQuery = text
            localSearch = MKLocalSearch(request: localSearchRequest)
            localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
                
                if localSearchResponse == nil{
                    let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return
                }
                
                let center = CLLocationCoordinate2D(latitude: (localSearchResponse!.boundingRegion.center.latitude), longitude: (localSearchResponse!.boundingRegion.center.longitude))
                
                let regionRadius: CLLocationDistance = 5000
                let region = MKCoordinateRegionMakeWithDistance(center, regionRadius, regionRadius)
                
                self.mapView.setRegion(region, animated: true)
                
                self.searchNewLocation = PFGeoPoint.init(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
                self.clearMap()
                self.arrayOfLocationsToShow = []
                self.populateLocations(true)
            }
        }
    }
    
    
    func estimatedLabelSize(label: UILabel) -> CGSize {
        guard let text = label.text else { return .zero }
        return NSString(string: text).boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: label.font], context: nil).size
    }

    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        if view.isKindOfClass(MKAnnotationView) {
            let lastSubview = view.subviews.last
            lastSubview!.removeFromSuperview()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller
        if(segue.identifier == "MapToLocationDetail") {
            NSLog("performing maptolocation")
            let detailScene = segue.destinationViewController as! LocationDetailViewController

            let annotationView = sender as! MKAnnotationView
            let annotation = annotationView.annotation as? Location
            
            detailScene.currentLocationObject = annotation?.location
        } else if(segue.identifier == "LocationTableEmbed") {
            
            let tableScene = segue.destinationViewController as! LocationsTableViewController
            tableScene.mapViewController = self
            tableScene.selectedType = (self.selectedType.rawValue)
            self.locationsTableController = tableScene
        }
    }
    
    func populateLocations(isNewLocation:Bool = false){
        
        let query : PFQuery = WRLocation.query()!
        query.whereKey("types", containsString: (self.selectedType.rawValue))
        query.whereKey("animals", containsString: "cats")
        if !isNewLocation{
            if(self.currentLocation != nil) {
                query.whereKey("geo", nearGeoPoint:self.currentLocation!, withinKilometers: 10.0)
            }
        } else {
            if(self.searchNewLocation != nil) {
                query.whereKey("geo", nearGeoPoint:self.searchNewLocation!, withinKilometers: 10.0)
            }
        }
        
        var locationExists = false
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        
                        let location = Location(locationObject: object as! WRLocation)
                        
                        if self.arrayOfLocationsToShow.count == 0 {
                            self.arrayOfLocationsToShow.append(location)
                            self.loadingIndicator.hidden = false
                            location.loadImage({ (image:UIImage?) in
                                self.addLocationToMap(location)
                            })
                        } else {
                            for lc in self.arrayOfLocationsToShow{
                                if location.coordinate.latitude == lc.coordinate.latitude {
                                    if location.coordinate.longitude == lc.coordinate.longitude{
                                        locationExists = true
                                        break
                                    }
                                } else {
                                    continue
                                }
                            }
                            
                            if !locationExists {
                                self.loadingIndicator.hidden = false
                                location.loadImage({ (image:UIImage?) in
                                    self.addLocationToMap(location)
                                })
                            }
                        }
                    }
                }
            } else {
                print("There was an error")
            }
        }
        
    }
    
    func clearMap() {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
    }
    
    func addLocationToMap(location: Location) {
        self.mapView.addAnnotation(location)
    }
    

}


public class Location: NSObject, MKAnnotation {
    public let title: String?
    public let coordinate: CLLocationCoordinate2D
    var image:UIImageView?
    var logoFileURL: String?
    
    var location: WRLocation?
    
    init(locationObject: WRLocation) {
        self.title = locationObject.name
        if let logoFile = locationObject.logo {
            self.logoFileURL = logoFile.url!
        } else {
            let imgView = UIImageView()
            imgView.image = UIImage(named: "form_traits")
            self.image = imgView
        }
        
        if let locationGeo = locationObject.geo {
            self.coordinate = CLLocationCoordinate2D(
                latitude: locationGeo.latitude,
                longitude: locationGeo.longitude
            )
        } else {
            self.coordinate = CLLocationCoordinate2D()
        }
        
        self.location = locationObject
        
        super.init()
        
    }
    
    
    func loadImage(comp:(_ image:UIImage)->()){
        
        let pinImage = UIImageView()
        
        if self.logoFileURL != nil {
            
        ImageLoader.sharedLoader.imageForUrl(self.logoFileURL!, completionHandler:{(image: UIImage?, url: String) in
            if image != nil{
            pinImage.image = image!
            self.image = pinImage
            comp(image:image!)
            } else {
                let imgView = UIImageView()
                imgView.image = UIImage(named: "form_traits")
                self.image = imgView
                comp(image: (self.image?.image)!)
            }
        })
        
        } else {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "form_traits")
        self.image = imgView
        comp(image: (self.image?.image)!)
        }
    
    }

}


class customAnnotationView: MKAnnotationView {
    var objectImage = UIImage()
    
    init(frame: CGRect, objImage:UIImage){
        self.objectImage = objImage
        
        let imgView = UIView(frame: CGRectMake(0, 0, 33, 48))
        let pinImage = UIImageView(frame: CGRectMake(0, 0, 33, 48))
        pinImage.image = UIImage(named: "icon_map_marker")
        
        
        let objectImage = UIImageView(frame: CGRectMake(2,2,29,29))
        objectImage.layer.cornerRadius = objectImage.frame.width/2
        objectImage.contentMode = .ScaleAspectFill
        objectImage.image = self.objectImage
        objectImage.clipsToBounds = true
        objectImage.backgroundColor = UIColor.whiteColor()
        
        imgView.addSubview(pinImage)
        
        imgView.addSubview(objectImage)
        super.init(frame:frame)
        self.addSubview(imgView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // need this to capture button taps since they are outside of self.frame
     override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView?{
        for subview: UIView in self.subviews {
            if CGRectContainsPoint(subview.frame, point) {
                return subview
            }
        }
        // use this to pass the 'touch' onward in case no subviews trigger the touch
        return super.hitTest(point, withEvent: event)
    }
}

class CustomCalloutView: UIView {
    let rightImage:UIImageView?
    let calloutLabel:UILabel?
    let calloutArrow:UIImageView?
    
     init(frame: CGRect, rightImage:UIImageView, calloutLabel:UILabel, calloutArrow:UIImageView) {
        self.rightImage = rightImage
        self.calloutLabel = calloutLabel
        self.calloutArrow = calloutArrow
        super.init(frame: frame)
        self.addSubview(rightImage)
        self.addSubview(calloutLabel)
        self.addSubview(calloutArrow)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 }

class ImageLoader {
    
    var cache = NSCache()
    
    class var sharedLoader : ImageLoader {
        struct Static {
            static let instance : ImageLoader = ImageLoader()
        }
        return Static.instance
    }
    
    func imageForUrl(urlString: String, completionHandler:(_ image: UIImage?, _ url: String) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {()in
            let data: NSData? = self.cache.objectForKey(urlString) as? NSData
            
            if let goodData = data {
                let image = UIImage(data: goodData)
                dispatch_async(dispatch_get_main_queue(), {() in
                    completionHandler(image: image, url: urlString)
                })
                return
            }
            
            let downloadTask: NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString)!, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if (error != nil) {
                    completionHandler(image: nil, url: urlString)
                    return
                }
                
                if data != nil {
                    let image = UIImage(data: data!)
                    self.cache.setObject(data!, forKey: urlString)
                    dispatch_async(dispatch_get_main_queue(), {() in
                        completionHandler(image: image, url: urlString)
                    })
                    return
                }
                
            })
            downloadTask.resume()
        })
        
    }
}


