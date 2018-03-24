//
//  CustomClass.swift
//  matchAndChat
//
//  Created by Kev on 24.03.2018.
//  Copyright © 2018 Kev. All rights reserved.
//

import Foundation
import Firebase


internal class UserChat {
    internal let isMyChat: Bool
    internal let id: String
    internal let receiverID: String
    internal let senderID: String

    init(key:String, values: Any) {
        let _values = UserChat.prepareValues(key: key, values: values)
        self.id = _values.id
        self.receiverID = _values.receiverID
        self.senderID = _values.senderID
        self.isMyChat = _values.isMyChat
        print("UserChat")
        
        print(_values)
    }
    func getReceiverID()->String{
        let currentUserID = Auth.auth().currentUser?.uid
        
        if currentUserID == self.receiverID {
            return senderID
        } else {
            return receiverID
        }
    }
    
    static func prepareValues(key: String, values: Any) -> (id:String, receiverID:String, senderID:String, isMyChat: Bool){
        var _values = values as! [String:Any]
        
        let receiverID = _values["receiverID"] as! String
        let senderID = _values["senderID"] as! String

        let currentUserID = Auth.auth().currentUser?.uid

        if currentUserID == receiverID || currentUserID == senderID {
            return ("\(key)", "-\(receiverID)", "-\(senderID)", true)
        }
        return ("","","", false)
    }
}

internal class UserDetail {
    internal let id: String
    internal let lat: String
    internal let long: String
    internal let name: String
    
    init(key:String, values: [String:Any]) {
        let userValue = UserDetail.prepareValues(key: key, values: values)
        self.id = key
        self.lat = userValue.lat
        self.long = userValue.long
        self.name = userValue.name
        print("userDetail")
        print(userValue)
}
    init(id: String) {
        self.id = id
        self.name = id
        self.lat = ""
        self.long = ""
    }
    
    static func prepareValues(key: String, values: [String:Any]) -> (name:String, lat:String, long:String){
        var _name = ""
        var _lat = ""
        var _long = ""
        if let _values = values[key] as? [String:Any] {
            if let name = _values["name"] as? String {
                _name = name
                if let lat = _values["lat"] as? Double {
                    _lat = String(describing: lat)
                    if let long = _values["long"] as? Double {
                        _long = String(describing: long)
                    }
                }
            }
        }
        return ("\(_name)", "-\(_lat)", "-\(_long)")
    }
}

