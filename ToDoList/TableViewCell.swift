//
//  TableViewCell.swift
//  ToDoList
//
//  Created by Jayalakshmi 
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var tittle: UILabel!
    @IBOutlet weak var status: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
