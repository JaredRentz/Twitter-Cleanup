//
//  ViewController.swift
//  FolloworNah
//
//  Created by Jared Rentz on 2/16/16.
//  Copyright © 2016 ioTDemon. All rights reserved.
//

import UIKit
import Accounts
import Social


class SignInVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationController?.navigationBarHidden = true
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signInTapped(sender: UIButton) {
        
        let account = ACAccountStore()
        
        let accountTypeTwitter = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        account.requestAccessToAccountsWithType(accountTypeTwitter, options: nil) { (granted, error) -> Void in
            
            if granted {
                // check for multiple accounts.
                let allAccounts = account.accountsWithAccountType(accountTypeTwitter)
                if allAccounts.count <= 0 {
                    self.Alert("You have no account", message: "Home > Settings > Twitter ")
                } else {
                     if allAccounts.count == 1 {
                        // use it
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                           self.performSegueWithIdentifier("decidesegue", sender: allAccounts.first)
                        })
                        
                } else {
                        
                    if allAccounts.count > 1 {
                            // Ask which account they want to use.
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.performSegueWithIdentifier("chooseaccount", sender: allAccounts)
                        })
                        
                        
                        }
                    }
                }
                
                
            } else {
               self.Alert("To login you will need to change your access permission", message: "Home > Settings > Privacy > Twitter > Follow or Nah")
            }
        }
        
    }
    
    func Alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chooseaccount" {
             let selectvc = segue.destinationViewController as! SelectAccountVC
                selectvc.accounts = sender as! [ACAccount]
        }
        if segue.identifier == "decidesegue" {
            let decidevc = segue.destinationViewController as! decideVC
            decidevc.account = sender as! ACAccount
        }
    }
    
    func moveToViewControllerWithAccount(account: ACAccount) {
        
      self.performSegueWithIdentifier("decidesegue", sender: account)
        
    }

}

