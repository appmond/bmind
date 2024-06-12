//
//  ThreePlayerGameInstance.swift
//  gametheory
//
//  Created by Edmond Osmani on 29/03/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import Foundation

class ThreePlayerGameInstance:GameInstance {
    
    var third_player_name:String?
    var third_player_actions:[Int]?
    var third_player_approved_configuration:[Bool]?
    var timer:Int?
    
    override init() {
        super.init()
    }
    
    override func retrieveGameInstance(gameInstance: [String : Any]) {
        super.retrieveGameInstance(gameInstance: gameInstance)
        self.third_player_name = gameInstance["third_player_name"] as? String
        self.third_player_actions = gameInstance["third_player_actions"] as? [Int]
        self.third_player_approved_configuration = gameInstance["third_player_approved_configuration"] as? [Bool]
    }
}
