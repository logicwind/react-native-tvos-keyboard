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

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupSearchController()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupSearchController()
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
