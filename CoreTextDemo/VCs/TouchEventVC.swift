//
//  AnimatedTextViewVC.swift
//  CoreTextDemo
//
//  Created by Chiao-Te Ni on 2018/9/13.
//  Copyright © 2018年 aaron. All rights reserved.
//

import UIKit

class TouchEventVC: BaseVC {

    override func viewDidLoad() {
        let demoView = TouchEventDemoView()
        demoView.backgroundColor = .white
        demoView.vc = self
        view = demoView
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class TouchEventDemoView: UIView {
    
    weak var vc: UIViewController?
    private var clickableRects: [CGRect] = []
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // new context ＆ 將坐標系轉正
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.textMatrix = .identity
        context.translateBy(x: 0, y: rect.height)
        context.scaleBy(x: 1, y: -1)
        
        // new Frame
        let path = CGPath(rect: rect, transform: nil)
        let attrStr = NSMutableAttributedString(string: "This collection of documents is the API reference for the Core Text framework. Core Text provides a modern, low-level programming interface for laying out text and handling fonts. The Core Text layout engine is designed for high performance, ease of use, and close integration with Core Foundation. The text layout API provides high-quality typesetting, including character-to-glyph conversion, with ligatures, kerning, and so on. The complementary Core Text font technology provides automatic font substitution (cascading), font descriptors and collections, easy access to font metrics and glyph data, and many other features. \n\n  Multicore Considerations: All individual functions in Core Text are thread safe. Font objects (CTFont, CTFontDescriptor, and associated objects) can be used simultaneously by multiple operations, work queues, or threads. However, the layout objects (CTTypesetter, CTFramesetter, CTRun, CTLine, CTFrame, and associated objects) should be used in a single operation, work queue, or thread. \n This collection of documents is the API reference for the Core Text framework. Core Text provides a modern, low-level programming interface for laying out text and handling fonts. The Core Text layout engine is designed for high performance, ease of use, and close integration with Core Foundation. The text layout API provides high-quality typesetting, including character-to-glyph conversion, with ligatures, kerning, and so on. The complementary Core Text font technology provides automatic font substitution (cascading), font descriptors and collections, easy access to font metrics and glyph data, and many other features. \n\n  Multicore Considerations: All individual functions in Core Text are thread safe. Font objects (CTFont, CTFontDescriptor, and associated objects) can be used simultaneously by multiple operations, work queues, or threads. However, the layout objects (CTTypesetter, CTFramesetter, CTRun, CTLine, CTFrame, and associated objects) should be used in a single operation, work queue, or thread.")
        
        attrStr.addAttribute(.foregroundColor, value: UIColor.blue, range: NSRange.init(location: 31, length: 10))
        attrStr.addAttribute(.foregroundColor, value: UIColor.blue, range: NSRange.init(location: 45, length: 20))
        attrStr.addAttribute(.foregroundColor, value: UIColor.blue, range: NSRange.init(location: 95, length: 30))
        attrStr.addAttribute(.foregroundColor, value: UIColor.blue, range: NSRange.init(location: 190, length: 30))
        
        attrStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 18), range: NSRange.init(location: 0, length: attrStr.length))
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attrStr as CFAttributedString)
        let range = CFRange.zero
        let frame = CTFramesetterCreateFrame(frameSetter, range, path, nil)
        
        let lines: NSArray = CTFrameGetLines(frame) // 不宣告則預設CFArray 哭出來的難用
        let count = lines.count//CFArrayGetCount(lines)
        var origins: [CGPoint] = Array.init(repeating: .zero, count: count)
        CTFrameGetLineOrigins(frame, CFRange.zero, &origins)
        
        for i in 0 ..< count {
            let line = lines[i] as! CTLine
            let origin = origins[i]
            context.textPosition = origin
            
            let runs: NSArray = CTLineGetGlyphRuns(line)
            runs.forEach { ctRun in
                let run = ctRun as! CTRun
                CTRunDraw(run, context, CFRange.zero)
                
                var runAscent = CGFloat()
                var runDescent = CGFloat()
                
                let width = CGFloat(CTRunGetTypographicBounds(run, CFRange.zero, &runAscent, &runDescent, nil))
                let leftSpacing = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                let runRect = CGRect(x: origin.x + leftSpacing, y: origin.y - runDescent, width: width, height: runAscent)
                
                let attr = CTRunGetAttributes(run) as NSDictionary
                guard let value = attr.object(forKey: NSAttributedStringKey.foregroundColor) as? UIColor else { return }
                guard value == .blue else { return }
                clickableRects.append(runRect)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touchPoint = touches.first?.location(in: self) else { return }
        guard let i = getTouchIndex(for: touchPoint) else { return }
        handleClickEvent(withIndex: i)
    }
    
    private func getTouchIndex(for point: CGPoint) -> Int? {
        for i in 0 ..< clickableRects.count {
            guard let rect: CGRect = clickableRects[safe: i] else { continue }
            guard rect.minX ... rect.maxX ~= point.x else { continue }
            let minY = bounds.height - rect.maxY
            guard minY ... minY + rect.height ~= point.y else { continue }
            return i
        }
        return nil
    }
    
    private func handleClickEvent(withIndex index: Int) {
        let alert = UIAlertController(title: "點擊: \(index)", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        vc?.present(alert, animated: true, completion: nil)
    }
}
