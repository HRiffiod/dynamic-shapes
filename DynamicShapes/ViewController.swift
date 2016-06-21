//
//  ViewController.swift
//  DynamicShapes
//
//  Created by Hugo RIFFIOD on 16/06/2016.
//  Copyright © 2016 hugo. All rights reserved.
//

import UIKit

class ViewController: UIViewController  {
    
    // ----------------------------------------------------------------------------------
    // MARK: - Properties
    // ----------------------------------------------------------------------------------

    var displayLink: CADisplayLink!
    var startTime: CFAbsoluteTime!
    var duration: CFAbsoluteTime!
    var radarLayer: CAShapeLayer!
    let screenWith = UIScreen.mainScreen().bounds.width
    
    // ----------------------------------------------------------------------------------
    // MARK: - Actions
    // ----------------------------------------------------------------------------------
    
    @IBAction func didTapButton(sender: UIButton) {
        if displayLink == nil {
            startDisplayLink()
        } else {
            stopDisplayLink()
            startDisplayLink()
        }
    }
    
    // ----------------------------------------------------------------------------------
    // MARK: - Lifecycle
    // ----------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        drawCircle(radius: self.view.bounds.width/2 - 10)
        drawCircle(radius: self.view.bounds.width/3 - 10)
        drawCircle(radius: self.view.bounds.width/6 - 10)
        drawCircle(radius: self.view.bounds.width/24 - 10)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let layer = CAShapeLayer()
        self.view.layer.addSublayer(layer)
        self.radarLayer = layer
        
        // Rotate around main view's center
        self.radarLayer.frame = self.view.frame
    }
    
    // ----------------------------------------------------------------------------------
    // MARK: - Layer
    // ----------------------------------------------------------------------------------
    
    func updateRadarLayer(radarLayer: CAShapeLayer, percent: CGFloat) {
        let angle = CGFloat(M_PI_4) * (1.0 - percent / 2.0)
        let distance = screenWith/2 * (0.5 + percent / 2.0) - 10.0
        
        // Create a Bezier path
        let path = UIBezierPath()
        
        // Go to view's center as our radar is centered
        path.moveToPoint(self.view.center)
        
        // Create our arc with a distance equal to half of the screen minus an offset
        // Notice how we create a dynamic angle
        path.addArcWithCenter(self.view.center, radius: distance, startAngle: CGFloat(M_PI_2) * 3.0 - angle, endAngle: CGFloat(M_PI_2) * 3.0 + angle, clockwise: true)
        
        // Close the path to form our pie slice cone
        path.closePath()
        
        // Set the previously defined path to our radar layer
        radarLayer.path = path.CGPath
        
        // Update cone color according to distance
        radarLayer.fillColor = colorForPercent(percent).CGColor
        
        // Rotate around z axis
        self.radarLayer.transform = CATransform3DMakeRotation(CGFloat(M_PI) * 4 * percent, 0.0, 0.0, 1.0)
    }
    
    // ----------------------------------------------------------------------------------
    // MARK: - DisplayLink
    // ----------------------------------------------------------------------------------
    
    func startDisplayLink() {
        self.startTime = CFAbsoluteTimeGetCurrent()
        self.duration = 5.0
        self.displayLink = CADisplayLink.init(target: self, selector: #selector(self.handleDisplayLink))
        self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func handleDisplayLink(link: CADisplayLink) {
        let percent = (CFAbsoluteTimeGetCurrent() - self.startTime) / duration
        
        if percent < 1.0 {
            updateRadarLayer(self.radarLayer, percent: CGFloat(percent))
        } else {
            self.stopDisplayLink()
            self.updateRadarLayer(self.radarLayer, percent: 1.0)
        }
    }
    
    func stopDisplayLink() {
        self.displayLink.invalidate()
        self.displayLink = nil
    }
    
    // ----------------------------------------------------------------------------------
    // MARK: - Utils
    // ----------------------------------------------------------------------------------
    
    func drawCircle(radius radius: CGFloat) {
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.view.bounds.width/2,y: self.view.bounds.height/2), radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: false)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.CGPath
        
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = UIColor.whiteColor().CGColor
        shapeLayer.lineWidth = 2.0
        
        view.layer.addSublayer(shapeLayer)
    }
    
    func colorForPercent(percent: CGFloat) -> UIColor {
        return UIColor(red: 1.0 - percent, green: 0.0, blue: percent, alpha: 1)
    }
    
}
