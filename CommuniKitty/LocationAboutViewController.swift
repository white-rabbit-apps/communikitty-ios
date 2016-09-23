//
//  AboutViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 3/17/16.
//  Copyright © 2016 White Rabbit Technology. All rights reserved.
//


class LocationAboutViewController : UIViewController {

    var currentLocationObject: WRLocation?
    var googlePlaceDetailsObject: NSDictionary?
    
    @IBOutlet weak var typesStackView: UIStackView!
    @IBOutlet weak var rescueView: UIView!
    @IBOutlet weak var shelterView: UIView!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var openHourLabel: UILabel!
    @IBOutlet weak var openTagImage: UIImageView!
   
    @IBOutlet weak var servicesView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var hoursView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.view.frame.size.width <= 320.0 {
            self.openHourLabel.font = UIFont.systemFont(ofSize: 13)
        }
        
        if let location = currentLocationObject {
           
            if let types = location.types {
                rescueView.isHidden = true
                shelterView.isHidden = true
                for (index , typeValue) in types.enumerated() {
                    
                    if(typeValue != "_new") {
                        let imageName = "icon_location_type_" + typeValue
                        let image = UIImage(named: imageName)
                        if image != nil {
                            let containerView=UIView(frame: CGRect(x: 0, y: CGFloat(29*index), width: rescueView.frame.size.width, height: 29))
                            containerView.heightAnchor.constraint(equalToConstant: 29).isActive = true
                            containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: rescueView.frame.size.width).isActive = true
                            self.typesStackView.addArrangedSubview(containerView)
                        
                            let typeLogo = UIImageView(image: image!)
                            typeLogo.contentMode = .scaleAspectFit
                            typeLogo.frame = CGRect(x: 0, y: 0, width: 29, height: 29)
                            containerView.addSubview(typeLogo)
                            
                            let typeName = UILabel(frame: CGRect(x: 37, y: 0, width: self.typesStackView.frame.size.width, height: 29))
                            typeName.font = typeName.font.withSize(15)
                            typeName.text = typeValue.capitalizeFirstLetter()
                            typeName.textColor = UIColor.black
                            containerView.addSubview(typeName)
                        }
                    }
                }
                
            } else {
                self.servicesView.isHidden = true
            }
            
            
            
            let countryInfo = (location.city != nil ? location.city! : "") + ", " + (location.state != nil ? location.state! : "") + " " + (location.zip != nil ? location.zip! : "")
             addressLabel.text = (location.address != nil ? location.address! : "") + "\n" + countryInfo
        }
        
        if let Details = googlePlaceDetailsObject {
            if let openHoursObject = Details.object(forKey: "opening_hours") as? NSDictionary {
                if let weekdays = openHoursObject.object(forKey: "weekday_text") as? NSArray {
                    let dayTimePeriodFormatter = DateFormatter()
                    dayTimePeriodFormatter.dateFormat = "EEEE"
                    let currentDay = dayTimePeriodFormatter.string(from: NSDate() as Date)
                    for elemnet in weekdays {
                        let dayAndTime = elemnet as? String
                        if dayAndTime!.range(of: currentDay) != nil{
                            self.openHourLabel.text = dayAndTime
                            break
                        } else {
                            self.openHourLabel.text = "Closed"
                        }
                    }
                } else{
                    self.openHourLabel.text = "Closed"
                }
                
                if openHoursObject.object(forKey: "open_now") as! Bool == false {
                    self.openTagImage.isHidden = true
                }
            } else {
                self.hoursView.isHidden = true
            }
        }
    }
}
