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
  
  public var decorator: InteractiveGraphDecorator {
    return InteractiveGraphDecorator(decorations:
      InteractiveGraphDecorations(
        startColor: UIColor.whiteColor(),
        endColor: UIColor.whiteColor(),
        curveColor: UIColor.whiteColor(),
        startAlpha: 0.8,
        endAlpha: 0.2,
        dotColor: UIColor(hex: 0xEFEFEF),
        dotTintColor: UIColor(hex: 0x00B6FF)
      )
    )
  }
  
  public lazy var drawable: InteractiveGraphDrawable<InteractiveGraphView, InteractiveGraphDecorator> = {
    return InteractiveGraphDrawable(canvas: self, decorator: self.decorator)
  }()
  
  // MARK: Public properties
  
  public var dataSource: InteractiveGraphViewDataSource? {
    didSet {
      collectDataPoints()
      buildCurve()
    }
  }
  
  public var delegate: InteractiveGraphViewDelegate?
  
  // MARK: Private properties 
  
  private let verticalOffset: CGFloat = 40
  private let dotCircleRadius: CGFloat = 7
  private let textColor = UIColor.whiteColor()
  
  private var values: [Int: (value: Double, title: String)] = [:]
  private var points: [CGPoint] = []
  
  private lazy var formatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .NoStyle
    formatter.maximumFractionDigits = 1
    return formatter
  }()
  
  private lazy var selectionLayer = CALayer()
  
  // MARK: Life cycle
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    let tapRec = UITapGestureRecognizer(target: self, action: #selector(InteractiveGraphView.didRecognizeTapGesture(_:)))
    tapRec.delegate = self
    addGestureRecognizer(tapRec)
    
    let panRec = UIPanGestureRecognizer(target: self, action: #selector(InteractiveGraphView.didRecognizePanGesture(_:)))
    panRec.delegate = self
    addGestureRecognizer(panRec)
  }
  
  public override func drawRect(rect: CGRect) {
    buildCurve()
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
  }
  
  // MARK: Public GraphView funtions 
  
  public func valueForIndex(index: Int) -> Double? {
    return values[index]?.value
  }
  
  // MARK: Setup
  
  private func collectDataPoints() {
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
  
  private func buildCurve() {
    layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    subviews.forEach { $0.removeFromSuperview() }
    
    let horizontalSpace = bounds.width / CGFloat(self.values.count)
    
    let values = self.values.values.map { value, _ in
      return value
      }.map { $0 }
    
    guard let maxValue = values.maxElement() else {
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
      let y = minY - (CGFloat(value) / CGFloat(maxValue)) * distanceDelta
      let point = CGPoint(x: x, y: y)
      
      points += [point]
    }
    
    drawable.drawCurve(points: [CGPoint(x: -bounds.width / 2, y: minY)] + points + [CGPoint(x: bounds.width * 1.5, y: minY)])
    
    addDataPoints()
    addDataPointValueLabels()
    addDataPointLabels()
    addSelectionLayer()
  }
  
  private func addDataPoints() {
    for point in points {
      drawable.drawCircle(center: point, radius: dotCircleRadius)
    }
  }
  
  private func addDataPointValueLabels() {
    for (i, point) in points.enumerate() {
      let label = UILabel()
      label.font = UIFont.systemFontOfSize(15)
      label.textColor = textColor
      label.text = formatter.stringFromNumber(values[i]!.value)
      label.sizeToFit()
      label.center = CGPoint(x: point.x, y: point.y - dotCircleRadius * 2.5)
      
      addSubview(label)
    }
  }
  
  private func addDataPointLabels() {
    for (i, point) in points.enumerate() {
      let label = UILabel()
      label.font = UIFont.systemFontOfSize(13)
      label.textColor = textColor
      label.text = values[i]!.title
      label.sizeToFit()
      label.center = CGPoint(x: point.x, y: bounds.maxY - (label.frame.height))
      
      label.layer.shadowColor = UIColor.blackColor().CGColor
      label.layer.shadowOffset = .zero
      label.layer.shadowRadius = 1
      label.layer.shadowOpacity = 0.6
      label.layer.masksToBounds = false
      label.layer.shouldRasterize = true
      label.layer.rasterizationScale = UIScreen.mainScreen().scale
      
      addSubview(label)
    }
  }
  
  private func addSelectionLayer() {
    let width = bounds.width / CGFloat(self.values.count)
    
    for subview in subviews {
      if let subview = subview as? CurveView {
        selectionLayer.frame.size = CGSize(width: width, height: bounds.height)
        selectionLayer.opaque = false
        selectionLayer.backgroundColor = UIColor.blackColor().alpha(0.7).CGColor
      
        subview.layer.insertSublayer(selectionLayer, atIndex: 1)
        
        let point = points.last!
        selectionLayer.position = CGPoint(x: point.x, y: bounds.midY)
        
        showSelectionLayer(true, animated: false)
      }
    }
  }
 
  // MARK: Gesture recognizers 
  
  internal func didRecognizeTapGesture(recognizer: UITapGestureRecognizer) {
    let point = nearestPoint(to: recognizer.locationInView(self))
    selectionLayer.position.x = point.x
    
    if let index = points.indexOf(point) {
      delegate?.interactiveGraphView(self, didSelectPointAtIndex: index)
    }
  }
  
  private var previousPoint: CGPoint = .zero
  internal func didRecognizePanGesture(recognizer: UIPanGestureRecognizer) {
    selectionLayer.removeAllAnimations()
    let point = recognizer.locationInView(self)
    guard recognizer.state != .Began else {
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
    }
    
    if recognizer.state == .Ended {
      let centerPoint = nearestPoint(to: point)
      selectionLayer.position.x = centerPoint.x
      
      if let index = points.indexOf(centerPoint) {
        delegate?.interactiveGraphView(self, didSelectPointAtIndex: index)
      }
    }
  }
  
  // MARK: Animation helpers 
  
  private func showSelectionLayer(show: Bool, animated: Bool = true) {
    if animated {
      let animation = CABasicAnimation(keyPath: "opacity")
      animation.toValue = show ? 1 : 0
      animation.removedOnCompletion = false
      animation.fillMode = kCAFillModeBoth
      
      selectionLayer.addAnimation(animation, forKey: nil)
    } else {
      selectionLayer.opacity = show ? 1 : 0
    }
  }
  
  // MARK: Geometry helpers 
  
  private func nearestPoint(to point: CGPoint) -> CGPoint {
    let width = bounds.width / CGFloat(self.values.count)
    return points.filter { abs(point.x - $0.x) < width / 2 }.first!
  }
  
  // MARK: Gesture recognizer delegate 
  
  public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
                                shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}