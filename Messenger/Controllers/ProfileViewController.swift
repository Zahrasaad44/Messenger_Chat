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
        //profileTableView.tableHeaderView = createTableHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileTableView.tableHeaderView = createTableHeader()
    }
    
    func createTableHeader()  -> UIView? {  // To create a header for the profile picture
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {   // To get the email
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "image/"+fileName
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 300))
        headerView.backgroundColor = .link
        let imageView = UIImageView(frame: CGRect(x: (headerView.bounds.width-150) / 2, y: 75, width: 150, height: 150))
        
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = imageView.bounds.width/2
        imageView.layer.masksToBounds = true
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadUrl(for: path, completion: {[weak self] result in
            switch result {
            case .success(let url):
                self?.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
            
        })
        
        return headerView
    }
    
    func downloadImage(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {     // Because the profile image is a UI related
                let image = UIImage(data: data)
                imageView.image = image
            }
        }) .resume()
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
                print("Failed to log out")
            }
        }))
        
        logoutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(logoutAlert, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)  //To navigate amoung the controllers of the storyboard (Main)
          let loginVC = storyboard.instantiateViewController(identifier: "LoginVC")
        let nav = UINavigationController(rootViewController: loginVC)    // Present LoginViewController if there is no user loggrd in (currentUser == nil)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: false)
        
        
    
    }
}
