//
//  AnimalTransferFormViewController.swift
//  White Rabbit
//
//  Created by Michael Bina on 12/28/15.
//  Copyright © 2015 White Rabbit Technology. All rights reserved.
//

import Eureka
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class AnimalTransferFormViewController : FormViewController {
    let TYPE_TAG = "type"
    let NAME_TAG = "name"
    let EMAIL_TAG = "email"
    let ANIMAL_TAG = "animal"
    let NOTE_TAG = "note"
    
    var animalObject : WRAnimal?
    var animalFormController : AnimalFormViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.generateForm()
        
        self.setUpNavigationBar(title: "Transfer Profile")
        
        self.navigationItem.leftBarButtonItem = self.getNavBarItem(imageId: "icon_close", action: #selector(AnimalTransferFormViewController.cancel), height: 25, width: 25)
//        self.navigationItem.rightBarButtonItem = self.getNavBarItem("check_white", action: "saveTransfer", height: 20, width: 25)
    }
    
    func generateForm() {
        form +++ Section("")
            <<< PushRow<TransferType>(TYPE_TAG) {
                $0.title = "Transfer Type"
                $0.options = [.Adopter, .Foster, .CoOwner]
                $0.value = .CoOwner
                
            }.cellSetup { cell, row in
//                cell.imageView?.image = UIImage(named: "form_medical_type")
            }
        
        form +++ Section("Transferee Info")
            <<< NameRow(NAME_TAG) {
                $0.title = "Name"
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "form_user")
            }
            <<< EmailRow(EMAIL_TAG) {
                $0.title = "Email"
            }.cellSetup { cell, row in
                cell.textField.placeholder = "name@email.com"
                cell.imageView?.image = UIImage(named: "form_email")
            }

        form +++ Section("")
            <<< TextAreaRow(NOTE_TAG) {
                $0.title = "Note"
                $0.placeholder = "Add some details or a personal message..."
                $0.onChange({ (row: TextAreaRow) -> () in
                    let val = row.baseValue as? String
                    let maxLength = 140
                    if val?.characters.count > maxLength {
                        row.cell!.textView.text = val?[0...maxLength]
                    }
                })
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage(named: "form_intro")
            }

        
        form +++ Section("")
            <<< ButtonRow("transfer") { $0.title = "Transfer" }.onCellSelection { cell, row in
                self.saveTransfer()
            }
    }
    
    func saveTransfer() {
        let transfer = WRAnimalTransfer()
        
        transfer.animal = self.animalObject!

        if let typeValue = self.form.rowBy(tag: self.TYPE_TAG)?.baseValue as? TransferType {
            transfer.typeValue = typeValue
        }
        
        if let nameValue = self.form.rowBy(tag: self.NAME_TAG)?.baseValue as? String {
            transfer.name = nameValue
        } else {
            self.showError(message: "What's their name?")
            return
        }
        
        if let emailValue = self.form.rowBy(tag: self.EMAIL_TAG)?.baseValue as? String {
            transfer.email = emailValue.lowercased()
        } else {
            self.showError(message: "Gotta give an email to invite.")
            return
        }
        
        if let noteValue = self.form.rowBy(tag: self.NOTE_TAG)?.baseValue as? String {
            transfer.note = noteValue
        }
        
        transfer.statusValue = .Unaccepted
        transfer.actingUser = WRUser.current()
        
        self.showLoader()
        transfer.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
            self.hideLoader()
            if error == nil {

                self.dismiss(animated: true, completion: { () -> Void in
                    self.animalFormController?.showSuccess(message: "Transfer invite sent!")
                })
            } else {
                self.showError(message: error!.localizedDescription)
            }
        })
    }
    
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
