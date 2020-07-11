//
//  CustomActivityIndicator.swift
//  White Rabbit
//
//  Created by Alina Chernenko on 6/8/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//

import UIKit

class CustomActivityIndicator: UIView {
    
    private var activityIndicatorImageView: UIImageView
    static private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    /**
     Initialize an instance of this activity indicator in the given UIView
     
     - Parameters:
     - parentView: The UIView that this indicator should be added to
     - verticalOffset: An optional vertical offset for the placement of the indicator.
     */
    init(parentView:UIView, verticalOffset:CGFloat = 0) {
        let loaderImage = UIImage(named: "animal_profile_photo_empty")
        self.activityIndicatorImageView = UIImageView(image: loaderImage)
        
        let loadingImageSize = activityIndicatorImageView.image?.size

        let frameX = parentView.bounds.midX - (loadingImageSize!.width / 2)
        let frameY = (verticalOffset==0) ? parentView.bounds.midY - (loadingImageSize!.height / 2) : verticalOffset
        
        let frame = CGRect(x: frameX, y: frameY, width: loadingImageSize!.width, height: loadingImageSize!.height)
        
        super.init(frame: frame)
        
        self.addSubview(self.activityIndicatorImageView)
        self.startAnimating()
    }
    
    deinit{
        self.stopAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        let loaderImage = UIImage(named: "animal_profile_photo_empty")
        self.activityIndicatorImageView = UIImageView(image: loaderImage)
        
        super.init(coder: aDecoder)
    }
    
    private func startAnimating() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.isRemovedOnCompletion = false
        animation.toValue = CGFloat.pi * 2.0
        animation.duration = 0.8
        animation.isCumulative = true
        animation.repeatCount = Float.infinity
        activityIndicatorImageView.layer.add(animation, forKey: "rotationAnimation")
    }
    
     private func stopAnimating() {
        activityIndicatorImageView.layer.removeAllAnimations()
        self.activityIndicatorImageView.removeFromSuperview()
        self.removeFromSuperview()
    }
}
