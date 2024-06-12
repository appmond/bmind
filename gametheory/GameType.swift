//
//  GameType.swift
//  gametheory
//
//  Created by Edmond Osmani on 07/02/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

class GameType  {
    
    var name:String?
    var created_date:String?
    var modified_date:String?
    
    var id:Int?
    var buzzer_timer:Int?
    var max_periods:Int?
    var min_periods:Int?
    var number_of_players:Int?
    
    var randomized_sequence:Bool?
    var show_running_payoff:Bool?
    var show_periods:Bool?
    var buzzer:Bool?
    var sequential:Bool?
    var explicit_approval:Bool?
    var final_payoff_only:Bool?
    var timer:Int?
    
    var payoff_matrix:[[Int]]?
    
    public func retrieveGameType(gametype : [String:Any])    {
        self.name = gametype["name"] as? String
        self.created_date = gametype["created_date"] as? String
        self.modified_date = gametype["modified_date"] as? String
        self.id = gametype["id"] as? Int
        self.buzzer_timer = gametype["buzzer_timer"] as? Int
        self.max_periods = gametype["max_periods"] as? Int
        self.min_periods = gametype["min_periods"] as? Int
        self.number_of_players = gametype["number_of_players"] as? Int
        self.randomized_sequence = gametype["randomized_sequence"] as? Bool
        self.show_running_payoff = gametype["show_running_payoff"] as? Bool
        self.show_periods = gametype["show_periods"] as? Bool
        self.buzzer = gametype["buzzer"] as? Bool
        self.sequential = gametype["sequential"] as? Bool
        self.explicit_approval = gametype["explicit_approval"] as? Bool
        self.final_payoff_only = gametype["final_payoff_only"] as? Bool
        self.timer = gametype["timer"] as? Int
        self.payoff_matrix = gametype["payoff_matrix"] as? [[Int]]
    }
}
