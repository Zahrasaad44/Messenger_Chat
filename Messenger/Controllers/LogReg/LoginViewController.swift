//
//  LoginViewController.swift
//  Messenger
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginFormStack: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var loginFacebookBtn: UIButton!
    @IBOutlet weak var goToRegBtn: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var messengerIcon: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Log In"
        
    }
    
    @IBAction func goToRegBtnPressed(_ sender: UIButton) {
        let regVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterViewController
        self.navigationController?.pushViewController(regVC, animated: true)
        
    }
    
    @IBAction func logInBtmPressed(_ sender: Any) {
        loginUser()
    }
    
    
    /*
    func loggedInUser() {
        //if Auth.auth().currentUser != nil {
            
        //}
        let isLoggedin = UserDefaults.standard.object(forKey: "loggedin")
        if isLoggedin != nil {
            let viewIs = ConversationsViewController()
            let nav = UINavigationController(rootViewController: viewIs)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    */
    
    
    
    
    func loginUser() {
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { [weak self] authresult, error in
            guard let strongSelf = self else {
                return
            }
            guard let result = authresult, error == nil else {
                
                let logInAlert = UIAlertController(title: "Unable to Log In", message: "Email or password is incorrect", preferredStyle: .alert)
                logInAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    
                    self?.navigationController?.popViewController(animated: true)
                }))
                
                self?.present(logInAlert, animated: true, completion: nil)
                
                print("Failed to log in user with email: \(String(describing: self?.emailTextField.text))")
                return
            }
            let user = result.user
            let conVC = self?.storyboard?.instantiateViewController(withIdentifier: "conVC") as! ConversationsViewController
            self?.navigationController?.pushViewController(conVC, animated: true)
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            print("User: \(user) successfully logged in")
            
            
        })
    }
}
