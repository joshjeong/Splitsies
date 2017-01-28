//
//  CalculatorRow.swift
//  tippy
//
//  Created by Josh Jeong on 1/27/17.
//  Copyright © 2017 JoshJeong. All rights reserved.
//

import UIKit

struct CalculatorRow {
    let inputLabel: UILabel
    let highlightLeadingConstraint: NSLayoutConstraint
    let titleLabel: UILabel
    
    init(inputLabel: UILabel, highlightLeadingConstraint: NSLayoutConstraint, titleLabel: UILabel) {
        self.inputLabel = inputLabel
        self.highlightLeadingConstraint = highlightLeadingConstraint
        self.titleLabel = titleLabel
    }
}
