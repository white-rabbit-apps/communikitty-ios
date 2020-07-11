//
//  QuirksSelectorViewController.swift
//  CommuniKitty
//
//  Created by Alina Chernenko on 9/29/16.
//  Copyright © 2016 White Rabbit Apps. All rights reserved.
//

import UIKit
import Device
import Eureka
import Parse

class QuirksSelectorViewController: UIViewController, UITextFieldDelegate, TypedRowControllerType {
    
    @IBOutlet weak var controllerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var toolbarView: UIToolbar!
    @IBOutlet weak var textFieldButtonItem: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addButtonItem: UIBarButtonItem!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var bottomToolbarContraint: NSLayoutConstraint!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var objectContainerView: UIView!
    @IBOutlet weak var bottomContainerObjectsViewConstraint: NSLayoutConstraint!
    
    public var row: RowOf<Set<String>>!
    typealias RowValue = Set<String>
    public var onDismissCallback: ((UIViewController) -> ())?
    public var completionCallback : ((UIViewController) -> ())?
    
    var animalObject : WRAnimal?
    var animalFormView: AnimalFormViewController?
    var quirksTableView: QuirksTableViewController?
    var quirksContainerView: QuirksContainerViewController?
    var navTitle : String? = "Title"
    var addedStrings:[String]?
    var arrayOfObjects: [String]?

    convenience internal init(_ callback: @escaping (UIViewController) -> ()){
        self.init(nibName: nil, bundle: nil)
        completionCallback = callback
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpNavigationBar(title: navTitle!)
    }
    
    override public func viewWillDisappear(_ _animated: Bool) {
        self.setUpTransparentNavigationBar()
        super.viewWillDisappear(_animated)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.updateView()
        self.objectContainerView.isHidden = true
        
        //prepopulate addedStrings/arrayOfObjects array depending on the calling form tag
        switch navTitle! {
        case "Loves":
            self.addedStrings = self.animalObject?.loves
            self.arrayOfObjects = self.animalObject?.loves
        case "Hates":
            self.addedStrings = self.animalObject?.hates
            self.arrayOfObjects = self.animalObject?.hates
        default:
            self.addedStrings = []
            self.arrayOfObjects = []
        }
        
        //triggers keyboard on field focus
        NotificationCenter.default.addObserver(self, selector: #selector(QuirksSelectorViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(QuirksSelectorViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.textField.delegate = self
        self.textField.addTarget(self, action: #selector(self.textWasChanged), for: .editingChanged)
        
        self.setUpNavigationBar(title: navTitle!)
        
        self.navigationItem.rightBarButtonItem = self.getNavBarItem(imageId: "icon_save", action: #selector(self.saveStrings), height: 20, width: 25)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(UIViewController.respondToSwipeGesture))
        
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    
    @objc func saveStrings(){
        if self.addedStrings?.isEmpty != nil {
            if self.animalObject?.name?.isEmpty != nil {
                self.arrayOfObjects = self.addedStrings
                
                //update the object's array
                switch navTitle! {
                case "Loves":
                    self.animalObject?.loves = self.addedStrings
                case "Hates":
                    self.animalObject?.hates = self.addedStrings
                default:
                    print("Animal object doesn't have an array to update")
                }
                
                //save the WRAnimal
                self.animalObject?.saveInBackground{(success: Bool, error: Error?) -> Void in
                    if (error == nil) {
                        _ = self.quirksTableView?.navigationController?.popToRootViewController(animated: true)
                        self.animalFormView?.selectedStringsReload(selectedStringsArray: self.addedStrings, nav: self.navTitle)
                    }
                }
                
                //if the object doesn't exist yet
            } else {
                self.arrayOfObjects = self.addedStrings
                switch navTitle! {
                case "Loves":
                    self.animalObject?.loves = self.addedStrings
                case "Hates":
                    self.animalObject?.hates = self.addedStrings
                default:
                    print("Animal object doesn't have an array to update")
                }
                _ = self.quirksTableView?.navigationController?.popToRootViewController(animated: true)
                self.animalFormView?.selectedStringsReload(selectedStringsArray: self.addedStrings, nav: self.navTitle)
            }
        }
    }
    
    //update addedStrings array with new item
    func addString(text:String){
        
        let animal = self.animalObject
        
        switch navTitle! {
        case "Loves":
            self.arrayOfObjects = animal?.loves
        case "Hates":
            self.arrayOfObjects = animal?.hates
        default:
            self.arrayOfObjects = []
        }
        var stringArray = [String]()
        
        stringArray = self.addedStrings!
        
        if self.arrayOfObjects?.isEmpty == nil {
            stringArray.append(text)
        } else {
            
            stringArray.append(text)
        }
        
        self.addedStrings = stringArray
        //update the table
        self.quirksTableView?.loadObjectsInTheTable(stringArray: stringArray, vc:self)
    }
    
    @IBAction func addWasPressed(_ sender: AnyObject) {
        if self.textField.text == "" {
            self.textField.resignFirstResponder()
        } else {
            self.addString(text: self.textField.text!)
            self.textField.resignFirstResponder()
            self.textField.text = ""
        }
 
    }
    //updates the footer container depending on the device
    func updateView() {
        
        switch Device.size() {
        case .screen3_5Inch:
            print("It's a 3.5 inch screen")
            break
        case .screen4Inch:
            print("It's a 4 inch screen")
            self.textFieldButtonItem.width = 240.0
            break
        case .screen4_7Inch:
            self.textFieldButtonItem.width = 300.0
            print("It's a 4.7 inch screen")
            break
        case .screen5_5Inch:
            self.textFieldButtonItem.width = 340.0
            self.addButtonItem.width = 30.0
            let frame = CGRect(x: textField.frame.minX, y: textField.frame.minY, width: 320, height: textField.frame.height)
            self.textField.frame(forAlignmentRect: frame)
            break
        default:
            print("Unknown size")
            break
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.objectContainerView.isHidden = false
        var info = notification.userInfo!
        
        let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue!
        let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            self.bottomToolbarContraint.constant = keyboardFrame.size.height
            self.view.layoutIfNeeded()
            }, completion: { (value: Bool) in
        })
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.objectContainerView.isHidden = true
        var info = notification.userInfo!
        
        let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue!
        let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            self.bottomToolbarContraint.constant = 0
            self.view.layoutIfNeeded()
            }, completion: { (value: Bool) in
        })
    }
    
    
     override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "QuirksTableViewEmbed") {
            let quirksTableView = segue.destination as! QuirksTableViewController
            quirksTableView.entryObject = self.animalObject
            quirksTableView.quirksPushView = self
            self.quirksTableView = quirksTableView
        }
        
        if (segue.identifier == "QuirksContainerViewEmbed"){
            let quirksContainerView = segue.destination as! QuirksContainerViewController
            quirksContainerView.quirksViewController = self
            self.quirksContainerView = quirksContainerView
        }
    }
}

