//
//  GameLogic.swift
//  gametheory
//
//  Created by Edmond Osmani on 20/01/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import Foundation

class GameLogic {
    
    let ACTION_URL = URLVariables.SERVER_STRING_URL+"action"
    let GAME_INSTANCE_URL = URLVariables.SERVER_STRING_URL+"game-instance/"
    let INVALIDATE = URLVariables.SERVER_STRING_URL+"invalidate"
    let TIMEOUT = URLVariables.SERVER_STRING_URL+"timeout"
    
    var dbFunctions = DBFunctions()
    var timer = Timer()
    var checkIfRoundIsDone = false
    var isGameFinished = false
    var isSequential:Bool?
}
