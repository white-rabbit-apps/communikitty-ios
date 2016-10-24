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
    @IBOutlet weak var logoButton: UIButton!
    
    var aboutViewController : LocationAboutViewController?
    
    var currentLocationObject: WRLocation?
    
    let googleApi = GoogleAPIConsole()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTransparentNavigationBar()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(UIViewController.goBack))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        if let location = currentLocationObject {
            print("Location Object==",location)
            nameLabel.text = location.name
            
            // make api call to get details of place using google place api
            if let googlePlaceId = location.googlePlaceId {
                
                let manager = AFHTTPSessionManager()
                
                // generate request url using google place id and api key to get place details as per bellow sample
                //https://maps.googleapis.com/maps/api/place/details/json?reference=CmRYAAAAciqGsTRX1mXRvuXSH2ErwW-jCINE1aLiwP64MCWDN5vkXvXoQGPKldMfmdGyqWSpm7BEYCgDm-iv7Kc2PF7QA7brMAwBbAcqMr5i1f4PwTpaovIZjysCEZTry8Ez30wpEhCNCXpynextCld2EBsDkRKsGhSLayuRyFsex6JA6NPh9dyupoTH3g&key=YOUR_API_KEY
                //test place id(replace it with googlePlaceId to get all information) = ChIJESa_DZ-AhYARew11kFkbGLc or ChIJN1t_tDeuEmsRUsoyG83frY4
                let googleRequestUrl = googleApi.googlePlaceDetailBaseUrl + "placeid=" + googlePlaceId + "&key=" + googleApi.googleApiKey

                manager.get( googleRequestUrl,
                            parameters: nil,
                            progress :nil,
                            success: { (operation: URLSessionDataTask!, responseObject: Any!) in
                                print("JSON: " ,(responseObject as AnyObject).object(forKey:"result"))
                                self.setupAboutView(sender: ((responseObject as AnyObject).object(forKey:"result") as? NSDictionary)!)
                    },
                            failure: { (operation: URLSessionDataTask?, error: Error!) in
                                print("Error: " + error.localizedDescription)
                                self.setupAboutView(sender: NSDictionary())
                })
                
            } else {
                self.setupAboutView(sender: NSDictionary())
            }
            
            
            if let logoFile = location.logo {
                //self.logoImage.kf_setImageWithURL(NSURL(string: logoFile.url!)!)
                logoFile.getDataInBackground(block: {
                    (data: Data?, error: Error?) -> Void in
                    if(error == nil) {
                        let image = UIImage(data:data!)
                        if image != nil {
                            self.logoButton.setImage(image, for: UIControlState.normal)
                        }
                    }
                })
                
            }
            
//            Answers.logContentViewWithName("Profile",
//                                           contentType: "Location",
//                                           contentId: self.currentLocationObject!.objectId!,
//                                           customAttributes: ["locationName": self.currentLocationObject!.name!])
        }
        
    }
    
    
    
    func setupAboutView(sender: NSDictionary) -> Void {
        
        self.aboutViewController!.googlePlaceDetailsObject = sender
        self.aboutViewController!.setupHours()
        
        
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
            self.aboutViewController!.setupPhotoCollectionView(googlePlacePhotos: imagesWithInfo)
            
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ShelterToAnimalsTable") {
//            let tableViewController = segue.destinationViewController as! AnimalsTableViewController
//            tableViewController.locationDetailController = self
//            tableViewController.shelter = self.currentLocationObject
        }
        else if(segue.identifier == "LocationDetailsEmbed") {
            
            let aboutController = segue.destination as! LocationAboutViewController
            self.aboutViewController = aboutController
            aboutController.currentLocationObject = self.currentLocationObject
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
