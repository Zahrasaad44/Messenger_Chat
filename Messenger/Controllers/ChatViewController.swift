//
//  ChatViewController.swift
//  Messenger
//
//  Created by administrator on 05/11/2021.
//

import UIKit
import MessageKit

struct Message: MessageType {
    
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind   // text, photo, video, location, emoji
    
}

struct Sender: SenderType {
    
    var senderId: String
    var displayName: String
    var photoURL: String
    
}

class ChatViewController: MessagesViewController{

    private var messages = [Message]()
    private var theSender = Sender(senderId: "1", displayName: "zahra", photoURL: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messages.append(Message(sender: theSender, messageId: "1", sentDate: Date(), kind: .text("hello first message")))
        messages.append(Message(sender: theSender, messageId: "2", sentDate: Date(), kind: .text("hello second message ,hello second message, hello second message, hello second message")))
        view.backgroundColor = .gray
    }

}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return theSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
