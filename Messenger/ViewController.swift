//
//  ViewController.swift
//  Messenger
//
//  Created by Admin on 25.11.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit
import UserNotifications

var imessenger = iMessenger()
var userList : [String]?

class ViewController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(createNotification), name: NSNotification.Name(rawValue: "notification"), object: nil)
    }
    
    
    func createNotification() {
        //create notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let content = UNMutableNotificationContent()
        let message = (imessenger?.getNewMessage())! as NSArray as? [String]
        content.title = (message?[0])!
        content.body = (message?[1])!
        
        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in if let error = error {
            print("Uh no we had error: \(error), \(error.localizedDescription)")
            }
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func enterButton(_ sender: AnyObject) {
        imessenger?.connect(loginTextField.text, and: passwordTextField.text)
    }

}

extension ViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
}
