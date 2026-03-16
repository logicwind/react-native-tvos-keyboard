import UIKit
import React

@objc(TvosKeyboardViewManager)
class TvosKeyboardViewManager: RCTViewManager {
  override func view() -> UIView {
    return TvosKeyboardView()
  }

  @objc override static func requiresMainQueueSetup() -> Bool {
    return true
  }

  @objc func focusSearchBar(_ reactTag: NSNumber) {
    DispatchQueue.main.async {
      if let view = self.bridge.uiManager.view(forReactTag: reactTag) as? TvosKeyboardView {
        view.focusSearchBar()
      }
    }
  }
}

class TvosKeyboardView: UIView, UISearchResultsUpdating, UISearchBarDelegate {

  private var searchController: UISearchController!
  private var containerVC: UISearchContainerViewController!
  private let searchResultsController = UICollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())

  @objc var onTextChange: RCTBubblingEventBlock?
  @objc var onFocus: RCTBubblingEventBlock?
  @objc var onBlur: RCTBubblingEventBlock?
  @objc var onKeyboardLayoutChange: RCTBubblingEventBlock?
  @objc var gridSeparatorColor: UIColor? { didSet { applySeparatorColor() } }
  @objc var linearSeparatorColor: UIColor? { didSet { applySeparatorColor() } }

  private var lastEmittedHeight: CGFloat = 0
  private var currentIsGrid = false
  private weak var observedKeyboardView: UIView?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupSearchController()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupSearchController()
  }

  deinit {
    observedKeyboardView?.removeObserver(self, forKeyPath: "frame")
  }

  private func setupSearchController() {
    let resultsVC = UIViewController()
    resultsVC.view.backgroundColor = .clear

    searchController = UISearchController(searchResultsController: resultsVC)
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.automaticallyShowsCancelButton = false
    searchController.searchBar.placeholder = "Enter keyword"
      
    if #available(tvOS 14.0, *) {
      searchController.searchControllerObservedScrollView = searchResultsController.collectionView
      searchController.searchSuggestions = nil
    }

    searchController.searchBar.delegate = self

    containerVC = UISearchContainerViewController(searchController: searchController)
    containerVC.view.translatesAutoresizingMaskIntoConstraints = false
    containerVC.view.clipsToBounds = true

    self.addSubview(containerVC.view)
    self.clipsToBounds = true

    NSLayoutConstraint.activate([
      containerVC.view.topAnchor.constraint(equalTo: self.topAnchor),
      containerVC.view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      containerVC.view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      containerVC.view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
    ])
  }

  private func applySeparatorColor() {
    let color = currentIsGrid ? gridSeparatorColor : linearSeparatorColor
    guard let color = color else { return }
    findAndColorSeparator(in: searchController.view, color: color)
  }

  private func updateSeparatorColor(_ color: UIColor) {
    findAndColorSeparator(in: searchController.view, color: color)
  }

  private func findAndColorSeparator(in view: UIView, color: UIColor) {
    if view.frame.height <= 1.0 && view.frame.width > 100 {
      view.backgroundColor = color
      return
    }
    for sub in view.subviews {
      findAndColorSeparator(in: sub, color: color)
    }
  }

  // Recursively finds the first view matching the given private class name
  private func findView(named className: String, in view: UIView) -> UIView? {
    if NSStringFromClass(type(of: view)) == className { return view }
    for sub in view.subviews {
      if let found = findView(named: className, in: sub) { return found }
    }
    return nil
  }

  private func emitKeyboardHeight() {
    guard let kbView = findView(named: "_UIKBCompatInputView", in: searchController.view) else { return }

    // KVO: watch this specific instance for frame changes (linear <-> grid switch)
    if observedKeyboardView !== kbView {
      observedKeyboardView?.removeObserver(self, forKeyPath: "frame")
      kbView.addObserver(self, forKeyPath: "frame", options: [.new], context: nil)
      observedKeyboardView = kbView
    }

    let h = kbView.frame.height
    guard h > 0, h != lastEmittedHeight else { return }
    lastEmittedHeight = h
    currentIsGrid = h > 700
    onKeyboardLayoutChange?(["height": h, "isGrid": currentIsGrid])
    applySeparatorColor()
  }

  override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey: Any]?,
                             context: UnsafeMutableRawPointer?) {
    guard keyPath == "frame",
          let view = object as? UIView,
          view === observedKeyboardView else { return }
    let h = view.frame.height
    guard h > 0, h != lastEmittedHeight else { return }
    lastEmittedHeight = h
    onKeyboardLayoutChange?(["height": h, "isGrid": h > 700])
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    // Defer to next run loop — by then RN has finished setting all props incl. onHeightChange
    DispatchQueue.main.async { [weak self] in
      self?.emitKeyboardHeight()
    }
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    if window == nil {
      // View is being removed — tear down VC containment cleanly
      if containerVC.parent != nil {
        containerVC.beginAppearanceTransition(false, animated: false)
        containerVC.endAppearanceTransition()
        containerVC.willMove(toParent: nil)
        containerVC.removeFromParent()
      }
      return
    }

    guard let parentVC = reactViewController() else { return }
    if containerVC.parent == nil {
      parentVC.addChild(containerVC)
      // Fire viewWillAppear/viewDidAppear so UISearchContainerViewController
      // registers its focus environment with the tvOS focus engine
      containerVC.beginAppearanceTransition(true, animated: false)
      containerVC.endAppearanceTransition()
      containerVC.didMove(toParent: parentVC)
      // Auto-focus the search bar so tvOS routes remote input here immediately,
      // instead of leaving focus on the tab bar item that triggered navigation
      focusSearchBar()
    }
  }

  func focusSearchBar() {
    DispatchQueue.main.async {
      self.searchController.searchSuggestions = nil
      self.searchController.searchBar.becomeFirstResponder()
    }
  }

  func updateSearchResults(for searchController: UISearchController) {
    let text = searchController.searchBar.text ?? ""
    onTextChange?(["text": text])
  }

  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
  #if os(tvOS)
    NotificationCenter.default.post(name: NSNotification.Name("RCTTVDisableSelectGestureNotification"), object: nil)
    DispatchQueue.main.async {
      searchBar.becomeFirstResponder()
    }
  #endif
    onFocus?(["focused": true])
  }

  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
  #if os(tvOS)
    NotificationCenter.default.post(name: NSNotification.Name("RCTTVEnableSelectGestureNotification"), object: nil)
  #endif
    onBlur?(["blurred": true])
  }
}
