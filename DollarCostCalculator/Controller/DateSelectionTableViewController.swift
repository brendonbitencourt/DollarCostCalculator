//
//  DateSelectionTableViewController.swift
//  DollarCostCalculator
//
//  Created by Brendon Bitencourt Braga on 2021-04-29.
//

import UIKit

class DateSelectionTableViewController: UITableViewController {
    
    var timeSeriesMonthlyAjusted: TimeSeriesMonthlyAjusted?
    var didSelectDate: ((Int) -> Void)?
    var selectedIndex: Int?
    private var monthInfos = [MonthInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMonthInfos()
    }
    
    private func setupMonthInfos() {
        if let setupMonthInfos = timeSeriesMonthlyAjusted?.getMonthInfos() {
            self.monthInfos = setupMonthInfos
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthInfos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DateSelectionTableViewCell
        let index = indexPath.row
        let monthInfo = monthInfos[index]
        let isSelected = index == selectedIndex
        cell.setup(with: monthInfo, index: indexPath.row, isSelected: isSelected)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelectDate?(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
