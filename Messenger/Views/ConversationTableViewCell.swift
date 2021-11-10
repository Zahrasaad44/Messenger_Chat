//
//  ConversationTableViewCell.swift
//  Messenger
//
//  Created by administrator on 09/11/2021.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
       let userImageView = UIImageView()
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 50
        userImageView.layer.masksToBounds = true
        return userImageView
    }()
    
    private let userNameLabel: UILabel = {
       let userNameLabel = UILabel()
        userNameLabel.font = .systemFont(ofSize: 21, weight: .semibold)
        return userNameLabel
    }()
    
    private let userMessageLabel: UILabel = {
       let userMessageLabel = UILabel()
        userMessageLabel.font = .systemFont(ofSize: 19, weight: .regular)
        userMessageLabel.numberOfLines = 0 // To allow line wrapping
        return userMessageLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        /*
        userImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        userNameLabel.frame = CGRect(x: userImageView.right +  10,
                                     y: 10, width: contentView.bounds.width -  20 - userImageView.width,
                                     height: (contentView.height-20)/2)
        userMessageLabel.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        */
    }
    
    public func configure(with model : String) {
        
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
