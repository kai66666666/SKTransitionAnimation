//
//  SKTranstionPointAnimation.swift
//  swiftTest
//
//  Created by sunkai on 2022/3/1.
//

import UIKit
import SKAnimationDelegate

class SKTranstionPointAnimation: SKTranstionBaseAnimation {
    override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        let height = bounds.size.height
        
        var point = CGPoint.zero
        if animationType == .pointSpread {
            point = .init(x: width * 0.5, y: height * 0.5)
        } else if animationType == .randomPointSpread {
            let randomWidth = arc4random() % (UInt32(width))
            let randomHeight = arc4random() % (UInt32(height))
            point = .init(x: Int(randomWidth), y: Int(randomHeight))
        }
        let fromRect = CGRect(origin: point, size: .init(width: 1, height: 1))
        let smallPath = UIBezierPath(ovalIn: fromRect)
        let radius = sqrt(width * width + height * height)
        let bigPath = UIBezierPath(arcCenter: containerView.center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
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
