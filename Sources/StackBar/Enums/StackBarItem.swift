//
//  StackBarItem.swift
//
//
//  Created by Antoine Barré on 8/23/22.
//

import Foundation
import UIKit

public enum StackBarItem: Hashable {
    /// The tag parameter can be used to identify the view later using `customView(withTag:)` and optionally replace it with an updated one.
    case customView(item: UIView, withTag: Int = .zero)
    /// On iOS 15.0+, you can update the primary button's configuration directly with the `primaryButton` property.
    case primaryButton(item: UIButton)
    /// On iOS 15.0+, you can update the secondary button's configuration directly with the `secondaryButton` property.
    case secondaryButton(item: UIButton)
}
