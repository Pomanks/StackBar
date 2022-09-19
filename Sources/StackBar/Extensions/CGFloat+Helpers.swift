//
//  CGFloat+Helpers.swift
//
//
//  Created by Antoine Barré on 8/23/22.
//

import Foundation
import UIKit

extension CGFloat {

    static let iPhoneProMaxGreatestPointsWidth: CGFloat = 430.0

    static func fractionComplete(in scrollView: UIScrollView, insetBy height: CGFloat) -> CGFloat {
        let threshold = scrollView.bounds.height - scrollView.contentSize.height
        let verticalScrolledOffset = height - scrollView.contentOffset.y

        return verticalScrolledOffset > threshold ? 1.0 : .zero
    }
}
