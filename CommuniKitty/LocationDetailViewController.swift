//
//  LocationDetailViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/18/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import MapKit
import PagingMenuController
import AFNetworking


private struct MenuOptions: MenuViewCustomizable {
    var displayMode: MenuDisplayMode
    var focusMode: MenuFocusMode {
        return .underline(height: 2.0, color: UIColor.lightGray, horizontalPadding: 0.0, verticalPadding: 0.0)
    }
    
    var itemsOptions: [MenuItemViewCustomizable]
    init(itemsOptions: [MenuItemViewCustomizable], displayMode: MenuDisplayMode){
        self.itemsOptions = itemsOptions
        self.displayMode = displayMode
    }
}

struct GoogleAPIConsole {
    var googleApiKey = "AIzaSyA777LCuxStL6AHBeGsJ-A-3ww3yiBj9G8"
    var googlePhotoBaseUrl = "https://maps.googleapis.com/maps/api/place/photo?"
    var googlePlaceDetailBaseUrl = "https://maps.googleapis.com/maps/api/place/details/json?"
}

class LocationDetailViewController: UIViewController,UITabBarDelegate,PagingMenuControllerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var logoButton: UIButton!
    
    @IBOutlet weak var address1Label: UILabel!
    @IBOutlet weak var cityStateZipLabel: UILabel!
    
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var yelpButton: UIButton!
    @IBOutlet weak var youtubeButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var pinterestButtone: UIButton!
    
    @IBOutlet weak var yelpRatingView: UIStackView!
    @IBOutlet weak var socialStackView: UIStackView!
    
    @IBOutlet weak var phoneNumberButton: UIButton!
    
    @IBOutlet weak var directionsButton: UIButton!
    
    @IBOutlet weak var customTabBar: UITabBar!
    
    
    var aboutViewController : LocationAboutViewController?
    var photosViewController : LocationPhotosViewController?
    var aboutAndPhotosTabs: PagingMenuController?
    
    var currentLocationObject: WRLocation?
    
    let googleApi = GoogleAPIConsole()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpNavigationBar()
        self.setUpTransparentNavigationBar()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.setUpTransparentNavigationBar()
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(UIViewController.goBack))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
       
        //let yelpClient = YelpAPIClient()
        if let location = currentLocationObject {
            print("Location Object==",location)
            nameLabel.text = location.name
            self.setUpNavigationBar(title: location.name!)
            
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
                pinterestButtone.setTitle(pinterestUrl, for: .reserved)
            } else {
                pinterestButtone.isHidden = true
            }
            
            // make api call to get details of place using google place api
            if let googlePlaceId = location.googlePlaceId {
                
                let manager = AFHTTPSessionManager()
                
                // generate request url using google place id and api key to get place details as per bellow sample
                //https://maps.googleapis.com/maps/api/place/details/json?reference=CmRYAAAAciqGsTRX1mXRvuXSH2ErwW-jCINE1aLiwP64MCWDN5vkXvXoQGPKldMfmdGyqWSpm7BEYCgDm-iv7Kc2PF7QA7brMAwBbAcqMr5i1f4PwTpaovIZjysCEZTry8Ez30wpEhCNCXpynextCld2EBsDkRKsGhSLayuRyFsex6JA6NPh9dyupoTH3g&key=YOUR_API_KEY
                //test place id(replace it with googlePlaceId to get all information) = ChIJESa_DZ-AhYARew11kFkbGLc
                let googleRequestUrl = googleApi.googlePlaceDetailBaseUrl + "placeid=" + googlePlaceId + "&key=" + googleApi.googleApiKey
                
                manager.get(googleRequestUrl, parameters: nil, progress: { (progress: Progress) in
                    }, success: { (task: URLSessionDataTask, responseObject: Any?) in
                        self.setupAboutAndPhotosView((responseObject as! NSDictionary).object(forKey: "result") as! NSDictionary)
                    }, failure: { (task: URLSessionDataTask?, error: Error) in
                        self.setupAboutAndPhotosView(NSDictionary())
                })
                
            } else {
                self.setupAboutAndPhotosView(NSDictionary())
            }
                       
            //            if let yelpBusinessId = location.yelpBusinessId {
            //                // let yelpUrl = SocialMediaUrl.yelpUrlSuffix + yelpBusinessId
            //                // yelpButton.setTitle(yelpUrl, forState: .Reserved)
            //                yelpRatingView.isHidden = true
            //                yelpClient.getBusinessInformationOf(yelpBusinessId, successSearch: { (data, response) in
            //                    let jsonObject = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
            //
            //                    //                    let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
            //                    //                    print(dataString)
            //
            //                    print(jsonObject.valueForKey("rating_img_url")!)
            //                    print("rating=",jsonObject.valueForKey("rating")!)
            //                    print(jsonObject.valueForKey("location")!)
            //                    print(jsonObject.valueForKey("reviews")!)
            //                    var yelpRating = jsonObject.valueForKey("rating")!.integerValue
            //                    while yelpRating < 5 {
            //                        let starImage = self.yelpRatingView.viewWithTag(yelpRating)
            //                        starImage!.isHidden = true
            //                        yelpRating! += 1
            //                    }
            //                    self.yelpRatingView.isHidden = false
            //                    }, failureSearch: { (error) in
            //                        self.showError("Error getting info from Yelp")
            //                })
            //
            //            } else {
            //                yelpRatingView.isHidden = true
            //            }
            
            if let logoFile = location.logo {
                //self.logoImage.kf_setImage(with: NSURL(string: logoFile.url!)!)
                logoFile.getDataInBackground(block: {
                    (imageData: Data?, error: Error?) -> Void in
                    if(error == nil) {
                        let image = UIImage(data:imageData!)
                        if image != nil {
                            self.logoButton.setImage(image, for: UIControlState())
                        }
                    }
                })
                
            }
        }
        
        self.setupCustomTabbar()
    }
    
    func setupCustomTabbar() -> Void {
        
        self.customTabBar.barTintColor = UIColor.init(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
        self.customTabBar.tintColor = UIColor.init(red: 37/255, green: 72/255, blue: 104/255, alpha: 1.0)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:self.customTabBar.tintColor], for: UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:self.customTabBar.tintColor], for: UIControlState.selected)
        
        let tabbarMapItem = self.customTabBar.items![0] as UITabBarItem
        tabbarMapItem.image = UIImage(named: "icon_map")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabbarMapItem.selectedImage = tabbarMapItem.image
        
        let tabbarCallItem = self.customTabBar.items![1] as UITabBarItem
        tabbarCallItem.image = UIImage(named: "icon_call")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabbarCallItem.selectedImage = tabbarCallItem.image
        
        let tabbarWebItem = self.customTabBar.items![2] as UITabBarItem
        tabbarWebItem.image = UIImage(named: "icon_website")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabbarWebItem.selectedImage = tabbarWebItem.image
        
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if tabBar.items![0] == item {
            //map button clicked
            openMapsAppWithDirections()
        } else if tabBar.items![1] == item {
            //call button clicked
            if let location = currentLocationObject {
                if let number = location.phone {
                    let strippedNumber = number.replacingOccurrences(of: "\\D", with: "", options: .regularExpression, range: number.rangeOfCharacter(from: .alphanumerics))
                    openUrl(url: "tel://" + strippedNumber)
                }
            }
            
        } else if tabBar.items![2] == item {
            //website button cliecked
            if let location = currentLocationObject {
                if let website = location.website {
                    openUrl(url: website)
                }
            }
        }
    }
    
    @IBAction func openWebsite(_ sender: UIButton) {
        openUrl(url: sender.title(for: .reserved))
    }
    
    @IBAction func callPhoneNumber(_ sender: UIButton) {
        if let number = sender.title(for: UIControlState()) as String? {
            let strippedNumber = number.replacingOccurrences(of: "\\D", with: "", options: .regularExpression, range: number.rangeOfCharacter(from: .alphanumerics))
            openUrl(url: "tel://" + strippedNumber)
        }
    }
    
    @IBAction func openDirections(_ sender: UIButton) {
        openMapsAppWithDirections()
    }
    
    func openMapsAppWithDirections() {
        if let coordinates = self.getCoordinates() {
            let regionDistance:CLLocationDistance = 10000
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            
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
    
    func setupAboutAndPhotosView(_ sender: NSDictionary) -> Void {
        let aboutViewController = self.storyboard?.instantiateViewController(withIdentifier: "LocationAboutView") as! LocationAboutViewController
        self.aboutViewController = aboutViewController
        self.aboutViewController!.currentLocationObject = self.currentLocationObject
        self.aboutViewController!.googlePlaceDetailsObject = sender

        var  viewControllers = [UIViewController]()
        var title1 = ""
        var title2 = ""
        
        // check if photos are availbe for the google place then only add photos tab
        if let photosArray = sender.object(forKey: "photos") as? NSArray {
            
            //create imageWithInfo array to show full screen image slidshow
            var imagesWithInfo = [String?](repeating: nil, count: photosArray.count)
            
            for (index, object) in photosArray.enumerated() {
                let photo = object as? NSDictionary
                // generate photo url using photo reference and api key to get actule photo url as per bellow sample
                //https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=CnRtAAAATLZNl354RwP_9UKbQ_5Psy40texXePv4oAlgP4qNEkdIrkyse7rPXYGd9D_Uj1rVsQdWT4oRz4QrYAJNpFX7rzqqMlZw2h2E2y5IKMUZ7ouD_SlcHxYq1yL4KbKUv3qtWgTK0A6QbGh87GB3sscrHRIQiG2RrmU_jF4tENr9wGS_YxoUSSDrYjWmrNfeEHSGSc3FyhNLlBU&key=YOUR_API_KEY
                let photoWidth = "maxwidth=" + (NSString(format: "%.f", self.view!.frame.size.width) as String)
                let phototReference = "&photoreference=" + ((photo?.object(forKey: "photo_reference"))! as! String)
                let photoKeys = "&key=" + googleApi.googleApiKey
                
                let photoUrl = googleApi.googlePhotoBaseUrl + photoWidth + phototReference + photoKeys
               
                imagesWithInfo[index] = photoUrl
            }
            
            let photosViewController = self.storyboard?.instantiateViewController(withIdentifier: "LocationPhotosView") as! LocationPhotosViewController
            self.photosViewController = photosViewController
            self.photosViewController!.googlePlacePhotos = imagesWithInfo

            viewControllers  = [self.aboutViewController!, self.photosViewController!]
            title1 = self.aboutViewController?.title ?? ""
            title2 = self.photosViewController?.title ?? ""
        } else {
            viewControllers  = [self.aboutViewController!]
             title1 = self.aboutViewController?.title ?? ""
        }
        let width = (UIApplication.shared.keyWindow?.bounds.width)!/CGFloat(viewControllers.count)+2 
        
        var optionItems = [MenuItemViewCustomizable]()
        if viewControllers.count == 1{
            var aboutPage = MenuItemCustom(title: title1, imageName: "tab_icon_about")
            aboutPage.imageFrame = CGRect(x: width/2-2*25, y: (50-25)/2 , width: 25, height: 25)
            aboutPage.labelFrame = CGRect(x: width/2-25+10, y: 0, width: 100, height: 50)
            aboutPage.numberOfPages = viewControllers.count
            optionItems = [aboutPage]
        } else if viewControllers.count == 2 {
            var aboutPage = MenuItemCustom(title: title1, imageName: "tab_icon_about")
            aboutPage.imageFrame = CGRect(x: width/2-2*25, y: (50-25)/2 , width: 25, height: 25)
            aboutPage.labelFrame = CGRect(x: width/2-25+10, y: 0, width: 100, height: 50)
            aboutPage.numberOfPages = viewControllers.count
            
            var photoPage = MenuItemCustom(title: title2, imageName: "tab_icon_photos")
            photoPage.imageFrame = CGRect(x: width/2-2*25, y: (50-25)/2 , width: 25, height: 25)
            photoPage.labelFrame = CGRect(x: width/2-25+10, y: 0, width: 100, height: 50)
            photoPage.numberOfPages = viewControllers.count
            optionItems = [aboutPage, photoPage]
        }
        
        let menuOptions = MenuOptions(itemsOptions: optionItems, displayMode: .segmentedControl)
        
        let options = PagingMenuOptions(pagingControllers: viewControllers, menuOptions: menuOptions)

        self.aboutAndPhotosTabs!.setup(options)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "LocationDetailTabsEmbed") {
            let profileTabs = segue.destination as! PagingMenuController
            self.aboutAndPhotosTabs = profileTabs
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
