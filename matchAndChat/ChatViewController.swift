//
//  ChatViewController.swift
//  matchAndChat
//
//  Created by Kev on 24.03.2018.
//  Copyright © 2018 Kev. All rights reserved.
//


import UIKit
import Firebase
import JSQMessagesViewController


var username = "as"
var channelID = ""
var groupPhoto:String? = ""

final class ChatViewController: JSQMessagesViewController {
    var chatRoomName:String? = ""
    var showPic: Bool!

    @IBOutlet var button: UIButton!
    var channelRef: DatabaseReference!
    private var messageRef: DatabaseReference!

    private var newMessageRefHandle: DatabaseHandle?
    private var updatedMessageRefHandle: DatabaseHandle?

    private var messages: [JSQMessage] = []
    private var photoMessageMap = [String: JSQPhotoMediaItem]()

    //    private var localTyping = false
    var usr: UserChat? {
        didSet {
            print(usr?.getReceiverID())
            title = userIDToDetail[(usr?.getReceiverID())!]?.name
            chatRoomName = userIDToDetail[(usr?.getReceiverID())!]?.name
            showPic = true
            channelRef = Database.database().reference().child("allChats").child(channelID)
            messageRef = self.channelRef!.child("messages")
        }
    }
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()


        self.senderId = Auth.auth().currentUser?.uid
        observeMessages()
        collectionView!.dataSource = self
        collectionView!.delegate = self

        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero

        //        let image : UIImage = UIImage(named: "profilePhoto")!
        //        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        //        imageView.contentMode = .scaleAspectFit
        //
        //        imageView.image = image
        //        self.navigationItem.titleView = imageView

        // Only execute the code if there's a navigation controller
        if self.navigationController != nil && showPic {


            // Create a navView to add to the navigation bar
            let navView = UIView()

            // Create the label
            let label = UILabel()
            label.text = chatRoomName
            label.textColor = UIColor.black
            label.sizeToFit()
            label.center = navView.center
            label.textAlignment = NSTextAlignment.center

            // Create the image view
            let image = UIImageView()
            image.image = UIImage(named: groupPhoto!)
            image.contentMode = .scaleAspectFill
            // To maintain the image's aspect ratio:
            //        let imageAspect = image.image!.size.width/image.image!.size.height
            // Setting the image frame so that it's immediately before the text:
            image.frame = CGRect(x: label.frame.origin.x - 50, y: 0, width: 40, height: 40)
            image.center.y = label.center.y
            image.contentMode = UIViewContentMode.scaleAspectFill

            let cons = image.layer
            cons.borderWidth = 1
            cons.masksToBounds = false
            cons.borderColor = UIColor.black.cgColor
            cons.cornerRadius = image.frame.height/2
            image.clipsToBounds = true

            // Add both the label and image view to the navView
            navView.addSubview(label)
            navView.addSubview(image)

            // Set the navigation bar's navigation item's titleView to the navView
            self.navigationItem.titleView = navView

            // Set the navView's frame to fit within the titleView
            navView.sizeToFit()
        }
    }

    override func didPressAccessoryButton(_ sender: UIButton!) {
        createAlert(title: "Yakın bir zamanda burası da halka açılacaktır. 🤓", sender: Any.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        observeTyping()
    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }

    // MARK: Collection view data source (and related) methods

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell

        let message = messages[indexPath.item]

        if message.senderId == senderId { // 1
            cell.textView?.textColor = UIColor.white // 2
        } else {
            cell.textView?.textColor = UIColor.black // 3
        }

        return cell
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = messages[indexPath.item]
        switch message.senderId {
        case senderId:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }


    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapCellAt indexPath: IndexPath!, touchLocation: CGPoint) {
        let message = messages[indexPath.item]
        print(message.senderDisplayName)

    }

    func observeMessages(){
        let messageQuery = messageRef.queryLimited(toLast:300)
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in

            if  let messageData = snapshot.value as! Dictionary<String, AnyObject>! {
                if let id = messageData["senderID"] as! String!, id.count > 0 {
                    if let name = messageData["senderName"] as! String!, name.count > 0 {
                        if let message = messageData["text"] as! String!, message.count > 0 {

                            self.addMessage(withId: id, name: name, text: message)
                            self.finishReceivingMessage()
                        }
                    }
                }
            }
        })
    }

    
    // MARK: Firebase related methods

    //    private func observeMessages() {
    //    }

    //        messageRef = channelRef!.child("messages")
    //        let messageQuery = messageRef.queryLimited(toLast:300)
    //
    //        // We can use the observe method to listen for new
    //        // messages being written to the Firebase DB
    //        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
    //            let messageData = snapshot.value as! Dictionary<String,String>
    ////            let  = snapshot.value as! Dictionary
    //
    //                if let id = messageData["senderId"] as! String!, let name = messageData["senderName"] as! String!, let text = messageData["text"] as! String!, text.characters.count > 0 {
    //                self.addMessage(withId: id, name: name, text: text)
    //                self.finishReceivingMessage()
    //                } else if let id = messageData["senderId"] as! String!, let _ = messageData["photoURL"] as! String! {
    //                    if (JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId)) != nil {
    //
    //                }
    //            } else {
    //                print("Error! Could not decode message data")
    //            }
    //        })
    //
    //    }

    // We can also use the observer method to listen for
    // changes to existing messages.
    // We use this to be notified when a photo has been stored
    // to the Firebase Storage, so we can update the message data
    //        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
    //            let key = snapshot.key
    //            let messageData = snapshot.value as! Dictionary<String, String>
    //
    //            if let photoURL = messageData["photoURL"] as String! {
    //                // The photo has been updated.
    //                if let mediaItem = self.photoMessageMap[key] {
    //                }
    //            }
    //        })
    //    }
    //
    //    private func observeTyping() {
    //        let typingIndicatorRef = channelRef!.child("typingIndicator")
    //        userIsTypingRef = typingIndicatorRef.child(senderId)
    //        userIsTypingRef.onDisconnectRemoveValue()
    //        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqual(toValue: true)
    //
    //        usersTypingQuery.observe(.value) { (data: DataSnapshot) in
    //
    //            // You're the only typing, don't show the indicator
    //            if data.childrenCount == 1 && self.isTyping {
    //                return
    //            }
    //
    //            // Are there others typing?
    //            self.showTypingIndicator = data.childrenCount > 0
    //            self.scrollToBottom(animated: true)
    //        }
    //    }

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // 1
        let itemRef = messageRef.childByAutoId()
        // 2
        let messageItem = [
            "senderID": Auth.auth().currentUser?.uid,
            "senderName": username,
            "text": text!,
            ]
        // 3
        itemRef.setValue(messageItem)
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        // 5
        finishSendingMessage()
        //        isTyping = false
    }

    // MARK: UI and User Interaction

    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()

        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }

    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }

    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    // MARK: UITextViewDelegate methods

    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        //        isTyping = textView.text != ""
    }

    func createAlert(title:String, sender: Any) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))

        self.present(alert, animated: true)
    }
}

