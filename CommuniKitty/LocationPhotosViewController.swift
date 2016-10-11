//
//  AboutViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 3/17/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//


class LocationPhotoCollectionViewCell: UICollectionViewCell {
    
}


class LocationPhotosViewController: UICollectionViewController {
    
    var googlePlacePhotos: [String?]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.clear
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        return (self.googlePlacePhotos?.count)!
    }
    
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width:90, height:90)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? LocationPhotoCollectionViewCell
        
        let photoUrl = googlePlacePhotos![indexPath.row]
        let thumbnailImage = UIImageView(frame: CGRect(x:0, y:0, width:90, height: 90))
        thumbnailImage.kf_setImage(with: URL(string: photoUrl!)!, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            
        })
        thumbnailImage.contentMode = .scaleAspectFill
        cell?.addSubview(thumbnailImage)
        
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as? LocationPhotoCollectionViewCell
        self.showImagesBrowser(imageUrls: googlePlacePhotos!, startIndex: indexPath.row, animatedFromView: cell!.subviews.last)
        collectionView.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: false)
    }
    
}


// MARK: UICollectionViewDelegate

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
 return true
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
 return true
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
 return false
 }
 
 override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
 return false
 }
 
 override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
 
 }
 */
    
