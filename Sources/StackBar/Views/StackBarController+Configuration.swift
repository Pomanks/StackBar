//
//  StackBarController+Configuration.swift
//
//
//  Created by Antoine Barré on 8/22/22.
//

import Foundation
import UIKit

public extension StackBarController {

    ///
    /// Replaces the stack items currently managed by the stack bar with the specified items.
    ///
    /// - Parameters:
    ///    - items: The `StackBarItem` objects to place in the stack.
    ///
    func setItems(_ items: [StackBarItem], animated: Bool = false) {
        configureStackBar(items: items, animated: animated)
    }

    ///
    /// Replaces the stack items currently managed by the stack bar with the specified items and manages the initial state of the secondary button.
    ///
    /// - Parameters:
    ///    - items: The `StackBarItem` objects to place in the stack.
    ///    - preferringSecondaryButtonHidden:
    ///
    func setItems(_ items: [StackBarItem], preferringSecondaryButtonHidden: Bool = false, animated: Bool = false) {
        setItems(items, animated: animated)

        prefersSecondaryButtonHidden = preferringSecondaryButtonHidden
    }

    func setStackBarHidden(_ hidden: Bool, animated: Bool) {
        let duration: TimeInterval = animated ? 0.3 : .zero
        let alpha = hidden ? .zero : 1.0

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: .zero) { [weak self] in
            self?.backgroundView.alpha = alpha

            if !hidden {
                self?.configureAdditionalSafeAreaInsets()
            }
            else {
                self?.rootViewController.additionalSafeAreaInsets.bottom = .zero
            }
        }
    }

    ///
    /// Use this method to retrieve and update any custom view from the stack bar.
    ///
    /// - Parameters:
    ///    - tag: An integer that you previously used in a stack bar item with `custom(view:withTag:)`.
    ///
    ///    - Note: You must have configured the stack bar item with a tag and its value must be other than `0`.
    ///
    func customView(withTag tag: Int) -> UIView? {
        guard tag != .zero else {
            return nil
        }
        return stackBar.arrangedSubviews.first(where: { $0.tag == tag })
    }
}

// MARK: - Helpers

private extension StackBarController {

    func configureStackBar(items: [StackBarItem], animated: Bool) {
        let duration: TimeInterval = animated ? 0.3 : .zero

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: .zero) { [weak self] in
            self?.configureStackBar(with: items)

        } completion: { [weak self] _ in
            self?.configureAdditionalSafeAreaInsets()
        }
        animator.fractionComplete = items.isEmpty ? 1.0 : .zero
    }

    func configureStackBar(with items: [StackBarItem]) {
        stackBar.arrangedSubviews.forEach {
            stackBar.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for item in items {
            switch item {
            case let .customView(item: view, withTag: tag):
                view.tag = tag

                stackBar.addArrangedSubview(view)

            case let .primaryButton(item: button):
                stackBar.addArrangedSubview(button)
                primaryButton = button

            case let .secondaryButton(item: button):
                stackBar.addArrangedSubview(button)
                secondaryButton = button
            }
        }
        self.items = items
    }
}
