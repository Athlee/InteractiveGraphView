//
//  ViewController.swift
//  Athlee-InteractiveGraphView
//
//  Created by mac on 28/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var interactiveGraphView: InteractiveGraphView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    interactiveGraphView.dataSource = self
    interactiveGraphView.delegate = self
  }
}

extension ViewController: InteractiveGraphViewDataSource, InteractiveGraphViewDelegate {
  func numberOfPoints() -> Int {
    return 7
  }
  
  func interactiveGraphView(_ interactiveGraphView: InteractiveGraphView, valueAtIndex index: Int) -> Double {
    switch index {
    case 0:
      return 10
    case 1:
      return 15
    case 2:
      return 9
    case 3:
      return 6
    case 4:
      return 14
    case 5:
      return 13
    case 6:
      return 7
    default:
      return 0
    }
  }
  
  func interactiveGraphView(_ interactiveGraphView: InteractiveGraphView, titleAtIndex index: Int) -> String {
    switch index {
    case 0:
      return "MON"
    case 1:
      return "TUE"
    case 2:
      return "WED"
    case 3:
      return "THU"
    case 4:
      return "FRI"
    case 5:
      return "SAT"
    case 6:
      return "SUN"
    default:
      return "N/A"
    }
  }
  
  func interactiveGraphView(_ interactiveGraphView: InteractiveGraphView, didSelectPointAtIndex index: Int) {
    if let value = interactiveGraphView.valueForIndex(index) {
      print("Selected value=\(value)")
    }
  }
}
