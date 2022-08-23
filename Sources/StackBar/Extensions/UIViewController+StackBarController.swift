//
//  UIViewController+StackBarController.swift
//
//
//  Created by Antoine Barré on 8/23/22.
//

import Foundation
import UIKit

public extension UIViewController {

    ///
    /// The nearest ancestor in the view controller hierarchy that is a stackBar controller.
    ///
    /// If the view controller or one of its ancestors is a child of a stackBar controller, this property contains the owning stackBar controller. This property is nil if the view controller is not embedded inside any stackBar controller.
    ///
    var stackBarController: StackBarController? {
        var parent: UIViewController? = self

        while parent != nil {
            if let stackBarController = parent as? StackBarController {
                return stackBarController
            }
            parent = parent?.parent
        }
        return nil
    }
}
