//
//  UserViewController.swift
//  Messenger
//
//  Created by Admin on 30.11.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit

var selectedUser: String?

class UserViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userList = (imessenger?.getActiveUsers())! as NSArray as? [String]
    }
    @IBAction func RefreshUserList(_ sender: AnyObject) {
        userList = (imessenger?.getActiveUsers())! as NSArray as? [String]
        // refresh view???????
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (userList?.count)!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = userList![indexPath.section]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = userList![indexPath.section]
    }
}
