//
//  InteractiveGraphView.swift
//  Athlee-GraphView
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit

public final class InteractiveGraphView: UIView, CanvasType, UIGestureRecognizerDelegate {
  
  // MARK: CanvasType properties 
  
  public var view: UIView {
    return self
  }
  
  public lazy var decorator: InteractiveGraphDecorator = {
    return InteractiveGraphDecorator(decorations:
      InteractiveGraphDecorations(
        startColor: UIColor.white,
        endColor: UIColor.white,
        curveColor: UIColor.white,
        startAlpha: 0.6,
        endAlpha: 0.05,
        dotColor: UIColor(hex: 0xEFEFEF),
        dotTintColor: UIColor(hex: 0x00B6FF),
        selectionColor: UIColor(hex: 0x00B6FF)
      )
    )
  }()
  
  public lazy var drawable: InteractiveGraphDrawable<InteractiveGraphView, InteractiveGraphDecorator> = {
    return InteractiveGraphDrawable(canvas: self, decorator: self.decorator)
  }()
  
  // MARK: Public properties
  
  public var dataSource: InteractiveGraphViewDataSource? {
    didSet {
      reloadData()
    }
  }
  
  public var delegate: InteractiveGraphViewDelegate?
  
  public var selectedIndex: Int? {
    didSet {
      if let selectedIndex = selectedIndex, selectedIndex < 0 { self.selectedIndex = nil  }
      guard !points.isEmpty else { return }
      //updateSelectedDot()
    }
  }
  
  public var selectedValue: (value: Double, title: String)? {
    guard let index = selectedIndex else {
      return nil
    }
    
    return values[index]
  }
  
  // MARK: Private properties
  
  fileprivate let verticalOffset: CGFloat = 40
  fileprivate let dotCircleRadius: CGFloat = 7
  fileprivate let textColor = UIColor.white
  
  public fileprivate(set) var values: [Int : (value: Double, title: String)] = [:]
  public fileprivate(set) var points: [CGPoint] = []
  
  fileprivate lazy var formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .none
    formatter.maximumFractionDigits = 1
    return formatter
  }()
  
  fileprivate lazy var selectionLayer = CALayer()
  
  public fileprivate(set) lazy var selectedDot = CALayer()
  
  // MARK: Life cycle
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    let radius = self.dotCircleRadius * 1.3
    selectedDot.frame.size = CGSize(width: radius, height: radius)
    selectedDot.cornerRadius = radius / 2
    selectedDot.backgroundColor = self.decorator.decorations.dotTintColor.cgColor
    
    let tapRec = UITapGestureRecognizer(target: self, action: #selector(InteractiveGraphView.didRecognizeTapGesture(_:)))
    tapRec.delegate = self
    addGestureRecognizer(tapRec)
    
    let panRec = UIPanGestureRecognizer(target: self, action: #selector(InteractiveGraphView.didRecognizePanGesture(_:)))
    panRec.delegate = self
    addGestureRecognizer(panRec)
  }
  
  public override func draw(_ rect: CGRect) {
    buildCurve()
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    if let index = selectedIndex, index < points.count {
      selectedDot.position = points[index]
    }
  }
  
  // MARK: Public GraphView funtions 
  
  public func valueForIndex(_ index: Int) -> Double? {
    return values[index]?.value
  }
  
  public func reloadData(animated: Bool = false) {
    selectedDot.removeFromSuperlayer()
    selectedDot.backgroundColor = decorator.decorations.dotTintColor.cgColor
    
    if animated {
      UIView.animate(withDuration: 0.1, animations: {
        self.alpha = 0
      }) 
    }
    
    reset()
    collectDataPoints()
    buildCurve()
    
    selectedIndex = points.count - 1
    
    if animated {
      UIView.animate(withDuration: 0.3, animations: {
        self.alpha = 1
      }) 
    }
  }
  
  // MARK: Private utils 
  
  fileprivate func reset() {
    values = [:]
  }
  
  fileprivate func updateSelectedDot() {
    guard !points.isEmpty else { return }
    guard let index = selectedIndex else { return }
    
    let center = points[index]
    
    CATransaction.begin()
    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    selectedDot.position = center
    CATransaction.commit()
    
    layer.addSublayer(selectedDot)
  }
  
  // MARK: Setup
  
  fileprivate func collectDataPoints() {
    guard let dataSource = dataSource else {
      return
    }
    
    let numberOfPoints = dataSource.numberOfPoints()
    
    for i in 0..<numberOfPoints {
      let (value, title): (Double, String)
      value = dataSource.interactiveGraphView(self, valueAtIndex: i)
      title = dataSource.interactiveGraphView(self, titleAtIndex: i)
      
      values[i] = (value, title)
    }
  }
  
  fileprivate func buildCurve() {
    layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    
    let horizontalSpace = bounds.width / CGFloat(self.values.count)
    
    let values = self.values.values.map { value, _ in
      return value
      }.map { $0 }
    
    guard let maxValue = values.max() else {
      return
    }
    
    points = []
    
    let maxY = bounds.minY + verticalOffset
    let minY = bounds.maxY - verticalOffset
    
    let distanceDelta = minY - maxY
    
    for i in 0..<self.values.count {
      guard let value = self.values[i]?.value else {
        continue
      }
      
      let x = (CGFloat(i) + 0.5) * horizontalSpace
      let valueDelta = maxValue != 0 ? (CGFloat(value) / CGFloat(maxValue)) : 0
      let y = minY - valueDelta * distanceDelta
      let point = CGPoint(x: x, y: y)
      
      points += [point]
    }
    
    layer.drawsAsynchronously = true 
    
    drawable.drawCurve(points: [CGPoint(x: -bounds.width / 2, y: minY)] + points + [CGPoint(x: bounds.width * 1.5, y: minY)])
    
    addDataPoints()
    addDataPointValueLabels()
    addDataPointLabels()
    addSelectionLayer()
  }
  
  fileprivate func addDataPoints() {
    for point in points {
      drawable.drawCircle(center: point, radius: dotCircleRadius)
    }
  }
  
  fileprivate func addDataPointValueLabels() {
    for (i, point) in points.enumerated() {
      let label = UILabel()
      let value = values[i]!.value
      
      label.font = UIFont.systemFont(ofSize: 15)
      label.textColor = textColor.alpha(0.7)
      label.text = formatter.string(from: NSNumber(value: value))
      label.sizeToFit()
      label.center = CGPoint(x: point.x, y: point.y - dotCircleRadius * 2.5)
      
      addSubview(label)
    }
  }
  
  fileprivate func addDataPointLabels() {
    for (i, point) in points.enumerated() {
      let label = UILabel()
      label.font = UIFont.systemFont(ofSize: 13)
      label.textColor = textColor.alpha(0.7)
      label.text = values[i]!.title
      label.sizeToFit()
      label.center = CGPoint(x: point.x, y: bounds.maxY - (label.frame.height))
      
      label.layer.shadowColor = UIColor.black.cgColor
      label.layer.shadowOffset = .zero
      label.layer.shadowRadius = 1
      label.layer.shadowOpacity = 0.6
      label.layer.masksToBounds = false
      label.layer.shouldRasterize = true
      label.layer.rasterizationScale = traitCollection.displayScale
      label.layer.isOpaque = false
      
      addSubview(label)
    }
  }
  
  fileprivate func addSelectionLayer() {
    let width = bounds.width / CGFloat(self.values.count)
    
    for subview in subviews {
      if let subview = subview as? CurveView {
        
        selectionLayer.frame.size = CGSize(width: width, height: bounds.height)
        selectionLayer.isOpaque = true
        selectionLayer.rasterizationScale = traitCollection.displayScale
        selectionLayer.shouldRasterize = true
        
        selectionLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let selectionColor = decorator.decorations.selectionColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.isOpaque = false
        gradientLayer.frame = selectionLayer.bounds
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.colors = [
          selectionColor.alpha(0).cgColor,
          selectionColor.alpha(0.45).cgColor,
          selectionColor.alpha(0.7).cgColor
        ]
        
        gradientLayer.locations = [ 0, 0.8, 1 ]
        
        selectionLayer.addSublayer(gradientLayer)
        selectionLayer.backgroundColor = UIColor.clear.cgColor
      
        subview.layer.insertSublayer(selectionLayer, at: 1)
        
        let point = points.last!
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
          OperationQueue.main.addOperation {
            self.updateSelectedDot()
          }
        }
        
        selectionLayer.position = CGPoint(x: point.x, y: bounds.midY)
        
        CATransaction.commit()
        
        
        
        showSelectionLayer(true, animated: false)
      }
    }
  }
 
  // MARK: Gesture recognizers 
  
  internal func didRecognizeTapGesture(_ recognizer: UITapGestureRecognizer) {
    let point = nearestPoint(to: recognizer.location(in: self))
    selectionLayer.position.x = point.x
    
    if let index = points.index(of: point), selectedIndex != index {
      selectedIndex = index
      delegate?.interactiveGraphView(self, didSelectPointAtIndex: index)
      updateSelectedDot()
    }
  }
  
  fileprivate var previousPoint: CGPoint = .zero
  internal func didRecognizePanGesture(_ recognizer: UIPanGestureRecognizer) {
    selectionLayer.removeAllAnimations()
    let point = recognizer.location(in: self)
    guard recognizer.state != .began else {
      let centerPoint = nearestPoint(to: point)
      selectionLayer.position.x = centerPoint.x
      
      previousPoint = point
      return
    }
    
    let delta = point.x - previousPoint.x
    previousPoint = point
    
    if selectionLayer.frame.minX + delta >= 0 && selectionLayer.frame.maxX + delta <= bounds.maxX {
      // disable implicit animations
      CATransaction.begin()
      CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
      selectionLayer.frame.origin.x += delta
      CATransaction.commit()
      
      let centerPoint = nearestPoint(to: point)
      if let index = points.index(of: centerPoint), selectedIndex != index {
        selectedIndex = index
        delegate?.interactiveGraphView(self, didSelectPointAtIndex: index)
        updateSelectedDot()
      }
    }
    
    if recognizer.state == .ended {
      let centerPoint = nearestPoint(to: point)
      selectionLayer.position.x = centerPoint.x
    }
  }
  
  // MARK: Animation helpers 
  
  fileprivate func showSelectionLayer(_ show: Bool, animated: Bool = true) {
    if animated {
      let animation = CABasicAnimation(keyPath: "opacity")
      animation.toValue = show ? 1 : 0
      animation.isRemovedOnCompletion = false
      animation.fillMode = kCAFillModeBoth
      
      selectionLayer.add(animation, forKey: nil)
    } else {
      selectionLayer.opacity = show ? 1 : 0
    }
  }
  
  // MARK: Geometry helpers 
  
  fileprivate func nearestPoint(to point: CGPoint) -> CGPoint {
    let width = bounds.width / CGFloat(self.points.count)
    return points.filter { abs(point.x - $0.x) <= width / 2 }.first!
  }
  
  // MARK: Gesture recognizer delegate 
  
  public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
