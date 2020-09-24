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
        
        self.setUpMenuBarController(title: "Find")
    }
    
    
    override func viewDidLayoutSubviews() {
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = UIBezierPath(roundedRect: showListView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        self.showListView.layer.mask = maskLayer

        self.showListView.layer.shadowOpacity = 0.7
        self.showListView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.showListView.layer.shadowRadius = 5.0
        self.showListView.layer.shadowColor = UIColor.lightGray.cgColor
        
        self.showListButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        if UIScreen.main.bounds.width > 400 && !isSearchFieldOpen {
            self.searchViewTrailingConstraint.constant = 329
        }
    }
    
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        
        if fullyRendered {
            NSLog("# annotations: \(mapView.annotations.count). # locations: \(arrayOfLocationsToShow.count)")
        
        //checking if there is more than one current location
        if mapView.annotations.count < 2 {
            let alertController = UIAlertController(title: nil, message: "No results found in this region", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        filterBoardView.isHidden = true
        self.searchTextField.delegate = self
        self.loadingIndicator.isHidden = true
        self.selectedType = SelectedType.Supplies
        
        self.currentLocationView.layer.shadowOpacity = 0.7
        self.currentLocationView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.currentLocationView.layer.shadowRadius = 5.0
        self.currentLocationView.layer.shadowColor = UIColor.lightGray.cgColor

        self.searchView.layer.shadowOpacity = 0.7
        self.searchView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.searchView.layer.shadowRadius = 5.0
        self.searchView.layer.shadowColor = UIColor.lightGray.cgColor
        
        self.showListButton.setTitle("Show List", for: .normal)
        self.showListButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 15)

        self.filterView.layer.shadowOpacity = 0.7
        self.filterView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.filterView.layer.shadowRadius = 5.0
        self.filterView.layer.shadowColor = UIColor.lightGray.cgColor
        
        self.filterBoardView.layer.shadowOpacity = 0.7
        self.filterBoardView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.filterBoardView.layer.shadowRadius = 5.0
        self.filterBoardView.layer.shadowColor = UIColor.lightGray.cgColor
        
//        Answers.logCustomEventWithName("Location Map Opened", customAttributes: nil)

        PFGeoPoint.geoPointForCurrentLocation { (geoPoint: PFGeoPoint?, error: Error?) in
            if error == nil {
                NSLog("got geolocation")
                
//                self.locationsTableController?.currentLocation = geoPoint
//                self.locationsTableController?.dataForTableAndMap()
                
                self.currentLocation = geoPoint
                self.visibleMapRect = self.mapView.visibleMapRect
                
                
                let center = CLLocationCoordinate2D(latitude: (geoPoint?.latitude)!, longitude: (geoPoint?.longitude)!)

                let regionRadius: CLLocationDistance = 5000
                let region = MKCoordinateRegion(center: center, latitudinalMeters: regionRadius * 1.0, longitudinalMeters: regionRadius * 1.0)
                
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
            self.currentLocationView.isHidden = false
            self.searchViewTrailingConstraint.constant = 315
            self.searchView.subviews.last?.removeFromSuperview()
            searchTextField.isHidden = true
            searchFieldViewTapped()
        }
        self.searchTextField.text = nil
        return true
    }
    
    /**
     * Called when the user clicks on the view (outside the UITextField).
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        if isSearchFieldOpen{
            isSearchFieldOpen = false
            self.currentLocationView.isHidden = false
            self.searchViewTrailingConstraint.constant = 315
            self.searchView.subviews.last?.removeFromSuperview()
            searchTextField.isHidden = true
        }
        
        if isFilterBoardOpen{
            isFilterBoardOpen = false
            filterBoardView.isHidden = true
            if isListOpen && isSearchFieldOpen{
                self.searchTextField.isHidden = false
            }

        }

        
    }
    
    
    // return user to his current location
    @IBAction func refreshLocation(sender: AnyObject) {
        let center = CLLocationCoordinate2D(latitude: (self.currentLocation?.latitude)!, longitude: (self.currentLocation?.longitude)!)
        
        let regionRadius: CLLocationDistance = 5000
        let region = MKCoordinateRegion(center: center, latitudinalMeters: regionRadius * 1.0, longitudinalMeters: regionRadius * 1.0)
        
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
        let region = MKCoordinateRegion(center: center, latitudinalMeters: regionRadius * 1.0, longitudinalMeters: regionRadius * 1.0)
        
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
        UIView.animate(withDuration: 0.5, delay: 0.3, options: UIView.AnimationOptions.curveEaseIn, animations:{() in
            // Animate squash
            }, completion:{(Bool) in
                UIView.animate(withDuration: 0.05, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations:{() in
                    annotationView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
                    
                    }, completion: {(Bool) in
                        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations:{() in
                            annotationView.transform = CGAffineTransform.identity
                            }, completion: nil)
                })
                
        })

    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.visibleMapRect = mapView.visibleMapRect
        
        let newCenter = mapView.centerCoordinate
        
        let newCenterGeoPoint  = PFGeoPoint(latitude: newCenter.latitude, longitude: newCenter.longitude)
        
        self.searchNewLocation = newCenterGeoPoint
        
        populateLocations(isNewLocation: true)
       
        
        for annotation in mapView.annotations {
    
            
        let location = annotation.coordinate
            
        //checking if the location is from visible map area
        //if it's from the visible area and hidden, then show this location
            if mapView.visibleMapRect.contains(MKMapPoint(location)){
                let annotationView = mapView.view(for: annotation)
                if annotationView?.isHidden == true {
                annotationView?.isHidden = false
                animateTheAnnotation(annotationView: annotationView!)
                
            }
            
        } else {
            //hide the location which is not in visible area
                let annotationView = mapView.view(for: annotation)
                if annotationView?.isHidden == false {
                annotationView?.isHidden = true
            }
        }

        }
        
    }
    
    
    @IBAction func filterButtonTap(sender: AnyObject) {
        if !isFilterBoardOpen{
            filterBoardView.isHidden = false
            isFilterBoardOpen = true
            if isListOpen && isSearchFieldOpen{
                self.searchTextField.isHidden = true
            }
        } else {
            isFilterBoardOpen = false
            filterBoardView.isHidden = true
            if isListOpen && isSearchFieldOpen{
                self.searchTextField.isHidden = false
            }
        }
    }
    
    @IBAction func searchTap(sender: AnyObject) {
        
        if !isSearchFieldOpen{
        isSearchFieldOpen = true
            self.currentLocationView.isHidden = true
        self.searchViewTrailingConstraint.constant = 0
        
            
            let searchImage = UIImageView()
            
            if UIScreen.main.bounds.width > 400{
                searchImage.frame = CGRect.init(x: 334, y: 5, width: 35, height: 35)
            } else {
                searchImage.frame = CGRect.init(x: 303, y: 5, width: 35, height: 35)
            }
        searchImage.image = UIImage(named: "icon_current_location")
            searchImage.isUserInteractionEnabled = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LocationsMapViewController.searchFieldViewTapped))
            searchImage.addGestureRecognizer(tapGesture)
            
            searchView.addSubview(searchImage)
            searchTextField.isHidden = false
            searchTextField.becomeFirstResponder()
   
        } else {
            isSearchFieldOpen = false
            self.currentLocationView.isHidden = false
            self.searchViewTrailingConstraint.constant = 315
            self.searchView.subviews.last?.removeFromSuperview()
            searchTextField.isHidden = true
            self.searchNewLocation = nil
        }
        
    }
    
    
    //update the map after changing the selected type
    func refreshLocations(){
        if self.searchNewLocation != nil {
            self.arrayOfLocationsToShow = []
            self.clearMap()
            populateLocations(isNewLocation: true)
        }
        else {
            self.clearMap()
            populateLocations()
        }
    }
    
    
    @IBAction func showListTap(sender: AnyObject) {
        
        if !isListOpen{
            self.showListButton.setTitle("Hide List", for: .normal)
            isListOpen = true
            mapViewHeightConstraint.constant = 420
            self.tableView.isHidden = false
            self.triangleImage.image = UIImage(cgImage: (UIImage(named: "icon_expand")?.cgImage)!, scale: 1.0, orientation: .downMirrored)
            
        }
        else {
            isListOpen = false
            self.showListButton.setTitle("Show List", for: .normal)
            mapViewHeightConstraint.constant = 736
            self.triangleImage.image = UIImage(named: "icon_expand")
        }
        
    }
    
    
    @IBAction func rescueButtonTap(sender: AnyObject) {
        let rescueButton = sender as! UIButton
        changeTheFilter(sender: rescueButton)
    }
    
    @IBAction func shelterButtonTap(sender: AnyObject) {
        let shelterButton = sender as! UIButton
        changeTheFilter(sender: shelterButton)
       
    }
    
    @IBAction func boardingButtonTap(sender: AnyObject) {
        let boardingButton = sender as! UIButton
        changeTheFilter(sender: boardingButton)
    }
    
    @IBAction func vetButtonTap(sender: AnyObject) {
        let vetButton = sender as! UIButton
        changeTheFilter(sender: vetButton)
    }
    
    @IBAction func suppliesButtonTap(sender: AnyObject) {
        let suppliesButton = sender as! UIButton
        changeTheFilter(sender: suppliesButton)
    }
    
    
    @IBAction func sittingButtonTap(sender: AnyObject) {
        let sittingButton = sender as! UIButton
        changeTheFilter(sender: sittingButton)
    }
    
    @IBAction func groomingButtonTap(sender: AnyObject) {
        let groomingButton = sender as! UIButton
        changeTheFilter(sender: groomingButton)
    }
    
    @IBAction func hospitalButtonTap(sender: AnyObject) {
        let hospitalButton = sender as! UIButton
        changeTheFilter(sender: hospitalButton)
    }
    
    
    @IBAction func cafeButtonTap(sender: AnyObject) {
        let cafeButton = sender as! UIButton
        changeTheFilter(sender: cafeButton)
    }
    
    func changeTheFilter(sender: UIButton){
        self.filterBoardView.isHidden = true
        self.isFilterBoardOpen = false
        
        switch sender.tag {
        case 0:
            self.filterButton.setImage(UIImage(named: "icon_location_type_emergency"), for: .normal)
            self.filterLabel.text = "Hospital"
            self.selectedType = SelectedType.Hospital
        case 1:
            self.filterButton.setImage(UIImage(named: "icon_location_type_rescue"), for: .normal)
            self.filterLabel.text = "Rescue"
            self.selectedType = SelectedType.Rescue
        case 2:
            self.filterButton.setImage(UIImage(named: "icon_location_type_shelter"), for: .normal)
            self.filterLabel.text = "Shelter"
            self.selectedType = SelectedType.Shelter
        case 3:
            self.filterButton.setImage(UIImage(named: "icon_location_type_vet"), for: .normal)
            self.filterLabel.text = "Vet"
           self.selectedType = SelectedType.Vet
        case 4:
            self.filterButton.setImage(UIImage(named: "icon_location_type_sitting"), for: .normal)
            self.filterLabel.text = "Sitting"
            self.selectedType = SelectedType.Sitting
        case 5:
            self.filterButton.setImage(UIImage(named: "icon_location_type_boarding"), for: .normal)
            self.filterLabel.text = "Boarding"
            self.selectedType = SelectedType.Boarding
        case 6:
            self.filterButton.setImage(UIImage(named: "icon_location_type_supplies"), for: .normal)
            self.filterLabel.text = "Supplies"
            self.selectedType = SelectedType.Supplies
        case 7:
            self.filterButton.setImage(UIImage(named: "icon_location_type_grooming"), for: .normal)
            self.filterLabel.text = "Grooming"
            self.selectedType = SelectedType.Grooming
        case 8:
            self.filterButton.setImage(UIImage(named: "icon_location_type_cafe"), for: .normal)
            self.filterLabel.text = "Cafe"
            self.selectedType = SelectedType.Cafe
        default: "No such button"
        }
        if isListOpen && isSearchFieldOpen{
            self.searchTextField.isHidden = false
        }
        refreshLocations()

    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        self.loadingIndicator.isHidden = true

    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        let reuseId = "pin"
        
        var annotationView: MKAnnotationView?
        
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) {
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
                let customView = customAnnotationView(frame: CGRect.init(x: 0, y: 0, width: 33, height: 48), objImage: (locationAnnotation.image?.image)!)
                customView.canShowCallout = false
                
                annotationView = customView
                
                let location = locationAnnotation.coordinate
                
                if self.visibleMapRect!.contains(MKMapPoint(location)){
                    annotationView?.isHidden = false
                } else {
                    annotationView?.isHidden = true
                }
            }
        }
        
        return annotationView!
        
    }

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation {
            // Don't proceed with custom callout
            return
        }
        
        let objectAnnotation = view.annotation as! Location
        
        let iconView = UIImageView(frame: CGRect.init(x: 2, y: 2, width: 29, height: 29))
        iconView.image = objectAnnotation.image?.image
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = iconView.frame.width/2
        iconView.backgroundColor = UIColor.white
        
        let annotationLabel = UILabel()
        annotationLabel.text = objectAnnotation.title
        let labelSize = self.estimatedLabelSize(label: annotationLabel)
        annotationLabel.frame = CGRect.init(x: 36, y: 5, width: ceil(labelSize.width)+10, height: 25)
        
        let arrowImage = UIImageView(frame: CGRect.init(x: 38+annotationLabel.frame.width, y: 10, width: 15, height: 15))
        arrowImage.image = UIImage(named: "icon_row_arrow")
        
        let annotationViewWidth = iconView.frame.width + annotationLabel.frame.width + arrowImage.frame.width + 14
        
        let calloutView = CustomCalloutView(frame: CGRect.init(x: 0, y: 0, width: annotationViewWidth, height: 34), rightImage: iconView, calloutLabel: annotationLabel, calloutArrow: arrowImage)
        calloutView.backgroundColor = UIColor.white
        calloutView.layer.cornerRadius = 10
        calloutView.layer.borderColor = UIColor.red.cgColor
        calloutView.layer.borderWidth = 1

        self.currentView = view
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LocationsMapViewController.openLocationDetail))
        tapGesture.numberOfTapsRequired = 1
        calloutView.addGestureRecognizer(tapGesture)
        
        view.addSubview(calloutView)
    }

 
    var currentView: MKAnnotationView?
    
    @objc func openLocationDetail() {
        performSegue(withIdentifier: "MapToLocationDetail", sender: self.currentView)
    }
    
    var localSearchRequest:MKLocalSearch.Request!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearch.Response!
    var error:NSError!
    var searchNewLocation: PFGeoPoint?
    
    @objc func searchFieldViewTapped(){
        var text = String()
        if !(self.searchTextField.text?.isEmpty)! {
            text = self.searchTextField.text!
            
            localSearchRequest = MKLocalSearch.Request()
            localSearchRequest.naturalLanguageQuery = text
            localSearch = MKLocalSearch(request: localSearchRequest)
            localSearch.start { (localSearchResponse, error) -> Void in
                
                if localSearchResponse == nil{
                    let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                let center = CLLocationCoordinate2D(latitude: (localSearchResponse!.boundingRegion.center.latitude), longitude: (localSearchResponse!.boundingRegion.center.longitude))
                
                let regionRadius: CLLocationDistance = 5000
                let region = MKCoordinateRegion(center: center, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
                
                self.mapView.setRegion(region, animated: true)
                
                self.searchNewLocation = PFGeoPoint.init(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
                self.clearMap()
                self.arrayOfLocationsToShow = []
                self.populateLocations(isNewLocation: true)
            }
        }
    }
    
    
    func estimatedLabelSize(label: UILabel) -> CGSize {
        guard let text = label.text else { return .zero }
        return NSString(string: text).boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: label.font], context: nil).size
    }

    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: MKAnnotationView.self) {
            let lastSubview = view.subviews.last
            lastSubview!.removeFromSuperview()
        }
    }

    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller
        if(segue.identifier == "MapToLocationDetail") {
            NSLog("performing maptolocation")
            let detailScene = segue.destination as! LocationDetailViewController

            let annotationView = sender as! MKAnnotationView
            let annotation = annotationView.annotation as? Location
            
            detailScene.currentLocationObject = annotation?.location
        } else if(segue.identifier == "LocationTableEmbed") {
            
            let tableScene = segue.destination as! LocationsTableViewController
            tableScene.mapViewController = self
            tableScene.selectedType = (self.selectedType.rawValue)
            self.locationsTableController = tableScene
        }
    }
    
    func populateLocations(isNewLocation:Bool = false){
        
        let query : PFQuery = WRLocation.query()!
        query.whereKey("types", contains: (self.selectedType.rawValue))
        query.whereKey("animals", contains: "cats")
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
        
        query.findObjectsInBackground { (objects, error) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        
                        let location = Location(locationObject: object as! WRLocation)
                        
                        if self.arrayOfLocationsToShow.count == 0 {
                            self.arrayOfLocationsToShow.append(location)
                            self.loadingIndicator.isHidden = false
                            location.loadImage(comp: { (image:UIImage?) in
                                self.addLocationToMap(location: location)
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
                                self.loadingIndicator.isHidden = false
                                location.loadImage(comp: { (image:UIImage?) in
                                    self.addLocationToMap(location: location)
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
    
    
    func loadImage(comp: @escaping (_ image:UIImage)->()){
        
        let pinImage = UIImageView()
        
        if self.logoFileURL != nil {
            
            ImageLoader.sharedLoader.imageForUrl(urlString: self.logoFileURL!) {(image: UIImage?, url: String) in
                if image != nil{
                pinImage.image = image!
                self.image = pinImage
                    comp(image!)
                } else {
                    let imgView = UIImageView()
                    imgView.image = UIImage(named: "form_traits")
                    self.image = imgView
                    comp((self.image?.image)!)
                }
            }
        
        } else {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "form_traits")
        self.image = imgView
            comp((self.image?.image)!)
        }
    
    }

}


class customAnnotationView: MKAnnotationView {
    var objectImage = UIImage()
    
    init(frame: CGRect, objImage:UIImage){
        self.objectImage = objImage
        
        let imgView = UIView(frame: CGRect.init(x: 0, y: 0, width: 33, height: 48))
        let pinImage = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 33, height: 48))
        pinImage.image = UIImage(named: "icon_map_marker")
        
        
        let objectImage = UIImageView(frame: CGRect.init(x: 2, y: 2, width: 29, height: 29))
        objectImage.layer.cornerRadius = objectImage.frame.width/2
        objectImage.contentMode = .scaleAspectFill
        objectImage.image = self.objectImage
        objectImage.clipsToBounds = true
        objectImage.backgroundColor = UIColor.white
        
        imgView.addSubview(pinImage)
        
        imgView.addSubview(objectImage)
        
        super.init(annotation: nil, reuseIdentifier: nil)
        self.addSubview(imgView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // need this to capture button taps since they are outside of self.frame
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {        for subview: UIView in self.subviews {
            if subview.frame.contains(point) {
                return subview
            }
        }
        // use this to pass the 'touch' onward in case no subviews trigger the touch
        return super.hitTest(point, with: event)
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
    
    var cache = NSCache<AnyObject, AnyObject>()
    
    class var sharedLoader : ImageLoader {
        struct Static {
            static let instance : ImageLoader = ImageLoader()
        }
        return Static.instance
    }
    
    func imageForUrl(urlString: String, completionHandler: @escaping(_ image: UIImage?, _ url: String) -> ()) {
        DispatchQueue.global().async {
            let data: NSData? = self.cache.object(forKey: urlString as AnyObject) as? NSData
            
            if let goodData = data {
                let image = UIImage(data: goodData as Data)
//                dispatch_async(dispatch_get_main_queue(), {() in
                completionHandler(image, urlString)
//                })
                return
            }
            
            let downloadTask: URLSessionDataTask = URLSession.shared.dataTask(with: URL(string: urlString)!) { (data: Data?, url: URLResponse?, error: Error?) in
                if (error != nil) {
                    completionHandler(nil, urlString)
                    return
                }

                if data != nil {
                    let image = UIImage(data: data!)
                    self.cache.setValue(data!, forKey: urlString)
//                    dispatch_async(dispatch_get_main_queue(), {() in
//                        completionHandler(image: image, url: urlString)
//                    })
                    return
                }
            }
            
//            let downloadTask: URLSessionDataTask =  URLSession.shared.dataTask(with: NSURL(string: urlString)!) { (data: Data?, response: URLResponse?, error: Error?) in
//                if (error != nil) {
//                    completionHandler(image: nil, url: urlString)
//                    return
//                }
//
//                if data != nil {
//                    let image = UIImage(data: data!)
//                    self.cache.setObject(data!, forKey: urlString)
//                    dispatch_async(dispatch_get_main_queue(), {() in
//                        completionHandler(image: image, url: urlString)
//                    })
//                    return
//                }
//            }
            downloadTask.resume()
        }
        
    }
}


