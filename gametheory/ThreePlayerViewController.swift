//  ThreePlayerViewController.swift
//  gametheory
//
//  Created by Edmond Osmani on 20/01/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.

import UIKit

class ThreePlayerViewController: UIViewController {
    
    /*############################# Class Properties #############################*/
    
    let BUZZER_URL = URLVariables.SERVER_STRING_URL+"buzzer"
    let GAME_INSTANCE_URL = URLVariables.SERVER_STRING_URL+"game-instance/"
    
    var currentPlayerOneScore = 0
    var currentPlayerTwoScore = 0
    var currentPlayerThreeScore = 0
    var timerLabelUpdate = 0
    var counter = 0
    var buzzerTimerLabelUpdate = 0
    var oldBuzzerClickState = 0
    var newBuzzerClickState = 0
    var checkUpdate = 0
    
    var firstBigView = BigPlayerView()
    var secondBigView = BigPlayerView()
    var firstSmallView = SmallPlayerOneView()
    var secondSmallView = SmallPlayerTwoView()
    var thirdSmallView = SmallPlayerOneView()
    var fourthSmallView = SmallPlayerTwoView()
    
    var lineFrames = BaseLineFrame()
    var singleGameInstance = ThreePlayerGameInstance()
    var gameLogic = ThreePlayerGameLogic()
    
    var numberOfRounds:Int?
    var amIPlayerOne:Bool?
    var amIPlayerTwo:Bool?
    var wasApproveButtonClicked = false
    var numberOfRowsAndColumns:CGFloat?
    
    var timer = Timer()
    var checkIfGameWasInterrupedTimer = Timer()
    var checkIfRoundIsDoneTimer = Timer()
    var gameTimer = Timer()
    var buzzerChecker = Timer()
    var tmpTimer = Timer()
    var checkIfSomeonePlayedWhoPressedBuzzer = Timer()
    var dbFunctions = DBFunctions()
    
    @IBOutlet weak var currentRound: UILabel!
    @IBOutlet weak var currentScore: UILabel!
    @IBOutlet weak var firstBigMatrixView: UIView!
    @IBOutlet weak var secondBigMatrixView: UIView!
    @IBOutlet weak var firstSmallMatrixView: UIView!
    @IBOutlet weak var secondSmallMatrixView: UIView!
    @IBOutlet weak var thirdSmallMatrixView: UIView!
    @IBOutlet weak var fourthSmallMatrixView: UIView!
    @IBOutlet weak var firstBigButtonView: UIView!
    @IBOutlet weak var secondBigButtonView: UIView!
    @IBOutlet weak var firstSmallButtonView: UIView!
    @IBOutlet weak var secondSmallButtonView: UIView!
    @IBOutlet weak var thirdSmallButtonView: UIView!
    @IBOutlet weak var fourthSmallButtonView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var buzzer: UIButton!
    @IBOutlet weak var updateLabel: UILabel!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var approveLabel: UILabel!
    
    /*############################# Game Logic #############################*/
    
    @IBAction func buzzerClicked(_ sender: UIButton) {
        self.buzzer.isUserInteractionEnabled = false
        self.buzzerChecker.invalidate()
        gameLogic.checkGameInstanceUpdate()
        let gameInstanceId = self.singleGameInstance.id!
        let myName = UIDevice.current.identifierForVendor!.uuidString
        let step = self.singleGameInstance.step!
        let jsonDict:[String:Any] = ["id":gameInstanceId, "name":"\(myName)", "step":step]
        self.dbFunctions.dbPostJSONRequest(postJSON: jsonDict, urlPath: BUZZER_URL, completionHandler: { dictionaryObj in
            self.singleGameInstance.retrieveGameInstance(gameInstance: dictionaryObj)
            if self.singleGameInstance.turn! == myName    {
                self.updateLabel.text = "Your turn to play!"
                self.enableUserInteraction()
                self.restartTimer()
                self.gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateGameTimer), userInfo: nil, repeats: true)
                self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.checkIfButtonWasClicked), userInfo: nil, repeats: true)
            } else {
                self.buzzerChecker = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.checkIfSomeoneClickedBuzzer), userInfo: nil, repeats: true)
            }
        })
    }
    @objc func checkIfButtonWasClicked()  {
        if !checkIfGameIsSequential() {
            self.updateLabel.text = "Wait for other players"
            removeUserInteraction()
        } else  {
            self.gameLogic.explicitTimer.invalidate()
            enableUserInteraction()
            self.updateLabel.text = "Select action"
            checkFirstButton()
            checkSecondButton()
        }
    }
    func checkFirstButton() {
        let tmpCells1 = firstBigView.buttonVector?.collectionView.visibleCells as! [ButtonCell]
        for cell in tmpCells1 {
            if cell.selectedCell != nil {
                gameLogic.checkGameInstanceUpdate()
                if !self.singleGameInstance.game_type!.explicit_approval! {
                    timer.invalidate()
                }
                cell.selectedCell = nil
                if (self.singleGameInstance.game_type?.buzzer)! {
                    gameLogic.sendBuzzerAction(buttonIndex: 1)
                    self.updateLabel.text = ""
                } else if wasApproveButtonClicked {
                    gameLogic.sendExplicitApprovAction(buttonIndex: 1)
                    wasApproveButtonClicked = false
                } else  {
                    self.updateLabel.text = "Wait for other players"
                    gameLogic.sendAction(buttonIndex: 1)
                }
                approveButton.backgroundColor = UIColor.clear
                checkIfRoundIsDoneTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkRoundTimer), userInfo: nil, repeats: true)
            }
        }
    }
    func checkSecondButton()    {
        let tmpCells2 = secondBigView.buttonVector?.collectionView.visibleCells as! [ButtonCell]
        for cell in tmpCells2 {
            if cell.selectedCell != nil {
                gameLogic.checkGameInstanceUpdate()
                if !self.singleGameInstance.game_type!.explicit_approval! {
                    timer.invalidate()
                }
                cell.selectedCell = nil
                if (self.singleGameInstance.game_type?.buzzer)! {
                    gameLogic.sendBuzzerAction(buttonIndex: 2)
                    self.updateLabel.text = ""
                } else if wasApproveButtonClicked {
                    gameLogic.sendExplicitApprovAction(buttonIndex: 2)
                    wasApproveButtonClicked = false
                } else {
                    self.updateLabel.text = "Wait for other players"
                    gameLogic.sendAction(buttonIndex: 2)
                }
                approveButton.backgroundColor = UIColor.clear
                checkIfRoundIsDoneTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkRoundTimer), userInfo: nil, repeats: true)
            }
        }
    }
    func checkIfSomeoneClickedBuzzer()  {
        dbFunctions.dbGetDictRequest(urlPath: GAME_INSTANCE_URL+"\((self.singleGameInstance.id)!)", completionHandler: { dictionaryObj in
            self.singleGameInstance.retrieveGameInstance(gameInstance: dictionaryObj)
            if let step = self.singleGameInstance.step  {
                self.newBuzzerClickState = step-2 + (self.singleGameInstance.buzzer_list?.count)!
                if ((self.singleGameInstance.step!-2) == (self.singleGameInstance.buzzer_list?.count)!) && (self.newBuzzerClickState > self.oldBuzzerClickState) {
                    self.oldBuzzerClickState = self.newBuzzerClickState
                    self.buzzerChecker.invalidate()
                    self.buzzer.isUserInteractionEnabled = false
                    self.waitForBuzzerPlayerToPlay()
                }
            }
        })
    }
    func waitForBuzzerPlayerToPlay() {
        self.updateLabel.text = "Waiting for other player..."
        self.restartTimer()
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateGameTimer), userInfo: nil, repeats: true)
        checkIfSomeonePlayedWhoPressedBuzzer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkBuzzerPlayUpdate), userInfo: nil, repeats: true)
    }
    func checkBuzzerPlayUpdate()    {
        self.dbFunctions.dbGetDictRequest(urlPath: GAME_INSTANCE_URL+"\((self.singleGameInstance.id)!)", completionHandler: { dictionaryObj in
            let step = self.singleGameInstance.step!
            self.singleGameInstance.retrieveGameInstance(gameInstance: dictionaryObj)
            if (step - 3) == (self.singleGameInstance.game_sequence?.count)!  {
                self.updateLabel.text = ""
                self.checkIfSomeonePlayedWhoPressedBuzzer.invalidate()
                self.gameLogic.unHighlightRowOrColumn()
                self.gameLogic.highlightSelectedFields(tmpFirstPlayer: (self.singleGameInstance.first_player_actions?.last)!, tmpSecondPlayer: (self.singleGameInstance.second_player_actions?.last)!, tmpThirdPlayer: (self.singleGameInstance.third_player_actions?.last)!)
                self.buzzer.isUserInteractionEnabled = true
                self.restartTimer()
                self.showRunningPeriods()
                self.gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateBuzzerTimer), userInfo: nil, repeats: true)
                self.buzzerChecker = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.checkIfSomeoneClickedBuzzer), userInfo: nil, repeats: true)
            }
        })
    }
    func checkRoundTimer()  {
        if self.gameLogic.checkIfRoundIsDone {
            checkIfRoundIsDoneTimer.invalidate()
            self.updateLabel.text = "Select action."
            showRunningPeriods()
            showRunningPayoffs()
            restartTimer()
            if !(self.singleGameInstance.game_type?.buzzer)! {
                enableUserInteraction()
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkIfButtonWasClicked), userInfo: nil, repeats: true)
            } else  {
                removeUserInteraction()
                buzzer.isUserInteractionEnabled = true
                self.buzzerChecker = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.checkIfSomeoneClickedBuzzer), userInfo: nil, repeats: true)
            }
            checkIfGameIsOver()
            gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateBuzzerTimer), userInfo: nil, repeats: true)
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
        if self.singleGameInstance.game_type!.sequential! && (currentRound != noOfPeriods) && !self.singleGameInstance.game_type!.buzzer! {
            if amIPlayerOne! && self.singleGameInstance.game_sequence?[step] ==  1   {
                return true
            } else if amIPlayerTwo! && self.singleGameInstance.game_sequence?[step] == 2 {
                return true
            } else if (!amIPlayerOne! && !amIPlayerTwo!) && self.singleGameInstance.game_sequence?[step] == 3 {
                return true
            } else  {
                return false
            }
        } else {
            if currentRound == noOfPeriods {
                checkEndGameState()
                return false
            } else  {
                return true
            }
        }
    }
    func checkIfGameIsOver()    {
        checkUpdate += 1
        if self.gameLogic.isGameFinished == true {
            checkEndGameState()
        } else if (checkUpdate%10) == 0 {
            gameLogic.checkGameInstanceUpdate()
        }
    }
    func checkEndGameState()    {
        if self.singleGameInstance.state! != -1 {
            removeUserInteraction()
            if self.singleGameInstance.game_type!.final_payoff_only! {
                showEndPayoff()
            }
            if !self.singleGameInstance.game_type!.show_periods! {
                showRunningPeriods()
            }
            checkIfGameWasInterrupedTimer.invalidate()
            timer.invalidate()
            self.updateLabel.text = "Game finished."
            self.timerLabel.text = ""
        } else  {
            let errorAlert = UIAlertController(title: "Invalid GameState", message: "Back to Home Screen", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {
                action in
                self.timer.invalidate()
                self.checkIfGameWasInterrupedTimer.invalidate()
                self.checkIfRoundIsDoneTimer.invalidate()
                self.gameTimer.invalidate()
                self.buzzerChecker.invalidate()
                self.tmpTimer.invalidate()
                self.checkIfSomeonePlayedWhoPressedBuzzer.invalidate()
                _ = self.navigationController?.popViewController(animated: true)
            }))
            self.present(errorAlert, animated: true, completion: nil)
            checkIfGameWasInterrupedTimer.invalidate()
        }
    }
    func showRunningPeriods()   {
        let maxPeriods = self.singleGameInstance.number_of_periods!
        let round = self.singleGameInstance.round!
        if !self.singleGameInstance.game_type!.buzzer! {
            if self.singleGameInstance.game_type!.show_periods! == true {
                if self.singleGameInstance.state! == 3 {
                    currentRound.text = "\(maxPeriods) / \(maxPeriods)"
                } else  {
                    currentRound.text = "\(round + 1) / \(maxPeriods)"
                }
            }
        } else {
            if self.singleGameInstance.game_type!.show_periods! {
                currentRound.text = "\((self.singleGameInstance.game_sequence?.count)!)"
            }
        }
    }
    func showRunningPayoffs()   {
        if self.singleGameInstance.game_type!.show_running_payoff! == true {
            
            let firstElement = self.singleGameInstance.result!.first!
            let lastElement = self.singleGameInstance.result!.last!
            self.singleGameInstance.result!.removeLast()
            let middleElement = self.singleGameInstance.result!.last!
            let firstPlayerName = self.singleGameInstance.first_player_name!
            let secondPlayerName = self.singleGameInstance.second_player_name!
            let thirdPlayerName = self.singleGameInstance.third_player_name!
            
            if amIPlayerOne! {
                let tmpStringArray = [secondPlayerName, thirdPlayerName]
                let sortedArray = tmpStringArray.sorted()
                if sortedArray.first == secondPlayerName {
                    currentScore.text = "\(firstElement) : \(middleElement) : \(lastElement)"
                } else  {
                    currentScore.text = "\(firstElement) : \(lastElement) : \(middleElement)"
                }
            } else if amIPlayerTwo! {
                let tmpStringArray = [firstPlayerName, thirdPlayerName]
                let sortedArray = tmpStringArray.sorted()
                if sortedArray.first == firstPlayerName {
                    currentScore.text = "\(middleElement) : \(firstElement) : \(lastElement)"
                } else  {
                    currentScore.text = "\(middleElement) : \(lastElement) : \(firstElement)"
                }
            } else  {
                let tmpStringArray = [firstPlayerName, secondPlayerName]
                let sortedArray = tmpStringArray.sorted()
                if sortedArray.first == firstPlayerName {
                    currentScore.text = "\(lastElement) : \(firstElement) : \(middleElement)"
                } else  {
                    currentScore.text = "\(lastElement) : \(middleElement) : \(firstElement)"
                }
            }
        } else  {
            showEndPayoff()
        }
    }
    func showEndPayoff()    {
        let firstPlayerName = self.singleGameInstance.first_player_name!
        let secondPlayerName = self.singleGameInstance.second_player_name!
        let thirdPlayerName = self.singleGameInstance.third_player_name!
        
        if self.singleGameInstance.state! == 3 || self.singleGameInstance.state! == -1 {
            let firstElement = self.singleGameInstance.result!.first!
            let lastElement = self.singleGameInstance.result!.last!
            self.singleGameInstance.result!.removeLast()
            let middleElement = self.singleGameInstance.result!.last!
            if amIPlayerOne! {
                let tmpStringArray = [secondPlayerName, thirdPlayerName]
                let sortedArray = tmpStringArray.sorted()
                if sortedArray.first == secondPlayerName {
                    currentScore.text = "\(firstElement) : \(middleElement) : \(lastElement)"
                } else  {
                    currentScore.text = "\(firstElement) : \(lastElement) : \(middleElement)"
                }
            } else if amIPlayerTwo! {
                let tmpStringArray = [firstPlayerName, thirdPlayerName]
                let sortedArray = tmpStringArray.sorted()
                if sortedArray.first == firstPlayerName {
                    currentScore.text = "\(middleElement) : \(firstElement) : \(lastElement)"
                } else  {
                    currentScore.text = "\(middleElement) : \(lastElement) : \(firstElement)"
                }
            } else  {
                let tmpStringArray = [firstPlayerName, secondPlayerName]
                let sortedArray = tmpStringArray.sorted()
                if sortedArray.first == firstPlayerName {
                    currentScore.text = "\(lastElement) : \(firstElement) : \(middleElement)"
                } else  {
                    currentScore.text = "\(lastElement) : \(middleElement) : \(firstElement)"
                }
            }
        }
    }
    func removeUserInteractionForSmallViews()   {
        firstSmallView.buttonVector?.isUserInteractionEnabled = false
        secondSmallView.buttonVector?.isUserInteractionEnabled = false
        thirdSmallView.buttonVector?.isUserInteractionEnabled = false
        fourthSmallView.buttonVector?.isUserInteractionEnabled = false
    }
    func sendFirstAction()   {
        let gameInstanceId = self.singleGameInstance.id!
        let myName = UIDevice.current.identifierForVendor!.uuidString
        var jsonDict:[String:Any] = ["id":gameInstanceId, "name":myName, "action":-1]
        let randomInt = Int(arc4random_uniform(2)+1)
        if randomInt == 1 {
            jsonDict = ["id":gameInstanceId, "name":myName, "action":1]
        } else  {
            jsonDict = ["id":gameInstanceId, "name":myName, "action":2]
        }
        
        dbFunctions.dbPostJSONRequest(postJSON: jsonDict, urlPath: gameLogic.ACTION_URL, completionHandler: {
            dictionaryObj in
            self.singleGameInstance.retrieveGameInstance(gameInstance: dictionaryObj)
            self.tmpTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.didAllPlayAtStart), userInfo: nil, repeats: true)
        })
    }
    func didAllPlayAtStart()  {
        if self.singleGameInstance.first_player_actions?.last != nil && self.singleGameInstance.second_player_actions?.last != nil && self.singleGameInstance.third_player_actions?.last != nil {
            self.tmpTimer.invalidate()
            self.gameLogic.highlightSelectedFields(tmpFirstPlayer: (self.singleGameInstance.first_player_actions?.last)!, tmpSecondPlayer: (self.singleGameInstance.second_player_actions?.last)!, tmpThirdPlayer: (self.singleGameInstance.third_player_actions?.last)!)
            self.gameLogic.lastPlays = ((self.singleGameInstance.first_player_actions?.last)!, (self.singleGameInstance.second_player_actions?.last)!, (self.singleGameInstance.third_player_actions?.last)!)
            if self.singleGameInstance.game_type!.explicit_approval! {
                self.gameLogic.explicitTimer = Timer.scheduledTimer(timeInterval: 1.0, target: gameLogic, selector: #selector(gameLogic.checkExplicitApprovStatus), userInfo: nil, repeats: true)
            }
            buzzer.isUserInteractionEnabled = true
        }
    }
    
    /*############################# TIMER FUNCTIONS #############################*/
    
    func restartTimer() {
        gameTimer.invalidate()
        self.timerLabelUpdate = self.singleGameInstance.game_type!.timer!
        self.buzzerTimerLabelUpdate = self.singleGameInstance.game_type!.buzzer_timer!
    }
    func updateGameTimer()  {
        timerLabelUpdate -= 1
        if self.singleGameInstance.game_type?.timer == -1 || (self.singleGameInstance.game_type?.explicit_approval)! {
            timerLabel.text = ""
            timerLabelUpdate = 1000
        } else	{
            timerLabel.text = "\(timerLabelUpdate)"
        }
        if timerLabelUpdate == 0 {
            self.buzzer.isUserInteractionEnabled = false
            self.buzzer.isHidden = true
            restartTimer()
            buzzerChecker.invalidate()
            timer.invalidate()
            self.updateLabel.text = "Game finished."
            self.timerLabel.text = ""
            gameLogic.invalidateGame()
        }
    }
    func updateBuzzerTimer()  {
        buzzerTimerLabelUpdate -= 1
        if self.singleGameInstance.game_type?.timer == -1 || (self.singleGameInstance.game_type?.explicit_approval)! {
            timerLabel.text = ""
            buzzerTimerLabelUpdate = 1000
        } else {
            timerLabel.text = "\(buzzerTimerLabelUpdate)"
        }
        if buzzerTimerLabelUpdate == 0 {
            self.buzzer.isUserInteractionEnabled = false
            self.buzzer.isHidden = true
            restartTimer()
            buzzerChecker.invalidate()
            gameLogic.timeout()
            self.updateLabel.text = "Game finished."
            self.timerLabel.text = ""
            timer.invalidate()
        }
    }
    func back(sender: UIBarButtonItem) {
        self.gameLogic.invalidateGame()
        timer.invalidate()
        checkIfGameWasInterrupedTimer.invalidate()
        checkIfRoundIsDoneTimer.invalidate()
        gameTimer.invalidate()
        buzzerChecker.invalidate()
        tmpTimer.invalidate()
        checkIfSomeonePlayedWhoPressedBuzzer.invalidate()
        _ = navigationController?.popViewController(animated: true)
    }
    
    /*############################# UIVC OVERRIDES #############################*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buzzer.isUserInteractionEnabled = false
        self.buzzerTimerLabelUpdate = (self.singleGameInstance.game_type!.buzzer_timer!)
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        self.addPayoffMatrix()
        self.setupButtonPickerView()
        self.removeUserInteractionForSmallViews()
        self.showRunningPeriods()
        self.setupGameLogic()
        self.checkIfGameWasInterrupedTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.checkIfGameIsOver), userInfo: nil, repeats: true)
        self.buzzerExplicitApprovSetup()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateBuzzerTimer), userInfo: nil, repeats: true)
            if (self.singleGameInstance.game_type?.buzzer)! {
                self.buzzerChecker = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.checkIfSomeoneClickedBuzzer), userInfo: nil, repeats: true)
            }
        }
    }
    func buzzerExplicitApprovSetup()   {
        if (self.singleGameInstance.game_type?.buzzer)! {
            self.timerLabelUpdate = self.singleGameInstance.game_type!.timer!
            self.updateLabel.text = ""
            removeUserInteraction()
            sendFirstAction()
            approveLabel.isHidden = true
            approveButton.isHidden = true
        } else if (self.singleGameInstance.game_type?.explicit_approval)! {
            self.updateLabel.text = "Select action."
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.checkIfButtonWasClicked), userInfo: nil, repeats: true)
            buzzer.isHidden = true
            sendFirstAction()
            approveButton.layer.borderWidth = CGFloat(2.0)
            approveButton.layer.borderColor = UIColor.black.cgColor
            approveButton.showsTouchWhenHighlighted = true
            approveButton.addTarget(self, action: #selector(approveButtonTouched), for: .touchUpInside)
        } else  {
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.checkIfButtonWasClicked), userInfo: nil, repeats: true)
            self.updateLabel.text = "Select action."
            buzzer.isHidden = true
            approveLabel.isHidden = true
            approveButton.isHidden = true
        }
    }
    @objc func approveButtonTouched()    {
        UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.approveButton.backgroundColor = UIColor.black
            self.wasApproveButtonClicked = true
        }, completion: nil)
        
        UIView.animate(withDuration: 0.55, animations: {
            self.approveButton.backgroundColor = UIColor.black
            self.wasApproveButtonClicked = true
        })
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
