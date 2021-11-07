//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import JGProgressHUD



class NewConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD()
     
    private let userSearchBar: UISearchBar = {
        let userSearchBar = UISearchBar()
        userSearchBar.placeholder = "Search for Users..."
        return userSearchBar
    }()
    
    private let searchResultsTableView: UITableView = {     // TableView to show the results of the search
      let searchResults = UITableView()
        searchResults.isHidden = true
        searchResults.register(UITableViewCell.self, forCellReuseIdentifier: "searchResultCell")
        return searchResults
    }()
    
    private let noResultsLabel: UILabel = {      // Label to display "No Results" if there are no results of the search
     let noResults = UILabel()
        noResults.isHidden = true
        noResults.textAlignment = .center
        noResults.text = "No Results"
        noResults.textColor = .green
        noResults.font = .systemFont(ofSize: 21, weight: .medium)
        return noResults
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        userSearchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = userSearchBar  // Posisioning the "userSearchBar" in topmost of the view
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelBatBtnClicked))
        // A cancel btn beside the search bar
        userSearchBar.becomeFirstResponder() //To pop up the keyboard once presenting this controller (once clicking the "compose" btn on the "ConversationsViewController"
    }
    @objc private func cancelBatBtnClicked() {
        dismiss(animated: true, completion: nil)
   }
}

    
extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {  // It is called when the user clicks the "search" button on the keyboard
    
    }
}

