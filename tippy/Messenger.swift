//
//  Messenger.swift
//  tippy
//
//  Created by Josh Jeong on 1/22/17.
//  Copyright © 2017 JoshJeong. All rights reserved.
//

import UIKit
import MessageUI

class Messenger: NSObject, MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController!, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func configuredMessageComposeViewController(amount: String) -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        let dateStr = formatter.string(from: date)
        messageComposeVC.messageComposeDelegate = self
        messageComposeVC.body = "(\(dateStr)) Requesting \(amount) for: "
        return messageComposeVC
    }
}
