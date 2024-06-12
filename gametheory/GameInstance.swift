//
//  GameInstance.swift
//  gametheory
//
//  Created by Edmond Osmani on 15/02/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

class GameInstance {
    
    var id:Int?
    var state:Int?
    var round:Int?
    var result:[Int]?
    var step:Int?
    var turn:String?
    var created_date:String?
    var modified_date:String?
    var first_player_name:String?
    var second_player_name:String?
    var first_player_actions:[Int]?
    var second_player_actions:[Int]?
    var first_player_approved_configuration:[Bool]?
    var second_player_approved_configuration:[Bool]?
    var buzzer_list:[Bool]?
    var number_of_periods:Int?
    var game_sequence:[Int]?
    var active:Bool?
    var invalid:Bool?
    var dirty:Bool?
    var game_type:GameType?
    
    public func retrieveGameInstance(gameInstance : [String:Any])    {
        self.id = gameInstance["id"] as? Int
        self.state = gameInstance["state"] as? Int
        self.round = gameInstance["round"] as? Int
        self.result = gameInstance["result"] as? [Int]
        self.step = gameInstance["step"] as? Int
        self.turn = gameInstance["turn"] as? String
        self.created_date = gameInstance["created_date"] as? String
        self.modified_date = gameInstance["modified_date"] as? String
        self.first_player_name = gameInstance["first_player_name"] as? String
        self.second_player_name = gameInstance["second_player_name"] as? String
        self.first_player_actions = gameInstance["first_player_actions"] as? [Int]
        self.second_player_actions = gameInstance["second_player_actions"] as? [Int]
        self.first_player_approved_configuration = gameInstance["first_player_approved_configuration"] as? [Bool]
        self.second_player_approved_configuration = gameInstance["second_player_approved_configuration"] as? [Bool]
        self.buzzer_list = gameInstance["buzzer_list"] as? [Bool]
        self.number_of_periods = gameInstance["number_of_periods"] as? Int
        self.game_sequence = gameInstance["game_sequence"] as? [Int]
        self.active = gameInstance["active"] as? Bool
        self.invalid = gameInstance["invalid"] as? Bool
        self.dirty = gameInstance["dirty"] as? Bool
        let tmpGameType = gameInstance["game_type"] as? [String:Any]
        self.game_type?.retrieveGameType(gametype: tmpGameType!)
    }
}
