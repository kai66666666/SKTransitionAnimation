//
//  SKTranstionBaseAnimation.swift
//  swiftTest
//
//  Created by sunkai on 2022/3/1.
//

import UIKit

@objc public enum SKTranstionOperation: Int {
    case none
    case push
    case pop
    case present
    case dismiss
    
    var isPushOrPresent: Bool {
        get {
            if self == .push || self == .present {
                return true
            } else {
                return false
            }
        }
    }
    var isPushOrPop: Bool {
        get {
            if self == .push || self == .pop {
                return true
            } else {
                return false
            }
        }
    }
}

open class SKTranstionBaseAnimation: NSObject {
    
    var operation = SKTranstionOperation.none
    var animationType = SKTransitionAnimationType.default
    
    public typealias SKTranstionBlock = (_ containerView: UIView, _ operation: SKTranstionOperation) -> Void

    //将要进行转场
    @objc public var willTheTransition: SKTranstionBlock?
    //开始转场
    @objc public var beginTheTransition: SKTranstionBlock?
    //取消转场
    @objc public var cancelTheTransition: SKTranstionBlock?
    //完成转场
    @objc public var endTheTransition: SKTranstionBlock?

    //交互控制器
    private var percentDrivenTransition: UIPercentDrivenInteractiveTransition?
    private weak var preViewCtrl: UIViewController?

    static func animation(with animationType: SKTransitionAnimationType) -> SKTranstionBaseAnimation? {
        var animation: SKTranstionBaseAnimation?
        if animationType == .default {
            return nil
        } else if animationType == .moveFromLeft ||
                    animationType == .moveFromRight ||
                    animationType == .moveFromTop ||
                    animationType == .moveFromBottom {
            animation = SKTranstionMoveAnimation()
        } else if animationType == .cover {
            animation = SKTranstionCoverAnimation()
        } else if animationType == .fade {
            animation = SKTranstionFadeAnimation()
        } else if animationType == .pointSpread ||
                    animationType == .randomPointSpread {
            animation = SKTranstionPointAnimation()
        } else if animationType == .spreadFromLeft ||
                    animationType == .spreadFromRight ||
                    animationType == .spreadFromTop ||
                    animationType == .spreadFromBottom {
            animation = SKTranstionSpreadAnimation()
        } else if animationType == .fragment {
            animation = SKTranstionFragmentAnimation()
        } else if animationType == .flip {
            animation = SKTranstionFlipAnimation()
        }
        guard let animation = animation else { return nil }
        animation.operation = .push
        animation.animationType = animationType
        return animation
    }
    func addScreenLeftEdgePanGestureRecognizer(_ viewCtrl: UIViewController, preViewCtrl: UIViewController?) {
        self.preViewCtrl = preViewCtrl
        let leftPan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePanGesture(_:)))
        leftPan.edges = .left
        viewCtrl.view.addGestureRecognizer(leftPan)
    }
}
extension SKTranstionBaseAnimation {
    //手势
    @objc private func edgePanGesture(_ edgePan: UIScreenEdgePanGestureRecognizer) {
        let progress = abs(edgePan.translation(in: UIApplication.shared.keyWindow).x / (UIApplication.shared.keyWindow?.bounds.size.width)!)
        if edgePan.state == .began {
            if edgePan.edges == .left {
                self.percentDrivenTransition = UIPercentDrivenInteractiveTransition()
                if let viewCtrl = self.preViewCtrl {
                    if operation.isPushOrPop {
                        viewCtrl.navigationController?.popViewController(animated: true)
                    } else {
                        viewCtrl.dismiss(animated: true, completion: nil)
                    }
                }
            }
        } else if edgePan.state == .changed {
            //更新动画进度
            guard let transition = self.percentDrivenTransition else { return }
            transition.update(progress)
        } else if edgePan.state == .cancelled || edgePan.state == .ended {
            guard let transition = self.percentDrivenTransition else { return }
            if progress > 0.3 {
                transition.finish()
            } else {
                transition.cancel()
            }
            self.percentDrivenTransition = nil
        }
    }
}
extension SKTranstionBaseAnimation: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) { }
}
extension SKTranstionBaseAnimation: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        operation = .present
        return self
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        operation = .dismiss
        return self
    }
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.percentDrivenTransition
    }
}
extension SKTranstionBaseAnimation: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            self.operation = .push
        } else if operation == .pop {
            self.operation = .pop
        }
        return self
    }
    public func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if self.operation == .push {
            return nil
        } else {
            return self.percentDrivenTransition
        }
    }
}
