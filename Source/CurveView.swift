//
//  CurveView.swift
//  Athlee-GraphView
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

public extension UIColor {
  func alpha(_ alpha: CGFloat) -> UIColor {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var _alpha: CGFloat = 0
    
    getRed(&red, green: &green, blue: &blue, alpha: &_alpha)
    
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
}

internal extension UIColor {
  convenience init(hex: Int) {
    let red = CGFloat((hex & 0xFF0000) >> 16) / CGFloat(255)
    let green = CGFloat((hex & 0xFF00) >> 8) / CGFloat(255)
    let blue = CGFloat((hex & 0xFF) >> 0) / CGFloat(255)
    
    self.init(red: red, green: green, blue: blue, alpha: 1)
  }
}

/// Finds the middle point with given two CGPoints.
infix operator <> { associativity left precedence 160 }

func <>(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
  return CGPoint(x: (lhs.x + rhs.x) / 2, y: (lhs.y + rhs.y) / 2)
}

/// Finds the control point between two CGPoints.
infix operator <?> { associativity left precedence 160 }

func <?>(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
  let midPoint = lhs <> rhs
  let deltaY = abs(rhs.y - midPoint.y)
  
  var point = midPoint
  
  if lhs.y < rhs.y {
    point.y += deltaY
  } else {
    point.y -= deltaY
  }
  
  return point
}

open class CurveView: UIView, PathBuilder {
  open var points: [CGPoint] = [] {
    didSet {
      setNeedsDisplay()
    }
  }
  
  open var startColor: UIColor = UIColor.white {
    didSet {
      setNeedsDisplay()
    }
  }
  
  open var endColor: UIColor = UIColor.white {
    didSet {
      setNeedsDisplay()
    }
  }
  
  open var curveColor: UIColor = UIColor.white {
    didSet {
      setNeedsDisplay()
    }
  }
  
  open var startAlpha: CGFloat = 0.8 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  
  open var endAlpha: CGFloat = 0.2 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @available(*, unavailable, deprecated: 0.0.5, message: "The curve view is now using a bitmap images for better performance.")
  open fileprivate(set) var curveLayer: CAShapeLayer?
  
  @available(*, unavailable, deprecated: 0.0.5, message: "The curve view is now using a bitmap images for better performance.")
  open fileprivate(set) var gradientLayer: CAGradientLayer?
  
  @available(*, unavailable, deprecated: 0.0.5, message: "The curve view is now using a bitmap images for better performance.")
  open fileprivate(set) var gradientView: UIView?
  
  override open func draw(_ rect: CGRect) {
    //// Draw the curve line.
    guard let path = quadCurvedPathWithPoints(points: points) else {
      return
    }
    
    guard let first = points.first, let last = points.last else {
      return
    }
    
    isOpaque = true
    
    layer.rasterizationScale = traitCollection.displayScale
    layer.shouldRasterize = true
    layer.drawsAsynchronously = true
    
    //// Clip the curve, so we can get the final shape.
    let clippingPath = path.copy() as! UIBezierPath
    
    clippingPath.addLine(to: CGPoint(x: last.x, y: bounds.height))
    clippingPath.addLine(to: CGPoint(x: first.x, y: bounds.height))
    clippingPath.close()
    
    
    
    let context = UIGraphicsGetCurrentContext()
    
    //// Gradient Declarations
    
    
    
    let colors = [startColor.alpha(startAlpha).cgColor,
                  endColor.alpha(endAlpha).cgColor] as CFArray
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                              colors: colors,
                                              locations: [0.05, 1])!
    
    //// Oval Drawing
    context?.saveGState()
    clippingPath.addClip()
    
    context?.drawLinearGradient(gradient,
                                start: CGPoint(x: bounds.midX, y: bounds.minY),
                                end: CGPoint(x: bounds.midX, y: bounds.maxY),
                                options: CGGradientDrawingOptions())
    
    context?.restoreGState()
    
//    let gradientLayer = CAGradientLayer()
//    gradientLayer.frame = bounds
//    gradientLayer.locations = [0.05, 1]
//    gradientLayer.colors = [startColor.alpha(startAlpha).CGColor,
//                            endColor.alpha(endAlpha).CGColor]
//    gradientLayer.rasterizationScale = traitCollection.displayScale
//    gradientLayer.shouldRasterize = true
//    gradientLayer.opaque = true
//    
//    let gradientMask = CAShapeLayer()
//    gradientMask.path = clippingPath.CGPath
//    gradientLayer.mask = gradientMask
//    
//    layer.addSublayer(gradientLayer)
    
    //// Shadow Declarations
    let shadow = NSShadow()
    shadow.shadowColor = UIColor.black
    shadow.shadowOffset = CGSize(width: 0.1, height: 1.1)
    shadow.shadowBlurRadius = 2
    
    context?.saveGState()
    context?.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: (shadow.shadowColor as! UIColor).cgColor)
    curveColor.set()
    path.lineWidth = 3.5
    path.stroke()
    context?.restoreGState()
  }
}
