//
//  SettingsViewController.swift
//  tippy
//
//  Created by Josh Jeong on 12/5/16.
//  Copyright © 2016 JoshJeong. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    let defaults = UserDefaults.standard
    var numOfPeople = 1

    @IBOutlet weak var numOfPeopleField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(defaults.integer(forKey: "num_of_people"))
        numOfPeople = defaults.integer(forKey: "num_of_people") ?? 1
        print(numOfPeople)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        defaults.set(numOfPeople, forKey: "num_of_people")
        defaults.synchronize()
    }
    
    @IBAction func numOfPeopleDidChange(_ textField: UITextField) {
        if let text = textField.text {
            if text != "0" {
                numOfPeople = Int(text)!
            }
        }
    }
}
