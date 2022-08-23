//
//  StackBarController+Configuration.swift
//
//
//  Created by Antoine Barré on 8/22/22.
//

import Foundation
import UIKit

public typealias StackBarButtonItem = UIButton

public extension StackBarController {

    ///
    /// Replaces the stack items currently managed by the stack bar with the specified items.
    ///
    /// - Parameters:
    ///    - items: The `StackBarItem` objects to place in the stack.
    ///
    func setItems(_ items: [StackBarItem], animated: Bool = true) {
        configureStackBar(items: items, animated: animated)
    }

    /// - Parameters:
    ///    - tag: An integer that you previously used in a stack bar item with `custom(view:withTag:)`.
    ///
    ///    - Note: `0` must not be used as a value.
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
        let duration: TimeInterval = stackBar.arrangedSubviews.isEmpty ? .zero : 0.3

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: .zero) { [weak self] in
            self?.configureStackBar(with: items)

        } completion: { [weak self] _ in
            let backgroundHeight = self?.backgroundView.bounds.height ?? .zero

            self?.rootViewController.additionalSafeAreaInsets.bottom = backgroundHeight
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
            case let .custom(view: view, withTag: tag):
                view.tag = tag

                stackBar.addArrangedSubview(view)

            case let .primary(button: button):
                stackBar.addArrangedSubview(button)
                primaryButton = button

            case let .secondary(button: button):
                stackBar.addArrangedSubview(button)
                secondaryButton = button
            }
        }
        self.items = items
    }
}
