//
//  CurveView.swift
//  Athlee-GraphView
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

public extension UIColor {
  func alpha(alpha: CGFloat) -> UIColor {
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

public class CurveView: UIView, PathBuilder {
  public var points: [CGPoint] = [] {
    didSet {
      setNeedsDisplay()
    }
  }
  
  public var startColor: UIColor = UIColor.whiteColor() {
    didSet {
      setNeedsDisplay()
    }
  }
  
  public var endColor: UIColor = UIColor.whiteColor() {
    didSet {
      setNeedsDisplay()
    }
  }
  
  public var curveColor: UIColor = UIColor.whiteColor() {
    didSet {
      setNeedsDisplay()
    }
  }
  
  public var startAlpha: CGFloat = 0.8 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  
  public var endAlpha: CGFloat = 0.2 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @available(*, unavailable, deprecated=0.0.5, message="The curve view is now using a bitmap images for better performance.")
  public private(set) var curveLayer: CAShapeLayer?
  
  @available(*, unavailable, deprecated=0.0.5, message="The curve view is now using a bitmap images for better performance.")
  public private(set) var gradientLayer: CAGradientLayer?
  
  @available(*, unavailable, deprecated=0.0.5, message="The curve view is now using a bitmap images for better performance.")
  public private(set) var gradientView: UIView?
  
  override public func drawRect(rect: CGRect) {
    //// Draw the curve line.
    guard let path = quadCurvedPathWithPoints(points) else {
      return
    }
    
    guard let first = points.first, last = points.last else {
      return
    }
    
    opaque = true
    
    layer.rasterizationScale = traitCollection.displayScale
    layer.shouldRasterize = true
    layer.drawsAsynchronously = true
    
    //// Clip the curve, so we can get the final shape.
    let clippingPath = path.copy() as! UIBezierPath
    
    clippingPath.addLineToPoint(CGPoint(x: last.x, y: bounds.height))
    clippingPath.addLineToPoint(CGPoint(x: first.x, y: bounds.height))
    clippingPath.closePath()
    
    
    
    let context = UIGraphicsGetCurrentContext()
    
    //// Gradient Declarations
    let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(),
                                              [startColor.alpha(startAlpha).CGColor,
                                                endColor.alpha(endAlpha).CGColor],
                                              [0.05, 1])!
    
    //// Oval Drawing
    CGContextSaveGState(context)
    clippingPath.addClip()
    
    CGContextDrawLinearGradient(context,
                                gradient,
                                CGPoint(x: bounds.midX, y: bounds.minY),
                                CGPoint(x: bounds.midX, y: bounds.maxY),
                                CGGradientDrawingOptions())
    
    CGContextRestoreGState(context)
    
    //// Shadow Declarations
    let shadow = NSShadow()
    shadow.shadowColor = UIColor.blackColor()
    shadow.shadowOffset = CGSizeMake(0.1, 1.1)
    shadow.shadowBlurRadius = 2
    
    CGContextSaveGState(context)
    CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, (shadow.shadowColor as! UIColor).CGColor)
    curveColor.set()
    path.lineWidth = 3.5
    path.stroke()
    CGContextRestoreGState(context)
  }
}