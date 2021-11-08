//
//  RegisterViewController.swift
//  Messenger
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

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
        
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let email = regEmailTextField.text, let password = regPasswordTextField.text, !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            let unfilledTextFieldsAlert = UIAlertController(title: "Something is Missing ", message: "All fields are required", preferredStyle: .alert)
            unfilledTextFieldsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(unfilledTextFieldsAlert, animated: true, completion: nil)
            return
        }
        spinner.show(in: view)
    }
    @IBAction func profileBtnPressed(_ sender: UIButton) {
        displayPhotoActionSheet()
    }
    
    @IBOutlet weak var goToLoginBtn: UIButton!
    
    let photoPickerSelected = UIImagePickerController()
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Create an Account"
        
        
        profileImageView.layer.masksToBounds = false
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2   
    }

    @IBAction func goToLogInBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    /*
    DatabaseManager.shared.userExists(with: regEmailTextField.text!, completion: { exists in
        guard !exists else {
            //show alert (error) user already exist, alert
            return
        }
    })
    */
    func createAccount() {
            Auth.auth().createUser(withEmail: regEmailTextField.text!, password: regPasswordTextField.text!, completion: {authResult, error in
               
            guard let result = authResult, error == nil else {
                
                print("Error creating user, \(String(describing: error?.localizedDescription))")  // password should be >= 6 characters
                return
            }
                // Instance of ChatAppUser struct
                let chatUser = ChatAppUser(firstName: self.firstNameTextField.text!, lastName: self.self.lastNameTextField.text!, emailAddress: self.regEmailTextField.text!)
                
                DatabaseManager.shared.insertUser(with: chatUser) { isInserted in
                    if isInserted == true {
                        guard let profileImage = self.profileImageView.image, let data = profileImage.pngData() else {
                         debugPrint("insertion failed")
                           return
                        }
                        let filename = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: {result in
                            switch result {   // the "result" has <String, Error>, .success(String) and .faliure(Error)
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Storage magager error: \(error)")
                            }
                        })
                        debugPrint("User inserted successfully")
                    }
                    DispatchQueue.main.async {
                        self.spinner.dismiss()
                    }
                }
                
            let user = result.user
            print("User created successfully. User: \(user)")
                let regAlert = UIAlertController(title: "Account is Successfully Created", message: "User's email: \(self.regEmailTextField.text!)", preferredStyle: .alert)
                regAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(regAlert, animated: true, completion: nil)
            })
           
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
