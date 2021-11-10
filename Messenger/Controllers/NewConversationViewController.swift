//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    public var completion: (([String: String]) -> (Void))?   // "([String: String])" is a dictionary inside a closure 
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var users = [[String: String]]()
    private var results = [[String: String]]()
    private var hasFetched = false
    
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
        noResults.textColor = .gray
        noResults.font = .systemFont(ofSize: 21, weight: .medium)
        return noResults
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(searchResultsTableView)
        view.addSubview(noResultsLabel)
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        view.backgroundColor = .white
        userSearchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = userSearchBar  // Posisioning the "userSearchBar" in topmost of the view
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelBatBtnClicked))
        // A cancel btn beside the search bar
        userSearchBar.becomeFirstResponder() //To pop up the keyboard once presenting this controller (once clicking the "compose" btn on the "ConversationsViewController"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchResultsTableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.bounds.width/4, y: (view.bounds.height-200)/2, width: view.bounds.width/2, height: 100)
    }
    
    @objc private func cancelBatBtnClicked() {
        dismiss(animated: true, completion: nil)
   }
}

extension NewConversationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {  // To select a user and start a conversation
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = results[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in   // dismissing the "NewConversationVC" after calling the "completion"
            self?.completion?(selectedUser)
            
        })
        
    }
    
    
}

    
extension NewConversationViewController: UISearchBarDelegate {  // To conform to the search bar protocol and enable its features
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {  // It is called when the user clicks the "search" button on the keyboard
        guard let text = userSearchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        userSearchBar.resignFirstResponder() // To remove the keyboard once the "search" clicked 
        results.removeAll()
        spinner.show(in: view)    // It will be displayed when the "search" btn on the keyboard clicked
        self.searchUsers(query: text)
    }
    func searchUsers(query: String) {
        if hasFetched {  // Check if "users" array has firebase results
            filterUsers(with: query)
            
        } else {  // if the array doesn't have the results, fetch them then filter them
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            })
        }
    }
    
    func filterUsers(with term: String) {   // To filter the array of users
        guard hasFetched else {
            return
        }
        let results: [[String: String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())    // "lowercased()" so that searching and querying are matching. Both are lowercased
        })
        self.results = results
        self.spinner.dismiss()
        updateUI()
        
    }
    
    func updateUI() {
        if results.isEmpty {
            self.searchResultsTableView.isHidden = true
            self.noResultsLabel.isHidden = false
        } else {
            self.searchResultsTableView.isHidden = false
            self.noResultsLabel.isHidden = true
            self.searchResultsTableView.reloadData()
        }
    }
}

