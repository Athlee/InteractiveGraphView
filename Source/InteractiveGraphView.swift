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
        startColor: UIColor.whiteColor(),
        endColor: UIColor.whiteColor(),
        curveColor: UIColor.whiteColor(),
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
  
  public var selectedIndex: Int = 0 {
    didSet {
      guard !points.isEmpty else { return }
      updateSelectedDot()
    }
  }
  
  public var selectedValue: (value: Double, title: String)? {
    return values[selectedIndex]
  }
  
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
  
  private lazy var selectedDot: UIView = {
    let radius = self.dotCircleRadius * 1.3
    
    let selectedDot = UIView()
    selectedDot.frame.size = CGSize(width: radius, height: radius)
    selectedDot.layer.cornerRadius = radius / 2
    selectedDot.backgroundColor = self.decorator.decorations.dotTintColor
    
    return selectedDot
  }()
  
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
    updateSelectedDot()
  }
  
  // MARK: Public GraphView funtions 
  
  public func valueForIndex(index: Int) -> Double? {
    return values[index]?.value
  }
  
  public func reloadData() {
    selectedDot.removeFromSuperview()
    selectedDot.backgroundColor = decorator.decorations.dotTintColor
    
    reset()
    collectDataPoints()
    buildCurve()
    
    selectedIndex = points.count - 1
  }
  
  // MARK: Private utils 
  
  private func reset() {
    values = [:]
  }
  
  private func updateSelectedDot() {
    guard !points.isEmpty else { return }
    
    let center = points[selectedIndex]
    selectedDot.center = center
    selectedDot.transform = CGAffineTransformMakeScale(0.7, 0.7)
    view.addSubview(selectedDot)
    
    UIView.animateWithDuration(
      0.5,
      delay: 0,
      usingSpringWithDamping: 0.4,
      initialSpringVelocity: 0,
      options: .CurveEaseInOut,
      animations: {
        self.selectedDot.transform = CGAffineTransformIdentity
      },
      completion: nil
    )
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
    
    layer.drawsAsynchronously = true 
    
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
      label.textColor = textColor.alpha(0.7)
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
      label.textColor = textColor.alpha(0.7)
      label.text = values[i]!.title
      label.sizeToFit()
      label.center = CGPoint(x: point.x, y: bounds.maxY - (label.frame.height))
      
      label.layer.shadowColor = UIColor.blackColor().CGColor
      label.layer.shadowOffset = .zero
      label.layer.shadowRadius = 1
      label.layer.shadowOpacity = 0.6
      label.layer.masksToBounds = false
      label.layer.shouldRasterize = true
      label.layer.rasterizationScale = traitCollection.displayScale
      label.layer.opaque = false
      
      addSubview(label)
    }
  }
  
  private func addSelectionLayer() {
    let width = bounds.width / CGFloat(self.values.count)
    
    for subview in subviews {
      if let subview = subview as? CurveView {
        
        selectionLayer.frame.size = CGSize(width: width, height: bounds.height)
        selectionLayer.opaque = false
        
        selectionLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let selectionColor = decorator.decorations.selectionColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.opaque = false
        gradientLayer.frame = selectionLayer.bounds
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.colors = [
          selectionColor.alpha(0).CGColor,
          selectionColor.alpha(0.45).CGColor,
          selectionColor.alpha(0.7).CGColor
        ]
        
        gradientLayer.locations = [ 0, 0.8, 1 ]
        
        selectionLayer.addSublayer(gradientLayer)
        selectionLayer.backgroundColor = UIColor.clearColor().CGColor
      
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
    
    if let index = points.indexOf(point) where selectedIndex != index {
      selectedIndex = index
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
      
      let centerPoint = nearestPoint(to: point)
      if let index = points.indexOf(centerPoint) where selectedIndex != index {
        selectedIndex = index
        delegate?.interactiveGraphView(self, didSelectPointAtIndex: index)
      }
    }
    
    if recognizer.state == .Ended {
      let centerPoint = nearestPoint(to: point)
      selectionLayer.position.x = centerPoint.x
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
    let width = bounds.width / CGFloat(self.points.count)
    return points.filter { abs(point.x - $0.x) <= width / 2 }.first!
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