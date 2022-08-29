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

    public var customBackgroundViewAnimationsProvider: ((UIView?) -> Void)?

    ///
    /// A Boolean value that indicates wether the stack bar's bottom constraint is set relative to the primary button or relative to the stack bar itself.
    ///
    /// When this property is set to false and no secondary button exists, the stack bar defines its bottom anchor relative to itself. When this property is set to true or any secondary button exists, the bottom constraints is relative to the primary button and offset from the bottom of the view. The default value of this property is `true`.
    public var primaryButtonDefinesBottomConstraint: Bool = true

    public var prefersSafeAreaOverConstant: Bool = false

    public internal(set) var primaryButton: UIButton? {
        didSet {
            if let primaryButton = primaryButton {
                NSLayoutConstraint.activate([
                    primaryButton.widthAnchor.constraint(equalTo: stackBar.widthAnchor),
                    primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 47.0),
                    primaryButton.heightAnchor.constraint(equalToConstant: 50.0).layoutPriority(rawValue: 999),
                ])
                // Button changed, we need to re-set the constraints.
                primaryButtonTopConstraint = primaryButton.topAnchor.constraint(greaterThanOrEqualTo: stackBar.topAnchor)
                primaryButtonTopConstraint?.isActive = true

                primaryButtonBottomConstraint = primaryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).layoutPriority(.required)
                primaryButtonBottomConstraint?.isActive = primaryButtonDefinesBottomConstraint || secondaryButton != nil
            }
        }
    }

    public internal(set) var secondaryButton: UIButton?

    private(set) lazy var customBackgroundView: UIView? = {
        guard !prefersDefaultBackground else {
            return nil
        }
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.preservesSuperviewLayoutMargins = true

        return view
    }()

    var backgroundView: UIView {
        customBackgroundView ?? backgroundVisualEffectView
    }

    var contentView: UIView {
        customBackgroundView ?? backgroundVisualEffectView.contentView
    }

    var items: [StackBarItem] = []
    var cancellable: AnyCancellable?

    private(set) lazy var backgroundVisualEffectView: UIVisualEffectView = {
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

    private lazy var stackBarTopConstraint: NSLayoutConstraint = stackBar.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor)
    private lazy var stackBarLeadingConstraint: NSLayoutConstraint = stackBar.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor)
    private lazy var stackBarTrailingConstraint: NSLayoutConstraint = stackBar.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor)
    var primaryButtonTopConstraint: NSLayoutConstraint?
    var primaryButtonBottomConstraint: NSLayoutConstraint?

    // MARK: Initializers

    let rootViewController: UIViewController
    let prefersDefaultBackground: Bool
    var animator: UIViewPropertyAnimator

    public init(rootViewController: UIViewController, prefersDefaultBackground: Bool = true) {
        let animator = UIViewPropertyAnimator()

        self.rootViewController = rootViewController
        self.prefersDefaultBackground = prefersDefaultBackground
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

extension StackBarController {

    func configureAdditionalSafeAreaInsets() {
        // We substitute the existing bottom safe area inset since its already accounted for in the child's view.
        rootViewController.additionalSafeAreaInsets.bottom = backgroundView.bounds.height - view.safeAreaInsets.bottom
    }
}

private extension StackBarController {

    func configureHierarchy() {
        view.addSubview(backgroundView)

        contentView.addSubview(stackBar)

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackBarTopConstraint,
            stackBarLeadingConstraint,
            stackBarTrailingConstraint,

            stackBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16.0).layoutPriority(.defaultLow),
            stackBar.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor).layoutPriority(.defaultHigh),
            stackBar.widthAnchor.constraint(equalToConstant: 360.0).layoutPriority(.defaultHigh),
            stackBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
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

        if case let .customView(item: view, withTag: _) = items.first, !view.isHidden {
            stackBarTopConstraint.constant = 8.0
        }
        else {
            stackBarTopConstraint.constant = constant
        }
        stackBarLeadingConstraint.constant = constant
        stackBarTrailingConstraint.constant = -constant

        primaryButtonTopConstraint?.constant = .zero // Will be used sometime when needing to add stuff above it like a UIPageControl…
        primaryButtonBottomConstraint?.constant = isNotched || isRegularSizeClassAndTallEnough ? -89.0 : -60.0

        configureAdditionalSafeAreaInsets()
    }
}
