//
//  StackBarController+UIScrollView.swift
//
//
//  Created by Antoine Barré on 8/22/22.
//

import Foundation
import UIKit

extension StackBarController {

    func configureAnimator() {
        animator.isInterruptible = true
        animator.pausesOnCompletion = true
        animator.addAnimations { [unowned self] in
            if let customBackgroundViewAnimations = customBackgroundViewAnimationsProvider?(backgroundView) {
                customBackgroundViewAnimations
            }
            else {
                backgroundVisualEffectView.effect = UIBlurEffect(style: .systemUltraThinMaterial)
            }
        }
    }

    func resetAnimator() {
        guard case .active = animator.state else {
            return
        }
        animator.stopAnimation(true)
        animator.finishAnimation(at: .current)
    }

    func observedScrollViewDidScroll(_ scrollView: UIScrollView?) {
        guard let scrollView = scrollView else {
            return
        }

        animator.fractionComplete = .fractionComplete(in: scrollView, insetBy: scrollView.safeAreaInsets.bottom)
    }
}
