//
//  GameTypesViewController.swift
//  gametheory
//
//  Created by Edmond Osmani on 20/01/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import UIKit

class GameTypesViewController: UICollectionViewController {
    
    let reuseIdentifier = "cellID"
    let HIGH_SCORE_URL = URLVariables.SERVER_STRING_URL+"high-score?id="+UIDevice.current.identifierForVendor!.uuidString
    let SCORE_URL = URLVariables.SERVER_STRING_URL+"scores"
    let GAME_TYPE_URL = URLVariables.SERVER_STRING_URL+"new-game"
    let GAME_INSTANCE_URL = URLVariables.SERVER_STRING_URL+"game-instance/"
    let searchingForPlayer = UIAlertController(title: "Searching for another Player", message: "Searching ...", preferredStyle: .alert)
    
    var dbFunctions = DBFunctions()
    var gameGroups : [GameGroup]?
    var scoreDeviceNames:[String] = ["Device-ID"]
    var scoreDeviceScores:[String] = ["Score"]
    var twoPlayerGameType = TwoPlayerGameType()
    var threePlayerGameType = ThreePlayerGameType()
    var gameInstance = GameInstance()
    var threePlayerGameInstance = ThreePlayerGameInstance()
    var timer = Timer()
    var counter = 0
    var amIFirst = false
    var amISecond = false
    var tmpHighScore = ""
    var isItThreePlayerGame = false
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameGroups!.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GameTypesCell
        let iconImage = gameGroups?[indexPath.item].iconImage!
        let iconName = gameGroups?[indexPath.item].name!
        let iconActiveGames = gameGroups?[indexPath.item].active_games!
        cell.imageView.image = iconImage
        cell.groupName.text = iconName!+" "+"(\(iconActiveGames!))"
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "GameTypesFooterView", for: indexPath) as! GameTypesFooterView
            footerView.deviceScore.text = "Score: "+"loading..."
            footerView.deviceName.text = UIDevice.current.identifierForVendor!.uuidString
            return footerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    ///Submits clicked gamegroup and either creates newgame or is added to an open game of this group
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let gameGroupId = gameGroups![indexPath.item].id!
        let myName = UIDevice.current.identifierForVendor!.uuidString
        let jsonDict:[String:Any] = ["group_id":gameGroupId, "name":myName]
        dbFunctions.dbPostJSONRequest(postJSON: jsonDict, urlPath: GAME_TYPE_URL, completionHandler: { dictionaryObj in
            let gametypeDictionary = dictionaryObj["game_type"] as! [String : Any]
            let first_player_name = dictionaryObj["first_player_name"] as? String?
            let second_player_name = dictionaryObj["second_player_name"] as? String?
            let numberOfPlayers = gametypeDictionary["number_of_players"] as! Int
            self.determineIfIAmFirst(name: first_player_name!)
            self.determineIfIAmSecond(name: second_player_name)
            if numberOfPlayers == 3 {
                self.isItThreePlayerGame = true
                self.threePlayerGameType.retrieveGameType(gametype: gametypeDictionary)
                self.threePlayerGameInstance.retrieveGameInstance(gameInstance: dictionaryObj)
                if self.threePlayerGameInstance.second_player_name == nil || self.threePlayerGameInstance.third_player_name == nil  {
                    self.checkInstanceUpdate()
                    self.present(self.searchingForPlayer, animated: true, completion: nil)
                } else  {
                    self.convertThreePlayerPayoffArray()
                    self.threePlayerGameInstance.game_type = self.threePlayerGameType
                    self.performSegue(withIdentifier: "toThreePlayerViewController", sender: self)
                }
            } else  {
                self.gameInstance.retrieveGameInstance(gameInstance: dictionaryObj)
                self.twoPlayerGameType.retrieveGameType(gametype: gametypeDictionary)
                self.twoPlayerGameType.convertStringtoPayoffArray()
                self.gameInstance.game_type = self.twoPlayerGameType
                self.checkTwoPlayerGameState()
            }
        })
    }
    
    ///Check game instance update
    func checkInstanceUpdate() {
        
        let group1 = DispatchGroup()
        group1.enter()
        dbFunctions.dbGetDictRequest(urlPath: GAME_INSTANCE_URL+"\((self.threePlayerGameInstance.id)!)", completionHandler: { dictionaryObj in
            self.threePlayerGameInstance.retrieveGameInstance(gameInstance: dictionaryObj)
            group1.leave()
        })
        group1.notify(queue: DispatchQueue.main, execute: {
            if self.threePlayerGameInstance.second_player_name == nil || self.threePlayerGameInstance.third_player_name == nil  {
                self.checkInstanceUpdate()
            } else  {
                self.timer.invalidate()
                self.convertThreePlayerPayoffArray()
                self.threePlayerGameInstance.game_type = self.threePlayerGameType
                self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "toThreePlayerViewController", sender: self)
            }
        })
    }
    
    ///Converts payoff-string to int
    func convertThreePlayerPayoffArray()   {
        if self.amIFirst    {
            self.threePlayerGameType.convertStringtoPayoffArray(playerIndex: 1, playerTwoName: self.threePlayerGameInstance.second_player_name!, playerThreeName: self.threePlayerGameInstance.third_player_name!)
        } else if self.amISecond    {
            self.threePlayerGameType.convertStringtoPayoffArray(playerIndex: 2, playerTwoName: self.threePlayerGameInstance.first_player_name!, playerThreeName: self.threePlayerGameInstance.third_player_name!)
        } else {
            self.threePlayerGameType.convertStringtoPayoffArray(playerIndex: 3, playerTwoName: self.threePlayerGameInstance.first_player_name!, playerThreeName: self.threePlayerGameInstance.second_player_name!)
        }
    }
    
    ///Check if the current device is player one
    func determineIfIAmFirst(name:String?)	{
        if name! == UIDevice.current.identifierForVendor!.uuidString    {
            self.amIFirst = true
        } else  {
            self.amIFirst = false
        }
    }
    
    ///Check if player two is found and if the current device is player 2
    func determineIfIAmSecond(name:String??)	{
        if name != nil && name! == UIDevice.current.identifierForVendor!.uuidString  {
            self.amISecond = true
        } else  {
            self.amISecond = false
        }
    }
    
    ///Checks if the gamestate is 1 (started)
    func checkTwoPlayerGameState()   {
        if self.gameInstance.state! == 0  {
            timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(updateCounting), userInfo: nil, repeats: true)
            present(searchingForPlayer, animated: true, completion: nil)
        } else   {
            self.performSegue(withIdentifier: "toTwoPlayerViewController", sender: self)
        }
    }
    
    ///Checks if another player was found
    func updateCounting()   {
        if isItThreePlayerGame == false {
            self.dbFunctions.dbGetDictRequest(urlPath: self.GAME_INSTANCE_URL+"\(self.gameInstance.id!)", completionHandler: { dictionaryObj in
                let gameState = dictionaryObj["state"] as? Int
                if (gameState! == 1){
                    self.timer.invalidate()
                    self.searchingForPlayer.title = "Found another Player!"
                    self.searchingForPlayer.message = ""
                    self.searchingForPlayer.addAction(UIAlertAction(title: "Great!", style: .default, handler: {
                        action in
                        self.performSegue(withIdentifier: "toTwoPlayerViewController", sender: self)
                    }))
                } else if (self.counter == 7) {
                    self.dismiss(animated: true, completion: nil)
                }
                self.counter = self.counter + 1
            })
        }
    }

    ///Segue to TwoPlayerVC and transfer all game-relevant parameters
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.destination.title == "Two Player Game") {
            let destinationVC = segue.destination as! TwoPlayerViewController
            destinationVC.singleGameInstance = self.gameInstance
            destinationVC.numberOfRowsAndColumns = CGFloat(sqrt(Double((twoPlayerGameType.playerOne?.payOffMatrix?.payoffMatrix?.count)!)))
            destinationVC.playerOneView.payOffMatrix?.payoffMatrix = twoPlayerGameType.playerOne?.payOffMatrix?.payoffMatrix
            destinationVC.playerTwoView.payOffMatrix?.payoffMatrix = twoPlayerGameType.playerTwo?.payOffMatrix?.payoffMatrix
            destinationVC.amIPlayerOne = amIFirst
        } else if (segue.destination.title == "Three Player Game")  {
            let destinationVC = segue.destination as! ThreePlayerViewController
            destinationVC.singleGameInstance = self.threePlayerGameInstance
            destinationVC.numberOfRowsAndColumns = CGFloat(sqrt(Double((threePlayerGameType.firstBigView?.payOffMatrix?.payoffMatrix?.count)!)))
            destinationVC.firstBigView.payOffMatrix?.payoffMatrix = threePlayerGameType.firstBigView?.payOffMatrix?.payoffMatrix
            destinationVC.secondBigView.payOffMatrix?.payoffMatrix = threePlayerGameType.secondBigView?.payOffMatrix?.payoffMatrix
            destinationVC.firstSmallView.payOffMatrix?.payoffMatrix = threePlayerGameType.firstSmallView?.payOffMatrix?.payoffMatrix
            destinationVC.secondSmallView.payOffMatrix?.payoffMatrix = threePlayerGameType.secondSmallView?.payOffMatrix?.payoffMatrix
            destinationVC.thirdSmallView.payOffMatrix?.payoffMatrix = threePlayerGameType.thirdSmallView?.payOffMatrix?.payoffMatrix
            destinationVC.fourthSmallView.payOffMatrix?.payoffMatrix = threePlayerGameType.fourthSmallView?.payOffMatrix?.payoffMatrix
            destinationVC.numberOfRounds = threePlayerGameType.max_periods!
            destinationVC.amIPlayerOne = amIFirst
            destinationVC.amIPlayerTwo = amISecond
        } else if (segue.destination.title == "Scoring View Controller")    {
            let destinationVC = segue.destination as! ScoringViewController
            destinationVC.deviceNames = self.scoreDeviceNames
            destinationVC.deviceScores = self.scoreDeviceScores
        }
    }
    
    ///Segue to Info-VC
    func touchInfoBarButton()    {
        self.performSegue(withIdentifier: "showInfoViewController", sender: self)
    }
    
    ///Retrieves high score of device
    func getHighscore() {
        dbFunctions.dbGetIntegerRequest(urlPath: HIGH_SCORE_URL, completionHandler: {
            tmpScore in
            let footerView = self.collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: IndexPath(item: 0, section: 0)) as! GameTypesFooterView
            footerView.deviceScore.text = "Score: "+"\(tmpScore)"
        })
    }
    
    @IBAction func getScores(_ sender: Any) {
        self.performSegue(withIdentifier: "toScoringViewController", sender: self)
    }
    
    func getTheScore()  {
        dbFunctions.dbGetRequest(urlPath: SCORE_URL, completionHandler: {
            dictionaryObj in
            for scorePair in dictionaryObj  {
                let tmpName = scorePair["ID"] as! String
                let tmpScore = scorePair["score"] as! Int
                self.scoreDeviceNames.append(tmpName)
                self.scoreDeviceScores.append("\(tmpScore)")
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView?.alwaysBounceVertical = true
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(touchInfoBarButton), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.leftBarButtonItem = infoBarButtonItem
        
        getHighscore()
        getTheScore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        twoPlayerGameType = TwoPlayerGameType()
        threePlayerGameType = ThreePlayerGameType()
        gameInstance = GameInstance()
        threePlayerGameInstance = ThreePlayerGameInstance()
        timer = Timer()
        counter = 0
        isItThreePlayerGame = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

class GameTypesCell : UICollectionViewCell    {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var groupName: UILabel!
    
    override init(frame: CGRect)    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
