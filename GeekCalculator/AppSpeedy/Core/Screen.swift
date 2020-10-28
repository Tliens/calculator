//
//  Screen.swift
//  WorldClock
//
//  Created by 2020 on 2020/10/20.
//

import UIKit
/*
 到 2020 年的现在这个时间点，iPhone 的逻辑分辨率宽度进化到了
 320pt（非全面屏、全面屏）、
 375pt（非全面屏、全面屏）、
 414pt（非全面屏、全面屏）、
 390pt（全面屏）、
 428pt（全面屏）
 八小种、五大种
 */
typealias App = SpeedyApp
class SpeedyApp {
    static let w = UIScreen.main.bounds.width
    static let h = UIScreen.main.bounds.width
    // 判断设备是不是iPhoneX
    static var isX : Bool {
        var isX = false
        if #available(iOS 11.0, *) {
            let bottom : CGFloat = UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0
            isX = bottom > 0.0
        }
        return isX
    }
    // TableBar距底部区域高度
    static var tabBarBottom : CGFloat {
        var bottomH : CGFloat = 0.0
        if isX {
            bottomH = 34.0
        }
        return bottomH
    }
    
    // 状态栏的高度
    static var statusBarHeight : CGFloat {
        var height = UIApplication.shared.statusBarFrame.size.height
        height = height < 20 ? (tabBarBottom > 0 ? 44 : 20) : height
        return height
    }
    
    // 导航栏的高度
    static var navBarHeight: CGFloat {
        return 44.0
    }
    
    // 状态栏和导航栏的高度
    static var statusWithNavBarHeight : CGFloat {
        let heigth = statusBarHeight + navBarHeight
        return heigth
    }
    class func scaleW(_ width: CGFloat,fit:CGFloat = 414.0) -> CGFloat {
        return w / fit * width
    }
     
    class func scaleH(_ height: CGFloat,fit:CGFloat = 667.0) -> CGFloat {
        return h / fit * height
    }
    class func scale(_ value: CGFloat) -> CGFloat {
        return scaleW(value)
    }
    ///根据控制器获取 顶层控制器
    class func topVC(_ viewController: UIViewController?) -> UIViewController? {
        guard let currentVC = viewController else {
            return nil
        }
        if let nav = currentVC as? UINavigationController {
            // 控制器是nav
            return topVC(nav.visibleViewController)
        } else if let tabC = currentVC as? UITabBarController {
            // tabBar 的跟控制器
            return topVC(tabC.selectedViewController)
        } else if let presentVC = currentVC.presentedViewController {
            //modal出来的 控制器
            return topVC(presentVC)
        } else {
            // 返回顶控制器
            return currentVC
        }
    }
    // MARK: - 顶层控制器的navigationController
    class var topNavVC: UINavigationController? {
        if let topVC = self.topVC() {
            if let nav = topVC.navigationController {
                return nav
            } else {
                return AppNavigationController(rootViewController: topVC)
            }
        }
        return nil
    }
    // MARK: - 查找顶层控制器、
    // 获取顶层控制器 根据window
    class func topVC() -> UIViewController? {
        var window = UIApplication.shared.keyWindow
        //是否为当前显示的window
        if window?.windowLevel != UIWindow.Level.normal{
            let windows = UIApplication.shared.windows
            for  windowTemp in windows{
                if windowTemp.windowLevel == UIWindow.Level.normal{
                    window = windowTemp
                    break
                }
            }
        }
        let vc = window?.rootViewController
        return topVC(vc)
    }
}
