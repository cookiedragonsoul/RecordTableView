//
//  TableViewCell.swift
//  RecordTableView
//
//  Created by おじぇ on 2022/10/22.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var rowDeleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
