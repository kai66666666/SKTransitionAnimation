//
//  SKTranstionFlipAnimation.swift
//  Test
//
//  Created by sunkai on 2022/6/22.
//  Copyright © 2022 sunkai. All rights reserved.
//

import Foundation

class SKTranstionFlipAnimation: SKTranstionBaseAnimation {
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        
        containerView.addSubview(toVC.view)
        
        let concatTransform: ((CGFloat) -> CATransform3D) = { direction in
            var transform = CATransform3DMakeRotation(Double.pi * 0.5, 0, 1, 0)
            transform.m14 = 0.001 * direction
            return transform
        }
        if operation.isPushOrPresent {
            toVC.view.layer.transform = concatTransform(1)
        } else {
            toVC.view.layer.transform = concatTransform(-1)
        }
        willTheTransition?(containerView, operation)
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration * 0.5, delay: 0, options: .curveLinear) {
            if self.operation.isPushOrPresent {
                fromVC.view.layer.transform = concatTransform(-1)
            } else {
                fromVC.view.layer.transform = concatTransform(1)
            }
            self.beginTheTransition?(containerView, self.operation)
        } completion: { _ in
            let wasCancelled = transitionContext.transitionWasCancelled
            if wasCancelled {
                transitionContext.completeTransition(false)
                self.cancelTheTransition?(containerView, self.operation)
                return
            }
            UIView.animate(withDuration: duration * 0.5, delay: 0, options: .curveLinear) {
                toVC.view.layer.transform = CATransform3DIdentity
            } completion: { _ in
                fromVC.view.layer.transform = CATransform3DIdentity
                transitionContext.completeTransition(!wasCancelled)
                if wasCancelled {
                    self.cancelTheTransition?(containerView, self.operation)
                } else {
                    self.endTheTransition?(containerView, self.operation)
                }
            }
        }
    }
}
