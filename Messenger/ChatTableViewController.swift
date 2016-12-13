//
//  ChatTableViewController.swift
//  Messenger
//
//  Created by Admin on 10.12.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit

var messages: [String]?

class ChatTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        self.textField.delegate = self
        navigationItem.title = selectedUser
        messages = (imessenger?.getAllMessagesIds(selectedUser))! as NSArray as? [String]
        //refresh()
        // refresh if new message for this user
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name("reload"), object: nil)
    
        // keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func reload(notification: NSNotification) {
        refresh()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    // hide keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if(textField.text != "") {
            imessenger?.sendMessage(selectedUser, with_message: textField.text)
            textField.text = ""
            refresh()
        }
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        messages = (imessenger?.getAllMessagesIds(selectedUser))! as NSArray as? [String]
        tableView.reloadData()
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!

    @IBAction func sendMessage(_ sender: AnyObject) {
        if(textField.text != "") {
            imessenger?.sendMessage(selectedUser, with_message: textField.text)
            textField.text = ""
        }
        refresh()
    }
    
    // table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return (messages?.count)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! MyCustomViewCell
        // message text
        cell.messageText.text = imessenger?.getDataForMessageId(messages?[indexPath.section])
        // message date
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd.MM.yyyy hh:mm"
        cell.date.text = dateFormater.string(from: (imessenger?.getDateForMessageId(messages?[indexPath.section]))!)
        // message status
        cell.status.text = imessenger?.getStatusForMessageId(messages?[indexPath.section])
        // background color
        if(imessenger?.getWhoseForMessageId(messages?[indexPath.section]))! {
            cell.backgroundColor = UIColor.blue
        } else {
            cell.backgroundColor = UIColor.green
        }
        return cell
    }
}
