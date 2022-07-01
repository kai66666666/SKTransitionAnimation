//
//  UIViewController+SKTransition.swift
//  swiftTest
//
//  Created by sunkai on 2022/3/1.
//

import Foundation

@objc public enum SKTransitionAnimationType: Int {
    case `default`
    
    case moveFromLeft
    case moveFromRight
    case moveFromTop
    case moveFromBottom
    
    case cover
    
    case fade

    case pointSpread
    case randomPointSpread
    case touchPointSpread

    case spreadFromLeft
    case spreadFromRight
    case spreadFromTop
    case spreadFromBottom
    
    case fragment
    case flip   //翻转

    //是否支持交互
    func interactionIsSupported() -> Bool {
        switch self {
        case .default:
            return false
        case .moveFromLeft,
                .moveFromRight,
                .moveFromTop,
                .moveFromBottom:
            return true
        case .cover:
            return true
        case .fade:
            return true
        case .pointSpread,
                .randomPointSpread,
                .touchPointSpread:
            return false
        case .spreadFromLeft,
                .spreadFromRight,
                .spreadFromTop,
                .spreadFromBottom:
            return false
        case .fragment:
            return true
        case .flip:
            return true
        }
    }
}
extension UINavigationController {
    @objc
    @discardableResult
    public
    func skPushViewController(_ viewCtrl: UIViewController,
                              animationType: SKTransitionAnimationType) -> SKTranstionBaseAnimation? {
        _ = UINavigationController.swiftLoadPopAnimation
        let animation = SKTranstionBaseAnimation.animation(with: animationType)
        if animation != nil {
            viewCtrl.transitionAnimation = animation
            delegate = viewCtrl.transitionAnimation
            if animationType.interactionIsSupported() {
                //返回手势不关也没事
                animation?.addScreenLeftEdgePanGestureRecognizer(viewCtrl, preViewCtrl: self.topViewController)
            }
        }
        pushViewController(viewCtrl, animated: true)
        delegate = nil
        return animation
    }
    ///使用自定义动画，继承SKTranstionBaseAnimation，使用swift
    @objc public func skPushViewController(_ viewCtrl: UIViewController,
                                           animation: SKTranstionBaseAnimation,
                                           interactionIsSupported: Bool = false) {
        _ = UINavigationController.swiftLoadPopAnimation
        viewCtrl.transitionAnimation = animation
        delegate = viewCtrl.transitionAnimation
        if interactionIsSupported {
            animation.addScreenLeftEdgePanGestureRecognizer(viewCtrl, preViewCtrl: self.topViewController)
        }
        pushViewController(viewCtrl, animated: true)
        delegate = nil
    }
}
extension UIViewController {
    private static var transitionAnimationKey: Void?
    @objc public var transitionAnimation: SKTranstionBaseAnimation? {
        get {
            return objc_getAssociatedObject(self, &Self.transitionAnimationKey) as? SKTranstionBaseAnimation
        }
        set {
            objc_setAssociatedObject(self, &Self.transitionAnimationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    @objc
    @discardableResult
    public
    func skPresentViewController(_ viewCtrl: UIViewController,
                                 animationType: SKTransitionAnimationType,
                                 completion: (() -> Void)? = nil) -> SKTranstionBaseAnimation? {
        _ = UIViewController.swiftLoadDismissAnimation
        let animation = SKTranstionBaseAnimation.animation(with: animationType)
        if animation != nil {
            viewCtrl.transitionAnimation = animation
            viewCtrl.transitioningDelegate = viewCtrl.transitionAnimation
            if animationType.interactionIsSupported() {
                animation?.addScreenLeftEdgePanGestureRecognizer(viewCtrl, preViewCtrl: self)
            }
        }
        DispatchQueue.main.async {
            self.present(viewCtrl, animated: true, completion: completion)
        }
        return animation
    }
    ///使用自定义动画，继承SKTranstionBaseAnimation，使用swift
    @objc public func skPresentViewController(_ viewCtrl: UIViewController,
                                       animation: SKTranstionBaseAnimation,
                                       interactionIsSupported: Bool = false,
                                       completion: (() -> Void)? = nil) {
        _ = UIViewController.swiftLoadDismissAnimation
        viewCtrl.transitionAnimation = animation
        viewCtrl.transitioningDelegate = viewCtrl.transitionAnimation
        if interactionIsSupported {
            animation.addScreenLeftEdgePanGestureRecognizer(viewCtrl, preViewCtrl: self)
        }
        DispatchQueue.main.async {
            self.present(viewCtrl, animated: true, completion: completion)
        }
    }
}
extension UINavigationController {
    fileprivate static var swiftLoadPopAnimation: Void? = {
        UINavigationController.swiftLoad()
    }()
    private static func swiftLoad() {
        Self.skSwizzleInstanceMethod(#selector(popViewController(animated:)),
                                     #selector(skTransition_popViewController(animated:)))
    }
    @objc private func skTransition_popViewController(animated: Bool) -> UIViewController? {
        if let transitionAnimation = self.viewControllers.last?.transitionAnimation {
            delegate = transitionAnimation
        }
        return skTransition_popViewController(animated: animated)
    }
}
extension UIViewController {
    fileprivate static var swiftLoadDismissAnimation: Void? = {
        UIViewController.swiftLoad()
    }()
    private static func swiftLoad() {
        Self.skSwizzleInstanceMethod(#selector(dismiss(animated:completion:)),
                                     #selector(skTransition_dismiss(animated:completion:)))
    }
    @objc private func skTransition_dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if let transitionAnimation = self.transitionAnimation {
            transitioningDelegate = transitionAnimation
        }
        skTransition_dismiss(animated: flag, completion: completion)
    }
}
import ObjectiveC.runtime
extension NSObject {
    fileprivate static func skSwizzleInstanceMethod(_ originalSel: Selector, _ newSel: Selector) {
        guard let originalMethod = class_getInstanceMethod(self, originalSel),
              let swizzledMethod = class_getInstanceMethod(self, newSel) else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
