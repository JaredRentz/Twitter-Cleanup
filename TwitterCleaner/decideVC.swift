//
//  decideVC.swift
//  FolloworNah
//
//  Created by Jared Rentz on 2/16/16.
//  Copyright © 2016 ioTDemon. All rights reserved.
//

import UIKit
import Social
import Accounts

class decideVC: UIViewController {
    
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    var twitteruser = [TwitterUsers]()
    var friendCount = Int()
    
    
    @IBOutlet weak var friendCountLabel: UILabel!
    var account = ACAccount()
    
    override func viewDidAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        getFollowingCount()
       
        getFriendsList()
       
    }


    
    func getFollowingCount () {
        
        // API call
        
        let url = NSURL(string: "https://api.twitter.com/1.1/account/verify_credentials.json")
        let verifyAccountRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: nil)
        
        verifyAccountRequest.account = self.account
        verifyAccountRequest.performRequestWithHandler { (data, response, error) -> Void in
            
            if error == nil {
                
                do {
                    let responseJSONDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! [String: AnyObject]
                   
                    
                    
                     self.friendCount = responseJSONDictionary["friends_count"] as! Int
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.friendCountLabel.text = "You have \(self.friendCount) friends on Twitter"
                    })
                    
                    
                } catch {}
                
                
            } else {
    
                self.Alert("Uh-Oh", message: "I'm sorry we could not retrieve your friends")
            }
        }
        
    }
    
  
    func getFriendsList () {
       let url = NSURL(string: "https://api.twitter.com/1.1/friends/ids.json")
        let verifyFriendsRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: nil)
        
        verifyFriendsRequest.account = self.account
        verifyFriendsRequest.performRequestWithHandler { (data, response, error) -> Void in
            
            if error == nil {
                
                do {
                    
                    let responseJSONDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! [String: AnyObject]
                    
                        let ids = responseJSONDictionary["ids"] as! [Int]
                   
                   
                    
                    self.getHydratedUsers(ids)
                    
                    
                    
                    
                } catch{}
                
            }
        }
        
    }
   
    func getHydratedUsers(twitterIds: [Int]) {
    
        var hundredIds = [String]()
        var count = 1
        
        if !twitterIds.isEmpty {
        
        for twitter in twitterIds {
            if count <= 100 {
              hundredIds.append("\(twitter)")
                
                count++
                
                if count == 95 {
                    count = 0
                }
                
            } else {
                break
            }
           

            
        }
        
        let url = NSURL(string: "https://api.twitter.com/1.1/users/lookup.json")
        
        let gethydratedRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: ["user_id":hundredIds ])

        
        gethydratedRequest.account = self.account
        gethydratedRequest.performRequestWithHandler { (data, response, error) -> Void in
            
            if error == nil {
                
                do {
                    
                    let responseJSONArray = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! [AnyObject!]
                    
                    
                    for user in responseJSONArray {
                        
                        let userDictionary = user as! [String : AnyObject]
                        let theUser = TwitterUsers()
                        
                        theUser.name = userDictionary["name"] as! String
                        theUser.image = userDictionary["profile_image_url_https"] as! String
                        theUser.backgroundImage = userDictionary["profile_background_image_url_https"] as! String
                        theUser.userId = userDictionary["id"] as! Int
                        
                        self.twitteruser.append(theUser)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                          
                            self.showCurrentUser()
                        })
                        
                    }
                    
                    
                    
                } catch {}
                
            } else {
                self.Alert("Sorry", message: "I couldn't get your friends")
            }
        }

        
        } else {
            Alert("Uh Oh...", message: "You have no friends")
        }
    }
    
    func showCurrentUser () {
        
       
            
        
           let user = self.twitteruser.first
        
        
            self.usernameLabel.text = user?.name
        
        
        // profile Image
        
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: (user?.image)! )!) { (data, response, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let image = UIImage(data: data!)
                self.profileImage.image = image
            })
        } .resume()
        
    }
    
    
// Keep or Delete friends Buttons
    
    @IBAction func onUnfollowPressed(sender: UIButton) {
        if twitteruser.count > 1 {
        removeUser()
        friendCount--
        friendCountLabel.text = "You have \(friendCount) friends on Twitter"
        
        twitteruser.removeAtIndex(0)
        showCurrentUser()
        }
    }

    @IBAction func onKeepFollowingPressed(sender: UIButton) {
        
        if twitteruser.count > 1 {
            
            twitteruser.removeAtIndex(0)
            showCurrentUser()
            
        } else {
            Alert("Whoa Whoa Whoa", message: "You've reached the end!")
        }
        
    }
    
// Remove user from Friendlist
    
    func removeUser () {
        
        if self.twitteruser.first != nil {
            
        
       let user = self.twitteruser.first!
        
        let url = NSURL(string: "https://api.twitter.com/1.1/friendships/destroy.json")
        
        let verifyAccountRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, URL: url, parameters: ["user_id": "\(user.userId)"])
        
            print(user.userId)
            
        verifyAccountRequest.account = self.account
        verifyAccountRequest.performRequestWithHandler { (data, response, error) -> Void in
          
            if error == nil {
                
                do {
                    
                    let responseJSONDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! [String : AnyObject!]
                    print(responseJSONDictionary)
                    
                } catch {
                
                }
                
            } else {
                self.Alert("Sorry", message: "I couldn't get your friends")
            }
        }
        }
    }
    
    func Alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }


}
