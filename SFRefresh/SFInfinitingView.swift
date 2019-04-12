//
//  SFInfinitingView.swift
//  SFRefresh
//
//  Created by vvveiii on 2019/3/30.
//  Copyright © 2019 vvveiii. All rights reserved.
//

import UIKit

@objc public enum SFInfinitingState : Int {
    case ready
    case triggered
    case infiniting
    case finished
}

fileprivate let contentOffsetKey: String = "contentOffset"

public class SFInfinitingView: UIView, SFRefresh {
    @objc open var infinitingHandler: ((_ completionHandler: @escaping SFCompletionHandler) -> Void)?
    @objc open private(set) var contentView: UIView!
    @objc open var enable: Bool = false // disable infiniting by default
    @objc open private(set) var state: SFInfinitingState = .ready

    internal weak var scrollView: UIScrollView?
    private var KVOadded: Bool = false
    
    var heightOfcontentView: CGFloat {
        get {
            return 50
        }
    }

    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        contentView = UIView(frame: self.bounds)
        self.addSubview(contentView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = self.bounds
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

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard scrollView != nil && keyPath != nil && object != nil && change != nil else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        guard keyPath!.caseInsensitiveCompare(contentOffsetKey) == .orderedSame && scrollView!.isEqual(object!) else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        let y = scrollView!.contentSize.height
        frame = CGRect(x: 0, y: y, width: scrollView!.frame.width, height: heightOfcontentView)

        if state == .triggered {
            state = .infiniting

            var inset = scrollView!.contentInset
            let bottom = inset.bottom
            inset.bottom += heightOfcontentView

            // exec on next runloop
            DispatchQueue.main.async { [weak self] in
                UIView.animate(withDuration: 0.25, animations: {
                    self?.scrollView?.contentInset = inset
                }) { (Bool) in
                    let completion = {
                        // exec on next runloop
                        DispatchQueue.main.async {
                            guard self?.scrollView != nil, self?.state == .infiniting else {
                                return
                            }

                            self?.state = .finished
                            self?.didFinish()

                            inset.bottom = bottom
                            let offset = self!.scrollView!.contentOffset

                            UIView.animate(withDuration: 0.25, animations: {
                                self?.scrollView?.contentInset = inset
                                self?.scrollView?.contentOffset = offset
                            }) { (Bool) in
                                self?.state = .ready
                                self?.didReset()
                            }
                        }
                    }

                    self?.didInfinite()
                    self?.infinitingHandler?(completion)
                }
            }

            return
        }

        let oldValue: CGPoint = (change![.oldKey] as! NSValue).cgPointValue
        let newValue: CGPoint = scrollView!.contentOffset
        let scrollDown = newValue.y > oldValue.y

        let refresing = scrollView!.SFrefreshView != nil && scrollView!.SFrefreshView?.state != .inactive
        guard enable && scrollDown && state != .infiniting && state != .finished && !refresing else {
            return
        }

        let atBottom = scrollView!.contentSize.height - newValue.y <= scrollView!.frame.height
        state = atBottom ? .triggered : .ready
    }

    @objc public func stopInfiniting() {
        // exec on next runloop
        DispatchQueue.main.async { [weak self] in
            guard self?.scrollView != nil && self?.state == .infiniting else {
                return
            }

            self?.state = .finished
            self?.didFinish()

            var inset = self!.scrollView!.contentInset
            inset.bottom -= self!.heightOfcontentView

            let offset = self!.scrollView!.contentOffset

            UIView.animate(withDuration: 0.25, animations: {
                self?.scrollView?.contentInset = inset
                self?.scrollView?.contentOffset = offset
            }) { (Bool) in
                self?.state = .ready
                self?.didReset()
            }
        }
    }

    func didInfinite() {
    }

    func didFinish() {
    }

    func didReset() {
    }
}
