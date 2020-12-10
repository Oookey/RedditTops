//
//  aw.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 10.12.2020.
//

import UIKit

class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  private let duration: TimeInterval = 0.3
  
  var originFrame: CGRect = .zero
  var presenting: Bool = true
  var dismissCompletion: (() -> Void)?
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)
  -> TimeInterval {
    return self.duration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    let toView = transitionContext.view(forKey: .to)
    
    guard
      let contentView = self.presenting ? toView : transitionContext.view(forKey: .from)
    else { return }
    
    let initialFrame = self.presenting ? self.originFrame : contentView.frame
    let finalFrame = self.presenting ? contentView.frame : self.originFrame
    
    let xScaleFactor = self.presenting ?
      initialFrame.width / finalFrame.width :
      finalFrame.width / initialFrame.width
    
    let yScaleFactor = self.presenting ?
      initialFrame.height / finalFrame.height :
      finalFrame.height / initialFrame.height
    
    let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
    
    if self.presenting {
      contentView.transform = scaleTransform
      contentView.center = CGPoint(
        x: initialFrame.midX,
        y: initialFrame.midY)
      contentView.clipsToBounds = true
    }
    
    contentView.layer.cornerRadius = self.presenting ? 20.0 : 0.0
    contentView.layer.masksToBounds = true
    
    if let toView = toView {
      containerView.addSubview(toView)
    }
    containerView.bringSubviewToFront(contentView)
    
    UIView.animate(withDuration: self.duration, animations: {
      contentView.transform = self.presenting ? .identity : scaleTransform
      contentView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
      contentView.layer.cornerRadius = !self.presenting ? 20.0 : 0.0
    }, completion: { _ in
      if !self.presenting {
        self.dismissCompletion?()
      }
      transitionContext.completeTransition(true)
    })
  }
}
