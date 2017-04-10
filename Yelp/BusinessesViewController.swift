//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MBProgressHUD

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FiltersViewControllerDelegate {
    
    var businesses: [Business]!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noSearchResultsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = false
        
        noSearchResultsLabel.frame.size.height = 0
        MBProgressHUD.showAdded(to: self.view, animated: true)

        Business.searchWithTerm(term: "", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.tableView.reloadData()
            MBProgressHUD.hide(for: self.view, animated: true)
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        
        return cell
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        if let searchText = searchBar.text {
            Business.searchWithTerm(term: searchText, completion: { (businesses: [Business]?, error: Error?) -> Void in
                self.businesses = businesses
                self.noSearchResultsLabel.frame.size.height = 0
                if (businesses == nil || businesses?.count == 0) {
                    self.noSearchResultsLabel.frame.size.height = 22
                }
                self.tableView.reloadData()
                
            })
        }
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didChangeFilter filters: SelectedFilters) {
        var sortMode: YelpSortMode?
        if let sortBy = filters.sortBy {
            sortMode = YelpSortMode(rawValue: Int(sortBy)!)
        }
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        Business.searchWithTerm(term: "Restaurants", sort: sortMode, categories: filters.categories, deals: filters.deals, distance: filters.distance) { (businesses, error) in
            self.businesses = businesses
            self.noSearchResultsLabel.frame.size.height = 0
            if (self.businesses == nil || self.businesses?.count == 0) {
                self.noSearchResultsLabel.frame.size.height = 22
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.delegate = self
    }
}
