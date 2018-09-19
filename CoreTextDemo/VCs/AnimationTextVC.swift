//
//  AnimationTextVC.swift
//  CoreTextDemo
//
//  Created by Chiao-Te Ni on 2018/9/13.
//  Copyright © 2018年 aaron. All rights reserved.
//

import UIKit

class AnimationTextVC: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var dynaminTextView: DynamicTextView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        dynaminTextView.addGestureRecognizer(gesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        dynaminTextView.text = textField.text ?? ""
    }
    
    @objc private func hideKeyboard() {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}

class DynamicTextView: UIView {
    
    private var shapeLayer: CAShapeLayer = CAShapeLayer()
    
    var text: String = "" {
        didSet { changePath(with: text) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        shapeLayer.frame = rect
    }
    
    private func setup() {
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(shapeLayer)
    }
    
    private func changePath(with text: String) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 2
        
        shapeLayer.isGeometryFlipped = true
        shapeLayer.position = CGPoint(x: shapeLayer.bounds.width/2, y: 0)//-shapeLayer.bounds.height/2)
        
        shapeLayer.path = text.getPath(withFont: UIFont.boldSystemFont(ofSize: 60)).cgPath
        shapeLayer.add(animation, forKey: animation.keyPath)
        
        let penImage: UIImage = #imageLiteral(resourceName: "pen1")
        let penLayer = CALayer()
        penLayer.contents = penImage.cgImage
        penLayer.anchorPoint = CGPoint.zero
        penLayer.frame = CGRect(x: 0, y: 0, width: 30, height: 30)

        let penAnimation = CAKeyframeAnimation.init(keyPath: "position")
        penAnimation.duration = animation.duration
        penAnimation.path = shapeLayer.path
        penAnimation.calculationMode = kCAAnimationPaced
        penAnimation.isRemovedOnCompletion = false
        penAnimation.fillMode = kCAFillModeForwards
        penLayer.add(penAnimation, forKey: "position")
        penLayer.perform(#selector(CALayer.removeFromSuperlayer), with: nil, afterDelay: penAnimation.duration + 0.2)
        shapeLayer.addSublayer(penLayer)
    }
}


extension String {
    func getPath(withFont font: UIFont) -> UIBezierPath {
        let pathes = CGMutablePath()
        let fontRef = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        let attrString = NSAttributedString(string: self, attributes: [kCTFontAttributeName as NSAttributedStringKey: fontRef])

        let line = CTLineCreateWithAttributedString(attrString)
        let runs: [CTRun] = CTLineGetGlyphRuns(line) as! [CTRun]
        
        for run in runs {
            let attribute: NSDictionary = CTRunGetAttributes(run)
            let ctFont = attribute[kCTFontAttributeName] as! CTFont

            for i in 0 ..< CTRunGetGlyphCount(run) {
                // take one glyph from run
                let range = CFRange(location: i, length: 1)
                // create array to hold glyphs, this should have array with one item
                var glyphs = [CGGlyph](repeating: 0, count: range.length)
                // create position holder
                var position = CGPoint()
                // get glyph
                CTRunGetGlyphs(run, range, &glyphs)
                // glyph postion
                CTRunGetPositions(run, range, &position)
                // append glyph path to letters
                for glyph in glyphs {
                    guard let path = CTFontCreatePathForGlyph(ctFont, glyph, nil) else { continue }
                    pathes.addPath(path, transform: CGAffineTransform(translationX: position.x, y: position.y))
                }
            }
        }
        
        let rotatedPath = CGMutablePath()
        rotatedPath.addPath(pathes, transform: CGAffineTransform(scaleX: 1, y: 1))
//        rotatedPath.addPath(pathes, transform: CGAffineTransform(scaleX: 1, y: -1))
        let movedPath = CGMutablePath()
        movedPath.addPath(rotatedPath, transform: CGAffineTransform(translationX: 0, y: rotatedPath.boundingBoxOfPath.height))

        let bezier = UIBezierPath(cgPath: movedPath)
        return bezier
    }
}
