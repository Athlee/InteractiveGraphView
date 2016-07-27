//
//  CanvasType.swift
//  Athlee-GraphView
//
//  Created by mac on 28/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import Foundation

public protocol CanvasType {
  associatedtype View
  var view: View { get }
}