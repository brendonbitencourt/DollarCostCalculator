//
//  CalculatorTableViewController.swift
//  DollarCostCalculator
//
//  Created by Brendon Bitencourt Braga on 2021-04-29.
//

import UIKit

class CalculatorTableViewController: UITableViewController {
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var investimentAmountCurrencyLabel: UILabel!
    @IBOutlet weak var initialInvestimentAmountTextField: UITextField!
    @IBOutlet weak var monthlyDollarCostAveragingTextField: UITextField!
    @IBOutlet weak var initialDateOfInvestimentTextField: UITextField!
    @IBOutlet var currencyLabels: [UILabel]!
    
    var asset: Asset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTextFields()
    }
    
    private func setupView() {
        symbolLabel.text = asset?.searchResult.symbol
        nameLabel.text = asset?.searchResult.name
        investimentAmountCurrencyLabel.text = asset?.searchResult.currency
        currencyLabels.forEach { (label) in
            label.text = asset?.searchResult.currency.addBrackets()
        }
    }
    
    private func setupTextFields() {
        initialInvestimentAmountTextField.addDoneButton()
        monthlyDollarCostAveragingTextField.addDoneButton()
        initialDateOfInvestimentTextField.delegate = self
    }
}

extension CalculatorTableViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
            case initialDateOfInvestimentTextField:
                performSegue(withIdentifier: "showDateSelection", sender: asset?.timeSeriesMonthlyAjusted)
                return false
            default:
                return true
        }
    }
    
}
