//
//  SFRefreshView.swift
//  SFRefresh
//
//  Created by vvveiii on 2019/3/30.
//  Copyright © 2019 vvveiii. All rights reserved.
//

import UIKit

@objc public enum SFRefreshState : Int {
    case inactive
    case ready
    case triggered
    case refreshing
    case finished
}

fileprivate let contentOffsetKey: String = "contentOffset"

open class SFRefreshView: UIView, SFRefresh  {
    @objc open var keepPosition: Bool = false
    @objc open var refreshHandler: ((_ completionHandler: @escaping SFCompletionHandler) -> Void)?
    @objc open private(set) var contentView: UIView!
    @objc open var enable: Bool = true  // enable refresh by default
    @objc open private(set) var state: SFRefreshState = .ready
    @objc open var minRefreshingTime: CGFloat {
        get {
            return 0
        }
    }

    internal weak var scrollView: UIScrollView?
    private var KVOadded: Bool = false
    private var triggerTime: UInt64 = 0

    @objc override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        contentView = UIView(frame: self.bounds)
        self.addSubview(contentView)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var heightOfcontentView: CGFloat {
        get {
            return 50
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = self.bounds
    }

    private func time(time: UInt64) -> Double {
        var timebase = mach_timebase_info_data_t()
        mach_timebase_info(&timebase)

        return (Double(time) * Double(timebase.numer) / Double(timebase.denom) / 1e9)
    }

    private func delaySinceNow() -> Double {
        let execTime = time(time: mach_absolute_time() - triggerTime)
        let minTime = Double(minRefreshingTime)
        let delay = minTime > execTime ? minTime - execTime : 0

        return delay
    }

    func addRefreshKVO() {
        guard !KVOadded else {
            return
        }

        KVOadded = true

        if let scrollView = scrollView {
            scrollView.addObserver(self, forKeyPath: contentOffsetKey, options: [.new, .old], context: nil)
        }
    }

    func removeRefreshKVO() {
        guard KVOadded else {
            return
        }

        if let scrollView = scrollView {
            scrollView.removeObserver(self, forKeyPath: contentOffsetKey, context: nil)
        }

        KVOadded = false
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard scrollView != nil && keyPath != nil && object != nil && change != nil else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        guard keyPath!.caseInsensitiveCompare(contentOffsetKey) == .orderedSame && scrollView!.isEqual(object!) else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        if state == .triggered && !scrollView!.isTracking {
            triggerRefresh()
            return
        }

        let newValue: CGPoint = scrollView!.contentOffset
        var percent = -(newValue.y + scrollView!.top) / heightOfcontentView

        let infiniting = scrollView!.SFinfinitingView != nil && scrollView!.SFinfinitingView?.state != .ready
        guard enable && state != .refreshing && state != .finished && !infiniting else {
            return
        }

        if percent > 0 {
            percent = min(1.0, percent)
            state = percent < 1 ? .ready : .triggered
            percentDidChange(percent, state: state, isTracking: scrollView!.isTracking)
        } else {
            if state != .inactive {
                state = .inactive
                didReset()
            }
        }
    }

    @objc public func startRefresh() {
        guard state != .triggered, state != .refreshing, state != .finished else {
            return
        }

        state = .triggered

        DispatchQueue.main.async { [weak self] in
            let infiniting = self?.scrollView?.SFinfinitingView != nil && self?.scrollView?.SFinfinitingView?.state != .ready
            guard let scrollView = self?.scrollView, self?.state != .refreshing, self?.state != .finished, !infiniting else {
                return
            }

            var offset = scrollView.contentOffset
            let y = self!.heightOfcontentView
            offset.y = -y - scrollView.top

            self?.percentDidChange(0.01, state: .triggered, isTracking: scrollView.isTracking)

            UIView.animate(withDuration: 0.25) {
                if let scrollView = self?.scrollView {
                    self?.percentDidChange(1, state: .triggered, isTracking: scrollView.isTracking)
                    scrollView.contentOffset = offset
                }
            }
        }
    }

    @objc public func stopRefresh() {
        // exec on next runloop
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySinceNow()) { [weak self] in
            guard self?.scrollView != nil && self?.state == .refreshing else {
                return
            }

            self?.state = .finished
            self?.didFinish()

            var inset = self!.scrollView!.contentInset
            inset.top -= self!.heightOfcontentView

            UIView.animate(withDuration: 0.25, animations: {
                self?.scrollView?.contentInset = inset
            }) { (Bool) in
                self?.state = .ready
                self?.didReset()
            }
        }
    }

    public func percentDidChange(_ value: CGFloat, state: SFRefreshState, isTracking: Bool) {
    }

    public func didRefresh() {
    }

    public func didFinish() {
    }

    public func didReset() {
    }

    private func triggerRefresh() {
        guard state != .refreshing else {
            return
        }

        state = .refreshing
        triggerTime = mach_absolute_time()

        var inset = scrollView!.contentInset
        let top = inset.top
        inset.top += heightOfcontentView

        // exec on next runloop
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.25, animations: {
                self?.scrollView?.contentInset = inset
            }) { (Bool) in
                let completion = {
                    guard self != nil else {
                        return
                    }

                    let delay = self!.delaySinceNow()

                    // exec on next runloop
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        guard self?.scrollView != nil, self?.state == .refreshing else {
                            return
                        }

                        self?.state = .finished
                        self?.didFinish()

                        inset.top = top

                        UIView.animate(withDuration: 0.25, animations: {
                            self?.scrollView?.contentInset = inset
                        }) { (Bool) in
                            self?.state = .ready
                            self?.didReset()
                        }
                    }
                }

                self?.didRefresh()
                self?.refreshHandler?(completion)
            }
        }
    }
}
