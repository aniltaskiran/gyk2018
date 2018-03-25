//
//  UserMessagesModel.swift
//  matchAndChat
//
//  Created by Veyis Egemen ERDEN on 25.03.2018.
//  Copyright © 2018 Kev. All rights reserved.
//

import Foundation

class UserMessagesModel {
    var userId = ""
    var userMessageId = ""
    
    
    init(userId:String, userMessageId:String) {
        self.userId=userId
        self.userMessageId=userMessageId
    }
    
}
