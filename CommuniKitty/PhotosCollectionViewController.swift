//
//  PhotosCollectionViewController.swift
//  White Rabbit
//
//  Created by Alina Chernenko on 8/19/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import UIKit
import Device
import Fusuma
import CLImageEditor

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

class PhotosCollectionViewController: UICollectionViewController, PhotoCollectionViewDelegateLayout, ImagesLoadedHandler, FusumaDelegate, CLImageEditorDelegate {

    
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
            self.showEmptyCustomView(view: self.collectionView!, currentUserIsOwner: currentUserIsOwner, vc: self)
        }

    }
    
    func tapOnCameraButton(){
        let fusuma = FusumaViewController()
        
        fusuma.delegate = self
        
        fusuma.modeOrder = .cameraFirst
        
        fusuma.transitioningDelegate = transitioningDelegate
        fusuma.modalPresentationStyle = .custom
        
        present(fusuma, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        return CGSize(width: 100,height: 100)
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
        
        cell.imageViewContent.kf_indicatorType = .activity
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
        
        self.showImagesBrowser(entries: imageEntries, startIndex: index, animatedFromView: cell.imageViewContent, displayUser: false, vc: self)
     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        KingfisherManager.shared.cache.clearMemoryCache()
    }

    var pickedImageDate: Date?
    var isAddingFirstImage: Bool = false
    func fusumaImageSelected(_ image: UIImage, creationDate: Date?) {
        self.pickedImageDate = creationDate
        
        self.modalTransitionStyle = .coverVertical
        self.dismiss(animated: false, completion: { () -> Void in
            self.isAddingFirstImage = true
            self.showEditor(image: image, delegate: self, ratios: [1, 1], fromController: self)
        })
    }
    
    public func fusumaImageSelected(_ image: UIImage) {
        self.modalTransitionStyle = .coverVertical
        self.dismiss(animated: false, completion: { () -> Void in
            self.isAddingFirstImage = true
            self.showEditor(image: image, delegate: self, ratios: [1, 1], fromController: self)
        })
    }
    
    /**
     Handle the video that is returned from the camera
     - implements FusumaDelegate
     */
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    
    /**
     Handle the user not authorizing access to the camera roll
     - implements FusumaDelegate
     */
    func fusumaCameraRollUnauthorized() {
        print("Camera roll unauthorized")
    }
    
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func imageEditor(_ editor: CLImageEditor!, didFinishEdittingWith image: UIImage!) {
        NSLog("got new image")

            if self.isAddingFirstImage {
                if image != nil {
                    let detailScene =  TimelineEntryFormViewController()
                    detailScene.type = "image"
                    detailScene.image = image
                    detailScene.pickedImageDate = self.pickedImageDate as Date?
                    detailScene.animalObject = self.animalTimelineController?.animalObject
                    detailScene.isFromTimelineController = true
                    detailScene.animalDetailController = self.animalTimelineController?.animalDetailController
                    detailScene.animalTimelineTableVC = self.animalTimelineController!
                    
                    let nav = UINavigationController(rootViewController: detailScene)
                    nav.modalTransitionStyle = .coverVertical
                    
                    self.dismiss(animated: false) { () -> Void in
                        self.present(nav, animated: false, completion: { () -> Void in
                            self.hideLoader()
                        })
                    }
                } else {
                    self.dismiss(animated: false, completion: { () -> Void in
                        self.hideLoader()
                    })
                }
                
                
            }
        self.showLoader()
        self.isAddingFirstImage = false
    }

 
}
