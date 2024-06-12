//
//  WelcomeViewController.swift
//  gametheory
//
//  Created by Edmond Osmani on 20/01/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    var dbFunctions = DBFunctions()
    var gameGroups = [GameGroup]()
    var imageUrl = [String]()
    var counter = 0
    var highScore = ""
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    @IBOutlet weak var playButton: UIButton!
    
    ///When User clicks on the PLAY ONLINE button, the game groups from the server are called via a http-request
    @IBAction func playOnlineButton(_ sender: UIButton) {
        playButton.isUserInteractionEnabled = false
        self.spinnerView.startAnimating()
        self.dbFunctions.dbGetRequest(urlPath: URLVariables.SERVER_STRING_URL+"groups", completionHandler: {
                dictionaryObj in
            if dictionaryObj.count != 0 {
                for gamegroup in dictionaryObj  {
                    let singleGameGroup = GameGroup()
                    let tmpIcon = gamegroup["icon"] as! String
                    let tmpImageUrl = URLVariables.SERVER_STRING_URL+tmpIcon
                    self.imageUrl.append(tmpImageUrl)
                    singleGameGroup.retrieveGameGroups(gamegroup: gamegroup)
                    self.gameGroups.append(singleGameGroup)
                }
                self.getIconImages()
                self.performSegue(withIdentifier: "toNavController", sender: self)
            } else	{
                let errorAlert = UIAlertController(title:"No Gamegroups",message:"Dismiss", preferredStyle:.alert)
                errorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        })
    }
    
    //Helper function, obtains images from the game-groups
    func getIconImages()    {
        let group1 = DispatchGroup()
            group1.enter()
            self.dbFunctions.downloadImage(urlPath: imageUrl[counter], completion: { retrievedImage in
                self.gameGroups[self.counter].iconImage = retrievedImage.0!
                group1.leave()
            })
            let result = group1.wait(timeout: DispatchTime.distantFuture)
            if result == .success   {
                self.counter += 1
                if(counter < imageUrl.count)    {
                    getIconImages()
                }
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Submits obtained gamegroups to the destination viewcontroller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! UINavigationController
        let gameGroupsVC = destinationVC.childViewControllers.first as! GameTypesViewController
        if(gameGroupsVC.gameGroups?.count == nil)  {
            gameGroupsVC.gameGroups = self.gameGroups
        }
        self.spinnerView.stopAnimating()
        playButton.isUserInteractionEnabled = false
    }
}
