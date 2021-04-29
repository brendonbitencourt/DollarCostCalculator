//
//  DateSelectionTableViewCell.swift
//  DollarCostCalculator
//
//  Created by Brendon Bitencourt Braga on 2021-04-29.
//

import UIKit

class DateSelectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthsAgoLabel: UILabel!
    
    func setup(with monthInfo: MonthInfo, index: Int, isSelected: Bool) {
        self.accessoryType = isSelected ? .checkmark : .none
        dateLabel.text = monthInfo.date.MMYYFormat
        if index == 1 {
            monthsAgoLabel.text = "Month ago"
        } else if index > 1 {
            monthsAgoLabel.text = "\(index) months ago"
        } else {
            monthsAgoLabel.text = "Just invested"
        }
    }
    
}
