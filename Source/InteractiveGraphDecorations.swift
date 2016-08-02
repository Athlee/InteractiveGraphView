//
//  InteractiveGraphDecorations.swift
//  Athlee-GraphView
//
//  Created by mac on 28/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit 

public struct InteractiveGraphDecorations {
  public let startColor: UIColor
  public let endColor: UIColor
  public let curveColor: UIColor
  public let startAlpha: CGFloat
  public let endAlpha: CGFloat
  
  public let dotColor: UIColor
  public let dotTintColor: UIColor

  public let selectionColor: UIColor
  
  public init(startColor: UIColor,
              endColor: UIColor,
              curveColor: UIColor,
              startAlpha: CGFloat,
              endAlpha: CGFloat,
              dotColor: UIColor,
              dotTintColor: UIColor,
              selectionColor: UIColor) {
    
    self.startColor = startColor
    self.endColor = endColor
    self.curveColor = curveColor
    self.startAlpha = startAlpha
    self.endAlpha = endAlpha
    self.dotColor = dotColor
    self.dotTintColor = dotTintColor
    self.selectionColor = selectionColor
  }
}