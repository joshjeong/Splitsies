//
//  ViewController.swift
//  tippy
//
//  Created by Josh Jeong on 11/30/16.
//  Copyright © 2016 JoshJeong. All rights reserved.
//

import UIKit
import AudioToolbox
class ViewController: UIViewController {

    // Values that are updated
    @IBOutlet weak var billAmountLabel: UILabel!
    @IBOutlet weak var perPersonAmountLabel: UILabel!
    @IBOutlet weak var splitLabel: UILabel!
    @IBOutlet weak var customTipLabel: UILabel!
    @IBOutlet weak var billSummaryLabel: UILabel!
    @IBOutlet weak var tipSummaryLabel: UILabel!
    @IBOutlet weak var summaryTotalLabel: UILabel!
    
    @IBOutlet weak var billLabelView: UIView!
    @IBOutlet weak var tipLabelView: UIView!
    @IBOutlet weak var splitLabelView: UIView!
    
    @IBOutlet weak var decimalButton: UIButton!
    @IBOutlet weak var billCurrencySymbol: UILabel!
    
    // Stack container views
    @IBOutlet weak var perPersonWrapperView: UIView!
    @IBOutlet weak var billAmountWrapperView: UIView!
    @IBOutlet weak var splitWrapperView: UIView!
    @IBOutlet weak var customTipWrapperView: UIView!
    @IBOutlet weak var tipWrapperView: UIView!
    
    
    @IBOutlet var tipButtons: [UIButton]!
    
    // Adjust these constraints to show highlighted row
    @IBOutlet weak var tipHighlightConstraint: NSLayoutConstraint!
    @IBOutlet weak var splitHighlightConstraint: NSLayoutConstraint!
    @IBOutlet weak var billHighlightConstraint: NSLayoutConstraint!
    
    var activeLabel: UILabel!
    var activeConstraint: NSLayoutConstraint?
    var activeLabelView: UIView?
    var localCurrencySymbol = "$"
    var isFirstTimeTyping = true
    var defaultVal = 0
    var tipPercentage = 0.00
    var total = 0.00
    
    
    let messenger = Messenger()
    let customColors = CustomColors()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindTapGestures()
        styleNavBar()
        setLocalCurrency()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let statusBar = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0))
        statusBar.backgroundColor = customColors.lightBlue()
        view.addSubview(statusBar)
    }
    override func viewDidAppear(_ animated: Bool) {
        drawBorders()
        activeLabel = billAmountLabel
        activeLabelView = billLabelView
        activeConstraint = billHighlightConstraint
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onTap(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    func setLocalCurrency() {
        var locale = Locale.current
        if let symbol = locale.currencySymbol {
            localCurrencySymbol = symbol
            billCurrencySymbol.text = "\(symbol)"
            calculate()
        }
    }

    @IBAction func calculateTip(_ sender: UIButton) {
        let tipPercentageDefaults = [0.15, 0.18, 0.2]
        let newTipPercentage = tipPercentageDefaults[sender.tag]
        isFirstTimeTyping = true
        defaultVal = 0
        resetButtonStyling()
        resetHighlightLeadingContraint(selectedConstraint: tipHighlightConstraint)
        activeLabel = customTipLabel
        moveConstraintRight(selectedConstraint: tipHighlightConstraint)
        
        if (tipPercentage == newTipPercentage) {
            tipPercentage = 0
            customTipLabel.text = "+"
            calculate()
            return
        }
        
        tipPercentage = newTipPercentage
        resetLabelView(selectedLabelView: tipLabelView)
        moveLabelViewRight(selectedLabelView: tipLabelView)
        sender.backgroundColor = customColors.salmon()
        sender.setTitleColor(UIColor.white, for: .normal)
        calculate()
    }
    
    func resetButtonStyling() {
        for button in tipButtons {
            button.backgroundColor = customColors.salmon().withAlphaComponent(0.1)
            button.setTitleColor(customColors.salmon(), for: .normal)
        }
        customTipLabel.backgroundColor = customColors.salmon().withAlphaComponent(0.1)
        customTipLabel.textColor = customColors.salmon()
        if let customTip = customTipLabel.text {
            if customTip == "0" {
                customTipLabel.text = "+"
            }
        }
    }
    

    func calculate() {
        let bill = Double(billAmountLabel.text!) ?? 0
        
        let tip = bill * tipPercentage
        let numOfWays = Double(splitLabel.text!) ?? 1
        total = bill + tip
        let perPersonTotal = (total)/numOfWays
        
        billSummaryLabel.text = String(format: "\(localCurrencySymbol)%.2f", bill)
        tipSummaryLabel.text = String(format: "\(localCurrencySymbol)%.2f", tip)
        summaryTotalLabel.text = String(format: "\(localCurrencySymbol)%.2f", total)
        perPersonAmountLabel.text = String(format: "\(localCurrencySymbol)%.2f", perPersonTotal)
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
        resetHighlightLeadingContraint(selectedConstraint: billHighlightConstraint)
        moveConstraintRight(selectedConstraint: billHighlightConstraint)
        resetLabelView(selectedLabelView: billLabelView)
        moveLabelViewRight(selectedLabelView: billLabelView)
    }
    
    func didSelectSplitView() {
        decimalButton.isEnabled = false
        activeLabel = splitLabel
        defaultVal = 1
        resetHighlightLeadingContraint(selectedConstraint: splitHighlightConstraint)
        moveConstraintRight(selectedConstraint: splitHighlightConstraint)
        resetLabelView(selectedLabelView: splitLabelView)
        moveLabelViewRight(selectedLabelView: splitLabelView)
    }
    
    func didSelectTipView() {
        decimalButton.isEnabled = false
        activeLabel = customTipLabel
        resetButtonStyling()
        activeLabel.backgroundColor = customColors.salmon()
        activeLabel.textColor = UIColor.white
        if let customTip = customTipLabel.text {
            if customTip != "+" {
                tipPercentage = Double(customTip)!/100.00
                calculate()
            }
        }
        resetHighlightLeadingContraint(selectedConstraint: tipHighlightConstraint)
        moveConstraintRight(selectedConstraint: tipHighlightConstraint)
        resetLabelView(selectedLabelView: tipLabelView)
        moveLabelViewRight(selectedLabelView: tipLabelView)
    }
    
    func toggleOnCustomTipButton() {
        resetButtonStyling()
        customTipLabel.backgroundColor = customColors.salmon()
        customTipLabel.textColor = UIColor.white
    }
    
    func toggleDecimalButton(str: String) {
        if activeLabel == splitLabel || activeLabel == customTipLabel {
            decimalButton.isEnabled = false
            return
        }
        decimalButton.isEnabled = !str.contains(".")
    }
    
    func isMaximumFloatDigits(str: String) -> Bool {
        if activeLabelView == customTipLabel && Int(str)! > 100 { return false }
        
        
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
        AudioServicesPlaySystemSound(1104)
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
                    toggleOnCustomTipButton()
                }
                
                toggleDecimalButton(str: newVal)
                if isMaximumFloatDigits(str: newVal) { return }
                
                activeLabel?.text = "\(newVal)"
                calculate()
            }
        }
    }
    
    @IBAction func tapDelete(_ sender: Any) {
        AudioServicesPlaySystemSound(1155)
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
            
            if activeLabel == customTipLabel {
                calculateCustomTip(val: newVal)
            }
            
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
        createTapGesture(view: splitWrapperView)
        createTapGesture(view: customTipWrapperView)
    }
    
    @IBAction func sendTextMessage(_ sender: UIButton) {
        if messenger.canSendText() {
            if let amountPerPerson = perPersonAmountLabel.text {
                let messageComposeVC = messenger.configuredMessageComposeViewController(amount: amountPerPerson)
                present(messageComposeVC, animated: true, completion: nil)
            }
        } else {
            presentAlertController(title: "Oops!", message: "This device is unable to send text messages 😣")
        }
    }
    
    func presentAlertController(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
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
        drawBottomBorder(wrapperView: splitWrapperView, color: customColors.turquoise())
        drawBottomBorder(wrapperView: tipWrapperView, color: customColors.salmon())
    }
    
    func selectDefault() {
        moveConstraintRight(selectedConstraint: billHighlightConstraint)
        moveLabelViewRight(selectedLabelView: billLabelView)
    }
    
    func moveConstraintRight(selectedConstraint: NSLayoutConstraint) {
        if selectedConstraint == activeConstraint {
            return
        }
        selectedConstraint.constant = 0
        animateConstraint()
        activeConstraint = selectedConstraint
    }
    
    func resetHighlightLeadingContraint(selectedConstraint: NSLayoutConstraint) {
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
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func moveLabelViewRight(selectedLabelView: UIView) {
        if selectedLabelView == activeLabelView {
            return
        }
        UILabel.animate(withDuration: 0.2, animations: {
            selectedLabelView.center.x += 10
        })
        activeLabelView = selectedLabelView
    }
    
    func resetLabelView(selectedLabelView: UIView) {
        if selectedLabelView == activeLabelView {
            return
        }
        moveLabelViewLeft(selectedLabelView: activeLabelView!)
    }
    
    func moveLabelViewLeft(selectedLabelView: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            selectedLabelView.center.x -= 10
        })
    }
}
