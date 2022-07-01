//
//  SKTranstionCoverAnimation.swift
//  swiftTest
//
//  Created by sunkai on 2022/3/1.
//

import UIKit

class SKTranstionCoverAnimation: SKTranstionBaseAnimation {
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        
        if operation.isPushOrPresent {
            toVC.view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            toVC.view.alpha = 0
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        } else {
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        }
        willTheTransition?(containerView, operation)
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
            if self.operation.isPushOrPresent {
                toVC.view.transform = .identity
                toVC.view.alpha = 1
            } else {
                fromVC.view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                fromVC.view.alpha = 0
            }
            self.beginTheTransition?(containerView, self.operation)
        } completion: { _ in
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
            if wasCancelled {
                self.cancelTheTransition?(containerView, self.operation)
            } else {
                self.endTheTransition?(containerView, self.operation)
            }
        }
    }
}
