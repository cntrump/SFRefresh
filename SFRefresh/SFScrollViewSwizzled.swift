//
//  SFScrollViewSwizzled.swift
//  SFRefresh
//
//  Created by vvveiii on 2019/3/30.
//  Copyright © 2019 vvveiii. All rights reserved.
//

import UIKit

extension NSObject {
    open class func SFswizzleMethod(_ originalSelector: Selector?, with swizzledSelector: Selector?) {
        guard let _ = originalSelector, let _ = swizzledSelector else {
            return
        }

        let originalMethod = class_getInstanceMethod(self, originalSelector!)!
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector!)!
        let exist = class_addMethod(self, originalSelector!, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        if (exist) {
            class_replaceMethod(self, swizzledSelector!, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

public extension UIScrollView {
    private static var hasSwizzled = false
    private static var refreshKey: UInt = 0
    private static var infinitingKey: UInt = 0

    var top: CGFloat {
        get {
            var value: CGFloat = 0
            if #available(iOS 11.0, *) {
                value = self.adjustedContentInset.top
            } else {
                value = self.contentInset.top
            }

            return value
        }
    }

    @objc private(set) var SFrefreshView: SFRefreshView? {
        get {
            let view = objc_getAssociatedObject(self, &UIScrollView.refreshKey) as? SFRefreshView
            return view
        }

        set (refreshView) {
            if let view = objc_getAssociatedObject(self, &UIScrollView.refreshKey) as? SFRefreshView {
                view.removeRefreshKVO()
            }

            objc_setAssociatedObject(self, &UIScrollView.refreshKey, refreshView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc private(set) var SFinfinitingView: SFInfinitingView? {
        get {
            let view = objc_getAssociatedObject(self, &UIScrollView.infinitingKey) as? SFInfinitingView
            return view
        }

        set (infinitingView) {
            if let view = objc_getAssociatedObject(self, &UIScrollView.infinitingKey) as? SFInfinitingView {
                view.removeRefreshKVO()
            }

            objc_setAssociatedObject(self, &UIScrollView.infinitingKey, infinitingView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc class func SFmethodSwizzling() {
        guard !hasSwizzled else {
            return
        }

        hasSwizzled = true

        self.SFswizzleMethod(#selector(UIView.willMove(toSuperview:)), with: #selector(SFwillMoveToSuperview(toSuperview:)))
        self.SFswizzleMethod(#selector(UIView.didMoveToSuperview), with: #selector(SFdidMoveToSuperview))
        self.SFswizzleMethod(#selector(setter: UIView.bounds), with: #selector(SFsetBounds(bounds:)))

        self.SFswizzleMethod(#selector(UIView.addSubview(_:)), with: #selector(SFaddSubview(_:)))
        self.SFswizzleMethod(#selector(UIView.insertSubview(_:at:)), with: #selector(SFinsertSubview(_:at:)))
        self.SFswizzleMethod(#selector(UIView.insertSubview(_:aboveSubview:)), with: #selector(SFinsertSubview(_:aboveSubview:)))
        self.SFswizzleMethod(#selector(UIView.insertSubview(_:belowSubview:)), with: #selector(SFinsertSubview(_:belowSubview:)))
    }

    @objc func SFaddRefresh(maker: () -> SFRefreshView?) {
        SFrefreshView = maker()
        if let refreshView = SFrefreshView {
            refreshView.scrollView = self
            let h = refreshView.heightOfcontentView
            let w = self.frame.width
            let y = self.contentOffset.y
            let keep = refreshView.keepPosition
            refreshView.frame = CGRect(x: 0, y: keep ? y + top : -h, width: w, height: h)
            self.addSubview(refreshView)

            refreshView.addRefreshKVO()
        }
    }

    @objc func SFaddInfiniting(maker: () -> SFInfinitingView?) {
        SFinfinitingView = maker()
        if let infinitingView = SFinfinitingView {
            infinitingView.scrollView = self
            let h = infinitingView.heightOfcontentView
            let w = self.frame.width
            let y = self.contentSize.height
            infinitingView.frame = CGRect(x: 0, y: y, width: w, height: h)
            self.addSubview(infinitingView)

            infinitingView.addRefreshKVO()
        }
    }

    private func keepRefreshViewPosition() {
        if let refreshView = SFrefreshView, refreshView.keepPosition {
            if self.isKind(of: UITableView.self) {
                let tableView = self as! UITableView
                if let backgroundView = tableView.backgroundView {
                    self.SFinsertSubview(refreshView, aboveSubview: backgroundView)
                    return
                }
            } else if self.isKind(of: UICollectionView.self) {
                let collectionView = self as! UICollectionView
                if let backgroundView = collectionView.backgroundView {
                    self.SFinsertSubview(refreshView, aboveSubview: backgroundView)
                    return
                }
            }

            self.sendSubviewToBack(refreshView)
        }
    }

    @objc func SFwillMoveToSuperview(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            SFrefreshView?.removeRefreshKVO()
            SFinfinitingView?.removeRefreshKVO()
        }

        self.SFwillMoveToSuperview(toSuperview: newSuperview)
    }

    @objc func SFdidMoveToSuperview() {
        if self.superview != nil {
            SFrefreshView?.addRefreshKVO()
            SFinfinitingView?.addRefreshKVO()
        }

        self.SFdidMoveToSuperview()
    }

    @objc func SFsetBounds(bounds: CGRect) {
        self.SFsetBounds(bounds: bounds)

        if let refreshView = SFrefreshView {
            let h = refreshView.heightOfcontentView
            let w = self.frame.width
            let y = self.contentOffset.y
            let state = refreshView.state
            let keep = refreshView.keepPosition
            refreshView.frame = CGRect(x: 0, y: (keep ? y + top + (state == .refreshing ? -h : 0) : -h), width: w, height: h)
        }

        if let infinitingView = SFinfinitingView {
            let h = infinitingView.heightOfcontentView
            let w = self.frame.width
            let y = self.contentSize.height
            infinitingView.frame = CGRect(x: 0, y: y, width: w, height: h)
        }
    }

    @objc func SFaddSubview(_ view: UIView) {
        self.SFaddSubview(view)

        self.keepRefreshViewPosition()
    }

    @objc func SFinsertSubview(_ view: UIView, at index: Int) {
        self.SFinsertSubview(view, at: index)

        self.keepRefreshViewPosition()
    }

    @objc func SFinsertSubview(_ view: UIView, aboveSubview siblingSubview: UIView) {
        self.SFinsertSubview(view, aboveSubview: siblingSubview)

        self.keepRefreshViewPosition()
    }

    @objc func SFinsertSubview(_ view: UIView, belowSubview siblingSubview: UIView) {
        self.SFinsertSubview(view, belowSubview: siblingSubview)

        self.keepRefreshViewPosition()
    }
}
