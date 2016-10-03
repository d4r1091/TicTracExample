//
//  UserListTableViewCell.swift
//  TicTracExample
//
//  Created by Dario Carlomagno on 07/08/16.
//  Copyright © 2016 Dario Carlomagno. All rights reserved.
//

import Foundation
import UIKit

protocol UserListTableViewCellDelegate: class {
    func didClickedUpdateNavigationBar(_ newTitle: String?, cell: UITableViewCell)
}

class UserListTableViewCell: UITableViewCell{
    
    // MARK: Properties
    
    weak var delegate:UserListTableViewCellDelegate?
    
    // MARK: Outlets
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var infosLabel: UILabel!
    @IBOutlet var labelCollection: [UILabel]!
    @IBAction func cellButtonClicked(_ sender: AnyObject) {
        guard delegate != nil else { return }
        delegate?.didClickedUpdateNavigationBar(nameLabel.text, cell: self)
        changeLabelsColor(UIColor.green)
    }
    
    // MARK: Fill Outlets
    
    func configureCellViews(_ name: String?,
                            email: String?,
                            infos:String?) {
        nameLabel.text = name
        emailLabel.text = email
        infosLabel.text = infos
        changeLabelsColor(UIColor.red)
        heightConstraint.constant = 65
    }
    
    // MARK: Update View
    
    func changeLabelsColor(_ color :UIColor) {
        for i in 0..<labelCollection.count {
            let aLabel = labelCollection[i]
            aLabel.textColor = color
        }
    }
}
