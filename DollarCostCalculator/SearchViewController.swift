//
//  SearchViewController.swift
//  DollarCostCalculator
//
//  Created by Brendon Bitencourt Braga on 2021-04-23.
//

import UIKit

class SearchViewController: UITableViewController {
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.delegate = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Enter a company name or symbol"
        controller.searchBar.autocapitalizationType = .sentences
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        navigationItem.searchController = searchController
    }
    
    
}

extension SearchViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
    }
    
}
