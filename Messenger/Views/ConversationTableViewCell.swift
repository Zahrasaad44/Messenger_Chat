//
//  ConversationTableViewCell.swift
//  Messenger
//
//  Created by administrator on 09/11/2021.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
   // static let identifier = "ConversationTableViewCell"
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userMessageLabel: UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func configure(with model : Conversation) {
        self.userMessageLabel.text = model.latestMessage.text
        self.userNameLabel.text = model.name
       
        let imagePath = "image/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadUrl(for: imagePath, completion: {[weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {   // because the profile image is UI related 
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed to get image url: \(error)")
            }
        })
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
