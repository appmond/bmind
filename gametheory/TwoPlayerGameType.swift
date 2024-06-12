//
//  TwoPlayerGameType.swift
//  gametheory
//
//  Created by Edmond Osmani on 29/03/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import Foundation

class TwoPlayerGameType: GameType {
    override init() {
        super.init()
        self.playerOne = PlayerOneView()
        self.playerTwo = PlayerTwoView()
    }
    
    var playerOne:PlayerOneView?
    var playerTwo:PlayerTwoView?
    
    public func convertStringtoPayoffArray()    {
        var tmpPlayerOnePayoff:[Int] = []
        var tmpPlayerTwoPayoff:[Int] = []
        for stringColl in self.payoff_matrix!   {
            let firstValue = Int(stringColl[0])
            let secondValue = Int(stringColl[1])
            tmpPlayerOnePayoff.append(firstValue)
            tmpPlayerTwoPayoff.append(secondValue)
        }
        self.playerOne?.payOffMatrix?.payoffMatrix = tmpPlayerOnePayoff
        self.playerTwo?.payOffMatrix?.payoffMatrix = tmpPlayerTwoPayoff
    }
}
