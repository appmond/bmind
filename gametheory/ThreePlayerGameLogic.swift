//
//  ThreePlayerGameLogic.swift
//  gametheory
//
//  Created by Edmond Osmani on 20/01/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import Foundation
import UIKit

class ThreePlayerGameLogic:GameLogic    {
    
    var firstBigView:BigPlayerView?
    var secondBigView:BigPlayerView?
    var firstSmallView:SmallPlayerOneView?
    var secondSmallView:SmallPlayerTwoView?
    var thirdSmallView:SmallPlayerOneView?
    var fourthSmallView:SmallPlayerTwoView?
    
    var gameInstance:ThreePlayerGameInstance?
    var currentPlayerIndex:Int?
    var explicitTimer = Timer()
    var lastPlays:(Int,Int,Int)?
    
    ///Send an action with explicit approval
    func sendExplicitApprovAction(buttonIndex:Int) {
        let gameInstanceId = self.gameInstance!.id!
        let myName = UIDevice.current.identifierForVendor!.uuidString
        let jsonDict:[String:Any] = ["id":gameInstanceId, "name":myName, "action":buttonIndex, "approve":true]
        dbFunctions.dbPostJSONRequest(postJSON: jsonDict, urlPath: ACTION_URL, completionHandler: {
            dictionaryObj in
            self.gameInstance?.retrieveGameInstance(gameInstance: dictionaryObj)
            let currentPlays = ((self.gameInstance?.first_player_actions?.last)!, (self.gameInstance?.second_player_actions?.last)!, (self.gameInstance?.third_player_actions?.last)!)
            self.highlightNewFields(tmpCurrent: currentPlays)
            self.unhighlightClickedButton()
            self.explicitTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.checkExplicitApprovStatus), userInfo: nil, repeats: true)
        })
    }
    
    func highlightNewFields(tmpCurrent:(Int,Int,Int))   {
        if self.lastPlays! != tmpCurrent {
            self.unHighlightRowOrColumn()
            self.highlightSelectedFields(tmpFirstPlayer: self.gameInstance!.first_player_actions!.last!, tmpSecondPlayer: self.gameInstance!.second_player_actions!.last!, tmpThirdPlayer: self.gameInstance!.third_player_actions!.last!)
        } else  {
            self.lastPlays = tmpCurrent
        }
    }
    
    ///Send a buzzer action
    func sendBuzzerAction(buttonIndex:Int) {
        let tmpgroup = DispatchGroup()
        let gameInstanceId = self.gameInstance!.id!
        let myName = UIDevice.current.identifierForVendor!.uuidString
        let jsonDict:[String:Any] = ["id":gameInstanceId, "name":myName, "action":buttonIndex]
        tmpgroup.enter()
        dbFunctions.dbPostJSONRequest(postJSON: jsonDict, urlPath: ACTION_URL, completionHandler: {
            dictionaryObj in
            self.gameInstance?.retrieveGameInstance(gameInstance: dictionaryObj)
            tmpgroup.leave()
        })
        tmpgroup.notify(queue: DispatchQueue.main, execute: {
            self.unHighlightRowOrColumn()
            self.highlightSelectedFields(tmpFirstPlayer: self.gameInstance!.first_player_actions!.last!, tmpSecondPlayer: self.gameInstance!.second_player_actions!.last!, tmpThirdPlayer: self.gameInstance!.third_player_actions!.last!)
            self.unhighlightClickedButton()
            self.checkIfRoundIsDone = true
        })
    }
    
    ///Send an normal action request
    func sendAction(buttonIndex: Int) {
        self.checkIfRoundIsDone = false
        let gameInstanceId = self.gameInstance!.id!
        let myName = UIDevice.current.identifierForVendor!.uuidString
        let jsonDict:[String:Any] = ["id":gameInstanceId, "name":myName, "action":buttonIndex]
        dbFunctions.dbPostJSONRequest(postJSON: jsonDict, urlPath: ACTION_URL, completionHandler: {
            dictionaryObj in
            self.gameInstance?.retrieveGameInstance(gameInstance: dictionaryObj)
            if (self.gameInstance?.game_type?.explicit_approval)!   {
                self.unhighlightClickedButton()
                let currentPlays = ((self.gameInstance?.first_player_actions?.last)!, (self.gameInstance?.second_player_actions?.last)!, (self.gameInstance?.third_player_actions?.last)!)
                self.highlightNewFields(tmpCurrent: currentPlays)
                self.explicitTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.checkExplicitApprovStatus), userInfo: nil, repeats: true)
            } else  {
                self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.checkIfOtherPlayerPlayed), userInfo: nil, repeats: true)
            }
        })
    }
    
    @objc func checkIfOtherPlayerPlayed() {
        let checkOtherPlayerGroup = DispatchGroup()
        checkOtherPlayerGroup.enter()
        
        dbFunctions.dbGetDictRequest(urlPath: GAME_INSTANCE_URL+"\((self.gameInstance?.id)!)", completionHandler: { dictionaryObj in
            self.gameInstance?.retrieveGameInstance(gameInstance: dictionaryObj)
            if (self.gameInstance!.first_player_actions!.count == self.gameInstance!.second_player_actions!.count && self.gameInstance!.first_player_actions!.count == self.gameInstance!.third_player_actions!.count) {
                self.highlightSelectedFields(tmpFirstPlayer: self.gameInstance!.first_player_actions!.last!, tmpSecondPlayer: self.gameInstance!.second_player_actions!.last!, tmpThirdPlayer: self.gameInstance!.third_player_actions!.last!)
                self.timer.invalidate()
                checkOtherPlayerGroup.leave()
            }
        })
        checkOtherPlayerGroup.notify(queue: DispatchQueue.main, execute: {
            let afterOneSecond = DispatchTime.now() + 1 // change 1 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: afterOneSecond) {
                self.checkResults()
            }
        })
    }
    
    @objc func checkExplicitApprovStatus()  {
        dbFunctions.dbGetDictRequest(urlPath: GAME_INSTANCE_URL+"\((self.gameInstance?.id)!)", completionHandler: { dictionaryObj in
            self.gameInstance?.retrieveGameInstance(gameInstance: dictionaryObj)
            let currentPlays = ((self.gameInstance?.first_player_actions?.last)!, (self.gameInstance?.second_player_actions?.last)!, (self.gameInstance?.third_player_actions?.last)!)
            self.highlightNewFields(tmpCurrent: currentPlays)
            self.checkResults()
        })
    }
    
    ///Check current game status
    func checkResults() {
        checkIfTheGameIsOver()
        if !(self.gameInstance?.game_type?.explicit_approval)! {
            unHighlightRowOrColumn()
            unhighlightClickedButton()
            checkIfRoundIsDone = true
        }
    }
    
    ///Unhighlights clicked button row/column
    func unhighlightClickedButton() {
        let tmpCells1 = firstBigView?.buttonVector?.collectionView.visibleCells as! [ButtonCell]
        let tmpCells2 = secondBigView?.buttonVector?.collectionView.visibleCells as! [ButtonCell]
        
        tmpCells1[0].buttonView.backgroundColor = UIColor.clear
        tmpCells2[0].buttonView.backgroundColor = UIColor.clear
        tmpCells1[0].isUserInteractionEnabled = true
        tmpCells2[0].isUserInteractionEnabled = true
    }
    
    ///Unhighlights the payoff matrix
    func unHighlightRowOrColumn()    {
        for cell in firstBigView?.payOffMatrix?.collectionView.visibleCells as! [MatrixCell] {
            cell.backgroundColor = UIColor.clear
        }
        for cell in secondBigView?.payOffMatrix?.collectionView.visibleCells as! [MatrixCell] {
            cell.backgroundColor = UIColor.clear
        }
        for cell in firstSmallView?.payOffMatrix?.collectionView.visibleCells as! [MatrixCell] {
            cell.backgroundColor = UIColor.clear
        }
        for cell in secondSmallView?.payOffMatrix?.collectionView.visibleCells as! [MatrixCell] {
            cell.backgroundColor = UIColor.clear
        }
        for cell in thirdSmallView?.payOffMatrix?.collectionView.visibleCells as! [MatrixCell] {
            cell.backgroundColor = UIColor.clear
        }
        for cell in fourthSmallView?.payOffMatrix?.collectionView.visibleCells as! [MatrixCell] {
            cell.backgroundColor = UIColor.clear
        }
    }
    
    ///Highlights the selected fields of the payoff matrix
    func highlightSelectedFields(tmpFirstPlayer:Int, tmpSecondPlayer:Int, tmpThirdPlayer:Int) {
        var field = -1
        let firstPlayerName = self.gameInstance!.first_player_name!
        let secondPlayerName = self.gameInstance!.second_player_name!
        let thirdPlayerName = self.gameInstance!.third_player_name!
        if currentPlayerIndex == 1 {
            let tmpStringArray = [secondPlayerName, thirdPlayerName]
            let sortedArray = tmpStringArray.sorted()
            if sortedArray.first == secondPlayerName {
                field = ((tmpSecondPlayer - 1) * 2)+tmpThirdPlayer - 1
            } else  {
                field = ((tmpThirdPlayer - 1) * 2)+tmpSecondPlayer - 1
            }
            switchHighlightedFieldsPlayers(playedField: tmpFirstPlayer, fieldToBeHighlighted: field)
        } else if currentPlayerIndex == 2   {
            let tmpStringArray = [firstPlayerName, thirdPlayerName]
            let sortedArray = tmpStringArray.sorted()
            if sortedArray.first == firstPlayerName {
                field = ((tmpFirstPlayer - 1) * 2)+tmpThirdPlayer - 1
            } else  {
                field = ((tmpThirdPlayer - 1) * 2)+tmpFirstPlayer - 1
            }
            switchHighlightedFieldsPlayers(playedField: tmpSecondPlayer, fieldToBeHighlighted: field)
        } else	{
            let tmpStringArray = [firstPlayerName, secondPlayerName]
            let sortedArray = tmpStringArray.sorted()
            if sortedArray.first == firstPlayerName {
                field = ((tmpFirstPlayer - 1) * 2)+tmpSecondPlayer - 1
            } else  {
                field = ((tmpSecondPlayer - 1) * 2)+tmpFirstPlayer - 1
            }
            switchHighlightedFieldsPlayers(playedField: tmpThirdPlayer, fieldToBeHighlighted: field)
        }
    }
    
    func switchHighlightedFieldsPlayers(playedField:Int, fieldToBeHighlighted:Int) {
        if playedField == 1    {
            firstSmallView?.payOffMatrix?.collectionView.cellForItem(at: IndexPath(item: fieldToBeHighlighted, section: 0))?.backgroundColor = UIColor.lightGray
            secondSmallView?.payOffMatrix?.collectionView.cellForItem(at: IndexPath(item: fieldToBeHighlighted, section: 0))?.backgroundColor = UIColor.lightGray
            firstBigView?.payOffMatrix?.collectionView.cellForItem(at: IndexPath(item: fieldToBeHighlighted, section: 0))?.backgroundColor = UIColor.lightGray
        } else  {
            thirdSmallView?.payOffMatrix?.collectionView.cellForItem(at: IndexPath(item: fieldToBeHighlighted, section: 0))?.backgroundColor = UIColor.lightGray
            fourthSmallView?.payOffMatrix?.collectionView.cellForItem(at: IndexPath(item: fieldToBeHighlighted, section: 0))?.backgroundColor = UIColor.lightGray
            secondBigView?.payOffMatrix?.collectionView.cellForItem(at: IndexPath(item: fieldToBeHighlighted, section: 0))?.backgroundColor = UIColor.lightGray
        }
    }
    
    ///Send timeout request
    func timeout()  {
        let jsonDict:[String:Any] = ["id":self.gameInstance!.id!]
        dbFunctions.dbPostJSONRequest(postJSON: jsonDict, urlPath: TIMEOUT, completionHandler: {
            dictionaryObj in
            self.gameInstance?.retrieveGameInstance(gameInstance: dictionaryObj)
            self.checkIfTheGameIsOver()
        })
    }
    
    ///Send invalidate request
    func invalidateGame() {
        let gameInstanceId = self.gameInstance!.id!
        let jsonDict:[String:Any] = ["id":gameInstanceId]
        dbFunctions.dbPostJSONRequest(postJSON: jsonDict, urlPath: INVALIDATE, completionHandler: {
        dictionaryObj in
            self.gameInstance?.retrieveGameInstance(gameInstance: dictionaryObj)
            self.checkIfTheGameIsOver()
        })
    }
    
    ///Checks for instance updates
    func checkGameInstanceUpdate()  {
        dbFunctions.dbGetDictRequest(urlPath: GAME_INSTANCE_URL+"\((self.gameInstance?.id)!)", completionHandler: { dictionaryObj in
            self.gameInstance?.retrieveGameInstance(gameInstance: dictionaryObj)
            self.checkIfTheGameIsOver()
        })
    }
    
    ///Checks if the game is over (-1 or 3)
    func checkIfTheGameIsOver() {
        if self.gameInstance?.state! == 3 || self.gameInstance?.state! == -1 {
            isGameFinished = true
            explicitTimer.invalidate()
            timer.invalidate()
        }
    }
    
    override init() {
        super.init()
    }
}
