//
//  UserLocationModel.swift
//  matchAndChat
//
//  Created by Veyis Egemen ERDEN on 24.03.2018.
//  Copyright © 2018 Kev. All rights reserved.
//

import Foundation

class UserLocationModel {
    var lat = 0.0
    var long = 0.0
    var name = ""
    var id = ""
    init(){
        
    }
    init(lat:Double,long:Double,name:String,id:String) {
        self.lat=lat
        self.long = long
        self.name=name
        self.id = id 
    }
    init(id:String) {
        
        self.id = id
    }
    
    func toString() -> String {
        return "Users = \(name) Lat = \(self.lat) long = \(self.long)"
    }
}
