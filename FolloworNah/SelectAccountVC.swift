//
//  SelectAccountVC.swift
//  FolloworNah
//
//  Created by Jared Rentz on 2/16/16.
//  Copyright © 2016 ioTDemon. All rights reserved.
//

import UIKit
import Accounts
import Social

class SelectAccountVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tableview: UITableView!
    var accounts = [ACAccount] ()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableview.delegate = self
        tableview.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        let account = self.accounts[indexPath.row]
       
        cell.textLabel?.text = account.username
        
        return cell    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let account = self.accounts[indexPath.row]
        
        let navigationVC = self.presentingViewController as! UINavigationController
        let signInVC = navigationVC.viewControllers[0] as! SignInVC
        self.dismissViewControllerAnimated(true) { () -> Void in
            signInVC.moveToViewControllerWithAccount(account)
        }
        
    }
    
    

  }
