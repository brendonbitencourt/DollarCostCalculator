//
//  SearchViewController.swift
//  DollarCostCalculator
//
//  Created by Brendon Bitencourt Braga on 2021-04-23.
//

import UIKit
import Combine
import MBProgressHUD

class SearchTableViewController: UITableViewController, UIAnimatable {
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.delegate = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Enter a company name or symbol"
        controller.searchBar.autocapitalizationType = .allCharacters
        return controller
    }()
    
    private enum Mode {
        case onboarding
        case search
    }
    
    private let apiService = APIService()
    private var subscribers = Set<AnyCancellable>()
    private var searchResults: SearchResults?
    
    @Published private var mode: Mode = .onboarding
    @Published private var searchQuery = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        observeForm()
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = searchController
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
    }
    
    private func observeForm() {
        $searchQuery
            .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
            .sink { [unowned self] (searchQuery) in
                self.performSearch(for: searchQuery)
            }
            .store(in: &subscribers)
        
        $mode
            .sink { [unowned self] (mode) in
                switch mode {
                    case .onboarding:
                        self.tableView.backgroundView = SearchPlaceholderView()
                    case .search:
                        self.tableView.backgroundView = nil
                }
            }
            .store(in: &subscribers)
    }
    
    private func performSearch(for keywords: String) {
        if !keywords.isEmpty {
            self.showLoadingAnimation()
            apiService.fetchSymbolsPublisher(query: keywords)
                .sink { [weak self] (completion) in
                    self?.hideLoadingAnimation()
                    switch completion {
                        case .finished: break
                        case .failure(let error):
                            print(error.localizedDescription)
                    }
                } receiveValue: { (searchResults) in
                    self.searchResults = searchResults
                    self.tableView.reloadData()
                }
                .store(in: &subscribers)
        }
    }
    
    private func handleSelection(for searchResult: SearchResult) {
        self.showLoadingAnimation()
        apiService.fetchTimeSeriesMonthlyAjustedPublisher(query: searchResult.symbol)
            .sink { [weak self] (completion) in
                self?.hideLoadingAnimation()
                switch completion {
                    case .finished: break
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            } receiveValue: { [weak self] (timeSeriesMonthlyAjusted) in
                let asset = Asset(searchResult: searchResult, timeSeriesMonthlyAjusted: timeSeriesMonthlyAjusted)
                self?.performSegue(withIdentifier: "showCalculator", sender: asset)
            }
            .store(in: &subscribers)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SearchViewCell
        if let searchResults = self.searchResults {
            let searchResult = searchResults.items[indexPath.row]
            cell.setup(with: searchResult)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searchResultItem = searchResults?.items[indexPath.row] {
            handleSelection(for: searchResultItem)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCalculator",
           let destination = segue.destination as? CalculatorTableViewController,
           let asset = sender as? Asset {
            destination.asset = asset
        }
    }
}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text, !searchQuery.isEmpty else { return }
        self.searchQuery = searchQuery
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        mode = .search
    }
    
}
