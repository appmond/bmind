//
//  DBFunctions.swift
//  gametheory
//
//  Created by Edmond Osmani on 20/01/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import Foundation
import UIKit

class  DBFunctions  {
    
    let username = "admin"
    let password = "admin1234"
    
    //All database post requests
    public func dbPostRequest(postString : String!, urlPath: String!, completionHandler:@escaping (NSDictionary) -> Void)  {
        
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        //created NSURL
        let requestURL = NSURL(string: urlPath)!
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL as URL)
        
        //setting the method to post
        request.httpMethod = "POST"
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        //adding the parameters to request body
        request.httpBody = postString.data(using: .utf8)
        
        //creating a task to send the post request
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil{
                print("error is \(error)")
                return;
            }
            
            do {
                //converting resonse to NSDictionary
                let myJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                DispatchQueue.main.async {
                    completionHandler(myJSON)
                }
            } catch {
                print(error)
            }
        }
        //executing the task
        task.resume()
    }
    
    //All database post requests
    public func dbGetRequest(urlPath: String!, completionHandler: @escaping ([[String:Any]]) -> ())  {
        
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        //created NSURL
        let requestURL = NSURL(string: urlPath)!
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL as URL)
        
        //setting the method to post
        request.httpMethod = "GET"
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        //creating a task to send the post request
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil{
                print("error is \(error)")
                return;
            }
            
            do {
                //converting resonse to NSDictionary
                let myJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [[String:Any]]
                DispatchQueue.main.async {
                    completionHandler(myJSON)
                }
            } catch {
                print(error)
            }
        }
        //executing the task
        task.resume()
    }
    
    
    //All database post requests
    public func dbGetDictRequest(urlPath: String!, completionHandler: @escaping ([String:Any]) -> ())  {
        
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        //created NSURL
        let requestURL = NSURL(string: urlPath)!
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL as URL)
        
        //setting the method to post
        request.httpMethod = "GET"
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        //creating a task to send the post request
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil{
                print("error is \(error)")
                return;
            }
            
            do {
                //converting resonse to NSDictionary
                let myJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any]
                DispatchQueue.main.async {
                    completionHandler(myJSON)
                }
            } catch {
                print(error)
            }
        }
        //executing the task
        task.resume()
    }
    
    public func downloadImage(urlPath: String, completion: @escaping (_ theImage: UIImage?, _ error: NSError?) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {

        let requestURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(url: requestURL as URL)
        request.httpMethod = "GET"
        var resultImage:UIImage?
        
        //creating a task to send the post request
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
    
            if error != nil {
                print("error is \(error)")
                return;
            }
    
            if let data = data {
                resultImage = UIImage(data: data)
            }
            completion(resultImage, error as NSError?)
        }
        //executing the task
        task.resume()
        }
    }
    
    public func dbPostJSONRequest(postJSON : [String:Any]!, urlPath: String!, completionHandler:@escaping ([String:Any]) -> Void)  {
        
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        let jsonData = try? JSONSerialization.data(withJSONObject: postJSON, options: .prettyPrinted)
        
        //created NSURL
        let requestURL = NSURL(string: urlPath)!
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL as URL)
        
        //setting the method to post
        request.httpMethod = "POST"
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //adding the parameters to request body
        request.httpBody = jsonData
        
        //creating a task to send the post request
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil{
                print("error is \(error)")
                return;
            }
            
            do {
                //converting resonse to NSDictionary
                let myJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any]
                DispatchQueue.main.async {
                    completionHandler(myJSON)
                }
            } catch {
                print(error)
            }
        }
        //executing the task
        task.resume()
    }
    
    //All database post requests
    public func dbGetIntegerRequest(urlPath: String!, completionHandler: @escaping (String) -> ())  {
        DispatchQueue.global(qos: .userInitiated).async {
        
        //created NSURL
        let requestURL = NSURL(string: urlPath)!
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL as URL)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            if let data = data,
                let html = String(data: data, encoding: String.Encoding.utf8) {
                DispatchQueue.main.async {
                    completionHandler(html)
                }
            }
        }
        task.resume()
        }
    }
}
