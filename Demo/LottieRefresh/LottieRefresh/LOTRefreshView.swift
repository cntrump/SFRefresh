//
//  LOTRefreshView.swift
//  LottieUp
//
//  Created by vvveiii on 2019/3/28.
//  Copyright © 2019 vvveiii. All rights reserved.
//

import UIKit
import Lottie

public class LOTRefreshView: SFRefreshView {
    private var aniName: String!
    private var aniView: AnimationView!
    private let loopAt: CGFloat = 62.0 / 330.0

    @objc public init(name: String) {
        super.init(frame: .zero)

        aniName = name
        aniView = AnimationView()
        aniView.backgroundBehavior = .pauseAndRestore
        self.contentView.addSubview(aniView)
        aniView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addConstraints([
            NSLayoutConstraint(item: aniView!, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: aniView!, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: aniView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100),
            NSLayoutConstraint(item: aniView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func aniPath(name: String) -> String {
        let lottieBundlePath = Bundle.main.path(forResource: "lottie", ofType: "bundle") ?? ""
        let lottieBundle = Bundle(path: lottieBundlePath)
        let aniPath = lottieBundle?.path(forResource: name, ofType: "json") ?? ""

        return aniPath
    }

    override var heightOfcontentView: CGFloat {
        get {
            return 104
        }
    }

    public override var minRefreshingTime: CGFloat {
        return 2 // 2s
    }

    public override func percentDidChange(_ value: CGFloat, state: SFRefreshState, isTracking: Bool) {
        if aniView.animation == nil {
            aniView.animation = Animation.filepath(aniPath(name: aniName))
        }

        aniView.currentProgress = value * loopAt
    }

    public override func didRefresh() {
        aniView.play(fromProgress: loopAt, toProgress: 1, loopMode: .loop)
    }

    public override func didFinish() {
        aniView.pause()
    }

    public override func didReset() {
        if aniView.animation != nil {
            aniView.stop()
            aniView.animation = nil
        }
    }
}
