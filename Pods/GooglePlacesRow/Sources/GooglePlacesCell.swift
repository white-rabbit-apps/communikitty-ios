
//
//  GooglePlacesCell.swift
//  GooglePlacesRow
//
//  Created by Mathias Claassen on 4/13/16.
//
//

import Foundation
import UIKit
import Eureka
//import GoogleMaps

/// This is the general cell for the GooglePlacesCell. Create a subclass or use GooglePlacesCollectionCell or GooglePlacesTableCell instead.
public class GooglePlacesCell: _FieldCell<GooglePlace>, CellType {
    
    /// Defines if the cell should wait for a moment before requesting places from google when the user edits the textField
    public var useTimer = true
    
    /// The interval to wait before requesting places from Google if useTimer = true
    public var timerInterval = 0.3
    
    
    //MARK: Private / internal
    let cellReuseIdentifier = "Eureka.GooglePlaceCellIdentifier"
    //var predictions: [GMSAutocompletePrediction]?
    var predictions: [Place]?
    
    private var autocompleteTimer: Timer?
    
    //MARK: Methods
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
    }
    
    //MARK: UITextFieldDelegate
    public override func textFieldDidBeginEditing(_ textField: UITextField) {
        formViewController()?.beginEditing(of: self)
        formViewController()?.textInputDidBeginEditing(textField, cell: self)
        textField.selectAll(nil)
    }
    
    public override func textFieldDidChange(_ textField: UITextField) {
        super.textFieldDidChange(textField)
        if useTimer {
            if let timer = autocompleteTimer {
                timer.invalidate()
                autocompleteTimer = nil
            }
            autocompleteTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(GooglePlacesCell.timerFired), userInfo: nil, repeats: false)
        } else {
            autocomplete()
        }
    }
    
    public override func textFieldDidEndEditing(_ textField: UITextField) {
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
        textField.text = row.displayValueFor?(row.value)
    }
    
    private func autocomplete() {
        if let text = textField.text , !text.isEmpty {
            (row as? GooglePlacesRowProtocol)?.autoComplete(text: text)
        } else {
            predictions?.removeAll()
            reload()
        }
    }
    
    func reload() {}
    
    /**
     Function called when the Google Places autocomplete timer is fired
     */
    func timerFired(timer: Timer?) {
        autocompleteTimer?.invalidate()
        autocompleteTimer = nil
        autocomplete()
    }
}
