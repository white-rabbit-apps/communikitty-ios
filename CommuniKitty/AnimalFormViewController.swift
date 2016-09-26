//
//  AnimalFormViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 10/13/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import Eureka
//import GooglePlacesRow
import Fusuma
import CLImageEditor

public final class Coat : NSObject {
    var name: String?
    var image: UIImage?
    var object: WRCoat?
    
    init(object: WRCoat, name: String, image: UIImage) {
        self.object = object
        self.name = name
        self.image = image
        super.init()
    }
}

//public final class CoatsPushRow : SelectorRow<Coat, PushSelectorCell<Coat>, CoatsTableViewController>, RowType {
//    typealias Cell = <#type#>
//
//    public var tag: String?
//    
//    public required init(tag: String?) {
//        super.init(tag: tag)
//        PresentationMode = .Show(controllerProvider: ControllerProvider.Callback {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let cvc = storyboard.instantiateViewControllerWithIdentifier("CoatsTableView") as! CoatsTableViewController
//            return cvc
//            }, completionCallback: { vc in
//                vc.navigationController?.popViewControllerAnimated(true)
//        })
//        
//        displayValueFor = {
//            guard let coat = $0 as Coat? else { return "" }
//            return coat.name
//        }
//    }
//}



public final class Breed : NSObject {
    var name: String?
    var image: UIImage?
    var object: WRBreed?
    
    init(object: WRBreed, name: String, image: UIImage) {
        self.object = object
        self.name = name
        self.image = image
        super.init()
    }
}

//public final class BreedsPushRow : SelectorRow<Breed, PushSelectorCell<Breed>, BreedsTableViewController>, RowType {
//    public var tag: String?
//
//    typealias Cell = <#type#>
//    
//    public required init(tag: String?) {
//        super.init(tag: tag)
//        PresentationMode = .Show(controllerProvider: ControllerProvider.Callback {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let bvc = storyboard.instantiateViewControllerWithIdentifier("BreedsTableView") as! BreedsTableViewController
//            return bvc
//            }, completionCallback: { vc in
//                vc.navigationController?.popViewControllerAnimated(true)
//        })
//        
//        displayValueFor = {
//            guard let breed = $0 as Breed? else { return "" }
//            return breed.name
//        }
//    }
//}

//// custom SelectorRow class to open Loves/Hates form sections
//public final class  QuirksSelectorRow<T: Hashable>: GenericMultipleSelectorRow<String, PushSelectorCell<Set<String>>, QuirksSelectorViewController>, RowType {
//    /// The cell associated to this row.
//    public var baseCell: BaseCell!
//
//    public var tag: String?
//    
//    
//    //pass the values of AnimalFormViewController
//    var animalObject: WRAnimal?
//    var animalForm: AnimalFormViewController?
//    var navTitle: String?
//    
//    
//    required public init(tag: String?) {
//        super.init(tag: tag)
//        
//        PresentationMode = .Show(controllerProvider: ControllerProvider.Callback {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let cvc = storyboard.instantiateViewControllerWithIdentifier("QuirksSelectorView") as! QuirksSelectorViewController
//            cvc.animalObject = self.animalObject
//            if self.animalForm != nil{
//                cvc.animalFormView = self.animalForm
//            }
//            cvc.navTitle = self.navTitle
//            return cvc
//            }, completionCallback: { vc in
//                vc.navigationController?.popViewControllerAnimated(true)
//        })
//        
//    }
//}


class AnimalFormViewController : FormViewController, FusumaDelegate, CLImageEditorDelegate {
    
    @IBOutlet var formView: UIView!
    
    let NAME_TAG = "name"
    let PROFILE_PHOTO_TAG = "profilePhoto"
    let COVER_PHOTO_TAG = "coverPhoto"
    
    let BIRTHDATE_TAG = "birthDate"
    let DECEASED_TAG = "deceasedDate"
    let GENDER_TAG = "gender"
    let USERNAME_TAG = "username"
    let HOMETOWN_TAG = "hometown"
    let INTRO_TAG = "intro"
    
    let TRAITS_TAG = "traits"
    let BREED_TAG = "breed"
    let COAT_TAG = "coat"
    let SHELTER_TAG = "shelter"
    
    let LOVES_TAG = "loves"
    let HATES_TAG = "hates"
    
    let ADOPTABLE_TAG = "adoptable"
    let FEATURED_TAG = "featured"
    
    let INSTAGRAM_TAG = "instagramUsername"
    let TWITTER_TAG = "twitterUsername"
    let YOUTUBE_TAG = "youtubeUsername"
    let FACEBOOK_TAG = "facebookPageId"
    
    var detailController : AnimalDetailViewController?
//    var animalTableController : AnimalsTableViewController?
    var animalObject : WRAnimal?
    var selectedTraitStrings : Set<String>?
    var selectedLoveStrings: Set<String>?
    var selectedHatesStrings: Set<String>?
    var firstLoad:Bool?
    var userObject : WRUser?
    var adoptableSelected : Bool = false
    var profileImage : UIImage?
    func isEditMode() -> Bool {
        return (self.animalObject != nil)
    }
    
    func loadTraits() {
        if let animal = self.animalObject {
            let traits = animal.traits
            
            var value = Set<String>()
            
            if traits != nil {
                for trait in traits! {
                    trait.fetchIfNeededInBackground(block: { (object: PFObject?, error: Error?) -> Void in
                        let trait = object as? WRTrait
                        let traitName = trait?.name
                        if traitName != nil {
                            value.insert(traitName!)
                        }
                    })
                }
            }
            
            self.selectedTraitStrings = value
            self.form.rowBy(tag: self.TRAITS_TAG)?.baseValue = value
            self.form.rowBy(tag: self.TRAITS_TAG)?.updateCell()
        }
    }
    
    //func to load array of Loves of a current object
    func loadLoves(){
        if let animal = self.animalObject{
            if let loves = animal.loves{
                
                var value = Set<String>()
                if loves.count != 0 {
                    
                    for love in loves{
                        value.insert(love)
                        
                    }
                    
                    self.selectedLoveStrings = value
                }
            } else {
                self.selectedHatesStrings = []
            }
        }
    }
    
    //func to load array of Hates of a current object
    func loadHates(){
        if let animal = self.animalObject{
            if let hates = animal.hates{
                
                var value = Set<String>()
                if hates.count != 0 {
                    for hate in hates{
                        value.insert(hate)
                    }
                    self.selectedHatesStrings = value
                }
            } else {
                self.selectedHatesStrings = []
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideLoader()
        self.firstLoad = true
        
        self.loadTraits()
        self.loadLoves()
        self.loadHates()
        self.generateForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.firstLoad == true{
            self.firstLoad = false
        } else{
            // it updates the cell value in the form with added values in the QuirksPushViewController
            self.loadLoves()
            self.loadHates()
            self.form.rowBy(tag: self.LOVES_TAG)?.baseValue = self.selectedLoveStrings
            self.form.rowBy(tag: self.LOVES_TAG)?.updateCell()
            self.form.rowBy(tag: self.HATES_TAG)?.baseValue = self.selectedHatesStrings
            self.form.rowBy(tag: self.HATES_TAG)?.updateCell()
        }
        
        if !self.isEditMode() {
            self.setUpNavigationBar(title: "New Kitty Profile")
        } else {
            self.setUpNavigationBar(title: "Edit Kitteh")
        }
        
        self.navigationItem.leftBarButtonItem = self.getNavBarItem(imageId: "icon_close", action: #selector(AnimalFormViewController.cancel), height: 25, width: 25)
        self.navigationItem.rightBarButtonItem = self.getNavBarItem(imageId: "icon_save", action: #selector(AnimalFormViewController.saveAnimal), height: 20, width: 25)
    }
    
    func generateForm() {
        let appDelegate = AppDelegate.getAppDelegate()
        
        //        form +++ ImageRow(PROFILE_PHOTO_TAG) {imageRow_ in
        //            }.cellSetup { cell, row in
        //                if self.isEditMode() {
        //                    if let profilePhotoFile = self.animalObject!.profilePhoto {
        //                        profilePhotoFile.getDataInBackgroundWithBlock({
        //                            (imageData: NSData?, error: Error?) -> Void in
        //                            if(error == nil) {
        //                                let image = UIImage(data:imageData!)
        //                                row.profileImage = (image?.circle)!
        //                                row.customUpdateCell()
        //                            }
        //                        })
        //                    } else {
        //                    }
        //                } else {
        //                    row.profileImage = UIImage(named: "animal_profile_photo_empty_add.png")!
        //                }
        //                row.shouldShowProfileImage  = true
        //            }.onCellSelection {cell,row in
        //                self.takeFusumaPhoto()
        //                row.shouldShowProfileImage  = false
        //            }.cellUpdate { cell, row in
        //                if(self.profileImage != nil) {
        //                    row.profileImage = self.profileImage!
        //                    row.customUpdateCell()
        //                }
        //        }
        
        form +++ Section("Info") { section  in
            section.color   = UIColor.lightOrangeColor()
        }

        <<< NameRow(NAME_TAG) {
            $0.title = "Name"
            if self.isEditMode() {
                $0.value = self.animalObject?.name
            }
        }.cellSetup { cell, row in
            cell.imageView?.image = UIImage(named: "form_cat_name")
        }
        <<< TwitterRow(USERNAME_TAG) {
            $0.title = "Username"
            if self.isEditMode() {
                $0.value = self.animalObject?.username
            }
        }.cellSetup { cell, row in
            cell.textField.placeholder = "@username"
            cell.imageView?.image = UIImage(named: "form_username")
        }
        <<< SegmentedRow<String>(GENDER_TAG) {
            
            $0.title = "Gender"
            $0.options = ["Male", "Female"]
            $0.optionImages = [UIImage(named: "icon_gender_male")!, UIImage(named: "icon_gender_female")!]
            if self.isEditMode() {
                $0.value = self.animalObject?.gender
            }
        }.cellSetup { cell, row in
            cell.imageView?.image = UIImage(named: "form_gender")
        }
        
        <<< DateInlineRow(BIRTHDATE_TAG) {
            $0.title = "Birth Date"
            
            if self.isEditMode() {
                $0.value = self.animalObject?.birthDate
            }
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "form_birthdate")
                row.maximumDate = Date()
        }
        //            <<< GooglePlacesTableRow(HOMETOWN_TAG) {
        //                $0.title = "Hometown"
        //                if self.isEditMode() {
        //                    if let hometownVal = self.animalObject?.objectForKey(self.HOMETOWN_TAG) as? String {
        //                        $0.value = GooglePlace(string: hometownVal)
        //                    }
        //                }
        //                }.cellSetup { cell, row in
        //                    cell.imageView?.image = UIImage(named: "form_hometown")
        //            }
        <<< TextAreaRow(INTRO_TAG) {
            $0.title = "Intro"
            $0.placeholder = "Enter an intro..."
            $0.onChange({ (row: TextAreaRow) -> () in
                let val = row.baseValue as? String
                let maxLength = 300
                if (val?.characters.count)! > maxLength {
                    row.cell!.textView.text = val?[0...maxLength]
                }
            })
            if self.isEditMode() {
                $0.value = self.animalObject?.intro
            }
        }.cellSetup { cell, row in
            cell.imageView?.image = UIImage(named: "form_intro")
        }
        
        form +++ Section("Details"){ section  in
                        section.color   = UIColor.lightYellowColor()
        }
            
//            <<< BreedsPushRow(BREED_TAG) {
//                $0.title = "Breed"
//                $0.options = appDelegate.breedsArray!
//                
//                if self.isEditMode() {
//                    if let breedObject = self.animalObject?.breed {
//                        let name = breedObject.name
//                        if name != nil {
//                            $0.value = appDelegate.breedByName![name!]
//                        }
//                    }
//                }
//                
//                }.cellSetup { cell, row in
//                    cell.imageView?.image = UIImage(named: "form_breed")
//            }
//            
//            <<< CoatsPushRow(COAT_TAG) {
//                $0.title = "Coat"
//                $0.options = appDelegate.coatsArray!
//                
//                if self.isEditMode() {
//                    if let coatObject = self.animalObject?.coat {
//                        let name = coatObject.name
//                        if name != nil {
//                            $0.value = appDelegate.coatByName![name!]
//                        }
//                    }
//                }
//                }.cellSetup { cell, row in
//                    cell.imageView?.image = UIImage(named: "form_coat")
//        }
        
        
        form +++ Section("Personality") { section  in
            section.color   = UIColor.lightGreenColor()
        }
            
            <<< MultipleSelectorRow<String>(TRAITS_TAG) {
                $0.title = "Traits"
                $0.options = appDelegate.traitsArray!
                if self.isEditMode() {
                    $0.value = self.selectedTraitStrings
                }
                }.cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "form_traits")
            }
            
//            <<< QuirksSelectorRow<String>(LOVES_TAG) {
//                
//                $0.title = "Loves"
//                $0.navTitle = "Loves"
//                // checking if the object exists
//                if self.isEditMode() {
//                    $0.animalObject = self.animalObject
//                    $0.animalForm   = self
//                    //load loves arrys again in case it was updated
//                    self.loadLoves()
//                    $0.value = self.selectedLoveStrings
//                } else {
//                    let animalObject = WRAnimal()
//                    animalObject.loves = [String]()
//                    $0.animalObject = animalObject
//                    $0.animalForm = self
//                }
//            }.cellSetup { cell, row in
//                cell.imageView?.image = UIImage(named: "form_loves")
//            }
        
//            <<< QuirksSelectorRow<String>(HATES_TAG){
//                $0.title = "Hates"
//                $0.navTitle = "Hates"
//                if self.isEditMode(){
//                    $0.animalObject = self.animalObject
//                    $0.animalForm = self
//                    self.loadHates()
//                    $0.value = self.selectedHatesStrings
//                } else {
//                    let animalObject = WRAnimal()
//                    animalObject.hates = [String]()
//                    $0.animalObject = animalObject
//                    $0.animalForm = self
//                }
//                
//                
//            }.cellSetup { cell, row in
//                cell.imageView?.image = UIImage(named: "form_hates")
//            }
        
        form +++ Section("Soshul Meowdia") { section  in
            section.color   = UIColor.lightBlueColor()
        }
            
            <<< TwitterRow(TWITTER_TAG) {
                $0.title = "Twitter"
                if self.isEditMode() {
                    $0.value = self.animalObject?.twitterUsername
                }
                }.cellSetup { cell, row in
                    cell.textField.placeholder = "@username"
                    cell.imageView?.image = UIImage(named: "form_social_twitter")
            }
            <<< TwitterRow(YOUTUBE_TAG) {
                $0.title = "Youtube"
                if self.isEditMode() {
                    $0.value = self.animalObject?.youtubeUsername
                }
                }.cellSetup { cell, row in
                    cell.textField.placeholder = "@username"
                    cell.imageView?.image = UIImage(named: "form_social_youtube")
            }
            <<< TwitterRow(FACEBOOK_TAG) {
                $0.title = "Facebook"
                if self.isEditMode() {
                    $0.value = self.animalObject?.facebookPageId
                }
                }.cellSetup { cell, row in
                    cell.textField.placeholder = "page_id"
                    cell.imageView?.image = UIImage(named: "form_social_facebook")
            }
            <<< TwitterRow(INSTAGRAM_TAG) {
                $0.title = "Instagram"
                if self.isEditMode() {
                    $0.value = self.animalObject?.instagramUsername
                }
                }.cellSetup { cell, row in
                    cell.textField.placeholder = "@username"
                    cell.imageView?.image = UIImage(named: "form_social_instagram")
            }
//            <<< ButtonRow("instagramImport") {
//                $0.title = "Import Photos from Instagram"
//                $0.hidden = .function([self.INSTAGRAM_TAG], { form -> Bool in
//                    if !self.isEditMode() {
//                        return true
//                    }
//                    let row: RowOf<String>! = form.rowBy(tag: self.INSTAGRAM_TAG)
//                    return row.value == nil
//                })
//                $0.cellStyle = .value1
//            }.onCellSelection { cell, row in
//                self.instagramImport()
//            }.cellSetup { cell, row in
//                cell.imageView?.image = UIImage(named: "form_social_instagram")
//            }
        
        if(self.isEditMode()) {
            form +++ Section("Memorial") { section  in
                section.color   = UIColor.orange
            }
                
            <<< DateInlineRow(DECEASED_TAG) {
                $0.title = "Deceased Date"
                if self.isEditMode() {
                    $0.value = self.animalObject?.deceasedDate
                }
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "form_date")
                row.maximumDate = Date()
            }
        }
        
        let isAdmin : Bool = WRUser.current()!.admin
        let userShelter = WRUser.current()!.shelter
        let isShelterCaregiver : Bool = false //(userShelter != nil)
        
        if(isAdmin || isShelterCaregiver) {
            var shelterOptions = appDelegate.sheltersArray!
            
            if isShelterCaregiver && !isAdmin {
                let shelterName = userShelter?.name
                shelterOptions = [shelterName!]
            }
            
            form +++ Section("Adoption") { section  in
                section.color   = UIColor.lightRedColor()
            }
                <<< SwitchRow(ADOPTABLE_TAG) {
                    $0.title = "Adoptable"
                    $0.value = false
                    if self.isEditMode() {
                        $0.value = self.animalObject?.object(forKey: self.ADOPTABLE_TAG) as? Bool
                    } else {
                        $0.value = self.adoptableSelected
                    }
                }
                
                <<< PushRow<String>(SHELTER_TAG) {
                    $0.title = "Shelter"
                    $0.options = shelterOptions
                    $0.hidden = .function([self.ADOPTABLE_TAG], { form -> Bool in
                        let row: RowOf<Bool>! = form.rowBy(tag: self.ADOPTABLE_TAG)
                        return row.value ?? false == false
                    })
                    if self.isEditMode() {
                        let shelterObject = self.animalObject?.shelter
                        
                        let field = $0
                        shelterObject?.fetchIfNeededInBackground(block: { (object: PFObject?, error: Error?) -> Void in
                            if(shelterObject != nil) {
                                field.value = shelterObject!.name
                            }
                        })
                    } else if self.adoptableSelected && !isAdmin {
                        $0.value = shelterOptions[0]
                    }
            }
        }
        
        if(isAdmin) {
            form +++ Section("Admin") { section  in
                section.color   = UIColor.lightPinkColor()
            }
                
            <<< SwitchRow(FEATURED_TAG) {
                $0.title = "Featured"
                $0.value = false
                if self.isEditMode() {
                    $0.value = self.animalObject?.object(forKey: self.FEATURED_TAG) as? Bool
                }
            }
        }
        
        if(self.isEditMode()) {
            form +++ Section("Options") { section  in
                section.color   = UIColor.facebookThemeColor()
            }
                
            <<< ButtonRow("transfer") { $0.title = "Transfer Profile" }.onCellSelection { cell, row in
                self.showTransferAnimalForm()
            }
                
            <<< ButtonRow("remove") { $0.title = "Remove Profile" }.onCellSelection { cell, row in
                self.removeAnimal()
            }
        }
    }
    
//    func instagramImport() {
//        if var instagramValue = self.form.rowBy(tag: self.INSTAGRAM_TAG)?.baseValue as? String {
//            if instagramValue[0] == "@" {
//                instagramValue = String(instagramValue.characters.dropFirst())
//            }
//            
//            var params = [NSObject : AnyObject]()
//            params["animalObjectId"] = self.animalObject?.objectId
//            params["instagramUsername"] = instagramValue
//            
//            PFCloud.callFunctionInBackground("importInstagramPhotos", withParameters: params) { (result: AnyObject?, error: NSError?) -> Void in
//                if (error == nil) {
//                    Answers.logCustomEventWithName("Instagram Photos Imported", customAttributes: ["instagramUsername": instagramValue, "animalUsername": self.animalObject!.username!])
//                    
//                    self.showSuccess("Importing your photos from Instagram")
//                }
//            }
//        } else {
//            self.showError(message: "Can't import from Instagram without a username")
//        }
//    }
    
    func showTransferAnimalForm() {
        let nav = UINavigationController()
        let transferForm = AnimalTransferFormViewController()
        transferForm.animalObject = self.animalObject
        transferForm.animalFormController = self
        nav.viewControllers = [transferForm]
        
        self.present(nav, animated: true, completion: nil)
    }
    
    func removeOwner() {
        animalObject?.fetchInBackground(block: { (object: PFObject?, error: Error?) -> Void in
            
            var owners = self.animalObject!.owners!
            let fosters = self.animalObject!.fosters!
            
            let adoptable : Bool = self.animalObject!.adoptable
            let shelter = self.animalObject!.shelter
            
            if (fosters.count + owners.count) > 1 || (adoptable && shelter != nil) {
                let refreshAlert = UIAlertController(title: "Remove Your Ownership of This Profile?", message: "The profile data will remain intact but you will no longer be able to access it as an owner.  All other owners will stay in place.", preferredStyle: UIAlertControllerStyle.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Do it", style: .default, handler: { (action: UIAlertAction!) in
                    
                    owners = owners.filter({ (user: WRUser) -> Bool in
                        return WRUser.current()!.objectId != user.objectId
                    })
                    self.animalObject!.owners = owners
                    
                    _ = self.animalObject!.username!
                    
                    self.animalObject!.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
                        
                        self.dismiss(animated: true, completion: { () -> Void in
                            self.detailController!.goBackAndRun(completion: { () -> () in
//                                if(self.animalTableController != nil) {
//                                    self.animalTableController!.userProfile?.refreshAll()
//                                    self.animalTableController!.showSuccess("Say bye bye :-(")
//                                }
                                AppDelegate.getAppDelegate().loadMyAnimals()
                            })
                        })
                        
                    })
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                }))
                
                self.present(refreshAlert, animated: true, completion: nil)
                
            } else {
                self.showError(message: "Can't remove ownership if you're the only owner or foster.  Please transfer the profile first.")
            }
        })
        
    }
    
    func removeAnimal() {
        self.animalObject?.fetchInBackground(block: { (object: PFObject?, error: Error?) -> Void in
            
            let owners = self.animalObject!.owners!
            let fosters = self.animalObject!.fosters!
            
            if (fosters.count + owners.count) > 1 {
                self.showError(message: "Can't remove the profile while there are other owners or fosters.  Please remove ownership.")
                
            } else {
                let refreshAlert = UIAlertController(title: "Remove This Profile?", message: "All data will be lost and cannot be recovered.", preferredStyle: UIAlertControllerStyle.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Do it", style: .default, handler: { (action: UIAlertAction!) in
                    _ = self.animalObject!.username!
                    self.animalObject!.deleteInBackground(block: { (success: Bool, error: Error?) -> Void in
                        
                        self.dismiss(animated: true, completion: { () -> Void in
                            self.detailController!.goBackAndRun(completion: { () -> () in
//                                if self.animalTableController != nil {
//                                    self.animalTableController!.userProfile?.refreshAll()
//                                    self.animalTableController!.showSuccess("Removed. KTHXBAI.")
//                                }
                                AppDelegate.getAppDelegate().loadMyAnimals()
                            })
                        })
                        
                    })
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                }))
                
                self.present(refreshAlert, animated: true, completion: nil)
            }
        })
    }
    
    /**
     Get the newly added values to the table.
     Parameters:
     - selectedStringsArray: array of updated values
     - nav: navigation name to update the appropriate array
     */
    func selectedStringsReload(selectedStringsArray:[String]?, nav:String?){
        var selectedString = Set<String>()
        
        if let array = selectedStringsArray{
            for item in array {
                selectedString.insert(item)
            }
        }
        if nav == "Loves"{
            self.selectedLoveStrings = selectedString
        } else if nav == "Hates"{
            self.selectedHatesStrings = selectedString
        }
    }
    
    func saveAnimal() {
        let appDelegate = AppDelegate.getAppDelegate()
        
        var animal = WRAnimal()
        if self.isEditMode() {
            animal = self.animalObject!
        }
        
        if let nameValue = self.form.rowBy(tag: self.NAME_TAG)?.baseValue as? String {
            animal.name = nameValue.trim()
        }
        
//        if let hometown = self.form.rowBy(tag: self.HOMETOWN_TAG)!.baseValue as? GooglePlace {
//            var hometownVal = ""
//            switch hometown {
//            case let GooglePlace.UserInput(val):
//                hometownVal = val
//            case let GooglePlace.Prediction(pred):
//                hometownVal = pred.desc
//            }
//            animal.setObject(hometownVal, forKey: HOMETOWN_TAG)
//        }
        
        if let breedValue = self.form.rowBy(tag: self.BREED_TAG)?.baseValue as? Breed {
            animal.breed = breedValue.object!
        }
        
        if let coatValue = self.form.rowBy(tag: self.COAT_TAG)?.baseValue as? Coat {
            animal.setObject(coatValue.object!, forKey: COAT_TAG)
        }
        
        if let birthDateValue = self.form.rowBy(tag: self.BIRTHDATE_TAG)?.baseValue as? Date {
            animal.birthDate = birthDateValue
        }
        if let deceasedDateValue = self.form.rowBy(tag: self.DECEASED_TAG)?.baseValue as? Date {
            animal.deceasedDate = deceasedDateValue
        }
        if let genderValue = self.form.rowBy(tag: self.GENDER_TAG)?.baseValue as? String {
            animal.gender = genderValue
        }
        if let introValue = self.form.rowBy(tag: self.INTRO_TAG)?.baseValue as? String {
            animal.intro = introValue.trim()
        } else {
            animal.intro = ""
        }
        if var usernameValue = self.form.rowBy(tag: self.USERNAME_TAG)?.baseValue as? String {
            if usernameValue[0] == "@" {
                usernameValue = String(usernameValue.characters.dropFirst())
            }
            animal.username = usernameValue.lowercased().trim()
        }
        if let facebookValue = self.form.rowBy(tag: self.FACEBOOK_TAG)?.baseValue as? String {
            animal.facebookPageId = facebookValue.trim()
        } else {
            animal.facebookPageId = nil
        }
        
        if var instagramValue = self.form.rowBy(tag: self.INSTAGRAM_TAG)?.baseValue as? String {
            if instagramValue[0] == "@" {
                instagramValue = String(instagramValue.characters.dropFirst())
            }
            animal.instagramUsername = instagramValue
        } else {
            animal.instagramUsername = nil
        }
        
        if var twitterValue = self.form.rowBy(tag: self.TWITTER_TAG)?.baseValue as? String {
            if twitterValue[0] == "@" {
                twitterValue = String(twitterValue.characters.dropFirst())
            }
            animal.twitterUsername = twitterValue
        } else {
            animal.twitterUsername = nil
        }
        
        if let youtubeValue = self.form.rowBy(tag: self.YOUTUBE_TAG)?.baseValue as? String {
            animal.youtubeUsername = youtubeValue.trim()
        } else {
            animal.youtubeUsername = nil
        }
        
        if !self.isEditMode() {
            animal.owners = [WRUser.current()!]
            animal.fosters = []
        }
        
        if let featuredValue = self.form.rowBy(tag: self.FEATURED_TAG)?.baseValue as? Bool {
            animal.setObject(featuredValue, forKey: FEATURED_TAG)
        }
        if let adoptableValue = self.form.rowBy(tag: self.ADOPTABLE_TAG)?.baseValue as? Bool {
            animal.setObject(adoptableValue, forKey: ADOPTABLE_TAG)
            
            if(adoptableValue && !self.isEditMode()) {
                animal.owners = []
            }
        }
        
        if let shelterValue = self.form.rowBy(tag: self.SHELTER_TAG)?.baseValue as? String {
            let shelter = appDelegate.shelterByName![shelterValue]
            animal.shelter = shelter!
        }
        
        
        var loveObjects = [String]()
        if self.selectedLoveStrings?.isEmpty != nil{
            for love in self.selectedLoveStrings!{
                loveObjects.append(love)
            }
        }
        //create loves array in the animal WRAnimal object
        animal.loves = loveObjects
        
        var hateObjects = [String]()
        if self.selectedHatesStrings?.isEmpty != nil{
            for hate in self.selectedHatesStrings!{
                hateObjects.append(hate)
            }
        }
        //create hates array in the animal WRAnimal object
        animal.hates = hateObjects
        
        if let traitsValue = self.form.rowBy(tag: self.TRAITS_TAG)?.baseValue as? Set<String> {
            var traitObjects = [WRTrait]()
            for trait in traitsValue{
                let trait = appDelegate.traitByName![trait]
                traitObjects.append(trait!)
            }
            animal.traits = traitObjects
        }
        
        if let image = self.profileImage {
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            
            let fileName : String
            if let name = self.form.rowBy(tag: self.NAME_TAG)?.baseValue as? String {
                fileName = name + ".jpg"
            } else {
                fileName = "profileImage.jpg"
            }
            
            let imageFile:PFFile = PFFile(name: fileName, data: imageData!)!
            
            animal.profilePhoto = imageFile
        }
        
        self.showLoader()
        animal.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
            self.hideLoader()
            if error == nil {
                if(self.isEditMode()) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NTF_FinishedGettingMyAnimals"), object: nil)
                } else {
                    AppDelegate.getAppDelegate().loadMyAnimals()
                }
                
                self.animalObject = animal
                
                self.dismiss(animated: true, completion: nil)
                
                _ = animal.name!
                
                if self.detailController != nil {
                    self.detailController!.loadAnimal()
                    self.detailController!.reloadTimeline()
                    self.detailController!.showSuccess(message: "Kitteh's info saved successfully")
                }
//                else if self.animalTableController != nil {
//                    self.animalTableController!.loadObjects()
//                    self.animalTableController!.showSuccess("Welcome to the kitty klub \(name)!")
//                }
            } else {
                self.showError(message: error!.localizedDescription)
            }
        })
    }
    
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Return the image which is selected from camera roll or is taken via the camera.
    func fusumaImageSelected(_ image: UIImage, creationDate: NSDate?) {
        self.modalTransitionStyle = .coverVertical
        
        self.dismiss(animated: false, completion: { () -> Void in
            self.showEditor(image: image, delegate: self, ratios: [1, 1], fromController: self)
        })
    }
    
    func fusumaImageSelected(_ image: UIImage) {
        self.modalTransitionStyle = .coverVertical
        
        self.dismiss(animated: false, completion: { () -> Void in
            self.showEditor(image: image, delegate: self, ratios: [1, 1], fromController: self)
        })
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        print("Camera roll unauthorized")
    }
    
    
    func imageEditor(_ editor: CLImageEditor!, didFinishEdittingWith image: UIImage!) {
        self.profileImage = image
        self.dismiss(animated: false) { () -> Void in
            self.form.rowBy(tag: self.PROFILE_PHOTO_TAG)?.updateCell()
        }
        
    }
    
    func takeFusumaPhoto() {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        
        fusuma.transitioningDelegate = transitioningDelegate
        fusuma.modalPresentationStyle = .custom
        
        present(fusuma, animated: true, completion: nil)
    }
}
