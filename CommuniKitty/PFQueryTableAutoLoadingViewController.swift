//
//  PFQueryTableAutoLoadingViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 6/2/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import ParseUI

class PFQueryTableAutoLoadingViewController : PFQueryTableViewController {
    
    var finishedLoadingAll : Bool = false
    
    var previousObjectCount : Int = 0
    var previousLastId : String?
    var wasAutoLoaded : Bool = true
    var firstLoad : Bool = true
    
    override func objectsWillLoad() {
        super.objectsWillLoad()
                
        if(!self.wasAutoLoaded) {
            self.finishedLoadingAll = false
            self.previousObjectCount = 0
            self.previousLastId = nil
        }
        
        self.wasAutoLoaded = false
        self.firstLoad = false
    }
    
    override func objectsDidLoad(_ error: Error?) {
        super.objectsDidLoad(error)
        self.hideLoader()
        let objectCount = self.objects!.count
        let lastObjectId = (self.objects![self.objects!.count - 1]).objectId!
        
        if((objectCount - previousObjectCount >= 0) && (objectCount - previousObjectCount < Int(self.objectsPerPage)) && lastObjectId != self.previousLastId) {

            self.previousObjectCount = self.objects!.count
            self.finishedLoadingAll = true
        } else if(objectCount > previousObjectCount || lastObjectId == self.previousLastId) {
            self.previousObjectCount = self.objects!.count
            self.finishedLoadingAll = false
            self.previousLastId = lastObjectId
        } else {
            self.finishedLoadingAll = true
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !finishedLoadingAll {
            if scrollView.contentSize.height - scrollView.contentOffset.y - 600 < (self.view.bounds.size.height) {
                if !self.isLoading {
                    self.wasAutoLoaded = true
                    self.loadNextPage()
                }
            }
        }
    }
}
