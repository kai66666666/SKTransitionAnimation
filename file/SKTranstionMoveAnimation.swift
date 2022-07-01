//
//  SKTranstionMoveAnimation.swift
//  swiftTest
//
//  Created by sunkai on 2022/3/1.
//

import UIKit

class SKTranstionMoveAnimation: SKTranstionBaseAnimation {
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        let height = bounds.size.height
        
        let fromVCStart: CGAffineTransform = .identity
        var fromVCEnd: CGAffineTransform = .identity
        var toVCStart: CGAffineTransform = .identity
        let toVCEnd: CGAffineTransform = .identity
        
        if animationType == .moveFromLeft {
            if operation.isPushOrPresent {
                toVCStart = CGAffineTransform(translationX: -width, y: 0)
                fromVCEnd = CGAffineTransform(translationX: width * 0.25, y: 0)
                containerView.addSubview(toVC.view)
            } else {
                toVCStart = CGAffineTransform(translationX: width * 0.25, y: 0)
                fromVCEnd = CGAffineTransform(translationX: -width, y: 0)
                containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            }
        } else if animationType == .moveFromRight {
            if operation.isPushOrPresent {
                toVCStart = CGAffineTransform(translationX: width, y: 0)
                fromVCEnd = CGAffineTransform(translationX: -width * 0.25, y: 0)
                containerView.addSubview(toVC.view)
            } else {
                toVCStart = CGAffineTransform(translationX: -width * 0.25, y: 0)
                fromVCEnd = CGAffineTransform(translationX: width, y: 0)
                containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            }
        } else if animationType == .moveFromTop {
            if operation.isPushOrPresent {
                toVCStart = CGAffineTransform(translationX: 0, y: -height)
                containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
            } else {
                fromVCEnd = CGAffineTransform(translationX: 0, y: -height)
                containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            }
        } else if animationType == .moveFromBottom {
            if operation.isPushOrPresent {
                toVCStart = CGAffineTransform(translationX: 0, y: height)
                containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
            } else {
                fromVCEnd = CGAffineTransform(translationX: 0, y: height)
                containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            }
        }
        fromVC.view.transform = fromVCStart
        toVC.view.transform = toVCStart
        willTheTransition?(containerView, operation)
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
            fromVC.view.transform = fromVCEnd
            toVC.view.transform = toVCEnd
            self.beginTheTransition?(containerView, self.operation)
        } completion: { _ in
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
            fromVC.view.transform = .identity
            toVC.view.transform = .identity
            if wasCancelled {
                self.cancelTheTransition?(containerView, self.operation)
            } else {
                self.endTheTransition?(containerView, self.operation)
            }
        }
    }
}
