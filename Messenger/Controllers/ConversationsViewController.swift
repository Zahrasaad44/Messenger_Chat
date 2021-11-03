//
//  ConversationsViewController.swift
//  Messenger
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
       /*
        do {
            try FirebaseAuth.Auth.auth().signOut()  // "signOut" method throws an error
        } catch {
        }
      */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        self.navigationItem.hidesBackButton = true  // Hidding the back button to prevent going back to the Login page
       // loggedInUser()
         }

    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let viewIs = LoginViewController()
            let nav = UINavigationController(rootViewController: viewIs)    // Present LoginViewController if there is no user loggrd in (currentUser == nil)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    /*
    func loggedInUser() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
        if !isLoggedIn {
            let viewIs = LoginViewController()
            let nav = UINavigationController(rootViewController: viewIs)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
            
           // let logVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            //self.navigationController?.pushViewController(logVC, animated: true)
        }
    }
    */
    
     
}
