# SFRefresh

Give pull-to-refresh & infinite scrolling to any UIScrollView

Support Lottie animation for `pull-to-refresh`

![](https://raw.githubusercontent.com/cntrump/SFRefresh/master/lottiedemo.gif)

## Using Carthage

```
github "cntrump/SFRefresh" "master"
```

## Using in your project

#### Swift

```swift
import SFRefresh
```

#### Objc

```objc
@import SFRefresh;
```

enable `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES` in your project settings

if your project using Objc++

add `-fmodules -fcxx-modules` to `OTHER_CPLUSPLUSFLAGS` in your project settings

#### Example

Swizzling `UIScrollView` in `func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool`.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  // enable swizzling
  UIScrollView.SFmethodSwizzling()
  
  // ...
  
  return true
}
```

Subclass `UITableView`

```swift
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
```

Using in view controller

```swift
override func viewDidLoad() {
  super.viewDidLoad()

  tableView = LOTTableView(frame: self.view.bounds, style: .plain)
  tableView.addRefresh { (completion) -> Void in
    // do your work in here
    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
      // work finished, stop the refresh
      completion()
    })
  }
  
  self.view.addSubview(tableView)
}
```

## Custom your refresh view

Subclass `SFRefreshView`, example `LOTRefreshView` in demo.

Override below methods

`heightOfcontentView` 

`percentDidChange`

`didRefresh`

`didFinish`

`didReset`

If you wanna the refresh animation end a little longer, you can override

`minRefreshingTime`

Run the Demo in `Demo/LottieRefresh`, you will see more details.
