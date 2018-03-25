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
    init(lat:Double,long:Double,name:String) {
        self.lat=lat
        self.long = long
        self.name=name
    }
    
    func toString() -> String {
        return "Users = \(name) Lat = \(self.lat) long = \(self.long)"
    }
}
