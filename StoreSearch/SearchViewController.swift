//
//  ViewController.swift
//  StoreSearch
//
//  Created by Nehemiah James on 9/18/23.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    private let search = Search()
    var landscapeVC: LandscapeViewController?
    weak var splitViewDetail: DetailViewController?
    
    struct TableView {
      struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
      }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.userInterfaceIdiom != .pad {
          searchBar.becomeFirstResponder()
        }
        
        tableView.contentInset = UIEdgeInsets(top: 91, left: 0, bottom:
        0, right: 0)
        
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(
          nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib,
          forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        
        title = NSLocalizedString("Search", comment: "split view primary button")
        
    }

    // MARK: - Helper Methods
    
    
    
    
    
    func showNetworkError() {
      let alert = UIAlertController(
        title: NSLocalizedString("Whoops...", comment: "Error alert: title"),
        message: NSLocalizedString( "There was an error reading from the iTunes Store. Please try again.",
            comment: "Error alert: message"),
        preferredStyle: .alert)
        let action = UIAlertAction(
            title: "OK", style: .default, handler: nil)
          alert.addAction(action)
          present(alert, animated: true, completion: nil)
        }
    
    func showLandscape(with coordinator:
    UIViewControllerTransitionCoordinator) {
    // 1
      guard landscapeVC == nil else { return }
      // 2
      landscapeVC = storyboard!.instantiateViewController(
        withIdentifier: "LandscapeViewController") as?
    LandscapeViewController
      if let controller = landscapeVC {
          controller.search = search
        // 3
        controller.view.frame = view.bounds
          controller.view.alpha = 0
    // 4
        view.addSubview(controller.view)
        addChild(controller)
        
          coordinator.animate(alongsideTransition: { _ in
              controller.view.alpha = 1
              self.searchBar.resignFirstResponder()
            }, completion: { _ in
              controller.didMove(toParent: self)
                
                if self.presentedViewController != nil {
                  self.dismiss(animated: true, completion: nil)
                }
            })
      } }
    
    func hideLandscape(with coordinator:
    UIViewControllerTransitionCoordinator) {
      if let controller = landscapeVC {
        controller.willMove(toParent: nil)
          coordinator.animate(
                alongsideTransition: { _ in
                  controller.view.alpha = 0
                }, completion: { _ in
                  controller.view.removeFromSuperview()
                  controller.removeFromParent()
                  self.landscapeVC = nil
                    
                    if self.presentedViewController != nil {
                      self.dismiss(animated: true, completion: nil)
                    }
          }) }
          }
    
    override func willTransition(
      to newCollection: UITraitCollection,
      with coordinator: UIViewControllerTransitionCoordinator) {
          super.willTransition(to: newCollection, with: coordinator)
            switch newCollection.verticalSizeClass {
            case .compact: showLandscape(with: coordinator)
            case .regular, .unspecified: hideLandscape(with: coordinator)
            @unknown default:
          break
          }
      }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      if UIDevice.current.userInterfaceIdiom == .phone {
        navigationController?.navigationBar.isHidden = true
      }
    }
    
}

// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      performSearch()
    }
    /*
    func performSearch() {
      if !searchBar.text!.isEmpty {
        searchBar.resignFirstResponder()
        isLoading = true
        dataTask?.cancel()
        tableView.reloadData()
        hasSearched = true
        searchResults = []
          
        let url = iTunesURL(
            searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
          // 2
        let session = URLSession.shared
          // 3
        dataTask = session.dataTask(with: url) {data, response, error in
            if let error = error as NSError?, error.code == -999 {
              return
            } else if let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 {
                if let data = data {
                  self.searchResults = self.parse(data: data)
                  self.searchResults.sort(by: <)
                  DispatchQueue.main.async {
                    self.isLoading = false
                    self.tableView.reloadData()
                  }
                return
                }
            } else {
              print("Failure! \(response!)")
            }
            
            DispatchQueue.main.async {
              self.hasSearched = false
              self.isLoading = false
              self.tableView.reloadData()
              self.showNetworkError()
            }
            
        }
          // 5
            dataTask?.resume()
        }
    }
    */
    
    func performSearch() {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
            search.performSearch(
                for: searchBar.text!,
                category: category) { success in
                    if !success {
                        self.showNetworkError()
                    }
                    self.tableView.reloadData()
                    self.landscapeVC?.searchResultsReceived()
                }
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
    }
}

// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(
      _ tableView: UITableView,
      numberOfRowsInSection section: Int
    ) -> Int {
      switch search.state {
      case .notSearchedYet:
        return 0
      case .loading:
        return 1
      case .noResults:
        return 1
      case .results(let list):
        return list.count
      }
    }
    
    func tableView(
      _ tableView: UITableView,
      cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
      switch search.state {
      case .notSearchedYet:
        fatalError("Should never get here")
      case .loading:
        let cell = tableView.dequeueReusableCell(
          withIdentifier: TableView.CellIdentifiers.loadingCell,
          for: indexPath)
        let spinner = cell.viewWithTag(100) as!
    UIActivityIndicatorView
        spinner.startAnimating()
        return cell
      case .noResults:
        return tableView.dequeueReusableCell(
          withIdentifier:
    TableView.CellIdentifiers.nothingFoundCell,
          for: indexPath)
      case .results(let list):
        let cell = tableView.dequeueReusableCell(
          withIdentifier:
    TableView.CellIdentifiers.searchResultCell,
          for: indexPath) as! SearchResultCell
        let searchResult = list[indexPath.row]
        cell.configure(for: searchResult)
        return cell
    }
        
    }
    
    func tableView(
      _ tableView: UITableView,
      didSelectRowAt indexPath: IndexPath
    ){ searchBar.resignFirstResponder()
      if view.window!.rootViewController!.traitCollection
        .horizontalSizeClass == .compact {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail",
                     sender: indexPath)
      } else {
        if case .results(let list) = search.state {
          splitViewDetail?.searchResult = list[indexPath.row]
        }
          if splitViewController!.displayMode != .oneBesideSecondary {
            hidePrimaryPane()
          }
      }
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender:
    Any?) {
      if segue.identifier == "ShowDetail" {
        if case .results(let list) = search.state {
          let detailViewController = segue.destination as! DetailViewController
          let indexPath = sender as! IndexPath
          let searchResult = list[indexPath.row]
          detailViewController.searchResult = searchResult
          detailViewController.isPopUp = true
        }
          
      }
    }
    
    // MARK: - Private Methods
    private func hidePrimaryPane() {
      UIView.animate(
        withDuration: 0.25,
        animations: {
          self.splitViewController!.preferredDisplayMode
    = .secondaryOnly
        }, completion: { _ in
          self.splitViewController!.preferredDisplayMode
    = .automatic
    } )
    }
    
}
