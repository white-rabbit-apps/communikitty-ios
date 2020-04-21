//
//  AboutViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 3/17/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//
import MapKit

class LocationAboutViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var currentLocationObject: WRLocation?
    var googlePlaceDetailsObject: NSDictionary?
    
    @IBOutlet weak var yelpRatingView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var servicesView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var openImage: UIImageView!
    @IBOutlet weak var linksView: UIView!
    
    @IBOutlet weak var openHoursLabel: UILabel!
    @IBOutlet weak var collectionViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var hoursView: UIView!
    @IBOutlet weak var photosView: UIView!
    
    
    @IBOutlet weak var containerPhotoCollection: UIView!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var pinterestButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    
    var yelpUrl:String?
    var googlePlacePhotos: [String?] = []
    var photoViewController: LocationPhotosViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        if self.view.frame.size.width <= 320.0 {
            self.openHoursLabel.font = UIFont.systemFont(ofSize: 13)
        }
        
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.isScrollEnabled = true
        
        if let location = currentLocationObject {
            
            let countryInfo = (location.city != nil ? location.city! : "") + ", " + (location.state != nil ? location.state! : "") + " " + (location.zip != nil ? location.zip! : "")
            addressLabel.text = (location.address != nil ? location.address! : "") + "\n" + countryInfo
            
            self.phoneView.isHidden = true
            self.hoursView.isHidden = true
            self.photosView.isHidden = true
            
            let phoneInfo = location.phone != nil ? location.phone! : ""
            if !phoneInfo.isEmpty {
                self.phoneLabel.text = phoneInfo
                self.phoneView.isHidden = false
            }
            
            let yelpClient = YelpAPIClient()
            self.yelpRatingView.isHidden = true
            
            if let yelpBusinessId = location.yelpBusinessId {
                self.yelpUrl = SocialMediaUrl.yelpUrlSuffix + yelpBusinessId
                yelpClient.getBusinessInformationOf(yelpBusinessId, successSearch: { (data, response) in
                    let jsonObject = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                    
                    if let yelpRating = (((jsonObject as AnyObject).object(forKey:"rating")!) as AnyObject).floatValue {
                        let ratingView = UIView(frame: CGRect(x:self.yelpRatingView.frame.width/2 - 25*CGFloat(ceil(yelpRating))/2,y:30, width:25*CGFloat(ceil(yelpRating)),height:25))
                        
                        if let starImageString = (jsonObject as AnyObject).object(forKey:"rating_img_url")! as? String {
                            
                            if let imageData = NSData(contentsOf: NSURL(string:starImageString)! as URL) {
                                let starImage = UIImageView(frame: CGRect(x:0,y:0,width:25*CGFloat(ceil(yelpRating)),height:25))
                                starImage.image = UIImage(data:imageData as Data)
                                starImage.contentMode = .scaleAspectFill
                                ratingView.addSubview(starImage)
                            }
                        }
                        
                        self.yelpRatingView.addSubview(ratingView)
                        
                        let yelpReviews = (jsonObject as AnyObject).object(forKey:"review_count")! as? Int ?? 0
                        let reviewsLabel = UILabel(frame: CGRect(x:self.yelpRatingView.frame.width/2 - 25*CGFloat(ceil(yelpRating))/2,y:55, width:25*CGFloat(ceil(yelpRating)),height:15))
                        reviewsLabel.text = String(yelpReviews) + " " + "reviews"
                        reviewsLabel.textAlignment = .center
                        reviewsLabel.font = UIFont(name: "Nunito-Regular", size: 10)
                        reviewsLabel.textColor = UIColor.darkGray
                        self.yelpRatingView.addSubview(reviewsLabel)
                        
                    }
                    
                    self.yelpRatingView.isHidden = false
                    }, failureSearch: { (error) in
                        self.showError(message: "Error getting info from Yelp")
                })
                
            }
            
            if let facebookPageId = location.facebookPageId {
                let facebookUrl = SocialMediaUrl.facebookUrlSuffix + facebookPageId
                facebookButton.setTitle(facebookUrl, for: .reserved)
            } else {
                facebookButton.isHidden = true
            }
            
            if let twitterId = location.twitterId {
                let twitterUrl = SocialMediaUrl.twitterUrlSuffix + twitterId
                twitterButton.setTitle(twitterUrl, for: .reserved)
            } else {
                twitterButton.isHidden = true
            }
            
            if let instagramId = location.instagramId {
                let instagramUrl = SocialMediaUrl.instagramUrlSuffix + instagramId
                instagramButton.setTitle(instagramUrl, for: .reserved)
            } else {
                instagramButton.isHidden = true
            }
            
            if let pinterestUrl = location.pinterestId {
                pinterestButton.setTitle(pinterestUrl, for: .reserved)
            } else {
                pinterestButton.isHidden = true
            }
            
            if let website = location.website {
                websiteButton.setTitle(website, for: .reserved)
            } else {
                websiteButton.isHidden = true
            }
            
            if location.facebookPageId == nil && location.twitterId == nil && location.instagramId == nil && location.pinterestId == nil && location.instagramId == nil && location.website == nil {
                self.linksView.isHidden = true
            }
        }
        
    }
    
    
    
    func setupPhotoCollectionView(googlePlacePhotos:[String?]){
        self.googlePlacePhotos = googlePlacePhotos
        self.photosView.isHidden = false
        let locationsStoryboard = UIStoryboard(name: "Locations", bundle: nil)
        
        //create LocationPhotosViewController view controller and pass googlePlacePhotos array
        let vc = locationsStoryboard.instantiateViewController(withIdentifier: "LocationPhotosView") as! LocationPhotosViewController
        vc.googlePlacePhotos = googlePlacePhotos
        //adding child vc to LocationAboutViewController
        self.addChild(vc)
        //setting the vc size equal to container's sizes
        vc.view.frame = CGRect(x:0, y:0, width:self.containerPhotoCollection.frame.size.width, height: self.containerPhotoCollection.frame.size.height)
        self.containerPhotoCollection.addSubview(vc.view)
        //let vc know about its parent vc
        vc.didMove(toParent: self)
    }
    
    
    func setupHours(){
        if let Details = googlePlaceDetailsObject {
            if let openingHours = Details.object(forKey: "opening_hours") {
                if let weekdays = (openingHours as AnyObject).object(forKey: "weekday_text") as? NSArray{
                    let dayTimePeriodFormatter = DateFormatter()
                    dayTimePeriodFormatter.dateFormat = "EEEE"
                    let currentDay = dayTimePeriodFormatter.string(from: NSDate() as Date)
                    for elemnet in weekdays {
                        let dayAndTime = elemnet as? String
                        if dayAndTime!.range(of: currentDay) != nil{
                            self.openHoursLabel.text = dayAndTime
                            break
                        } else {
                            self.openHoursLabel.text = "Closed"
                            self.openImage.isHidden = true
                            self.hoursView.isHidden = false
                        }
                    }
                }
            } else {
                self.hoursView.isHidden = true
            }
            
//            if ((Details as AnyObject).object(forKey:"opening_hours") as AnyObject).object(forKey:"open_now") as? Bool == false {
//                self.openImage.isHidden = true
//            } 
        } else {
            self.hoursView.isHidden = true
        }
    }
    
    
    @IBAction func yeplButtonTap(_ sender: AnyObject) {
        if self.yelpUrl != nil {
            openUrl(url: self.yelpUrl)
        }
    }
    
    @IBAction func mapButtonTap(_ sender: AnyObject) {
        openMapsAppWithDirections()
    }
    
    @IBAction func websiteTap(_ sender: AnyObject) {
        openUrl(url: sender.title(for: .reserved))
    }
    
    @IBAction func facebookTap(_ sender: AnyObject) {
        openUrl(url: sender.title(for: .reserved))
    }
    
    @IBAction func instagramTap(_ sender: AnyObject) {
        openUrl(url: sender.title(for: .reserved))
    }
    
    @IBAction func twitterTap(_ sender: AnyObject) {
        openUrl(url: sender.title(for: .reserved))
    }
    
    @IBAction func pinterestTap(_ sender: AnyObject) {
        openUrl(url: sender.title(for: .reserved))
    }
    
    func openMapsAppWithDirections() {
        if let coordinates = self.getCoordinates() {
            let regionDistance:CLLocationDistance = 10000
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = currentLocationObject?.name
            mapItem.openInMaps(launchOptions: options)
        } else {
            self.showError(message: "This location does not have coordinates")
        }
    }
    
    func getCoordinates() -> CLLocationCoordinate2D? {
        if let locationGeo = currentLocationObject!.geo {
            let latitute:CLLocationDegrees =  locationGeo.latitude
            let longitute:CLLocationDegrees =  locationGeo.longitude
            
            let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
            
            return coordinates
        } else {
            return nil
        }
    }
    
    
    @IBAction func phoneButtonTap(_ sender: AnyObject) {
        if let location = currentLocationObject {
            if let number = location.phone {
                let strippedNumber = number.replacingCharacters(in: number.startIndex..<number.endIndex, with: "")

//                let strippedNumber = number.stringByReplacingOccurrencesOfString("\\D", withString: "", options: .RegularExpressionSearch, range: number.startIndex..<number.endIndex)
                openUrl(url: "tel://" + strippedNumber)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if let location = currentLocationObject {
            if let types = location.types {
                return types.count
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    
    //creating the Cell for services section
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                      for: indexPath as IndexPath)
        if cell.subviews.count > 1{
            cell.subviews[cell.subviews.count-1].removeFromSuperview()
        }
        
        if let location = currentLocationObject {
            
            if let types = location.types {
                
                let currentType = types[indexPath.item]
                
                if(currentType != "_new") {
                    let imageName = "icon_location_type_" + currentType
                    let image = UIImage(named: imageName)
                    if image != nil {
                        let containerView=UIView(frame: CGRect(x:0, y:0, width:86, height:96))
                        
                        let typeLogo = UIImageView(image: image!)
                        typeLogo.contentMode = .scaleAspectFit
                        typeLogo.frame = CGRect(x: 8, y: 2, width: 70, height: 70)
                        containerView.addSubview(typeLogo)
                        
                        let typeName = UILabel(frame: CGRect(x:0, y:75, width:86, height:20))
                        typeName.font = typeName.font.withSize(15)
                        typeName.text = currentType.capitalizeFirstLetter()
                        typeName.textColor = UIColor.gray
                        typeName.textAlignment = .center
                        containerView.addSubview(typeName)
                        
                        
                        self.collectionViewWidthConstraint.constant = 86*CGFloat((types.count))
                        
                        if types.count < 5 {
                            collectionView.isScrollEnabled = false
                            if  indexPath.item == 0 {
                                self.collectionViewCenterXConstraint.constant = 0
                            } else if indexPath.item < 4 {
                                self.collectionViewCenterXConstraint.constant = -86*CGFloat(indexPath.item)/2
                            }
                            
                        } else {
                            self.collectionViewCenterXConstraint.isActive = false
                        }
                        
                        cell.addSubview(containerView)
                        
                    }
                }
            }
        }
        
        
        return cell
    }
    
}



