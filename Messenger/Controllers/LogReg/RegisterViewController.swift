//
//  RegisterViewController.swift
//  Messenger
//
//  Created by administrator on 27/10/2021.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var regEmailTextField: UITextField!
    @IBOutlet weak var regPasswordTextField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var registerImage: UIImageView!
    
    @IBOutlet weak var regQuestionLabel: UILabel!
    
    @IBOutlet weak var goToLoginBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        firstNameTextField.placeholder = "First Name..."
        lastNameTextField.placeholder = "Last Name..."
        regEmailTextField.placeholder = "Email Address..."
        regPasswordTextField.placeholder = "Password..."
        
        firstNameTextField.backgroundColor = .white
        lastNameTextField.backgroundColor = .white
        regEmailTextField.backgroundColor = .white
        regPasswordTextField.backgroundColor = .white
        
        firstNameTextField.layer.borderWidth = 1
        lastNameTextField.layer.borderWidth = 1
        regEmailTextField.layer.borderWidth = 1
        regPasswordTextField.layer.borderWidth = 1
        
        firstNameTextField.layer.cornerRadius = 10
        lastNameTextField.layer.cornerRadius = 10
        regEmailTextField.layer.cornerRadius = 10
        regPasswordTextField.layer.cornerRadius = 10
        
        firstNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        lastNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        regEmailTextField.layer.borderColor = UIColor.lightGray.cgColor
        regPasswordTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        firstNameTextField.addConstraint(firstNameTextField.heightAnchor.constraint(equalToConstant: 50))
        
        registerBtn.layer.cornerRadius = 10
        goToLoginBtn.setTitle("Log In", for: .normal)
        regQuestionLabel.text = "Already have an account?"
        
    }

    @IBAction func goToLogInBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
