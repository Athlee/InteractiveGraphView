//
//  InteractiveGraphViewDataSource.swift
//  Athlee-GraphView
//
//  Created by mac on 28/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import Foundation

public protocol InteractiveGraphViewDataSource: class {
  func numberOfPoints() -> Int
  func interactiveGraphView(interactiveGraphView: InteractiveGraphView, valueAtIndex index: Int) -> Double
  func interactiveGraphView(interactiveGraphView: InteractiveGraphView, titleAtIndex index: Int) -> String
}