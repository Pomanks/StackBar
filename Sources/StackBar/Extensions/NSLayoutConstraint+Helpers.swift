//
//  NSLayoutConstraint+Helpers.swift
//
//
//  Created by Antoine Barré on 8/23/22.
//

import Foundation
import UIKit

extension NSLayoutConstraint {

    func layoutPriority(_ priority: UILayoutPriority) -> Self {
        let constraint = self

        constraint.priority = priority

        return constraint
    }

    func layoutPriority(rawValue: Float) -> Self {
        let constraint = self

        constraint.priority = UILayoutPriority(rawValue: rawValue)

        return constraint
    }
}
