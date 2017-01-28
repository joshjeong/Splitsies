//
//  ViewController.swift
//  tippy
//
//  Created by Josh Jeong on 11/30/16.
//  Copyright © 2016 JoshJeong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var billAmountLabel: UILabel!
    @IBOutlet weak var perPersonAmountLabel: UILabel!
    @IBOutlet weak var numOfWaysLabel: UILabel!
    @IBOutlet weak var decimalButton: UIButton!
    @IBOutlet weak var perPersonWrapperView: UIView!
    @IBOutlet weak var billAmountWrapperView: UIView!
    @IBOutlet weak var numOfWaysWrapperView: UIView!
    @IBOutlet weak var customTipWrapperView: UIView!
    @IBOutlet weak var customTipLabel: UILabel!
    @IBOutlet weak var tipWrapperView: UIView!
    @IBOutlet weak var summaryTotalLabel: UILabel!
    @IBOutlet weak var summarySplitLabel: UILabel!
    
    @IBOutlet weak var tipHighlightConstraint: NSLayoutConstraint!
    @IBOutlet weak var splitHighlightConstraint: NSLayoutConstraint!
    @IBOutlet weak var billHighlightConstraint: NSLayoutConstraint!
    
    
    
    
    var isFirstTimeTyping = true
    var activeLabel: UILabel!
    var activeConstraint: NSLayoutConstraint?
    var defaultVal = 0
    var tipPercentage = 0.00
    
    let messenger = Messenger()
    let customColors = CustomColors()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindTapGestures()
        
        styleNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        drawBorders()
        
        selectDefault()
        // this is where your joureny is to begin
        // remove all traces of activeHighlight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onTap(_ sender: AnyObject) {
        view.endEditing(true)
    }

    @IBAction func calculateTip(_ sender: UIButton) {
        let tipPercentageDefaults = [0.18, 0.2, 0.25]
        tipPercentage = tipPercentageDefaults[sender.tag]
        calculate()
    }
    

    func calculate() {
        let bill = Double(billAmountLabel.text!) ?? 0
        
        let tip = bill * tipPercentage
        let numOfWays = Double(numOfWaysLabel.text!) ?? 1
        let perPersonTotal = (bill + tip)/numOfWays
        
        perPersonAmountLabel.text = String(format: "$%.2f", perPersonTotal)
    }
    
    func selectInput(sender: UITapGestureRecognizer) {
        isFirstTimeTyping = true
        defaultVal = 0
        switch sender.view!.tag {
        case 1:
            didSelectBillView()
        case 2:
            didSelectSplitView()
        case 3:
            didSelectTipView()
        default:
            activeLabel = billAmountLabel
        }
    }
    
    func didSelectBillView() {
        toggleDecimalButton(str: billAmountLabel.text!)
        activeLabel = billAmountLabel
        resetViews(selectedConstraint: billHighlightConstraint)
        moveConstraintRight(selectedConstraint: billHighlightConstraint)
    }
    
    func didSelectSplitView() {
        decimalButton.isEnabled = false
        activeLabel = numOfWaysLabel
        defaultVal = 1
        resetViews(selectedConstraint: splitHighlightConstraint)
        moveConstraintRight(selectedConstraint: splitHighlightConstraint)
    }
    
    func didSelectTipView() {
        decimalButton.isEnabled = false
        activeLabel = customTipLabel
        if let customTip = customTipLabel.text {
            tipPercentage = Double(customTip)!/100.00
            calculate()
        }
        resetViews(selectedConstraint: tipHighlightConstraint)
        moveConstraintRight(selectedConstraint: tipHighlightConstraint)
    }
    
    
    func toggleDecimalButton(str: String) {
        if activeLabel == numOfWaysLabel || activeLabel == customTipLabel {
            decimalButton.isEnabled = false
            return
        }
        decimalButton.isEnabled = !str.contains(".")
    }
    
    func isMaximumFloatDigits(str: String) -> Bool {
        if let range = str.range(of: ".") {
            var digitsAfterDecimal = str.substring(from: range.upperBound)
            if digitsAfterDecimal.characters.count > 2 {
                return true
            }
        }
        
        return false
    }
    
    func calculateCustomTip(val: String) {
        if let tip = Double(val) {
            tipPercentage = tip/100.00
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if let operation = sender.titleLabel {
            if let currentVal = activeLabel.text {
                var newVal = ""
                
                if operation.text! == "0" && currentVal == "0" { return }
                
                if isFirstTimeTyping {
                    newVal = "\(operation.text!)"
                    isFirstTimeTyping = false
                } else {
                    newVal = "\(currentVal)\(operation.text!)"
                }
                
                if activeLabel == customTipLabel {
                    calculateCustomTip(val: newVal)
                }
                
                toggleDecimalButton(str: newVal)
                if isMaximumFloatDigits(str: newVal) { return }
                
                activeLabel?.text = "\(newVal)"
                calculate()
            }
        }
    }
    
    @IBAction func tapDelete(_ sender: Any) {
        if let currentVal = activeLabel.text {
            var newVal = ""
            
            if currentVal.characters.count == 1 {
                isFirstTimeTyping = true
                newVal = "\(defaultVal)"
            } else {
                let truncated = currentVal.substring(to: currentVal.index(before: currentVal.endIndex))
                newVal = truncated
            }
            
            toggleDecimalButton(str: newVal)
            activeLabel.text = "\(newVal)"
            calculate()
        }
    }

    func createTapGesture(view: UIView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.selectInput))
        view.addGestureRecognizer(tapGesture)
    }
    
    func bindTapGestures() {
        activeLabel = billAmountLabel
        createTapGesture(view: billAmountWrapperView)
        createTapGesture(view: numOfWaysWrapperView)
        createTapGesture(view: customTipWrapperView)
    }
    
    @IBAction func sendTextMessage(_ sender: UIBarButtonItem) {
        if messenger.canSendText() {
            if let amountPerPerson = perPersonAmountLabel.text {
                let messageComposeVC = messenger.configuredMessageComposeViewController(amount: amountPerPerson)
                present(messageComposeVC, animated: true, completion: nil)
            }
        } else {
            let alertController = UIAlertController(title: "Error", message: "This device is unable to send text messages", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(OKAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func styleNavBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = customColors.darkBlue()
    }
    
    func drawBottomBorder(wrapperView: UIView, color: UIColor) {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: wrapperView.frame.size.height, width: wrapperView.frame.size.width, height: 1)
        bottomBorder.backgroundColor = color.withAlphaComponent(0.2).cgColor
        wrapperView.layer.addSublayer(bottomBorder)
    }
    
    func drawBorders() {
        drawBottomBorder(wrapperView: billAmountWrapperView, color: customColors.darkBlue())
        drawBottomBorder(wrapperView: numOfWaysWrapperView, color: customColors.turquoise())
        drawBottomBorder(wrapperView: tipWrapperView, color: customColors.salmon())
    }
    
    func selectDefault() {
        moveConstraintRight(selectedConstraint: billHighlightConstraint)
    }
    
    func moveConstraintRight(selectedConstraint: NSLayoutConstraint) {
        if selectedConstraint == activeConstraint {
            return
        }
        selectedConstraint.constant = 0
        animateConstraint()
        activeConstraint = selectedConstraint
    }
    
    func resetViews(selectedConstraint: NSLayoutConstraint) {
        if selectedConstraint == activeConstraint {
            return
        }
        moveConstraintLeft(selectedConstraint: activeConstraint!)
    }
    
    func moveConstraintLeft(selectedConstraint: NSLayoutConstraint) {
        selectedConstraint.constant = -10
        animateConstraint()
    }
    
    
    func animateConstraint() {
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
}
