//
//  SKTranstionSpreadAnimation.swift
//  swiftTest
//
//  Created by sunkai on 2022/3/1.
//

import UIKit
import SKAnimationDelegate

class SKTranstionSpreadAnimation: SKTranstionBaseAnimation {
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        let height = bounds.size.height
        
        var smallPath = UIBezierPath()
        let bigPath = UIBezierPath(rect: bounds)
        if animationType == .spreadFromLeft {
            smallPath = UIBezierPath(rect: .init(x: 0, y: 0, width: 0, height: height))
        } else if animationType == .spreadFromRight {
            smallPath = UIBezierPath(rect: .init(x: width, y: 0, width: 0, height: height))
        } else if animationType == .spreadFromTop {
            smallPath = UIBezierPath(rect: .init(x: 0, y: 0, width: width, height: 0))
        } else if animationType == .spreadFromBottom {
            smallPath = UIBezierPath(rect: .init(x: 0, y: height, width: width, height: 0))
        }
        
        var fromPath = smallPath
        var toPath = bigPath
        var animationVC = toVC

        if operation.isPushOrPresent {
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        } else {
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            fromPath = bigPath
            toPath = smallPath
            animationVC = fromVC
        }
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = toPath.cgPath
        animationVC.view.layer.mask = maskLayer
        
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = fromPath.cgPath
        maskLayerAnimation.toValue = toPath.cgPath
        
        willTheTransition?(containerView, operation)
        
        let duration = transitionDuration(using: transitionContext)
        maskLayerAnimation.duration = duration
        
        let animationDelegate = SKAnimationDelegate()
        animationDelegate.animationDidStop = { anim, finished in
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
            animationVC.view.layer.mask = nil
            if wasCancelled {
                self.cancelTheTransition?(containerView, self.operation)
            } else {
                self.endTheTransition?(containerView, self.operation)
            }
        }
        maskLayerAnimation.delegate = animationDelegate
        maskLayer.add(maskLayerAnimation, forKey: nil)
        beginTheTransition?(containerView, self.operation)
    }
}
