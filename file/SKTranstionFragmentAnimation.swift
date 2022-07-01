//
//  SKTranstionFragmentAnimation.swift
//  swiftTest
//
//  Created by sunkai on 2022/3/1.
//

import UIKit

class SKTranstionFragmentAnimation: SKTranstionBaseAnimation {
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        
        var image: UIImage?
        if operation.isPushOrPresent {
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
            image = toVC.view.skToImage()
            toVC.view.alpha = 0
        } else {
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            image = fromVC.view.skToImage()
            fromVC.view.alpha = 0
        }
        guard let image = image else {
            return
        }

        let horizontal: Double = 20
        let vertical: Double = 40
        let itemWidth = image.size.width / horizontal
        let itemHeight = image.size.height / vertical
        var fragmentViews = [UIView]()
        for i in 0 ..< Int(horizontal) {
            for j in 0 ..< Int(vertical) {
                let x = Double(i) * itemWidth
                let y = Double(j) * itemHeight
                let frame = CGRect.init(x: x, y: y, width: itemWidth, height: itemHeight)
                let subImage = image.skByCrop(to: frame)
                
                let fragmentView = UIImageView()
                fragmentView.image = subImage
                fragmentView.frame = frame
                containerView.addSubview(fragmentView)
                if operation.isPushOrPresent {
                    fragmentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, CGFloat(arc4random() % 50) * 50, 0, 0)
                    fragmentView.alpha = 0
                } else {
                    fragmentView.layer.transform = CATransform3DIdentity
                    fragmentView.alpha = 1
                }
                fragmentViews.append(fragmentView)
            }
        }
        willTheTransition?(containerView, operation)
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
            for fragmentView in fragmentViews {
                if self.operation.isPushOrPresent {
                    fragmentView.layer.transform = CATransform3DIdentity
                    fragmentView.alpha = 1
                } else {
                    fragmentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, CGFloat(arc4random() % 50) * 50, 0, 0)
                    fragmentView.alpha = 0
                }
            }
            self.beginTheTransition?(containerView, self.operation)
        } completion: { _ in
            _ = fragmentViews.map { v in
                v.removeFromSuperview()
            }
            if self.operation.isPushOrPresent {
                toVC.view.alpha = 1
            } else {
                fromVC.view.alpha = 1
            }
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
private extension UIView {
    func skToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
import CoreGraphics
private extension UIImage {
    func skByCrop(to rect: CGRect) -> UIImage? {
        var rect = rect
        rect.origin.x = rect.origin.x * self.scale
        rect.origin.y = rect.origin.y * self.scale
        rect.size.width = rect.size.width * self.scale
        rect.size.height = rect.size.height * self.scale
        guard rect.size.width > 0,
              rect.size.height > 0,
              let cg = self.cgImage,
              let imageRef = cg.cropping(to: rect) else { return nil }
        let image = UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
        return image
    }
}
