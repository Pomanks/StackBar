//
//  StackBarController.swift
//
//
//  Created by Antoine Barré on 8/21/22.
//

import Combine
import Foundation
import UIKit

public final class StackBarController: UIViewController {

    // MARK: Members

    override public var childForStatusBarHidden: UIViewController? {
        rootViewController
    }

    override public var childForStatusBarStyle: UIViewController? {
        rootViewController
    }

    override public var childForHomeIndicatorAutoHidden: UIViewController? {
        rootViewController
    }

    override public var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        rootViewController
    }

    override public var childViewControllerForPointerLock: UIViewController? {
        rootViewController
    }

    override public var navigationItem: UINavigationItem {
        rootViewController.navigationItem
    }

    override public var hidesBottomBarWhenPushed: Bool {
        get {
            rootViewController.hidesBottomBarWhenPushed
        }
        set {
            rootViewController.hidesBottomBarWhenPushed = newValue
        }
    }

    /// The child's scrollView, if any, used to track and update the background effect/opacity of the stack bar.
    public var observedScrollView: UIScrollView? {
        didSet {
            guard let scrollView = observedScrollView else {
                cancellable?.cancel()
                cancellable = nil

                return
            }
            cancellable = scrollView
                .publisher(for: \.contentOffset)
                .combineLatest(scrollView.publisher(for: \.contentSize))
                .sink { [weak self] _ in
                    self?.observedScrollViewDidScroll(scrollView)
                }
        }
    }

    public internal(set) var primaryButton: UIButton? {
        didSet {
            if let primaryButton = primaryButton {
                NSLayoutConstraint.activate([
                    primaryButton.widthAnchor.constraint(equalTo: stackBar.widthAnchor),
                    primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 47.0),
                    primaryButton.heightAnchor.constraint(equalToConstant: 50.0).layoutPriority(rawValue: 999),
                ])

                primaryButtonTopConstraint?.isActive = true
                primaryButtonBottomConstraint?.isActive = true
            }
        }
    }

    public internal(set) var secondaryButton: UIButton?

    var items: [StackBarItem] = []
    var cancellable: AnyCancellable?

    private(set) lazy var backgroundView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: nil)

        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.preservesSuperviewLayoutMargins = true
        visualEffectView.contentView.preservesSuperviewLayoutMargins = true

        return visualEffectView
    }()

    private(set) lazy var stackBar: UIStackView = {
        let stackView = UIStackView()

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 13.0

        return stackView
    }()

    private lazy var stackBarTopConstraint: NSLayoutConstraint = stackBar.topAnchor.constraint(equalTo: backgroundView.contentView.layoutMarginsGuide.topAnchor)
    private lazy var stackBarLeadingConstraint: NSLayoutConstraint = stackBar.leadingAnchor.constraint(greaterThanOrEqualTo: backgroundView.contentView.leadingAnchor)
    private lazy var stackBarTrailingConstraint: NSLayoutConstraint = stackBar.trailingAnchor.constraint(lessThanOrEqualTo: backgroundView.contentView.trailingAnchor)
    private lazy var primaryButtonTopConstraint: NSLayoutConstraint? = primaryButton?.topAnchor.constraint(greaterThanOrEqualTo: stackBar.topAnchor)
    private lazy var primaryButtonBottomConstraint: NSLayoutConstraint? = primaryButton?.bottomAnchor.constraint(equalTo: view.bottomAnchor)

    // MARK: Initializers

    let rootViewController: UIViewController
    var animator: UIViewPropertyAnimator

    init(rootViewController: UIViewController) {
        let animator = UIViewPropertyAnimator(duration: 2.0, curve: .easeInOut)

        self.rootViewController = rootViewController
        self.animator = animator

        super.init(nibName: nil, bundle: nil)

        configureAnimator()
    }

    deinit {
        resetAnimator()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()

        configureHierarchy()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateConstraintsConstants()
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard !traitCollection.containsTraits(in: previousTraitCollection) else {
            return
        }
        updateConstraintsConstants()
    }
}

// MARK: - Helpers

private extension StackBarController {

    func configureHierarchy() {
        view.addSubview(backgroundView)

        backgroundView.contentView.addSubview(stackBar)

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackBarTopConstraint,
            stackBarLeadingConstraint,
            stackBarTrailingConstraint,

            stackBar.bottomAnchor.constraint(lessThanOrEqualTo: backgroundView.contentView.layoutMarginsGuide.bottomAnchor),
            stackBar.widthAnchor.constraint(equalToConstant: 360.0).layoutPriority(.defaultHigh),
            stackBar.centerXAnchor.constraint(equalTo: backgroundView.contentView.centerXAnchor),
        ])

        // Pointing to our rootViewController's view causes it to load.
        // We need to configure our hierarchy first, then add it as a subview with index .zero in order for it to be behind our hierarchy.
        addChild(rootViewController)
        view.insertSubview(rootViewController.view, at: .zero)
        rootViewController.didMove(toParent: self)
    }

    func updateConstraintsConstants() {
        let isWide = view.bounds.width >= .iPhoneProMaxGreatestPointsWidth
        let isNotched = view.safeAreaInsets.bottom > .zero
        let isRegularSizeClassAndTallEnough = traitCollection.horizontalSizeClass == .regular && view.bounds.height >= 732
        let constant = isWide ? 44.0 : 24.0

        stackBarTopConstraint.constant = constant // disclaimerText == nil ? constant : stackView.spacing
        stackBarLeadingConstraint.constant = constant
        stackBarTrailingConstraint.constant = -constant

        primaryButtonTopConstraint?.constant = .zero // Will be used sometime when needing to add stuff above it like a UIPageControl…
        primaryButtonBottomConstraint?.constant = isNotched || isRegularSizeClassAndTallEnough ? -89.0 : -60.0
    }
}
