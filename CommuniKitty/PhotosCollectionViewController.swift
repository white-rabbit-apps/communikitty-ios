//
//  PhotosCollectionViewController.swift
//  White Rabbit
//
//  Created by Alina Chernenko on 8/19/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import UIKit
import Device

class PhotoViewCell :UICollectionViewCell{
    var imageViewContent : UIImageView = UIImageView()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        contentView.addSubview(imageViewContent)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageViewContent.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    }
}

private let reuseIdentifier = "Cell"

public let screenBounds = UIScreen.main.bounds
public var controllerHeight: CGFloat {
    get {
        switch Device.size() {
        case .Screen4_7Inch:
            return CGFloat(430)
        case .Screen5_5Inch:
            return CGFloat(500)
        default:
            return CGFloat(430)
        }
    }
}

class PhotosCollectionViewController: UICollectionViewController, PhotoCollectionViewDelegateLayout, ImagesLoadedHandler{
    
    var imageEntries: [WRTimelineEntry] = []
    var imageIndexById : [String : Int] = [:]
    var animalTimelineController: AnimalTimelineTableViewController?
    var currentUserIsOwner : Bool = false
    var firstLoad: Bool = true
    var animalImagesRepository:AnimalImagesRepository?{
        didSet{
            animalImagesRepository?.subscribeLoadAll(self)
        }
    }
    
    deinit {
        animalImagesRepository?.unsubscribe(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.frame = screenBounds
        self.currentUserIsOwner = (self.animalTimelineController?.currentUserIsOwner)!
        self.collectionView?.isScrollEnabled = false
        setBackGroundView()
        self.collectionView?.setCollectionViewLayout(PhotosCollectionViewLayout(), animated: false)
        self.collectionView!.register(PhotoViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.reloadData()

    }
    
    /**
     Loads imageEntries and imageIndexById. Conforms ImagesLoadedHandler protocol
     
     - Parameters:
     - objects: An array of the objects to scroll to
     - imageIndexById: [String : Int]? - adds the dictionary after images loading
     - imageEntries:[WRTimelineEntry]? - adds the entries after image loading
     */
    func imagesLoaded(_ objects: [PFObject]?, imageIndexById: [String : Int]? , imageEntries:[WRTimelineEntry]?){
        self.imageIndexById = imageIndexById ?? [String : Int]()
        self.imageEntries = imageEntries ?? [WRTimelineEntry]()
        self.viewWillAppear(false)
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        if !firstLoad{
            setBackGroundView()
        }
        firstLoad = false
    }
    
    /**
     setBackGroundView function displays empty background view in case there are no photos to show
     and reloads collectionView data if there are some items
     */
    func setBackGroundView(){
        
        if imageEntries.count > 0 {
            for subview in self.collectionView!.subviews{
                subview.removeFromSuperview()
            }
            self.collectionView!.reloadData()
        } else {
            for subview in self.collectionView!.subviews{
                subview.removeFromSuperview()
            }
            self.collectionView!.backgroundColor = UIColor.white
            let backImage = UIImageView()
            if currentUserIsOwner {
                let image = UIImage(named: "kitteh_selfie")!
                backImage.image = image
                backImage.sizeToFit()
                let imageWidth = backImage.frame.width
                let imageHeight = backImage.frame.height
                backImage.frame = CGRect(x: screenBounds.width/2-imageWidth/2, y: controllerHeight/4-imageHeight/2, width: imageWidth, height: imageHeight)
            } else {
                let image = UIImage(named: "kitteh_hit")!
                backImage.image = image
                backImage.sizeToFit()
                let imageWidth = backImage.frame.width
                let imageHeight = backImage.frame.height
                backImage.frame = CGRect(x: screenBounds.width/2-imageWidth/2, y: controllerHeight/4-imageHeight/2, width: imageWidth, height: imageHeight)
            }
            self.collectionView!.addSubview(backImage)
            
            let attr: [String : AnyObject] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0), NSForegroundColorAttributeName: UIColor.darkGray]
            let label = UILabel(frame:CGRect(x: 15,y: controllerHeight/4+backImage.frame.height-30, width: screenBounds.width-30, height: 20))
            label.textAlignment = .center
            
            if currentUserIsOwner {
                label.attributedText = NSAttributedString(string: "No meowments yet", attributes: attr)
            } else {
                label.frame = CGRect(x: 15,y: controllerHeight/4+backImage.frame.height-60, width: screenBounds.width-30, height: 20)
                label.attributedText = NSAttributedString(string: "No meowments yet", attributes: attr)
            }
            
            self.collectionView!.addSubview(label)
            
            let par: NSMutableParagraphStyle = NSMutableParagraphStyle()
            par.lineBreakMode = .byWordWrapping
            par.alignment = .center
            let parAttributes: [String : AnyObject] = [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: UIColor.lightGray, NSParagraphStyleAttributeName: par]
            
            let secondLabel = UILabel(frame:CGRect(x: 15,y: controllerHeight/4+backImage.frame.height-30+label.frame.height, width: screenBounds.width-30, height: 40))
            
            if currentUserIsOwner {
                secondLabel.attributedText =  NSAttributedString(string: "Start capturing some of your kitteh’s best meowments.", attributes: parAttributes)
            } else {
                secondLabel.frame = CGRect(x: 15,y: controllerHeight/4+backImage.frame.height-60+label.frame.height, width: screenBounds.width-30, height: 40)
                secondLabel.attributedText = NSAttributedString(string: "This kitteh hasn’t added any meowments yet", attributes: parAttributes)
            }
            secondLabel.numberOfLines = 0
            
            self.collectionView!.addSubview(secondLabel)
            
            let cameraImage = UIButton()
            
            if currentUserIsOwner {
                cameraImage.setImage(UIImage(named: "arrow_to_button_camera"), for: UIControlState())
                cameraImage.sizeToFit()
                
                
                let imageWidth = cameraImage.frame.width
                let imageHeight = cameraImage.frame.height
                cameraImage.frame = CGRect(x: screenBounds.width/2-imageWidth/2, y: controllerHeight/4+imageHeight+label.frame.height+secondLabel.frame.height - 90, width: imageWidth, height: imageHeight)
                
                cameraImage.addTarget(self, action: #selector(self.tapOnCameraButton), for: .touchUpInside)
                
            } else {
                cameraImage.setImage(UIImage(named: "button_nudge"), for: UIControlState())
                cameraImage.sizeToFit()
                let imageWidth = cameraImage.frame.width
                let imageHeight = cameraImage.frame.height
                cameraImage.frame = CGRect(x: screenBounds.width/2-imageWidth/2, y: controllerHeight/4+imageHeight+label.frame.height+secondLabel.frame.height + 30, width: imageWidth, height: imageHeight)
            }
            
            self.collectionView!.addSubview(cameraImage)
        }

    }
    func tapOnCameraButton(){
         self.animalTimelineController?.takeFusumaPhoto()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        return CGSize(width: 50,height: 50)
    }
    
    /**
       disable/enable scroll in collectionView to pass/get the control to/from scroll from AnimalDetailViewController
     */
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y <= 0 ) {
            self.collectionView!.isScrollEnabled = false
        } else {
            self.collectionView!.isScrollEnabled = true
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageEntries.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:PhotoViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoViewCell
    
        // Configure the cell
        let entry = self.imageEntries[(indexPath as IndexPath).row]
        if let imageFile = entry.image {
            cell.imageViewContent.kf_setImage(with: URL(string: imageFile.url!)!, placeholder: nil, options: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            })
        } else  if let imageUrl = entry.imageUrl {
            cell.imageViewContent.kf_setImage(with: URL(string: imageUrl)!, placeholder: nil, options: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            })
        }
        cell.setNeedsLayout()
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoViewCell
        let imageIndex = (indexPath as IndexPath).row
        
        let object = self.imageEntries[imageIndex]
        
        let index = self.imageIndexById[object.objectId!]
        
        self.showImagesBrowser(entries: imageEntries, startIndex: index, animatedFromView: cell.imageViewContent, displayUser: false)
     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        KingfisherManager.shared.cache.clearMemoryCache()
    }

    
}
