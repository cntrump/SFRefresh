//
//  LOTTableView.swift
//  LottieRefresh
//
//  Created by vvveiii on 2019/3/30.
//  Copyright © 2019 lvv. All rights reserved.
//

import UIKit

class LOTTableView: UITableView {
    func addRefresh(handler: @escaping (_ completion: @escaping SFCompletionHandler) -> Void) {
        self.SFaddRefresh { () -> SFRefreshView? in
            // using https://lottiefiles.com/4497-pull-to-refresh
            let refreshView = LOTRefreshView(name: "4497-pull-to-refresh")
            refreshView.refreshHandler = handler
            return refreshView
        }
    }

}
