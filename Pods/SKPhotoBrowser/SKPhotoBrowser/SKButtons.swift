//
//  SKButtons.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/09.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import Foundation

// helpers which often used
private let bundle = Bundle(for: SKPhotoBrowser.self)

class SKButton: UIButton {
    var showFrame: CGRect!
    var hideFrame: CGRect!
    var insets: UIEdgeInsets {
        
        
        return UI_USER_INTERFACE_IDIOM() == .phone
            ?  UIEdgeInsets(top: 15.25, left: 15.25, bottom: 15.25, right: 15.25) : UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    var size: CGSize = CGSize(width: 60, height: 60)
    var margin: CGFloat = 5
    
    var buttonTopOffset: CGFloat { return 5 }
    
    func setup(_ imageName: String) {
        backgroundColor = UIColor.clear
        imageEdgeInsets = insets
        //        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        
        let image = UIImage(named: "SKPhotoBrowser.bundle/images/\(imageName)",
            in: bundle, compatibleWith: nil) ?? UIImage()
        setImage(image, for: UIControlState())
    }
    
    func setupWithImage(_ image: UIImage) {
        backgroundColor = UIColor.clear
        imageEdgeInsets = insets
        //        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        
        setImage(image, for: UIControlState())
    }
    
    func updateFrame() { }
    
    func setFrameSize(_ size: CGSize) {
        let newRect = CGRect(x: margin, y: buttonTopOffset, width: size.width, height: size.height)
        self.frame = newRect
        showFrame = newRect
        hideFrame = CGRect(x: margin, y: -20, width: size.width, height: size.height)
    }
}

class SKCloseButton: SKButton {
    let imageName = "btn_common_close_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if let image = SKPhotoBrowserOptions.customCloseButtonImage {
            setupWithImage(image)
            showFrame = CGRect(x: margin, y: buttonTopOffset, width: 60, height: 60)
        } else {
            setup(imageName)
            showFrame = CGRect(x: margin, y: buttonTopOffset, width: size.width, height: size.height)
        }
        hideFrame = CGRect(x: margin, y: -20, width: size.width, height: size.height)
    }
}

class SKDeleteButton: SKButton {
    let imageName = "btn_common_delete_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(imageName)
        
        if let image = SKPhotoBrowserOptions.customDeleteButtonImage {
            setupWithImage(image)
            showFrame = CGRect(x: SKMesurement.screenWidth - 60, y: buttonTopOffset, width: 60, height: 60)
            hideFrame = CGRect(x: SKMesurement.screenWidth - 60, y: -20, width: 60, height: 60)
        } else {
            showFrame = CGRect(x: SKMesurement.screenWidth - size.width, y: buttonTopOffset, width: size.width, height: size.height)
            hideFrame = CGRect(x: SKMesurement.screenWidth - size.width, y: -20, width: size.width, height: size.height)
        }
    }
    
    override func setFrameSize(_ size: CGSize) {
        let newRect = CGRect(x: SKMesurement.screenWidth - size.width, y: buttonTopOffset, width: size.width, height: size.height)
        self.frame = newRect
        showFrame = newRect
        hideFrame = CGRect(x: SKMesurement.screenWidth - size.width, y: -20, width: size.width, height: size.height)
    }
}

class SKMoreButton: SKButton {
    let imageName = "btn_common_delete_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(imageName)
        
        if let image = SKPhotoBrowserOptions.customMoreButtonImage {
            setupWithImage(image)
        }
        showFrame = CGRect(x: SKMesurement.screenWidth - size.width, y: buttonTopOffset, width: size.width, height: size.height)
        hideFrame = CGRect(x: SKMesurement.screenWidth - size.width, y: -20, width: size.width, height: size.height)
    }
}

class SKCommentButton: SKButton {
    let imageName = "btn_common_delete_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(imageName)
        
        if let image = SKPhotoBrowserOptions.customCommentButtonImage {
            setupWithImage(image)
        }
        showFrame = CGRect(x: (SKMesurement.screenWidth / 2) - (size.width / 2), y: SKMesurement.screenHeight - size.height + buttonTopOffset, width: size.width, height: size.height)
        hideFrame = CGRect(x: (SKMesurement.screenWidth / 2) - (size.width / 2), y: SKMesurement.screenHeight + size.height + 20, width: size.width, height: size.height)
    }
}

class SKLikeButton: SKButton {
    let imageName = "btn_common_delete_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(imageName)
        
        if let image = SKPhotoBrowserOptions.customLikeButtonImage {
            setupWithImage(image)
        }
        showFrame = CGRect(x: SKMesurement.screenWidth - (SKMesurement.screenWidth / 10) - size.width, y: SKMesurement.screenHeight - size.height + buttonTopOffset, width: size.width, height: size.height)
        hideFrame = CGRect(x: SKMesurement.screenWidth - (SKMesurement.screenWidth / 10) - size.width, y: SKMesurement.screenHeight + size.height + 20, width: size.width, height: size.height)
    }
}

class SKShareButton: SKButton {
    let imageName = "btn_common_delete_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(imageName)
        
        if let image = SKPhotoBrowserOptions.customShareButtonImage {
            setupWithImage(image)
        }
        showFrame = CGRect(x: margin + (SKMesurement.screenWidth / 10), y: SKMesurement.screenHeight - size.height + buttonTopOffset, width: size.width, height: size.height)
        hideFrame = CGRect(x: margin + (SKMesurement.screenWidth / 10), y: SKMesurement.screenHeight + size.height + 20, width: size.width, height: size.height)
    }
}

class SKUserButton: SKButton {
    let imageName = "btn_common_close_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        let buttonWidth = CGFloat(80.0)
        
        super.init(frame: frame)
        if let image = SKPhotoBrowserOptions.customUserButtonDefaultImage {
            setupWithImage(image)
            showFrame = CGRect(x: margin, y: buttonTopOffset + 60, width: buttonWidth, height: buttonWidth)
        } else {
            setup(imageName)
            showFrame = CGRect(x: margin, y: buttonTopOffset + 60, width: buttonWidth, height: buttonWidth)
        }
        hideFrame = CGRect(x: margin, y: -20 + 60, width: buttonWidth, height: buttonWidth)
    }
}
