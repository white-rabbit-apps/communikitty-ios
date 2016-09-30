//
//  SKPhotoBrowserOptions.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/18.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import Foundation

public struct SKPhotoBrowserOptions {
    public static var displayAction: Bool = true
    public static var shareExtraCaption: String? = nil
    public static var actionButtonTitles: [String]?
    
    public static var displayToolbar: Bool = true
    public static var displayCustomToolbar: Bool = false
    public static var displayCounterLabel: Bool = true
    public static var displayBackAndForwardButton: Bool = true
    public static var disableVerticalSwipe: Bool = false
    
    public static var displayCloseButton = true
    public static var displayDeleteButton = false
    
    public static var displayCommentButton = false
    public static var displayLikeButton = false
    public static var displayMoreButton = false
    public static var displayShareButton = false
    
    public static var displayUserButton = false
    
    public static var handleUserButtonPressed : ((_ object: NSObject?)->Void)? = nil
    public static var handleCommentButtonPressed : ((_ object: NSObject?)->Void)? = nil
    public static var handleLikeButtonPressed : ((_ object: NSObject?, _ photo: SKPhotoProtocol?)->Void)? = nil
    public static var handleMoreButtonPressed : ((_ object: NSObject?)->Void)? = nil
    public static var handleShareButtonPressed : ((_ object: NSObject?, _ image: UIImage)->Void)? = nil
    
    public static var handleEntryLoaded : ((_ object: NSObject?, _ photo: SKPhotoProtocol?)->Void)? = nil
    
    public static var customCloseButtonImage : UIImage? = nil
    public static var customLikeButtonImage : UIImage? = nil
    public static var customCommentButtonImage : UIImage? = nil
    public static var customMoreButtonImage : UIImage? = nil
    public static var customShareButtonImage : UIImage? = nil
    public static var customDeleteButtonImage : UIImage? = nil
    public static var customUserButtonDefaultImage : UIImage? = nil
    
    public static var bounceAnimation = false
    public static var enableZoomBlackArea = true
    public static var enableSingleTapDismiss = false
    public static var autoHideControls = true
}
