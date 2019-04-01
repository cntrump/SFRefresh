//
//  SFRefresh.swift
//  SFRefresh
//
//  Created by vvveiii on 2019/3/30.
//  Copyright © 2019 vvveiii. All rights reserved.
//

import UIKit

public typealias SFCompletionHandler = () -> Void

protocol SFRefresh {
    var heightOfcontentView: CGFloat { get }
    func addRefreshKVO()
    func removeRefreshKVO()
}
