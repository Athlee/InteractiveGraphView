//
//  PathBuilder.swift
//  Athlee-GraphView
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit 

public protocol PathBuilder {
  associatedtype Point
  func quadCurvedPathWithPoints(points: [Point]) -> UIBezierPath?
}

public extension PathBuilder where Point == CGPoint {
  func quadCurvedPathWithPoints(points: [CGPoint]) -> UIBezierPath? {
    var points = points
    
    guard let firstPoint = points.first else {
      return nil
    }
    
    let path = UIBezierPath()
    path.move(to: firstPoint)
    
    if points.count == 2 {
      path.addLine(to: points[1])
      
      return path
    }
    
    points = points.dropFirst().map { $0 }
    
    var prevPoint = firstPoint
    
    for point in points {
      let midPoint = prevPoint <> point
      path.addQuadCurve(to: midPoint, controlPoint: midPoint <?> prevPoint)
      path.addQuadCurve(to: point, controlPoint: midPoint <?> point)
      
      prevPoint = point
    }
    
    return path
  }
}
