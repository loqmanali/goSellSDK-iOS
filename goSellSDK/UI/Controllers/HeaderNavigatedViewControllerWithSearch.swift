//
//  HeaderNavigatedControllerWithSearch.swift
//  goSellSDK
//
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import struct CoreGraphics.CGAffineTransform.CGAffineTransform
import struct CoreGraphics.CGBase.CGFloat
import struct CoreGraphics.CGGeometry.CGPoint
import struct CoreGraphics.CGGeometry.CGSize
import protocol TapSearchView.TapSearchUpdating
import class TapSearchView.TapSearchView
import class UIKit.NSLayoutConstraint.NSLayoutConstraint
import class UIKit.UIColor.UIColor
import struct UIKit.UIGeometry.UIEdgeInsets
import class UIKit.UIScrollView.UIScrollView
import protocol UIKit.UIScrollView.UIScrollViewDelegate
import class UIKit.UISearchBar.UISearchBar
import protocol UIKit.UISearchBar.UISearchBarDelegate
import class UIKit.UITableView.UITableView

internal class HeaderNavigatedViewControllerWithSearch: HeaderNavigatedViewController {
    
    // MARK: - Internal -
    // MARK: Properties
    
    @IBOutlet internal private(set) weak var tableView: UITableView? {
        
        didSet {
            
            if let nonnullTableView = self.tableView {
                
                self.tableViewLoaded(nonnullTableView)
                
                if let nonnullSearchView = self.searchView {
                    
                    self.bothTableViewAndSearchViewLoaded(nonnullTableView, searchView: nonnullSearchView)
                }
            }
        }
    }
    
    // MARK: Methods
    
    internal override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        self.updateTableViewContentInset()
    }
    
    internal func tableViewLoaded(_ aTableView: UITableView) {
        
        if #available(iOS 11.0, *) {
            
            aTableView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    internal func searchViewLoaded(_ aSearchView: TapSearchView) {
        
        aSearchView.delegate = self
        
        aSearchView.layer.shadowOpacity = 0.0
        aSearchView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        aSearchView.layer.shadowRadius = 1.0
        aSearchView.layer.shadowColor = UIColor(hex: "B5B5B5A8")?.cgColor
    }
    
    internal func bothTableViewAndSearchViewLoaded(_ aTableView: UITableView, searchView aSearchView: TapSearchView) {
        
        self.updateTableViewContentInset()
        aTableView.contentOffset = .zero
    }
    
    internal func searchViewTextChanged(_ text: String) {}
    
    // MARK: - Private -
    
    private struct Constants {
        
        fileprivate static let headerViewAndSearchBarOverlapping: CGFloat = 4.0
        fileprivate static let shadowHeight: CGFloat = 2.0
        
        @available(*, unavailable) private init() {}
    }
    
    // MARK: Properties
    
    @IBOutlet private weak var searchView: TapSearchView? {
        
        didSet {
            
            if let nonnullSearchView = self.searchView {
                
                self.searchViewLoaded(nonnullSearchView)
                
                if let nonnullTableView = self.tableView {
                    
                    self.bothTableViewAndSearchViewLoaded(nonnullTableView, searchView: nonnullSearchView)
                }
            }
        }
    }
    
    @IBOutlet private weak var searchViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: Methods
    
    private func updateTableViewContentInset() {
        
        guard let nonnullTableView = self.tableView else { return }
        guard let searchHeight = self.searchView?.intrinsicContentSize.height else { return }
        
        let desiredInset = UIEdgeInsets(top: searchHeight - Constants.headerViewAndSearchBarOverlapping, left: 0.0, bottom: 0.0, right: 0.0)
        if nonnullTableView.contentInset != desiredInset {
            
            nonnullTableView.contentInset = desiredInset
        }
    }
    
    private func endSearching() {
        
        self.searchView?.endEditing(true)
    }
    
    private func updateSearchViewShadowOpacity(for searchViewRelativeSize: CGFloat) {
        
        let shadowOpacity = searchViewRelativeSize > 0.5 ? 0.0 : 1.0 - 2.0 * searchViewRelativeSize
        self.searchView?.layer.shadowOpacity = Float(shadowOpacity)
    }
}

// MARK: - UIScrollViewDelegate
extension HeaderNavigatedViewControllerWithSearch: UIScrollViewDelegate {
    
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView === self.tableView else { return }
        guard let height = self.searchView?.intrinsicContentSize.height else { return }
        let visibleSearchViewPart = max(Constants.headerViewAndSearchBarOverlapping + Constants.shadowHeight,
                                        height - max(0.0, min(height, scrollView.contentInset.top + scrollView.contentOffset.y)))
        self.searchViewHeightConstraint?.constant = visibleSearchViewPart
        
        let scaleY = visibleSearchViewPart / height
        
        self.updateSearchViewShadowOpacity(for: scaleY)
    }
}

// MARK: - TapSearchUpdating
extension HeaderNavigatedViewControllerWithSearch: TapSearchUpdating {
    
    internal func updateSearchResults(with searchText: String) {
        
        self.searchViewTextChanged(searchText)
    }
}