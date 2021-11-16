//
//  ConversationsViewController.swift
//  Messenger
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
class ConversationsViewController: UIViewController {
    
    private var conversations = [Conversation]()

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
        startListeningForConversations()  // To start listening when the view did load 
        
    }
    
    // Adding a listener to check the array in the firebase and update the table view with the new messages
    private func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: {[weak self] result in
            
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {  // if it is empty, no need to update (get the conversations) the table view
                    return
                }
                self?.conversations = conversations
                
                DispatchQueue.main.async {   // To reload data of "chatsTableView" in the main thread
                    self?.chatsTableView.reloadData()
                }
                
            case .failure(let error):
                print("failed to get conversations \(error)")
            }
        })
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
        viewIs.completion = { [weak self] result in
            self?.createNewConversation(result: result)
        }
      let nav = UINavigationController(rootViewController: viewIs)
          present(nav, animated: true)   // If I used "push", the seach bar would be in "ConversationsViewController". I think because I used navigation controller to position the search bar
    }
    
    private func createNewConversation(result: [String: String]) {
        guard let name = result["name"], let email = result["email"] else {
            return
        }
        let vc = ChatViewController(with: email, id: nil) 
        vc.isNewConversation = true 
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
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
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ConversationTableViewCell
        
        cell.configure(with: model)
        
        cell.textLabel?.text = "Hello World!"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {  // when the user clicks on a cell(chat) of the conversationsVC's TableView it should go to the ChatVC
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = conversations[indexPath.row]
        
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

