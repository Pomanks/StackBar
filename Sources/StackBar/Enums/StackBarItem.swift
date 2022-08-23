//
//  StackBarItem.swift
//
//
//  Created by Antoine Barré on 8/23/22.
//

import Foundation
import UIKit

public enum StackBarItem {
    /// The tag parameter can be used to identify the view later using `customView(withTag:)`.
    case custom(view: UIView, withTag: Int = .zero)
    case primary(button: UIButton)
    case secondary(button: UIButton)
}
