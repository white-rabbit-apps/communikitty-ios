//
//  BreedDetailViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 9/17/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import MMMarkdown

class BreedDetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var breedImage: UIImageView!

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var sheddingButton: UIButton!
    @IBOutlet weak var groomingButton: UIButton!
    @IBOutlet weak var weightRangeButton: UIButton!
    @IBOutlet weak var lifeExpectancyRangeButton: UIButton!
    
    @IBOutlet weak var lapCatButton: UIButton!
    @IBOutlet weak var hypoallergenicButton: UIButton!
    
    var currentBreedObject : WRBreed?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigationBar()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(UIViewController.goBack))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        if let breed = currentBreedObject {
            self.setUpNavigationBar(title: breed.name!)

            if let imageFile = breed.image {
//                self.breedImage.kf_showIndicatorWhenLoading = true
//                self.breedImage.kf.setImage(with: URL(string: imageFile.url!)!, placeholder: nil)
            }

            nameLabel.text = breed.name!

            if let type = breed.type {
                typeButton.setTitle(type, for: UIControlState())
            } else {
                typeButton.setTitle("Unknown", for: UIControlState())
            }
            
            if let country = breed.originCountry {
                countryButton.setTitle(country, for: UIControlState())
            } else {
                countryButton.setTitle("Unknown", for: UIControlState())
            }
            
            if let shedding = breed.sheddingFrequency {
                sheddingButton.setTitle(shedding, for: UIControlState())
            } else {
                sheddingButton.setTitle("Unknown", for: UIControlState())
            }
            
            if let grooming = breed.groomingFrequency {
                groomingButton.setTitle(grooming, for: UIControlState())
            } else {
                groomingButton.setTitle("Unknown", for: UIControlState())
            }
            
            let minLifeExpectancy = breed.minLifeExpectancy
            let maxLifeExpectancy = breed.maxLifeExpectancy
            if(minLifeExpectancy != nil && maxLifeExpectancy != nil) {
                lifeExpectancyRangeButton.setTitle("\(minLifeExpectancy!) - \(maxLifeExpectancy!) years", for: UIControlState())
            } else {
                lifeExpectancyRangeButton.setTitle("Unknown", for: UIControlState())
            }
            
            let minWeight = breed.minWeightLbs
            let maxWeight = breed.maxWeightLbs
            if(minWeight != nil && maxWeight != nil) {
                weightRangeButton.setTitle("\(minWeight!) - \(maxWeight!) lbs", for: UIControlState())
            } else {
                weightRangeButton.setTitle("Unknown", for: UIControlState())
            }
            
            if let lapCat = breed.lapCat {
                if lapCat {
                    lapCatButton.setTitle("Yes", for: UIControlState())
                } else {
                    lapCatButton.setTitle("No", for: UIControlState())
                }
            } else {
                lapCatButton.setTitle("Unknown", for: UIControlState())
            }
            
            if let hypoallergenic = breed.hypoallergenic {
                if hypoallergenic {
                    hypoallergenicButton.setTitle("Yes", for: UIControlState())
                } else {
                    hypoallergenicButton.setTitle("No", for: UIControlState())
                }
            } else {
                hypoallergenicButton.setTitle("Unknown", for: UIControlState())
            }
            
            if let imageFile = breed["image"] as? PFFile {
//                self.breedImage.kf_showIndicatorWhenLoading = true
//                self.breedImage.kf.setImage(with: URL(string: imageFile.url!)!, placeholder: nil)
            }
            
//            let appDelegate = AppDelegate.getAppDelegate()
//            appDelegate.client?.fetchAssets(success: {(response: CDAResponse, entry: CDAArray) -> Void in
//                
//                let content = breed["description"] as? String
//                var markDownText : String!
//                do {
//                    if content != nil {
//                        markDownText = try MMMarkdown.htmlString(withMarkdown: content!)
//                    }
//                } catch _ {
//                    print("Something went wrong converting markdown!")
//                }
//                let markDownString = NSString(format: "<html><body style=\"font-family:'Nunito-Regular';font-size:16px;padding: 10px; padding-top: 50px; padding-bottom: 80px;\">%@</body></html>", markDownText).replacingOccurrences(of: "//", with: "https://") as String
//                
//                let attrStr = try! NSAttributedString(
//                    data: markDownString.data(using: String.Encoding.unicode)!,
//                    options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8, NSStrikethroughStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue],
//                    documentAttributes: nil)
//                                
//               self.descriptionLabel.attributedText = attrStr
//
//                }, failure: { (response: CDAResponse?, error: Error) -> Void in
//                    NSLog("error getting entry: \(error)")
//                    //self.hideLoader()
//                    self.showError(message: error.localizedDescription)
//            })
//            
        }
    }
}
