//
//  LOTInfinitingView.swift
//  LottieUp
//
//  Created by vvveiii on 2019/3/28.
//  Copyright © 2019 vvveiii. All rights reserved.
//

import UIKit

public class LOTInfinitingView: SFInfinitingView {
    private var indicatorView: UIActivityIndicatorView?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        indicatorView = UIActivityIndicatorView(style: .gray)
        self.contentView.addSubview(indicatorView!)
        indicatorView?.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addConstraints([
            NSLayoutConstraint(item: indicatorView!, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: indicatorView!, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func didInfinite() {
        indicatorView?.startAnimating()
    }

    public override func didFinish() {
        indicatorView?.stopAnimating()
    }

    public override func didReset() {
    }
}
