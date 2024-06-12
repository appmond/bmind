//
//  TwoPlayerViewController.swift
//  gametheory
//
//  Created by Edmond Osmani on 20/01/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import UIKit

class TwoPlayerViewController : UIViewController    {
    
    var numberOfRowsAndColumns:CGFloat?
    var playerOneView = PlayerOneView()
    var playerTwoView = PlayerTwoView()
    var lineFrames = BaseLineFrame()
    var singleGameInstance = GameInstance()
    var amIPlayerOne:Bool?
    var gameLogic = TwoPlayerGameLogic()
    var timer = Timer()
    var checkIfGameWasInterrupedTimer = Timer()
    var checkIfRoundIsDoneTimer = Timer()
    var currentPlayerOneScore = 0
    var currentPlayerTwoScore = 0
    var checkUpdate = 0
    @IBOutlet weak var playerOneMatrixView: UIView!
    @IBOutlet weak var playerTwoMatrixView: UIView!
    @IBOutlet weak var playerOneRowPick: UIView!
    @IBOutlet weak var playerTwoColumnPick: UIView!
    @IBOutlet weak var currentRound: UILabel!
    @IBOutlet weak var currentScore: UILabel!
    @IBOutlet weak var updateLabel: UILabel!
    
    func checkRoundTimer()  {
        if self.gameLogic.checkIfRoundIsDone == true {
            self.updateLabel.text = ""
            checkIfRoundIsDoneTimer.invalidate()
            showRunningPeriods()
            showRunningPayoffs()
            enableAllButtons()
            checkIfGameIsOver()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkIfButtonWasClicked), userInfo: nil, repeats: true)
        } else  {
            timer.invalidate()
        }
    }
    ///Selector-method to check if a button was clicked from the other player
    @objc func checkIfButtonWasClicked()  {
        var cells:[ButtonCell] = []
        if amIPlayerOne! {
            cells = playerOneView.buttonVector?.collectionView.visibleCells as! [ButtonCell]
        } else {
            cells = playerTwoView.buttonVector?.collectionView.visibleCells as! [ButtonCell]
        }
        for cell in cells {
            if cell.selectedCell != nil {
                self.updateLabel.text = ""
                if checkIfGameIsSequential()    {
                    timer.invalidate()
                    gameLogic.sendAction(buttonIndex: cell.selectedCell!.item + 1)
                    cell.selectedCell = nil
                    checkIfRoundIsDoneTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkRoundTimer), userInfo: nil, repeats: true)
                } else  {
                    if !self.gameLogic.isGameFinished {
                        gameLogic.unhighlightClickedButton()
                        self.updateLabel.text = "Not your turn."
                        cell.selectedCell = nil
                        enableAllButtons()
                    }
                }
            } else  {
                if self.checkIfGameIsSequential() {
                    self.updateLabel.text = "Select action."
                }
            }
        }
    }
    
    func checkIfGameIsSequential()->Bool  {
        var step = -1
        let currentRound = self.singleGameInstance.round!
        let noOfPeriods = self.singleGameInstance.number_of_periods!
        if self.singleGameInstance.step == nil  {
            step = 0
        } else  {
            step = self.singleGameInstance.step!
        }
        if self.singleGameInstance.game_type!.sequential! && (currentRound != noOfPeriods) {
            if amIPlayerOne! && self.singleGameInstance.game_sequence?[step] ==  1   {
                return true
            } else if !amIPlayerOne! && self.singleGameInstance.game_sequence?[step] == 2 {
                return true
            } else  {
                return false
            }
        } else {
            if currentRound == noOfPeriods {
                self.gameLogic.isGameFinished = true
                self.checkIfGameIsOver()
                return false
            } else  {
                return true
            }
        }
    }
    func checkIfGameIsOver()    {
        checkUpdate += 1
        if self.gameLogic.isGameFinished == true {
            self.updateLabel.text = "Game finished."
            showEndPayoff()
            removeUserInteraction()
            checkIfGameWasInterrupedTimer.invalidate()
            if self.singleGameInstance.state! == -1 {
                
                let errorAlert = UIAlertController(title: "Invalid GameState", message: "Back to Home Screen", preferredStyle: UIAlertControllerStyle.alert)
                errorAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {
                    action in
                    self.timer.invalidate()
                    self.checkIfGameWasInterrupedTimer.invalidate()
                    self.checkIfRoundIsDoneTimer.invalidate()
                    _ = self.navigationController?.popViewController(animated: true)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        } else if (checkUpdate%10) == 0   {
            gameLogic.checkGameInstanceUpdate()
        }
    }
    func enableAllButtons()    {
        var tmpcells:[ButtonCell] = []
        if amIPlayerOne! == true {
            tmpcells = playerOneView.buttonVector?.collectionView.visibleCells as! [ButtonCell]
        } else {
            tmpcells = playerTwoView.buttonVector?.collectionView.visibleCells as! [ButtonCell]
        }
        
        for cell in tmpcells {
            cell.isUserInteractionEnabled = true
        }
    }
    func removeUserInteraction()    {
        var tmpcells:[ButtonCell] = []
        if amIPlayerOne! == true {
            tmpcells = playerOneView.buttonVector?.collectionView.visibleCells as! [ButtonCell]
        } else {
            tmpcells = playerTwoView.buttonVector?.collectionView.visibleCells as! [ButtonCell]
        }
        
        for cell in tmpcells {
            cell.isUserInteractionEnabled = false
        }
    }
    ///Setup of firstplayer and secondplayer, as well as determines the current player
    func setupGameLogic()   {
        gameLogic.gameInstance = singleGameInstance
        gameLogic.playerOne = playerOneView
        gameLogic.playerTwo = playerTwoView
        if amIPlayerOne! {
            gameLogic.currentPlayer = playerOneView
        } else  {
            gameLogic.currentPlayer = playerTwoView
        }
        if singleGameInstance.game_type!.sequential! {
            gameLogic.isSequential = true
        } else {
            gameLogic.isSequential = false
        }
    }
    /// Sets boundaries for the Payoff-Matrix on the UI
    func addPayoffMatrix() {
        playerOneMatrixView.layer.cornerRadius = CGFloat(7.0)
        playerTwoMatrixView.layer.cornerRadius = CGFloat(7.0)
        
        lineFrames.divideGridView(tempMatrixView: playerOneMatrixView, numberOfRowsAndColumns: numberOfRowsAndColumns!)
        lineFrames.divideGridView(tempMatrixView: playerTwoMatrixView, numberOfRowsAndColumns: numberOfRowsAndColumns!)
        if amIPlayerOne! {
            playerOneMatrixView.addSubview(playerOneView.payOffMatrix!)
            playerOneMatrixView.addConstraintsWithFormat(format: "H:|[v0]|", views: playerOneView.payOffMatrix!)
            playerOneMatrixView.addConstraintsWithFormat(format: "V:|[v0]|", views: playerOneView.payOffMatrix!)
            
            playerTwoMatrixView.addSubview(playerTwoView.payOffMatrix!)
            playerTwoMatrixView.addConstraintsWithFormat(format: "H:|[v0]|", views: playerTwoView.payOffMatrix!)
            playerTwoMatrixView.addConstraintsWithFormat(format: "V:|[v0]|", views: playerTwoView.payOffMatrix!)
        } else  {
            playerOneMatrixView.addSubview(playerTwoView.payOffMatrix!)
            playerOneMatrixView.addConstraintsWithFormat(format: "H:|[v0]|", views: playerTwoView.payOffMatrix!)
            playerOneMatrixView.addConstraintsWithFormat(format: "V:|[v0]|", views: playerTwoView.payOffMatrix!)
            
            playerTwoMatrixView.addSubview(playerOneView.payOffMatrix!)
            playerTwoMatrixView.addConstraintsWithFormat(format: "H:|[v0]|", views: playerOneView.payOffMatrix!)
            playerTwoMatrixView.addConstraintsWithFormat(format: "V:|[v0]|", views: playerOneView.payOffMatrix!)
        }
    }
    /// Sets boundaries for the buttons on the UI
    func setupButtonPickerView()    {
        playerOneView.buttonVector?.numberOfButtons = numberOfRowsAndColumns
        playerTwoView.buttonVector?.numberOfButtons = numberOfRowsAndColumns
        
        playerOneRowPick.addSubview(playerOneView.buttonVector!)
        playerOneRowPick.addConstraintsWithFormat(format: "H:|[v0]|", views: playerOneView.buttonVector!)
        playerOneRowPick.addConstraintsWithFormat(format: "V:|[v0]|", views: playerOneView.buttonVector!)
        
        playerTwoColumnPick.addSubview(playerTwoView.buttonVector!)
        playerTwoColumnPick.addConstraintsWithFormat(format: "H:|[v0]|", views: playerTwoView.buttonVector!)
        playerTwoColumnPick.addConstraintsWithFormat(format: "V:|[v0]|", views: playerTwoView.buttonVector!)
    }
    /// Hides the buttons of the other player
    func hideOtherPlayersButtons()  {
        if amIPlayerOne! {
            playerTwoView.buttonVector?.isHidden = true
        } else  {
            playerOneView.buttonVector?.isHidden = true
        }
    }
    func showRunningPeriods()   {
        if self.singleGameInstance.game_type!.show_periods! == true {
            if self.singleGameInstance.round! != self.singleGameInstance.game_type!.max_periods! {
                if (self.singleGameInstance.round! == -1) || (self.singleGameInstance.round! == 0) {
                    currentRound.text = "1 / \(self.singleGameInstance.number_of_periods!)"
                } else	{
                    currentRound.text = "\((self.singleGameInstance.round! + 1)) / \(self.singleGameInstance.game_type!.max_periods!)"
                }
            } else	{
                currentRound.text = "\(self.singleGameInstance.number_of_periods!) / \(self.singleGameInstance.number_of_periods!)"
            }
        } else  {
            if self.singleGameInstance.round! == self.singleGameInstance.number_of_periods! {
                let maxPeriods = self.singleGameInstance.number_of_periods!
                currentRound.text = "\(maxPeriods) / \(maxPeriods)"
            }
        }
    }
    func showRunningPayoffs()   {
        if self.singleGameInstance.game_type!.show_running_payoff! == true {
            
            currentPlayerOneScore = self.singleGameInstance.result!.first!
            currentPlayerTwoScore = self.singleGameInstance.result!.last!
            
            if amIPlayerOne! == true {
                currentScore.text = "\(currentPlayerOneScore) : \(currentPlayerTwoScore)"
            } else  {
                currentScore.text = "\(currentPlayerTwoScore) : \(currentPlayerOneScore)"
            }
        } else  {
            if self.singleGameInstance.round! == self.singleGameInstance.game_type!.max_periods! {
                showEndPayoff()
            }
        }
    }
    func showEndPayoff()    {
        if amIPlayerOne! {
            currentScore.text = "\(self.singleGameInstance.result!.first!) : \(self.singleGameInstance.result!.last!)"
        } else  {
            currentScore.text = "\(self.singleGameInstance.result!.last!) : \(self.singleGameInstance.result!.first!)"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateLabel.text = "Select action."
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        addPayoffMatrix()
        setupButtonPickerView()
        hideOtherPlayersButtons()
        setupGameLogic()
        showRunningPeriods()
        if self.singleGameInstance.game_type!.show_running_payoff! == true {
            currentScore.text = "0 : 0"
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkIfButtonWasClicked), userInfo: nil, repeats: true)
        checkIfGameWasInterrupedTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkIfGameIsOver), userInfo: nil, repeats: true)
    }
    func back(sender: UIBarButtonItem) {
        self.gameLogic.invalidateGame()
        timer.invalidate()
        checkIfGameWasInterrupedTimer.invalidate()
        checkIfRoundIsDoneTimer.invalidate()
        _ = navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
}
