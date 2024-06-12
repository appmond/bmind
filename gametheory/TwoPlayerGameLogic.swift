//
//  TwoPlayerGameLogic.swift
//  gametheory
//
//  Created by Edmond Osmani on 20/01/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import Foundation
import UIKit

class TwoPlayerGameLogic:GameLogic  {
    
    override init() {
        super.init()
    }
    
    var playerOne:PlayerOneView?
    var playerTwo:PlayerTwoView?
    var currentPlayer:PlayerView?
    var gameInstance:GameInstance?
    
    ///Send action to server
    func sendAction(buttonIndex:Int) {
        self.checkIfRoundIsDone = false
        let tmpgroup = DispatchGroup()
        let gameInstanceId = self.gameInstance!.id!
        let myName = UIDevice.current.identifierForVendor!.uuidString
        let jsonDict:[String:Any] = ["id":gameInstanceId, "name":myName, "action":buttonIndex]
        tmpgroup.enter()
        dbFunctions.dbPostJSONRequest(postJSON: jsonDict, urlPath: ACTION_URL, completionHandler: { dictionaryObj in
            self.gameInstance?.retrieveGameInstance(gameInstance: dictionaryObj)
            tmpgroup.leave()
        })
        tmpgroup.notify(queue: DispatchQueue.main, execute: {
            let afterOneSecond = DispatchTime.now() + 1 // change 1 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: afterOneSecond) {
                
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.checkIfOtherPlayerPlayed), userInfo: nil, repeats: true)
            }
        })
    }
    
    ///Check if other player played
    @objc func checkIfOtherPlayerPlayed()	{
        let checkOtherPlayerGroup = DispatchGroup()
        checkOtherPlayerGroup.enter()
        
        dbFunctions.dbGetDictRequest(urlPath: GAME_INSTANCE_URL+"\((self.gameInstance?.id)!)", completionHandler: { dictionaryObj in
            self.gameInstance?.retrieveGameInstance(gameInstance: dictionaryObj)
            if self.gameInstance!.first_player_actions!.count == self.gameInstance!.second_player_actions!.count {
                self.timer.invalidate()
                self.highlightRowOrColumn(firstPlayer: ((self.gameInstance?.first_player_actions?.last)! - 1), secondPlayer: ((self.gameInstance?.second_player_actions?.last)! - 1))
                checkOtherPlayerGroup.leave()
            }
        })
        checkOtherPlayerGroup.notify(queue: DispatchQueue.main, execute: {
            let afterOneSecond = DispatchTime.now() + 1 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: afterOneSecond) {
                self.checkResults()
            }
        })
    }
    
    func invalidateGame() {
        let gameInstanceId = self.gameInstance!.id!
        let jsonDict:[String:Any] = ["id":gameInstanceId]
        dbFunctions.dbPostJSONRequest(postJSON: jsonDict, urlPath: INVALIDATE, completionHandler: {
            dictionaryObj in
        })
    }
    
    func checkGameInstanceUpdate()  {
        dbFunctions.dbGetDictRequest(urlPath: GAME_INSTANCE_URL+"\((self.gameInstance?.id)!)", completionHandler: { dictionaryObj in
            self.gameInstance?.retrieveGameInstance(gameInstance: dictionaryObj)
            self.checkIfTheGameIsOver()
        })
    }
    
    func checkIfTheGameIsOver() {
        if self.gameInstance?.state! == 3 || self.gameInstance?.state! == -1 {
            isGameFinished = true
        }
    }
    
    func checkResults() {
        checkIfTheGameIsOver()
        showButtonsAgain()
        unHighlighRowOrColumn(firstPlayer: ((self.gameInstance?.first_player_actions?.last)! - 1), secondPlayer: ((self.gameInstance?.second_player_actions?.last)! - 1))
        unhighlightClickedButton()
        self.checkIfRoundIsDone = true
    }
    
    ///Un-Highlights the complete UI
    func unHighlighRowOrColumn(firstPlayer:Int, secondPlayer:Int)    {
        let numberOfItemsInPayoffMatrix = playerOne?.payOffMatrix?.payoffMatrix?.count
        let numberOfColumns = Int(sqrt(Double(numberOfItemsInPayoffMatrix!)))
        let fromWhenToStartHighlighting = (firstPlayer * numberOfColumns)+secondPlayer
        playerOne?.payOffMatrix?.collectionView.cellForItem(at: IndexPath(item: fromWhenToStartHighlighting, section: 0))?.backgroundColor = UIColor.clear
        
        playerTwo?.payOffMatrix?.collectionView.cellForItem(at: IndexPath(item: fromWhenToStartHighlighting, section: 0))?.backgroundColor = UIColor.clear
    }
    
    ///Highlights the selected cells from both players
    func highlightRowOrColumn(firstPlayer: Int, secondPlayer: Int) {
        
        let numberOfItemsInPayoffMatrix = playerOne?.payOffMatrix?.payoffMatrix?.count
        let numberOfColumns = Int(sqrt(Double(numberOfItemsInPayoffMatrix!)))
        let fromWhenToStartHighlighting = (firstPlayer * numberOfColumns)+secondPlayer
        playerOne?.payOffMatrix?.collectionView.cellForItem(at: IndexPath(item: fromWhenToStartHighlighting, section: 0))?.backgroundColor = UIColor.lightGray
        
        playerTwo?.payOffMatrix?.collectionView.cellForItem(at: IndexPath(item: fromWhenToStartHighlighting, section: 0))?.backgroundColor = UIColor.lightGray
    }
    
    ///Shows buttons again once other player has played
    func showButtonsAgain()   {
        if currentPlayer is PlayerOneView {
            for cell in playerOne?.buttonVector?.collectionView.visibleCells as! [ButtonCell] {
                cell.buttonView.isUserInteractionEnabled = true
            }
        } else{
            for cell in playerTwo?.buttonVector?.collectionView.visibleCells as! [ButtonCell] {
                cell.buttonView.isUserInteractionEnabled = true
            }
        }
    }
    
    ///Unhighlights clicked button row/column
    func unhighlightClickedButton() {
        if currentPlayer is PlayerOneView {
            for cell in playerOne?.buttonVector?.collectionView.visibleCells as! [ButtonCell]   {
                cell.buttonView.backgroundColor = UIColor.clear
            }
        } else  {
            for cell in playerTwo?.buttonVector?.collectionView.visibleCells as! [ButtonCell]   {
                cell.buttonView.backgroundColor = UIColor.clear
            }
        }
    }
}
