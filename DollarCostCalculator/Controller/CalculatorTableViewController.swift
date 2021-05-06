//
//  CalculatorTableViewController.swift
//  DollarCostCalculator
//
//  Created by Brendon Bitencourt Braga on 2021-04-29.
//

import UIKit
import Combine

class CalculatorTableViewController: UITableViewController {
    
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var investimentAmountLabel: UILabel!
    @IBOutlet weak var gainLabel: UILabel!
    @IBOutlet weak var yieldLabel: UILabel!
    @IBOutlet weak var annualReturnLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var investimentAmountCurrencyLabel: UILabel!
    @IBOutlet weak var initialInvestimentAmountTextField: UITextField!
    @IBOutlet weak var monthlyDollarCostAveragingTextField: UITextField!
    @IBOutlet weak var initialDateOfInvestimentTextField: UITextField!
    @IBOutlet weak var dateSlider: UISlider!
    @IBOutlet var currencyLabels: [UILabel]!
    
    var asset: Asset?
    private var subscribers = Set<AnyCancellable>()
    private var dcaService = DCAService()
    
    @Published private var initialDateOfInvestimentIndex: Int?
    @Published private var initialInvestimentAmount: Int?
    @Published private var monthlyDollarCostAveraging: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTextFields()
        setupDateSlider()
        observeForm()
        resetViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initialInvestimentAmountTextField.becomeFirstResponder()
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
    
    private func setupDateSlider() {
        if let count = asset?.timeSeriesMonthlyAjusted.getMonthInfos().count {
            let dateSliderCount = count - 1
            dateSlider.maximumValue = dateSliderCount.floatValue
        }
    }
    
    private func observeForm() {
        $initialDateOfInvestimentIndex
            .sink { [weak self] (index) in
                guard let index = index else { return }
                self?.dateSlider.value = index.floatValue
                if let dateString = self?.asset?.timeSeriesMonthlyAjusted.getMonthInfos()[index].date.MMYYFormat {
                    self?.initialDateOfInvestimentTextField.text = dateString
                }
            }
            .store(in: &subscribers)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: initialInvestimentAmountTextField)
            .compactMap({ ($0.object as? UITextField)?.text })
            .sink { [weak self] (text) in
                self?.initialInvestimentAmount = Int(text) ?? 0
            }
            .store(in: &subscribers)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: monthlyDollarCostAveragingTextField)
            .compactMap({ ($0.object as? UITextField)?.text })
            .sink { [weak self] (text) in
                self?.monthlyDollarCostAveraging = Int(text) ?? 0
            }
            .store(in: &subscribers)
        
        Publishers.CombineLatest3($initialDateOfInvestimentIndex, $initialInvestimentAmount, $monthlyDollarCostAveraging)
            .sink { [weak self] (initialDateOfInvestimentIndex, initialInvestimentAmount, monthlyDollarCostAveraging) in
                
                guard let asset = self?.asset,
                      let initialDateOfInvestimentIndex = initialDateOfInvestimentIndex,
                      let initialInvestimentAmount = initialInvestimentAmount,
                      let monthlyDollarCostAveraging = monthlyDollarCostAveraging
                else { return }
                
                let result = self?.dcaService.calculate(
                    asset: asset,
                    initialInvestimentAmount: initialInvestimentAmount.doubleValue,
                    monthlyDollarCostAveraging: monthlyDollarCostAveraging.doubleValue,
                    initialDateOfInvestimentIndex: initialDateOfInvestimentIndex)
                
                let gainSymbol = (result?.isProfitable == true) ? "+" : ""
                
                self?.currentValueLabel.textColor = (result?.isProfitable == true) ? .systemGreen : .systemRed
                self?.currentValueLabel.text = result?.currentValue.currencyFormat
                self?.investimentAmountLabel.text = result?.investimentAmount.currencyFormat
                self?.gainLabel.text = result?.gain.toCurrencyFormat(hasDollarSymbol: false, hasDecimalPlaces: false).prefix(withText: gainSymbol)
                self?.yieldLabel.text = result?.yield.percentageFormat.prefix(withText: gainSymbol).addBrackets()
                self?.yieldLabel.textColor = (result?.isProfitable == true) ? .systemGreen : .systemRed
                self?.annualReturnLabel.text = result?.annualReturn.percentageFormat
                self?.annualReturnLabel.textColor = (result?.isProfitable == true) ? .systemGreen : .systemRed
            }
            .store(in: &subscribers)
    }
    
    private func handleSelectedDate(at index: Int) {
        guard navigationController?.visibleViewController is DateSelectionTableViewController else { return }
        navigationController?.popViewController(animated: true)
        if let monthInfos = asset?.timeSeriesMonthlyAjusted.getMonthInfos() {
            let monthInfo = monthInfos[index]
            initialDateOfInvestimentIndex = index
            initialDateOfInvestimentTextField.text = monthInfo.date.MMYYFormat
        }
    }
    
    private func resetViews() {
        self.currentValueLabel.text = "0.00"
        self.investimentAmountLabel.text = "0.00"
        self.gainLabel.text = "-"
        self.yieldLabel.text = "-"
        self.annualReturnLabel.text = "-"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDateSelection",
           let destination = segue.destination as? DateSelectionTableViewController,
           let timeSeriesMonthlyAjusted = sender as? TimeSeriesMonthlyAjusted {
            destination.timeSeriesMonthlyAjusted = timeSeriesMonthlyAjusted
            destination.selectedIndex = initialDateOfInvestimentIndex
            destination.didSelectDate = { [weak self] index in
                self?.handleSelectedDate(at: index)
            }
        }
    }
    
    @IBAction func dateSliderDidChange(_ sender: UISlider) {
        initialDateOfInvestimentIndex = Int(sender.value)
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
