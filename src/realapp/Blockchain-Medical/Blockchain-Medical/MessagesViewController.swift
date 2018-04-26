//
//  SecondViewController.swift
//  Blockchain-Medical
//
//  Created by Ben Francis on 4/3/18.
//  Copyright © 2018 Ben Francis. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firestore
import FirebaseAuth

class MessagesViewController: JSQMessagesViewController {

    let user = Auth.auth().currentUser!.uid
    var receiverId = ""
    private var currentCalendar: Calendar?
    // array to store messages
    var senderMessages = [(JSQMessage, Date)]()
    var receiverMessages = [(JSQMessage, Date)]()
    var messages = [JSQMessage]()
    
    // set colors for messages (blue outgoing, gray incoming)
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())}()
    

    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())}()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        senderId = user
        let timeZoneBias = 0
        currentCalendar = Calendar(identifier: .gregorian)
        currentCalendar?.locale = Locale(identifier: "en_US")
        if let timeZone = TimeZone(secondsFromGMT: -timeZoneBias * 60) {
            currentCalendar?.timeZone = timeZone
        }
        
        senderDisplayName = "1234"
        
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        let db = Firestore.firestore()
        
        db.collection("messages").order(by: "date", descending: true).limit(to: 10).whereField("senderId", isEqualTo: self.senderId).whereField("receiverId", isEqualTo: receiverId)
            .addSnapshotListener {querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }
                self.senderMessages = []
                //for i in 0 ... 10 {
                for document in documents {
                    
                    let data = document.data()
                    let id = data["senderId"]
                    let text = data["message"]
                    if let message = JSQMessage(senderId: id as! String, displayName: self.title, text: text as! String)
                    {
                        self.senderMessages.insert((message, data["date"] as! Date), at: 0)
                        
                    }
                    
                }
                var totalMessages = self.senderMessages + self.receiverMessages
                totalMessages.sort(by: self.compareTimes(first:second:))
                self.messages = totalMessages.map { $0.0 }
                self.finishReceivingMessage()
            }
        
        db.collection("messages").order(by: "date", descending: true).limit(to: 10).whereField("senderId", isEqualTo: self.receiverId).whereField("receiverId", isEqualTo: self.senderId)
            .addSnapshotListener {querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }
                self.receiverMessages = []
                //for i in 0 ... 10 {
                for document in documents {
                    
                    let data = document.data()
                    let id = data["senderId"]
                    let text = data["message"]
                    if let message = JSQMessage(senderId: id as! String, displayName: "Bob", text: text as! String)
                    {
                        self.receiverMessages.insert((message, data["date"] as! Date), at: 0)
                        
                    }
                    
                }
                var totalMessages = self.receiverMessages + self.senderMessages
                totalMessages.sort(by: self.compareTimes(first:second:))
                self.messages = totalMessages.map { $0.0 }
                self.finishReceivingMessage()
        }
    }
    
    private func compareTimes(first: (_: JSQMessage, date: Date), second: (_ : JSQMessage, date: Date)) -> Bool {
        return first.date < second.date
    }
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            self.tabBarController?.tabBar.isHidden = false
            
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        
        let db = Firestore.firestore()
        db.collection("messages").addDocument(data: [
            "senderId": senderId,
            "receiverId": receiverId,
            "message": text,
            "date": date]) { (error:Error?) in
                if let error = error {
                    print("\(error.localizedDescription)")
                } else {
                    print("Document was successfully created and written.")
                }
        }
        finishSendingMessage()
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

