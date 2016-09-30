//
//  GooglePlacesTableCell.swift
//  GooglePlacesRow
//
//  Created by Mathias Claassen on 4/14/16.
//
//

import Foundation
import UIKit

public class GooglePlacesTableCell<TableViewCell: UITableViewCell where TableViewCell: EurekaGooglePlacesTableViewCell>: GooglePlacesCell, UITableViewDelegate, UITableViewDataSource {
    
    /// callback that can be used to cuustomize the appearance of the UICollectionViewCell in the inputAccessoryView
    public var customizeTableViewCell: ((TableViewCell) -> Void)?
    
    /// UICollectionView that acts as inputAccessoryView.
    public var tableView: UITableView?
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setup() {
        super.setup()
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView?.autoresizingMask = .flexibleHeight
        tableView?.isHidden = true
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.backgroundColor = UIColor.white
        tableView?.register(TableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    public func showTableView() {
        
        if let controller = formViewController() {
            if tableView?.superview == nil {
                controller.view.addSubview(tableView!)
            }
            let frame = controller.tableView?.convert(self.frame, to: controller.view) ?? self.frame
            tableView?.frame = CGRect(x:0, y:frame.origin.y + frame.height, width:contentView.frame.width, height:44*5)
            tableView?.isHidden = false
        }
    }
    
    public func hideTableView() {
        tableView?.isHidden = true
    }
    
    override func reload() {
        tableView?.reloadData()
    }
    
    public override func textFieldDidChange(_ textField: UITextField) {
        super.textFieldDidChange(textField)
        if textField.text?.isEmpty == false {
            showTableView()
        }
    }
    
    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        hideTableView()
    }
    
    //MARK: UITableViewDelegate and Datasource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions?.count ?? 0
    }
    

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! TableViewCell
        if let prediction = predictions?[indexPath.row] {
            cell.setTitle(prediction: prediction)
        }
        customizeTableViewCell?(cell)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: NSIndexPath) {
        if let prediction = predictions?[indexPath.row] {
            row.value = GooglePlace.Prediction(prediction: prediction)
            cellResignFirstResponder()
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
}
