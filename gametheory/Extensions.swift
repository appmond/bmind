//
//  Extensions.swift
//  gametheory
//
//  Created by Edmond Osmani on 20/01/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import UIKit

extension UIView {
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

public func castToOptional<T>(x: Any) -> T {
    return x as! T
}

struct URLVariables {
    static let SERVER_STRING_URL = "http://straint.ddnss.org:8080/"
}

extension ThreePlayerViewController {
    func enableUserInteraction()    {
        self.firstBigView.buttonVector?.isUserInteractionEnabled = true
        self.secondBigView.buttonVector?.isUserInteractionEnabled = true
    }
    
    func removeUserInteraction()    {
        self.firstBigView.buttonVector?.isUserInteractionEnabled = false
        self.secondBigView.buttonVector?.isUserInteractionEnabled = false
    }
    
    func setupGameLogic()   {
        gameLogic.gameInstance = singleGameInstance
        gameLogic.firstBigView = firstBigView
        gameLogic.secondBigView = secondBigView
        gameLogic.firstSmallView = firstSmallView
        gameLogic.secondSmallView = secondSmallView
        gameLogic.thirdSmallView = thirdSmallView
        gameLogic.fourthSmallView = fourthSmallView
        if (singleGameInstance.game_type?.randomized_sequence)! {
            gameLogic.isSequential = true
        } else {
            gameLogic.isSequential = false
        }
        determineCurrentPlayer()
    }
    
    func determineCurrentPlayer()   {
        if amIPlayerOne! {
            gameLogic.currentPlayerIndex = 1
        } else if amIPlayerTwo!  {
            gameLogic.currentPlayerIndex = 2
        } else  {
            gameLogic.currentPlayerIndex = 3
        }
    }
    
    /*############################# UI VISUAL FORMAT #############################*/
    
    /// Sets boundaries for the Payoff-Matrix on the UI
    func addPayoffMatrix() {
        firstBigMatrixView.layer.cornerRadius = CGFloat(2.0)
        secondBigMatrixView.layer.cornerRadius = CGFloat(2.0)
        firstSmallMatrixView.layer.cornerRadius = CGFloat(2.0)
        secondSmallMatrixView.layer.cornerRadius = CGFloat(2.0)
        thirdSmallMatrixView.layer.cornerRadius = CGFloat(2.0)
        fourthSmallMatrixView.layer.cornerRadius = CGFloat(2.0)
        
        
        lineFrames.divideGridView(tempMatrixView: firstBigMatrixView, numberOfRowsAndColumns: numberOfRowsAndColumns!)
        lineFrames.divideGridView(tempMatrixView: secondBigMatrixView, numberOfRowsAndColumns: numberOfRowsAndColumns!)
        lineFrames.divideGridView(tempMatrixView: firstSmallMatrixView, numberOfRowsAndColumns: numberOfRowsAndColumns!)
        lineFrames.divideGridView(tempMatrixView: secondSmallMatrixView, numberOfRowsAndColumns: numberOfRowsAndColumns!)
        lineFrames.divideGridView(tempMatrixView: thirdSmallMatrixView, numberOfRowsAndColumns: numberOfRowsAndColumns!)
        lineFrames.divideGridView(tempMatrixView: fourthSmallMatrixView, numberOfRowsAndColumns: numberOfRowsAndColumns!)
        
        firstBigMatrixView.addSubview(firstBigView.payOffMatrix!)
        firstBigMatrixView.addConstraintsWithFormat(format: "H:|[v0]|", views: firstBigView.payOffMatrix!)
        firstBigMatrixView.addConstraintsWithFormat(format: "V:|[v0]|", views: firstBigView.payOffMatrix!)
        
        secondBigMatrixView.addSubview(secondBigView.payOffMatrix!)
        secondBigMatrixView.addConstraintsWithFormat(format: "H:|[v0]|", views: secondBigView.payOffMatrix!)
        secondBigMatrixView.addConstraintsWithFormat(format: "V:|[v0]|", views: secondBigView.payOffMatrix!)
        
        firstSmallMatrixView.addSubview(firstSmallView.payOffMatrix!)
        firstSmallMatrixView.addConstraintsWithFormat(format: "H:|[v0]|", views: firstSmallView.payOffMatrix!)
        firstSmallMatrixView.addConstraintsWithFormat(format: "V:|[v0]|", views: firstSmallView.payOffMatrix!)

        secondSmallMatrixView.addSubview(secondSmallView.payOffMatrix!)
        secondSmallMatrixView.addConstraintsWithFormat(format: "H:|[v0]|", views: secondSmallView.payOffMatrix!)
        secondSmallMatrixView.addConstraintsWithFormat(format: "V:|[v0]|", views: secondSmallView.payOffMatrix!)

        thirdSmallMatrixView.addSubview(thirdSmallView.payOffMatrix!)
        thirdSmallMatrixView.addConstraintsWithFormat(format: "H:|[v0]|", views: thirdSmallView.payOffMatrix!)
        thirdSmallMatrixView.addConstraintsWithFormat(format: "V:|[v0]|", views: thirdSmallView.payOffMatrix!)
        
        fourthSmallView.buttonVector?.layer.borderColor = UIColor.green.cgColor
        fourthSmallMatrixView.addSubview(fourthSmallView.payOffMatrix!)
        fourthSmallMatrixView.addConstraintsWithFormat(format: "H:|[v0]|", views: fourthSmallView.payOffMatrix!)
        fourthSmallMatrixView.addConstraintsWithFormat(format: "V:|[v0]|", views: fourthSmallView.payOffMatrix!)
    }
    
    /// Sets boundaries for the buttons on the U    I
    func setupButtonPickerView()    {
        firstSmallView.buttonVector?.numberOfButtons = numberOfRowsAndColumns
        secondBigView.buttonVector?.numberOfButtons = numberOfRowsAndColumns
        firstSmallView.buttonVector?.numberOfButtons = numberOfRowsAndColumns
        secondSmallView.buttonVector?.numberOfButtons = numberOfRowsAndColumns
        thirdSmallView.buttonVector?.numberOfButtons = numberOfRowsAndColumns
        fourthSmallView.buttonVector?.numberOfButtons = numberOfRowsAndColumns
        
        firstBigButtonView.addSubview(firstBigView.buttonVector!)
        firstBigButtonView.addConstraintsWithFormat(format: "H:|[v0]|", views: firstBigView.buttonVector!)
        firstBigButtonView.addConstraintsWithFormat(format: "V:|[v0]|", views: firstBigView.buttonVector!)
        
        secondBigButtonView.addSubview(secondBigView.buttonVector!)
        secondBigButtonView.addConstraintsWithFormat(format: "H:|[v0]|", views: secondBigView.buttonVector!)
        secondBigButtonView.addConstraintsWithFormat(format: "V:|[v0]|", views: secondBigView.buttonVector!)
        
        firstSmallButtonView.addSubview(firstSmallView.buttonVector!)
        firstSmallButtonView.addConstraintsWithFormat(format: "H:|[v0]|", views: firstSmallView.buttonVector!)
        firstSmallButtonView.addConstraintsWithFormat(format: "V:|[v0]|", views: firstSmallView.buttonVector!)
        
        secondSmallButtonView.addSubview(secondSmallView.buttonVector!)
        secondSmallButtonView.addConstraintsWithFormat(format: "H:|[v0]|", views: secondSmallView.buttonVector!)
        secondSmallButtonView.addConstraintsWithFormat(format: "V:|[v0]|", views: secondSmallView.buttonVector!)
        
        thirdSmallButtonView.addSubview(thirdSmallView.buttonVector!)
        thirdSmallButtonView.addConstraintsWithFormat(format: "H:|[v0]|", views: thirdSmallView.buttonVector!)
        thirdSmallButtonView.addConstraintsWithFormat(format: "V:|[v0]|", views: thirdSmallView.buttonVector!)
        
        fourthSmallButtonView.addSubview(fourthSmallView.buttonVector!)
        fourthSmallButtonView.addConstraintsWithFormat(format: "H:|[v0]|", views: fourthSmallView.buttonVector!)
        fourthSmallButtonView.addConstraintsWithFormat(format: "V:|[v0]|", views: fourthSmallView.buttonVector!)
    }
    
//    func checkWhoWon(playerIndex:Int)   {
//        var alertTitle = ""
//        var alertMessage = ""
//        switch playerIndex {
//        case 1:
//            if (self.singleGameInstance.result!.first! >= self.singleGameInstance.result!.last! && self.singleGameInstance.result!.first! >= self.singleGameInstance.result![1]) {
//                alertTitle = "You Won!"
//                alertMessage = "Well Played!"
//            } else  {
//                alertTitle = "You Lost!"
//                alertMessage = "Better Luck next time!"
//            }
//        case 2:
//            if (self.singleGameInstance.result![1] >= self.singleGameInstance.result!.first! && self.singleGameInstance.result![1] >= self.singleGameInstance.result!.last!) {
//                alertTitle = "You Won!"
//                alertMessage = "Well Played!"
//            } else  {
//                alertTitle = "You Lost!"
//                alertMessage = "Better Luck next time!"
//            }
//        case 3:
//            if (self.singleGameInstance.result!.last! >= self.singleGameInstance.result!.first! && self.singleGameInstance.result!.last! >= self.singleGameInstance.result![1]) {
//                alertTitle = "You Won!"
//                alertMessage = "Well Played!"
//            } else  {
//                alertTitle = "You Lost!"
//                alertMessage = "Better Luck next time!"
//            }
//        default:
//            print("ERROR IN CHECKWHOWON METHOD")
//        }
//        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
}
