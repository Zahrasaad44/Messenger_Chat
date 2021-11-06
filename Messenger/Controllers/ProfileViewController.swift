//
//  ProfileViewController.swift
//  Messenger
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileTableView: UITableView!
    
    let data = ["log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileTableView.delegate = self
        profileTableView.dataSource = self
    
    }
    
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = profileTableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let logoutAlert = UIAlertController(title: "Log Out", message: "Are you sure you want to log Out?", preferredStyle: .alert)
        logoutAlert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in  // "destructive" to make the "title" red
            // to avoid "retain cycle"
            guard let strongSelf = self else {
                return
            }
            do {    // the action to be handled once the "log Out" selected
                try FirebaseAuth.Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(identifier: "LoginVC")                //let viewIs = LoginViewController()
                let nav = UINavigationController(rootViewController: loginVC)    // To go to the LoginViewController after clicking on the cell
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
                
            } catch {
                print("Failed to log out ")
            }
        }))
        
        logoutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(logoutAlert, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)  //To navigate amoung the controllers of the storyboard (Main)
          let loginVC = storyboard.instantiateViewController(identifier: "LoginVC")
       // let viewIs = LoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)    // Present LoginViewController if there is no user loggrd in (currentUser == nil)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: false)
        
        
        
        /*
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
         */
    }
}
