//
//  ThreePlayerGameType.swift
//  gametheory
//
//  Created by Edmond Osmani on 29/03/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import Foundation
class ThreePlayerGameType:GameType {
    
    override init() {
        super.init()
        self.firstBigView = PlayerOneView()
        self.secondBigView = PlayerOneView()
        self.firstSmallView = PlayerOneView()
        self.secondSmallView = PlayerTwoView()
        self.thirdSmallView = PlayerOneView()
        self.fourthSmallView = PlayerTwoView()
    }
    
    var firstBigView:PlayerOneView?
    var secondBigView:PlayerOneView?
    var firstSmallView:PlayerOneView?
    var secondSmallView:PlayerTwoView?
    var thirdSmallView:PlayerOneView?
    var fourthSmallView:PlayerTwoView?
    var tmpfirstBigView:[Int] = []
    var tmpsecondBigView:[Int] = []
    var tmpfirstSmallView:[Int] = []
    var tmpsecondSmallView:[Int] = []
    var tmpthirdSmallView:[Int] = []
    var tmpfourthSmallView:[Int] = []
    
    func convertStringtoPayoffArray(playerIndex:Int, playerTwoName:String, playerThreeName:String) {
        for stringColl in 0...(self.payoff_matrix!.count-1) {
            matrixViewPayoffs(tmpindex: stringColl, playerIndex: playerIndex, playerTwoName: playerTwoName, playerThreeName:playerThreeName)
        }
        self.firstBigView?.payOffMatrix?.payoffMatrix = tmpfirstBigView
        self.secondBigView?.payOffMatrix?.payoffMatrix = tmpsecondBigView
        self.firstSmallView?.payOffMatrix?.payoffMatrix = tmpfirstSmallView
        self.secondSmallView?.payOffMatrix?.payoffMatrix = tmpsecondSmallView
        self.thirdSmallView?.payOffMatrix?.payoffMatrix = tmpthirdSmallView
        self.fourthSmallView?.payOffMatrix?.payoffMatrix = tmpfourthSmallView
    }
    func matrixViewPayoffs(tmpindex:Int, playerIndex:Int, playerTwoName:String, playerThreeName:String) {
        let tmpStringArray = [playerTwoName, playerThreeName]
        let sortedArray = tmpStringArray.sorted()
        if playerIndex == 1 {
            switch tmpindex {
            case 0,1,2,3:
                if sortedArray.first! == playerThreeName {
                    if tmpindex == 2 {
                        tmpfirstBigView.insert(self.payoff_matrix![tmpindex][0], at: 1)
                        tmpsecondSmallView.insert(self.payoff_matrix![tmpindex][1], at: 1)
                        tmpfirstSmallView.insert(self.payoff_matrix![tmpindex][2], at: 1)
                    } else  {
                        tmpfirstBigView.append(self.payoff_matrix![tmpindex][0])
                        tmpsecondSmallView.append(self.payoff_matrix![tmpindex][1])
                        tmpfirstSmallView.append(self.payoff_matrix![tmpindex][2])
                    }
                } else  {
                    tmpfirstBigView.append(self.payoff_matrix![tmpindex][0])
                    tmpfirstSmallView.append(self.payoff_matrix![tmpindex][1])
                    tmpsecondSmallView.append(self.payoff_matrix![tmpindex][2])
                }
            case 4,5,6,7:
                if sortedArray.first! == playerThreeName {
                    if tmpindex == 6 {
                        tmpsecondBigView.insert(self.payoff_matrix![tmpindex][0], at: 1)
                        tmpfourthSmallView.insert(self.payoff_matrix![tmpindex][1], at: 1)
                        tmpthirdSmallView.insert(self.payoff_matrix![tmpindex][2], at: 1)
                    } else  {
                        tmpsecondBigView.append(self.payoff_matrix![tmpindex][0])
                        tmpfourthSmallView.append(self.payoff_matrix![tmpindex][1])
                        tmpthirdSmallView.append(self.payoff_matrix![tmpindex][2])
                    }
                } else  {
                    tmpsecondBigView.append(self.payoff_matrix![tmpindex][0])
                    tmpthirdSmallView.append(self.payoff_matrix![tmpindex][1])
                    tmpfourthSmallView.append(self.payoff_matrix![tmpindex][2])
                }
            default:
                print("SHOULD NOT BE HERE")
            }
        } else if playerIndex == 2  {
            switch tmpindex {
            case 0,1,4,5:
                if sortedArray.first! == playerThreeName    {
                    if tmpindex == 4 {
                        tmpsecondSmallView.insert(self.payoff_matrix![tmpindex][0], at: 1)
                        tmpfirstBigView.insert(self.payoff_matrix![tmpindex][1], at: 1)
                        tmpfirstSmallView.insert(self.payoff_matrix![tmpindex][2], at: 1)
                    } else{
                        tmpsecondSmallView.append(self.payoff_matrix![tmpindex][0])
                        tmpfirstBigView.append(self.payoff_matrix![tmpindex][1])
                        tmpfirstSmallView.append(self.payoff_matrix![tmpindex][2])
                    }
                } else  {
                    tmpfirstSmallView.append(self.payoff_matrix![tmpindex][0])
                    tmpfirstBigView.append(self.payoff_matrix![tmpindex][1])
                    tmpsecondSmallView.append(self.payoff_matrix![tmpindex][2])
                }
            case 2,3,6,7:
                if sortedArray.first! == playerThreeName    {
                    if tmpindex == 6 {
                        tmpfourthSmallView.insert(self.payoff_matrix![tmpindex][0], at: 1)
                        tmpsecondBigView.insert(self.payoff_matrix![tmpindex][1], at: 1)
                        tmpthirdSmallView.insert(self.payoff_matrix![tmpindex][2], at: 1)
                    } else{
                        tmpfourthSmallView.append(self.payoff_matrix![tmpindex][0])
                        tmpsecondBigView.append(self.payoff_matrix![tmpindex][1])
                        tmpthirdSmallView.append(self.payoff_matrix![tmpindex][2])
                    }
                } else  {
                    tmpthirdSmallView.append(self.payoff_matrix![tmpindex][0])
                    tmpsecondBigView.append(self.payoff_matrix![tmpindex][1])
                    tmpfourthSmallView.append(self.payoff_matrix![tmpindex][2])
                }
            default:
                print("SHOULD NOT BE HERE")
            }
        } else  {
            switch tmpindex {
            case 0,2,4,6:
                if sortedArray.first! == playerThreeName    {
                    if tmpindex == 4 {
                        tmpsecondSmallView.insert(self.payoff_matrix![tmpindex][0], at: 1)
                        tmpfirstSmallView.insert(self.payoff_matrix![tmpindex][1], at: 1)
                        tmpfirstBigView.insert(self.payoff_matrix![tmpindex][2], at: 1)
                    } else  {
                        tmpsecondSmallView.append(self.payoff_matrix![tmpindex][0])
                        tmpfirstSmallView.append(self.payoff_matrix![tmpindex][1])
                        tmpfirstBigView.append(self.payoff_matrix![tmpindex][2])
                    }
                } else  {
                    tmpfirstSmallView.append(self.payoff_matrix![tmpindex][0])
                    tmpsecondSmallView.append(self.payoff_matrix![tmpindex][1])
                    tmpfirstBigView.append(self.payoff_matrix![tmpindex][2])
                }
            case 1,3,5,7:
                if sortedArray.first! == playerThreeName    {
                    if tmpindex == 5 {
                        tmpfourthSmallView.insert(self.payoff_matrix![tmpindex][0], at: 1)
                        tmpthirdSmallView.insert(self.payoff_matrix![tmpindex][1], at: 1)
                        tmpsecondBigView.insert(self.payoff_matrix![tmpindex][2], at: 1)
                        
                    } else  {
                        tmpfourthSmallView.append(self.payoff_matrix![tmpindex][0])
                        tmpthirdSmallView.append(self.payoff_matrix![tmpindex][1])
                        tmpsecondBigView.append(self.payoff_matrix![tmpindex][2])
                    }
                } else  {
                    tmpthirdSmallView.append(self.payoff_matrix![tmpindex][0])
                    tmpfourthSmallView.append(self.payoff_matrix![tmpindex][1])
                    tmpsecondBigView.append(self.payoff_matrix![tmpindex][2])
                }
            default:
                print("SHOULD NOT BE HERE")
            }
        }
    }
}
