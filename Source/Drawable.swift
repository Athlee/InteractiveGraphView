//
//  Drawable.swift
//  Athlee-GraphView
//
//  Created by mac on 28/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit 

public protocol Drawable {
  associatedtype Canvas: CanvasType
  associatedtype Decorator: DecoratorType
  
  var canvas: Canvas { get }
  var decorator: Decorator { get }
  
  func drawLine(startPoint startPoint: CGPoint, endPoint: CGPoint)
  func drawCircle(center center: CGPoint, radius: CGFloat)
  func drawCurve(points points: [CGPoint])
}

public extension Drawable {
  func drawLine(startPoint startPoint: CGPoint, endPoint: CGPoint) { }
  func drawCircle(center center: CGPoint, radius: CGFloat) { }
  func drawCurve(points points: [CGPoint]) { }
}