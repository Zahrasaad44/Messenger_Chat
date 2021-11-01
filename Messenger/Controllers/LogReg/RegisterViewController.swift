//
//  RegisterViewController.swift
//  Messenger
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var regEmailTextField: UITextField!
    @IBOutlet weak var regPasswordTextField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var profileImageBtn: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var regQuestionLabel: UILabel!
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        createAccount()
    }
    @IBAction func profileBtnPressed(_ sender: UIButton) {
        displayPhotoActionSheet()
    }
    
    @IBOutlet weak var goToLoginBtn: UIButton!
    let photoPickerSelected = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Create an Account"
        firstNameTextField.placeholder = "First Name..."
        lastNameTextField.placeholder = "Last Name..."
        regEmailTextField.placeholder = "Email Address..."
        regPasswordTextField.placeholder = "Password (must has 6 characters or more)..."
        
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
        profileImageView.layer.masksToBounds = false
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2 
    }

    @IBAction func goToLogInBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func createAccount() {
        Auth.auth().createUser(withEmail: regEmailTextField.text!, password: regPasswordTextField.text!, completion: {authResult, error in
           
        guard let result = authResult, error == nil else {
            print("Error creating user, \(String(describing: error?.localizedDescription))")  // password should be >= 6 characters 
            return
        }
        let user = result.user
        print("User created successfully. User: \(user)")
    })
        let regAlert = UIAlertController(title: "Account is Successfully Created", message: "User's email: \(regEmailTextField.text!)", preferredStyle: .alert)
        regAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            
            self.navigationController?.popViewController(animated: true)
        }))
        present(regAlert, animated: true, completion: nil)
    }
}


extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // get results of user taking picture or selecting from camera roll
    func displayPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a profile picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.openCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.displayPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    func openCamera() {
        let cameraSelected = UIImagePickerController()
        cameraSelected.sourceType = .camera
        cameraSelected.delegate = self
        cameraSelected.allowsEditing = true
        present(cameraSelected, animated: true)
    }
    func displayPhotoPicker() {
        let photoPickerSelected = UIImagePickerController()
        photoPickerSelected.sourceType = .photoLibrary
        photoPickerSelected.delegate = self
        photoPickerSelected.allowsEditing = true
        present(photoPickerSelected, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            profileImageView.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
        
        /*picker.dismiss(animated: true, completion: nil)
          print(info)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {   // I can use this instead of the above "if let"
            return
        }
        self.profileImageView.image = selectedImage */
    }
   
}
