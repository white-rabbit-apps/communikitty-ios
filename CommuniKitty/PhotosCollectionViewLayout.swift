//
//  PhotosCollectionViewLayout.swift
//  White Rabbit
//
//  Created by Alina Chernenko on 8/22/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//
import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc protocol PhotoCollectionViewDelegateLayout: UICollectionViewDelegate{
    
    func collectionView (_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
                         sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    
    @objc optional func colletionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                 heightForHeaderInSection section: NSInteger) -> CGFloat
    
    @objc optional func colletionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                 heightForFooterInSection section: NSInteger) -> CGFloat
    
    @objc optional func colletionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                 insetForSectionAtIndex section: NSInteger) -> UIEdgeInsets
    
    @objc optional func colletionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                 minimumInteritemSpacingForSectionAtIndex section: NSInteger) -> CGFloat
}


enum PhotoCollectionViewLayoutItemRenderDirection : NSInteger{
    case shortestFirst
    case leftToRight
    case rightToLeft
}

class PhotosCollectionViewLayout: UICollectionViewLayout {
    let PhotoCollectionElementKindSectionHeader = "PhotoCollectionElementKindSectionHeader"
    let PhotoCollectionElementKindSectionFooter = "PhotoCollectionElementKindSectionFooter"
    
    var columnCount : NSInteger{
        didSet{
            invalidateLayout()
        }}
    
    var minimumColumnSpacing : CGFloat{
        didSet{
            invalidateLayout()
        }}
    
    var minimumInteritemSpacing : CGFloat{
        didSet{
            invalidateLayout()
        }}
    
    var headerHeight : CGFloat{
        didSet{
            invalidateLayout()
        }}
    
    var footerHeight : CGFloat{
        didSet{
            invalidateLayout()
        }}
    
    var sectionInset : UIEdgeInsets{
        didSet{
            invalidateLayout()
        }}
    
    
    var itemRenderDirection : PhotoCollectionViewLayoutItemRenderDirection{
        didSet{
            invalidateLayout()
        }}
    
    
    //    private property and method above.
    weak var delegate : PhotoCollectionViewDelegateLayout?{
        get{
            return self.collectionView!.delegate as? PhotoCollectionViewDelegateLayout
        }
    }
    var columnHeights : NSMutableArray
    var sectionItemAttributes : NSMutableArray
    var allItemAttributes : NSMutableArray
    var headersAttributes : NSMutableDictionary
    var footersAttributes : NSMutableDictionary
    var unionRects : NSMutableArray
    let unionSize = 20
    
    override init(){
        self.headerHeight = 0.0
        self.footerHeight = 0.0
        self.columnCount = 4
        self.minimumInteritemSpacing = 5
        self.minimumColumnSpacing = 5
        self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        self.itemRenderDirection = .shortestFirst
        
        headersAttributes = NSMutableDictionary()
        footersAttributes = NSMutableDictionary()
        unionRects = NSMutableArray()
        columnHeights = NSMutableArray()
        allItemAttributes = NSMutableArray()
        sectionItemAttributes = NSMutableArray()
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare(){
        super.prepare()
        
        let numberOfSections = self.collectionView!.numberOfSections
        if numberOfSections == 0 {
            return
        }
        
        self.headersAttributes.removeAllObjects()
        self.footersAttributes.removeAllObjects()
        self.unionRects.removeAllObjects()
        self.columnHeights.removeAllObjects()
        self.allItemAttributes.removeAllObjects()
        self.sectionItemAttributes.removeAllObjects()
        
        var idx = 0
        while idx<self.columnCount{
            self.columnHeights.add(0)
            idx += 1
        }
        
        var top : CGFloat = 0.0
        var attributes = UICollectionViewLayoutAttributes()
        
        for section in 0 ..< numberOfSections{
            /*
             * 1. Get section-specific metrics (minimumInteritemSpacing, sectionInset)
             */
            var minimumInteritemSpacing : CGFloat
            if let miniumSpaceing = self.delegate?.colletionView?(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAtIndex: section){
                minimumInteritemSpacing = miniumSpaceing
            }else{
                minimumInteritemSpacing = self.minimumColumnSpacing
            }
            
            let width = self.collectionView!.frame.size.width - sectionInset.left - sectionInset.right
            let spaceColumCount = CGFloat(self.columnCount-1)
            let itemWidth = floor((width - (spaceColumCount*self.minimumColumnSpacing)) / CGFloat(self.columnCount))
            
            /*
             * 2. Section header
             */
            var heightHeader : CGFloat
            if let height = self.delegate?.colletionView?(self.collectionView!, layout: self, heightForHeaderInSection: section){
                heightHeader = height
            }else{
                heightHeader = self.headerHeight
            }
            
            if heightHeader > 0 {
                attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: PhotoCollectionElementKindSectionHeader, with: IndexPath(row: 0, section: section))
                attributes.frame = CGRect(x: 0, y: top, width: self.collectionView!.frame.size.width, height: heightHeader)
                self.headersAttributes.setObject(attributes, forKey: (section as NSCopying))
                self.allItemAttributes.add(attributes)
                
                top = attributes.frame.maxX
            }
            top += sectionInset.top
            for idx in 0 ..< self.columnCount {
                self.columnHeights[idx]=top;
            }
            
            /*
             * 3. Section items
             */
            let itemCount = self.collectionView!.numberOfItems(inSection: section)
            let itemAttributes = NSMutableArray(capacity: itemCount)
            
            // Item will be put into shortest column.
            for idx in 0 ..< itemCount {
                let indexPath = IndexPath(item: idx, section: section)
                
                let columnIndex = self.nextColumnIndexForItem(idx)
                let xOffset = sectionInset.left + (itemWidth + self.minimumColumnSpacing) * CGFloat(columnIndex)
                let yOffset = (self.columnHeights.object(at: columnIndex) as AnyObject).doubleValue
                let itemSize = self.delegate?.collectionView(self.collectionView!, layout: self, sizeForItemAtIndexPath: indexPath)
                var itemHeight : CGFloat = 0.0
                if itemSize?.height > 0 && itemSize?.width > 0 {
                    itemHeight = floor(itemSize!.height*itemWidth/itemSize!.width)
                }
                
                attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: CGFloat(yOffset!), width: itemWidth, height: itemHeight)
                itemAttributes.add(attributes)
                self.allItemAttributes.add(attributes)
                self.columnHeights[columnIndex]=attributes.frame.maxY + minimumInteritemSpacing;
            }
            self.sectionItemAttributes.add(itemAttributes)
            
            /*
             * 4. Section footer
             */
            var footerHeight : CGFloat = 0.0
            let columnIndex  = self.longestColumnIndex()
            top = CGFloat((self.columnHeights.object(at: columnIndex) as AnyObject).floatValue) - minimumInteritemSpacing + sectionInset.bottom
            
            if let height = self.delegate?.colletionView?(self.collectionView!, layout: self, heightForFooterInSection: section){
                footerHeight = height
            }else{
                footerHeight = self.footerHeight
            }
            
            if footerHeight > 0 {
                attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: PhotoCollectionElementKindSectionFooter, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: 0, y: top, width: self.collectionView!.frame.size.width, height: footerHeight)
                self.footersAttributes.setObject(attributes, forKey: section as NSCopying)
                self.allItemAttributes.add(attributes)
                top = attributes.frame.maxY
            }
            
            for idx in 0 ..< self.columnCount {
                self.columnHeights[idx] = top
            }
        }
        
        idx = 0;
        let itemCounts = self.allItemAttributes.count
        while(idx < itemCounts){
            let rect1 = (self.allItemAttributes.object(at: idx) as AnyObject).frame as CGRect
            idx = min(idx + unionSize, itemCounts) - 1
            let rect2 = (self.allItemAttributes.object(at: idx) as AnyObject).frame as CGRect
            self.unionRects.add(NSValue(cgRect:rect1.union(rect2)))
            idx += 1
        }
    }
    
    override var collectionViewContentSize : CGSize{
        let numberOfSections = self.collectionView!.numberOfSections
        if numberOfSections == 0{
            return CGSize.zero
        }
        
        var contentSize = self.collectionView!.bounds.size as CGSize
        let height = self.columnHeights.object(at: 0) as! NSNumber
        contentSize.height = CGFloat(height.doubleValue)
        return  contentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?{
        if (indexPath as IndexPath).section >= self.sectionItemAttributes.count{
            return nil
        }
        if (indexPath as IndexPath).item >= (self.sectionItemAttributes.object(at: (indexPath as IndexPath).section) as AnyObject).count{
            return nil;
        }
        let list = self.sectionItemAttributes.object(at: (indexPath as IndexPath).section) as! NSArray
        return list.object(at: (indexPath as IndexPath).item) as? UICollectionViewLayoutAttributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes{
        var attribute = UICollectionViewLayoutAttributes()
        if elementKind == PhotoCollectionElementKindSectionHeader{
            attribute = self.headersAttributes.object(forKey: (indexPath as IndexPath).section) as! UICollectionViewLayoutAttributes
        }else if elementKind == PhotoCollectionElementKindSectionFooter{
            attribute = self.footersAttributes.object(forKey: (indexPath as IndexPath).section) as! UICollectionViewLayoutAttributes
        }
        return attribute
    }
    
    override func layoutAttributesForElements (in rect : CGRect) -> [UICollectionViewLayoutAttributes] {
        var begin = 0, end = self.unionRects.count
        let attrs = NSMutableArray()
        
        for i in 0 ..< end {
            if rect.intersects((self.unionRects.object(at: i) as AnyObject).cgRectValue){
                begin = i * unionSize;
                break
            }
        }
        var i = self.unionRects.count - 1
        while i>=0 {
            if rect.intersects((self.unionRects.object(at: i) as AnyObject).cgRectValue){
                end = min((i+1)*unionSize,self.allItemAttributes.count)
                break
            }
            i -= 1
        }
        for i in begin ..< end {
            let attr = self.allItemAttributes.object(at: i) as! UICollectionViewLayoutAttributes
            if rect.intersects(attr.frame) {
                attrs.add(attr)
            }
        }
        
        return NSArray(array: attrs) as! [UICollectionViewLayoutAttributes]
    }
    
    override func shouldInvalidateLayout (forBoundsChange newBounds : CGRect) -> Bool {
        let oldBounds = self.collectionView!.bounds
        if newBounds.width != oldBounds.width{
            return true
        }
        return false
    }
    
    
    /**
     *  Find the shortest column.
     *
     *  @return index for the shortest column
     */
    func shortestColumnIndex () -> NSInteger {
        var index = 0
        var shorestHeight = MAXFLOAT
        
        self.columnHeights.enumerateObjects(({(object : Any, idx : Int, pointer :UnsafeMutablePointer<ObjCBool>) in
            let height = (object as AnyObject).floatValue
            if (height<shorestHeight){
                shorestHeight = height!
                index = idx 
            }
            } ))
        return index
    }
    
    /**
     *  Find the longest column.
     *
     *  @return index for the longest column
     */
    
    func longestColumnIndex () -> NSInteger {
        var index = 0
        var longestHeight:CGFloat = 0.0
        
        self.columnHeights.enumerateObjects({(object : Any, idx : Int, pointer :UnsafeMutablePointer<ObjCBool>) in
            let height = CGFloat((object as AnyObject).floatValue)
            if (height > longestHeight){
                longestHeight = height
                index = idx
            }
        } )
        return index
    }
    
    /**
     *  Find the index for the next column.d    *
     *  @return index for the next column
     */
    func nextColumnIndexForItem (_ item : NSInteger) -> Int {
        var index = 0
        switch (self.itemRenderDirection){
        case .shortestFirst :
            index = self.shortestColumnIndex()
        case .leftToRight :
            index = (item%self.columnCount)
        case .rightToLeft:
            index = (self.columnCount - 1) - (item % self.columnCount);
            //        default:
            //            index = self.shortestColumnIndex()
        }
        return index
    }
}
