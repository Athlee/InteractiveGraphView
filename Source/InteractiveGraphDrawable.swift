//
//  InteractiveGraphDrawable.swift
//  Athlee-GraphView
//
//  Created by mac on 28/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

public struct InteractiveGraphDrawable<T: CanvasType, U: DecoratorType>: Drawable where T.View == UIView, U.Decorations == InteractiveGraphDecorations {
  
  public let canvas: T
  public let decorator: U

  public func drawCurve(points: [CGPoint]) {
    let curve = CurveView()
    curve.backgroundColor = .clear
    curve.frame = canvas.view.bounds
    curve.points = points
    curve.startColor = decorator.decorations.startColor
    curve.endColor = decorator.decorations.endColor
    curve.curveColor = decorator.decorations.curveColor
    curve.startAlpha = decorator.decorations.startAlpha
    curve.endAlpha = decorator.decorations.endAlpha
    
    canvas.view.addSubview(curve)
  }
  
  public func drawCircle(center: CGPoint, radius: CGFloat) {
    let circlePath = UIBezierPath(arcCenter: center,
                                  radius: radius,
                                  startAngle: 0,
                                  endAngle: CGFloat(M_PI) * 2,
                                  clockwise: false)
    let circleLayer = CAShapeLayer()
    circleLayer.path = circlePath.cgPath
    circleLayer.fillColor = decorator.decorations.dotColor.cgColor
    circleLayer.shadowColor = UIColor.black.cgColor
    circleLayer.shadowOffset = .zero
    circleLayer.shadowRadius = 1
    circleLayer.shadowOpacity = 0.6
    circleLayer.masksToBounds = false
    circleLayer.isOpaque = true
    circleLayer.shouldRasterize = true
    circleLayer.rasterizationScale = UIScreen.main.scale
    
//    let tintCirclePath = UIBezierPath(arcCenter: center,
//                                      radius: radius / 2,
//                                      startAngle: 0,
//                                      endAngle: CGFloat(M_PI) * 2,
//                                      clockwise: false)
//    
//    let tintCircleLayer = CAShapeLayer()
//    tintCircleLayer.path = tintCirclePath.CGPath
//    tintCircleLayer.fillColor = decorator.decorations.dotTintColor.CGColor
    
    canvas.view.layer.addSublayer(circleLayer)
    //canvas.view.layer.addSublayer(tintCircleLayer)
  }
}
