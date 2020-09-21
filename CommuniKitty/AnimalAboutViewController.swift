//
//  AnimalAboutViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 12/2/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import Parse
import Eureka

class AnimalAboutViewController: UIViewController, UIScrollViewDelegate{

    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var hatesView: UIView!
    @IBOutlet weak var lovesView: UIView!
    @IBOutlet weak var traitsView: UIView!
    @IBOutlet weak var coatView: UIView!
    @IBOutlet weak var breedView: UIView!
    @IBOutlet weak var introView: UIView!
    
    @IBOutlet weak var coatButton: UIButton!
    @IBOutlet weak var breedButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var eyesView: UIView!
    @IBOutlet weak var traitsObjectsView: UIView!
    
    @IBOutlet weak var hatesLabel: UILabel!
    @IBOutlet weak var lovesLabel: UILabel!
    @IBOutlet weak var traitsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var trObViewHeightConstraint: NSLayoutConstraint!
    var animalObject : [String:Any]?
    var traitObjects : [WRTrait?] = []
    var traitsArray: [String?] = []
    var loveObjects:[String?] = []
    var breedObject : WRBreed?
    
    var currentUserIsOwner : Bool = false
    
    var animalDetailController : AnimalDetailViewController?
    var animalTimelineViewController: AnimalTimelineTableViewController?
    
    @IBAction func breedButtonPressed(_ sender: AnyObject) {
        if let breed =  animalObject?["breed"] as? [String: Any]{
            self.performSegue(withIdentifier: "AboutToBreedDetail", sender: self)
        } else if currentUserIsOwner {
            let breedRow = RowOf<Breed>(tag: "Breed")
            let bvc = self.storyboard?.instantiateViewController(withIdentifier: "BreedsTableView") as! BreedsTableViewController
            
            bvc.row = breedRow
            bvc.completionCallback = { vc in
                
//                if let breedValue = breedRow.value {
//                    self.animalObject!.breed = breedValue.object!
//                }
                
//                self.animalObject!.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
//                    self.hideLoader()
//                    if error == nil {
//                        let appDelegate = AppDelegate.getAppDelegate()
//                        appDelegate.loadMyAnimals()
//                    }
//                    else {
//                        self.showError(message: error!.localizedDescription)
//                    }
//                })
                
                _ = vc.navigationController?.popViewController(animated: true)
            }
            self.show(bvc, sender: self)
        }
    }
    
    @IBAction func coatButtonPressed(_ sender: AnyObject) {
        if let _ = animalObject?["coat"] as? [String: Any] {
        } else if currentUserIsOwner {
            let coatRow = RowOf<Coat>(tag: "Coat")
            let cvc = self.storyboard?.instantiateViewController(withIdentifier: "CoatsTableView") as! CoatsTableViewController
            
            cvc.row = coatRow
            cvc.completionCallback = { vc in
//                if let coatValue = coatRow.value {
//                    self.animalObject!.coat = coatValue.object
//                }
                
//                self.animalObject!.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
//                    self.hideLoader()
//                    if error == nil {
//                        AppDelegate.getAppDelegate().loadMyAnimals()
//                    } else {
//                        self.showError(message: error!.localizedDescription)
//                    }
//                })
                
                _ = vc.navigationController?.popViewController(animated: true)
            }
            self.show(cvc, sender: self)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y <= 0 ) {
            self.scrollView.isScrollEnabled = false
        } else {
            self.scrollView.isScrollEnabled = true
        }
    }
    
    func loadLoves() {
        var text = ""
        if let loves = animalObject?["loves"] as? [[String:Any]]{
            if loves.count > 0 {
                for love in loves {
                    let bulletPoint: String = "\u{2022}"
                    let formattedString: String = "\(bulletPoint) \(love["text"] as? String ?? "")\n"
                    text = text + formattedString
                }
                self.lovesLabel.text = text
                self.lovesView.isHidden = false
            } else {
                self.lovesView.isHidden = true
            }
        } else {
            self.lovesView.isHidden = true
        }
    }
    
    
    func loadHates() {
        var text = ""
        if let hates = animalObject?["hates"] as? [[String:Any]]{
            if hates.count > 0 {
                for hate in hates {
                    let bulletPoint: String = "\u{2022}"
                    let formattedString: String = "\(bulletPoint) \(hate["text"] as? String ?? "")\n"
                    text = text + formattedString
                }
                self.hatesLabel.text = text
                self.hatesView.isHidden = false
            } else {
                self.hatesView.isHidden = true
            }
        } else {
            self.hatesView.isHidden = true
        }
    }
    
    
    
    
    func loadTraits() {
        
        self.traitsArray = []
        
        if let traits = self.animalObject?["traits"] as? [[String:Any]]{
            if (traits.count > 0) {
                for trait in traits {
                            let name = trait["name"] as? String
                            if(name != nil) {
                                self.traitsArray.append(name)
                                self.addTraits()
                            }
                            self.traitsView.isHidden = false
                    
                }
                
                
            } else {
                self.traitsView.isHidden = true
            }
        } else {
            self.traitsView.isHidden = true
        }
        
    }
    
    var traitsSeparatorWasAdded = false
    
    func addTraits(){
        
        self.traitsObjectsView.subviews.forEach({ $0.removeFromSuperview() })
        if self.traitsSeparatorWasAdded{
            self.traitsView.subviews.last?.removeFromSuperview()
        }
        var counter = 0
        var viewHgt = CGFloat(0)
        if self.traitsArray.count > 0 {
            for trait in self.traitsArray {
                //create a view for label and image
                let viewX = CGFloat(0)
                let viewY = CGFloat(40*counter)
                let viewWidth = self.traitsObjectsView.frame.width
                let viewHeight = CGFloat(40)
                viewHgt = viewHgt + viewHeight
                let generalView = UIView()
                generalView.frame = CGRect(x: viewX, y: viewY, width: viewWidth , height: viewHeight)
                
                
                //create label
                let labelX = CGFloat(0)
                let labelY = CGFloat(0)
                let labelWidth = 2*generalView.frame.width/3
                let labelHeight = CGFloat(40)
                let generalLabel = UILabel()
                generalLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
                generalLabel.font = UIFont(name: "HelveticaNeue", size: 17.0)
                generalLabel.textColor = UIColor.darkGray
                generalLabel.text = trait
                generalView.addSubview(generalLabel)
                self.traitsObjectsView.addSubview(generalView)
                counter += 1
                
                //create image
                let imageX = generalView.frame.width - 40
                let imageY = CGFloat(0)
                let imageWidth = CGFloat(40)
                let imageHeight = CGFloat(40)
                let generalImage = UIImageView()
                generalImage.frame = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
                generalImage.image = self.pickTheImage(traitName: trait!)
                generalView.addSubview(generalImage)
            }
            //update the traitView
            self.traitsViewBottomConstraint.constant = viewHgt + 40
            self.trObViewHeightConstraint.constant = viewHgt
            
            let separatorBGColor = UIColor(red: 190.0 / 255.0, green: 190.0 / 255.0, blue: 190.0 / 255.0, alpha: 1.0)
            let separator = UIImageView(frame: CGRect(x: 15, y: self.trObViewHeightConstraint.constant+40-2, width: self.view.frame.width - 2*15, height: 2.0 / UIScreen.main.scale))
            separator.backgroundColor = separatorBGColor
            self.traitsView.addSubview(separator)
            self.traitsSeparatorWasAdded = true
            
        }
    }
    
    
    func pickTheImage(traitName:String)-> UIImage {
        switch traitName {
//        case "independent":
//            return UIImage(named: "independent")!
//        case "calm":
//            return UIImage(named: "lazy")!
//        case "chill":
//            return  UIImage(named: "sleepy")!
        default:
            return UIImage()
        }
    }
    
    override func viewDidLoad() {
        self.loadAnimal()
        super.viewDidLoad()
        self.scrollView.isScrollEnabled = false
        animalDetailController?.aboutViewController = self
        scrollView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.clearsContextBeforeDrawing = true
        self.loadAnimal()
        self.view.updateConstraintsIfNeeded()
        super.viewWillAppear(animated)
        
    }
    
    
    
    func loadAnimal() {
        if(self.animalObject != nil) {
            
            if let intro = animalObject?["intro"] as? String {
                if !intro.isEmpty {
                    self.introLabel.text = intro
                    self.introView.isHidden = false
                    self.setSeparator(view: self.introView)
                } else {
                    self.introView.isHidden = true
                }
            } else {
                self.introView.isHidden = true
            }
            
            if let city = animalObject?["city"] as? [String:Any], let hometown = city["name"] as? String{
                self.locationLabel.text = hometown
                self.locationView.isHidden = false
                self.setSeparator(view: self.locationView)
            } else {
                self.locationView.isHidden = true
            }
            
            if let breed = animalObject?["breed"] as? [String:Any] {
                    let name = breed["name"] as? String
                    self.breedButton.setTitle(name, for: .normal)
//                    self.breedObject = breed
            } else if currentUserIsOwner {
                self.breedButton.setTitle("Choose One", for: .normal)
            } else {
                // Suggest a breed
                self.breedButton.setTitle("", for: .normal)
            }
            self.setSeparator(view: self.breedView)
            
            if let coat = animalObject?["coat"] as? [String:Any]  {
                    let name = coat["name"] as? String
                    self.coatButton.setTitle(name, for: .normal)
            } else if currentUserIsOwner {
                self.coatButton.setTitle("Choose One", for: .normal)
            } else {
                //Suggest a coat
                self.coatButton.setTitle("", for: .normal)
            }
            self.setSeparator(view: self.coatView)
            
            self.eyesView.isHidden = true
            
            self.loadTraits()
            self.loadLoves()
            self.setSeparator(view: self.lovesView)
            self.loadHates()
            self.setSeparator(view: self.hatesView)
        }
    }
    
    var introSeparator = false
    var locationSeparator = false
    var lovesSeparator = false
    var hatesSeparator = false
    
    func setSeparator(view:UIView){
        
        DispatchQueue.main.async() {
            switch view {
            case self.introView:
                if self.introSeparator {
                    view.subviews.last?.removeFromSuperview()
                }
            case self.locationView:
                if self.locationSeparator{
                    view.subviews.last?.removeFromSuperview()
                }
            case self.lovesView:
                if self.lovesSeparator{
                    view.subviews.last?.removeFromSuperview()
                }
            case self.hatesView:
                if self.hatesSeparator{
                    view.subviews.last?.removeFromSuperview()
                }
            default:
                break
            }
            
            var separatorInset: CGFloat
            // Separator x position
            var separatorHeight: CGFloat
            var separatorWidth: CGFloat
            var separatorY: CGFloat
            var separator: UIImageView
            var separatorBGColor: UIColor
            separatorY = view.bounds.size.height
            separatorWidth = view.frame.size.width
            separatorHeight = (2.0 / UIScreen.main.scale)
            // This assures you to have a 1px line height whatever the screen resolution
            separatorInset = 15.0
            separatorBGColor = UIColor(red: 190.0 / 255.0, green: 190.0 / 255.0, blue: 190.0 / 255.0, alpha: 1.0)
            separator = UIImageView(frame: CGRect(x: separatorInset, y: separatorY-1, width: separatorWidth - 2*separatorInset, height: separatorHeight))
            separator.backgroundColor = separatorBGColor
            view.addSubview(separator)
            
            
            switch view {
            case self.introView:
                self.introSeparator = true
                
            case self.locationView:
                self.locationSeparator = true
            case self.lovesView:
                self.lovesSeparator = true
            case self.hatesView:
                self.hatesSeparator = true
            default:
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AboutToBreedDetail" {
            let detailScene = segue.destination as! BreedDetailViewController
            detailScene.currentBreedObject = self.breedObject
        }
    }
}
