//
//  TimelineEntryDetailViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 11/19/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import ActiveLabel
import Device

class TimelineEntryDetailViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var commentAnimalProfilePhoto: UIButton!
    @IBOutlet weak var commentToolbar: UIToolbar!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var commentToolbarBottomContraint: NSLayoutConstraint!
    
    @IBOutlet weak var commentBarItem: UIBarButtonItem!
    @IBOutlet weak var commentSendButtonBarItem: UIBarButtonItem!
    @IBOutlet weak var translateButton: UIBarButtonItem!
    
    @IBOutlet weak var commentsContainerView: UIView!
    
    var entryObject : WRTimelineEntry?
    var commentsView : TimelineEntryCommentsViewController?
    var shareImage: UIImage!
    
    var showClose : Bool = false
    
    let previewPadding = 20
    let previewWidth = 125
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.commentField.delegate = self
//        self.commentField.addTarget(self, action: #selector(textWasChanged), for: .editingChanged)
        self.commentSendButtonBarItem.image = UIImage(named: "button_chat_send")!.withRenderingMode(.alwaysOriginal)
        

        self.navigationItem.rightBarButtonItem = self.getNavBarItem(imageId: "button_share", action: #selector(showShareSheet), height: 45, width: 35)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        if self.isLoggedIn() {
            self.setAnimalToComment(0)
        }
            
        //self.initActiveLabel(self.textLabel)
        
        self.updateView()
    }
    
    func updateView() {
        switch Device.size() {
        case .screen3_5Inch:
            print("It's a 3.5 inch screen")
            break
        case .screen4Inch:
            print("It's a 4 inch screen")
            self.commentBarItem.width = 180.0
            self.translateButton.width = 20.0
            break
        case .screen4_7Inch:
            print("It's a 4.7 inch screen")
            break
        case .screen5_5Inch:
            let frame = CGRect(x: commentField.frame.minX, y: commentField.frame.minY, width: 340.0, height: commentField.frame.height)
            self.commentField.frame(forAlignmentRect: frame)
            self.translateButton.width = 30.0
            break
        default:
            print("Unknown size")
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(self.showClose) {
            self.setUpModalBar(title: "Meowment")
        } else {
            self.setUpNavigationBar(title: "Meowment")
        }
    }
        
    func setAnimalToComment(_ index: Int) {
        //check if myAnimalsArray updated after login
        if let myAnimalsArray = AppDelegate.getAppDelegate().myAnimalsArray {
            if myAnimalsArray.count > 0 {
            let animalName = myAnimalsArray[index]
            let animalToComment = AppDelegate.getAppDelegate().myAnimalByName![animalName]
            
            if let profilePhotoFile = animalToComment!.profilePhoto {
                profilePhotoFile.getDataInBackground(block: {
                    (imageData: Data?, error: Error?) -> Void in
                    if(error == nil) {
                        let image = UIImage(data:imageData!)
                        self.commentAnimalProfilePhoto.setImage(image?.circle, for: UIControlState())
                    }
                })
            } else {
                self.commentAnimalProfilePhoto.setImage(UIImage(named: "animal_profile_photo_empty"), for: UIControlState())
            }
            
            self.commentAnimalProfilePhoto.tag = index
            }
        }
    }
    
    func showAnimalToCommentSheet() {
        let optionMenu = UIAlertController(title: nil, message: "Comment as:", preferredStyle: .actionSheet)
        
        let appDelegate = AppDelegate.getAppDelegate()

        for (_, animalTuple) in appDelegate.myAnimalByName!.enumerated() {
            let username = animalTuple.value.name
            let animalAction = UIAlertAction(title: username, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in

                self.setAnimalToComment(appDelegate.myAnimalsArray!.index(of: username!)!)
            })

            optionMenu.addAction(animalAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(cancelAction)

        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func commentAnimalProfilePhotoPressed(_ sender: AnyObject) {
        self.checkForUser {
            self.showAnimalToCommentSheet()
        }
    }
    
    func showShareSheet() {
        if let image = self.commentsView?.mainImage {
            self.showShareActionSheet(image: image)
        }
    }
    
    func addComment(_ text: String) {
        self.showLoader()
        let appDelegate = AppDelegate.getAppDelegate()
        if((appDelegate.myAnimalsArray?.count)! > 0) {
            let comment = WRComment()
            comment.entry = self.entryObject!
            
            let animalIndex = self.commentAnimalProfilePhoto.tag
            let animalName = appDelegate.myAnimalsArray![animalIndex]
            let animalToComment = appDelegate.myAnimalByName![animalName]
            comment.animal = animalToComment!
            
            comment.text = text
            comment.saveInBackground { (success: Bool, error: Error?) -> Void in
                if(error == nil) {
                    self.commentsView?.loadObjects()
                    self.hideLoader()
                }
            }
        } else {
            self.hideLoader()
            self.showError(message: "Add a cat to make a comment")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendWasPressed()
        return true
    }
    
    func keyboardWillShow(_ notification: Notification) {
        var info = (notification as NSNotification).userInfo!

        let duration = (info[UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue!
        let curve = info[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: {
            self.commentToolbarBottomContraint.constant = keyboardFrame.size.height
            self.view.layoutIfNeeded()
        }, completion: { (value: Bool) in
        })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        var info = (notification as NSNotification).userInfo!
        
        let duration = (info[UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue!
        let curve = info[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: {
            self.commentToolbarBottomContraint.constant = 0
            self.view.layoutIfNeeded()
            }, completion: { (value: Bool) in
        })
    }
    
    @IBAction func translateWasPressed(_ sender: AnyObject) {
        if(self.commentField.text == "") {
            self.showInfo(message: "type ur msg n use this for lolspeak translayshun.")
            
        } else {
            self.commentField.resignFirstResponder()
            
            var params = [AnyHashable: Any]()
            params["message"] = self.commentField.text
            
            PFCloud.callFunction(inBackground: "translate", withParameters: params, block: { (result: Any?, error: Error?) in
                if (error == nil) {
                    self.commentField.text = result as? String
                }
            })
        }
    }
    
    @IBAction func sendWasPressed() {
        self.checkForUser {
            if(self.commentField.text == "") {
                self.commentField.resignFirstResponder()
            } else {
                self.addComment(self.commentField.text!)
                self.commentField.resignFirstResponder()
                self.commentField.text = ""
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "EntryDetailCommentsEmbed") {
            let commentsView = segue.destination as! TimelineEntryCommentsViewController
            commentsView.entryObject = self.entryObject
            self.commentsView = commentsView
        } else if(segue.identifier == "TimelineEntryDetailToAnimalDetail") {
            let detailView = segue.destination as! AnimalDetailViewController
            
            let animalObject = entryObject?.animal
            detailView.currentAnimalObject = animalObject
        }
    }
}
