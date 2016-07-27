//
//  DecoratorType.swift
//  Athlee-GraphView
//
//  Created by mac on 28/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import Foundation

public protocol DecoratorType {
  associatedtype Decorations
  var decorations: Decorations { get }
}