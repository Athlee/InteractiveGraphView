//
//  InteractiveGraphViewDelegate.swift
//  Athlee-GraphView
//
//  Created by mac on 28/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import Foundation

public protocol InteractiveGraphViewDelegate: class {
  func interactiveGraphView(interactiveGraphView: InteractiveGraphView, didSelectPointAtIndex index: Int)
}

// optional implementations
public extension InteractiveGraphViewDelegate {
  func interactiveGraphView(interactiveGraphView: InteractiveGraphView, didSelectPointAtIndex index: Int) {
    
  }
}