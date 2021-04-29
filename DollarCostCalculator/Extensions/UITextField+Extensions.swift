//
//  UITextField+Extensions.swift
//  DollarCostCalculator
//
//  Created by Brendon Bitencourt Braga on 2021-04-29.
//

import UIKit

extension UITextField {
    
    func addDoneButton() {
        let cgPoint = CGPoint(x: 0, y: 0)
        let cgSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        let flexBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        let doneToolBar = UIToolbar(frame: .init(origin: cgPoint, size: cgSize))
        doneToolBar.barStyle = .default
        doneToolBar.items = [flexBarButtonItem, doneBarButtonItem]
        doneToolBar.sizeToFit()
        self.inputAccessoryView = doneToolBar
    }
    
    @objc private func dismissKeyboard() {
        self.resignFirstResponder()
    }
    
}
