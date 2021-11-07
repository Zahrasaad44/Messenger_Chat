//
//  ConversationsViewController.swift
//  Messenger
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationsViewController: UIViewController {

    @IBOutlet weak var chatsTableView: UITableView!
    
    private let spinner =  JGProgressHUD(style: .dark)
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        chatsTableView.isHidden = false
        view.addSubview(noConversationsLabel)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeBtnPressed))
        fetchConversations()
        chatsTableView.dataSource = self
        chatsTableView.delegate = self
       /*
        do {
            try FirebaseAuth.Auth.auth().signOut()  // "signOut" method throws an error
        } catch {
        }
      */
    }
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        chatsTableView.frame = view.bounds  // To make the frame of the table fill the entir view
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        self.navigationItem.hidesBackButton = true  // Hidding the back button to prevent going back to the Login page
       // loggedInUser()
         }
    
    @objc private func composeBtnPressed() {      // using "@objc" because this function is called in the "#selector"
      let viewIs = NewConversationViewController()
      let nav = UINavigationController(rootViewController: viewIs)
          present(nav, animated: true)   // If I used "push", the seach bar would be in "ConversationsViewController". I think because I used navigation controller to                                    position the search bar
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
              let loginVC = storyboard.instantiateViewController(identifier: "LoginVC")
           // let viewIs = LoginViewController()
            let nav = UINavigationController(rootViewController: loginVC)    // Present LoginViewController if there is no user loggrd in (currentUser == nil)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    private func fetchConversations() {
        
    }
     
}

extension ConversationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        cell.textLabel?.text = "Hello World!"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {  // when the user clicks on a cell(chat) of the conversationsVC's TableView it should go                                                                                  to the ChatVC
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatViewController()
        vc.title = "a person's name"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

