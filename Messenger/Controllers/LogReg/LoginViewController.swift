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

        emailTextField.placeholder = "Email Address..."
        passwordTextField.placeholder = "Password..."
        
        emailTextField.backgroundColor = .white
        passwordTextField.backgroundColor = .white
        
        emailTextField.layer.borderWidth = 1
        passwordTextField.layer.borderWidth = 1
        
        emailTextField.layer.cornerRadius = 10
        passwordTextField.layer.cornerRadius = 10

        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        emailTextField.addConstraint(emailTextField.heightAnchor.constraint(equalToConstant: 50))
        
        loginBtn.layer.cornerRadius = 10
        loginFacebookBtn.layer.cornerRadius = 0
        
        messengerIcon.image = UIImage(named: "Messenger-Logo")
        
        questionLabel.text = "Don't have account yet?"
        goToRegBtn.setTitle("Register", for: .normal)
        
        
    }
    @IBAction func goToRegBtnPressed(_ sender: UIButton) {
        let regVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterViewController;
        self.navigationController?.pushViewController(regVC, animated: true)
    }
    
    
    @IBAction func logInBtmPressed(_ sender: Any) {
        loginUser()
    }
    
    func loginUser() {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { authresult, error in
            guard let result = authresult, error == nil else {
                print("Failed to log in user with email: \(String(describing: self.emailTextField.text))")
                return
            }
            let user = result.user
            print("User: \(user) successfully logged in")
        })
    }
}
