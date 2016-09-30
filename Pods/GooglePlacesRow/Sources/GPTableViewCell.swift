//
//  GPTableViewCell.swift
//  GooglePlacesRow
//
//  Created by Mathias Claassen on 4/14/16.
//
//

import Foundation
//import GoogleMaps
import Eureka

public protocol EurekaGooglePlacesTableViewCell {
    func setTitle(prediction: Place)
}

/// Default cell for the table of the GooglePlacesTableCell
public class GPTableViewCell: UITableViewCell, EurekaGooglePlacesTableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        textLabel?.font = UIFont.systemFont(ofSize: 16)
        textLabel?.minimumScaleFactor = 0.8
        textLabel?.adjustsFontSizeToFitWidth = true
        textLabel?.textColor = UIColor.blue
        contentView.backgroundColor = UIColor.white
    }
    
    public func setTitle(prediction: Place) {
        //textLabel?.text = prediction.attributedFullText.string
        textLabel?.text = prediction.desc
        
    }
}
