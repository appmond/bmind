//
//  GameGroup.swift
//  gametheory
//
//  Created by Edmond Osmani on 02/02/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import UIKit

class GameGroup  {
        
    let dbFunctions = DBFunctions()
    let group = DispatchGroup()
    
    var created_date:String?
    var game_types:[Int]?
    var icon:String?
    var iconImage:UIImage?
    var id:Int?
    var modified_date:String?
    var active_games:Int?
    var name:String?
    
    public func retrieveGameGroups(gamegroup : [String:Any])    {
        self.created_date = gamegroup["created_date"] as? String
        self.game_types = gamegroup["game_types"] as? [Int]
        self.id = gamegroup["id"] as? Int
        self.modified_date = gamegroup["modified_date"] as? String
        self.name = gamegroup["name"] as? String
        self.icon = gamegroup["icon"] as? String
        self.active_games = gamegroup["active_games"] as? Int
    }
}
