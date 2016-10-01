//
//  QuirksTableViewController.swift
//  CommuniKitty
//
//  Created by Alina Chernenko on 9/29/16.
//  Copyright © 2016 White Rabbit Apps. All rights reserved.
//


import ParseUI
import Eureka
//import Crashlytics

class QuirksTableViewCell: PFTableViewCell{
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var name: UILabel!
}

public class QuirksTableViewController: PFQueryTableViewController{
    
    var entryObject : WRAnimal?
    var arrayOfStrings:[String]?
    var isLoadFirstTime = false
    
    
    var quirksPushView: QuirksSelectorViewController?
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required public init(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)!
        
        self.parseClassName = ""
        self.paginationEnabled = false
        self.pullToRefreshEnabled = false
    }
    
    /**
     Updates the table with new values and scrolls to the bottom of the screen to see last added values
     - stringArray: new values
     - vc: viewController for getting access to its values
     */
    
    func loadObjectsInTheTable(stringArray:[String]?, vc:QuirksSelectorViewController?){
        self.quirksPushView = vc
        self.arrayOfStrings = stringArray
        self.tableView.reloadData()
        self.scrollToBottom()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.replacePFLoadingView()
        isLoadFirstTime = true
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60.0
        
        if let animal = entryObject {
            
            switch (quirksPushView?.navTitle)! {
            case "Loves":
                //checking if the array exists
                if let array = animal.loves{
                    if array.count == 0 {
                        self.tableView.backgroundView = UIImageView(image: UIImage(named: "love_back"))
                        self.tableView.backgroundView?.sizeToFit()
                    } else {
                        self.arrayOfStrings = array
                        self.tableView.separatorColor = UIColor.clear
                    }
                    
                    //creates the array if it doesn't exist and set the backgroundView
                } else {
                    animal.loves = [String]()
                    self.tableView.backgroundView = UIImageView(image: UIImage(named: "love_back"))
                    self.tableView.backgroundView?.sizeToFit()
                }
            case "Hates":
                if let array = animal.hates{
                    if array.count == 0 {
                        self.tableView.backgroundView = UIImageView(image: UIImage(named: "love_back"))
                        self.tableView.backgroundView?.sizeToFit()
                    } else {
                        self.arrayOfStrings = array
                        self.tableView.separatorColor = UIColor.clear
                    }
                } else {
                    animal.hates = [String]()
                    self.tableView.backgroundView = UIImageView(image: UIImage(named: "love_back"))
                    self.tableView.backgroundView?.sizeToFit()
                }
            default:
                break
            }
            
        }
        
    }
    
    func scrollToBottom(){
        if isLoadFirstTime == false {
            let index = self.tableView.numberOfRows(inSection: 0)
            if index > 0 {
                let indextPath = NSIndexPath(row: index-1, section: 0)
                self.tableView.scrollToRow(at: indextPath as IndexPath, at: UITableViewScrollPosition.bottom, animated: true)
            } else {
                let indextPath = NSIndexPath(index:0)
                self.tableView.scrollToRow(at: indextPath as IndexPath, at: UITableViewScrollPosition.bottom, animated: true)
            }
        }
        isLoadFirstTime = false
    }
    
    override public func objectsDidLoad(_ error: Error?) {
        super.objectsDidLoad(error)
        self.scrollToBottom()
        
    }
    
    
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60.0
    }
    
    //returns the number of array's element
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let arOfStr = self.arrayOfStrings {
            if arOfStr.count > 0{
                self.tableView.backgroundView = nil
                self.tableView.separatorColor = UIColor.lightGray
                return (self.arrayOfStrings?.count)!
            } else {
                    return 0
            }
        } else {
            return 0
        }
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "QuirksCell", for: indexPath as IndexPath) as? QuirksTableViewCell
        
        if cell == nil  {
            cell = QuirksTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "QuirksCell")
        }
        
        cell?.name.text = self.arrayOfStrings![indexPath.row]
        
        var separatorInset: CGFloat
        // Separator x position
        var separatorHeight: CGFloat
        var separatorWidth: CGFloat
        var separatorY: CGFloat
        var separator: UIImageView
        var separatorBGColor: UIColor
        separatorY = (cell?.frame.size.height)!
        separatorHeight = (1.0 / UIScreen.main.scale)
        // This assures you to have a 1px line height whatever the screen resolution
        separatorWidth = cell!.frame.size.width
        separatorInset = 15.0
        separatorBGColor = UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
        separator = UIImageView(frame: CGRect(x:separatorInset, y:separatorY-1, width: separatorWidth, height: separatorHeight))
        separator.backgroundColor = separatorBGColor
        cell?.addSubview(separator)
        
        cell?.deleteButton.tag = indexPath.row
        
        cell?.deleteButton.addTarget(self, action: #selector(self.deleteString), for: .touchUpInside)
        
        return cell!
    }
    
    func deleteString(sender:UIButton){
        let tag = sender.tag
        
        if (self.arrayOfStrings?.count)! > 1{
            self.arrayOfStrings?.remove(at: tag)
            self.quirksPushView?.addedStrings = self.arrayOfStrings
            self.tableView.reloadData()
            self.scrollToBottom()
        }
        else {
            self.arrayOfStrings?.remove(at: tag)
            self.quirksPushView?.addedStrings = self.arrayOfStrings
            self.tableView.reloadData()
            self.tableView.backgroundView = UIImageView(image: UIImage(named: "love_back"))
            self.tableView.backgroundView?.sizeToFit()
        }
        
    }
    
}
