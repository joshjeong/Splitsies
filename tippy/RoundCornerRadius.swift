//
//  RoundCornerRadius.swift
//  tippy
//
//  Created by Josh Jeong on 1/24/17.
//  Copyright © 2017 JoshJeong. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 0.5 * bounds.size.width
        clipsToBounds = true
    }
}

class RoundLabel: UILabel {
    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 0.5 * bounds.size.width
        clipsToBounds = true
    }
}
