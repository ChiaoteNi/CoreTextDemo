//
//  RtfVC.swift
//  CoreTextDemo
//
//  Created by Chiao-Te Ni on 2018/9/13.
//  Copyright © 2018年 aaron. All rights reserved.
//

import UIKit
import CoreText
import CoreGraphics

class RtfVC: BaseVC {

    override func viewDidLoad() {
        view = RtfDemoView()
        view.backgroundColor = .white
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

class RtfDemoView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // new context ＆ 將坐標系轉正
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.textMatrix = .identity
        context.translateBy(x: 0, y: rect.height)
        context.scaleBy(x: 1, y: -1)
        
        // new Frame
        let attrStr = NSMutableAttributedString(string: "This collection of documents is the API reference for the Core Text framework. Core Text provides a modern, low-level programming interface for laying out text and handling fonts. The Core Text layout engine is designed for high performance, ease of use, and close integration with Core Foundation. The text layout API provides high-quality typesetting, including character-to-glyph conversion, with ligatures, kerning, and so on. The complementary Core Text font technology provides automatic font substitution (cascading), font descriptors and collections, easy access to font metrics and glyph data, and many other features. \n\n  Multicore Considerations: All individual functions in Core Text are thread safe. Font objects (CTFont, CTFontDescriptor, and associated objects) can be used simultaneously by multiple operations, work queues, or threads. However, the layout objects (CTTypesetter, CTFramesetter, CTRun, CTLine, CTFrame, and associated objects) should be used in a single operation, work queue, or thread.\nThis collection of documents is the API reference for the Core Text framework. Core Text provides a modern, low-level programming interface for laying out text and handling fonts. The Core Text layout engine is designed for high performance, ease of use, and close integration with Core Foundation. The text layout API provides high-quality typesetting, including character-to-glyph conversion, with ligatures, kerning, and so on. The complementary Core Text font technology provides automatic font substitution (cascading), font descriptors and collections, easy access to font metrics and glyph data, and many other features. \n\n  Multicore Considerations: All individual functions in Core Text are thread safe. Font objects (CTFont, CTFontDescriptor, and associated objects) can be used simultaneously by multiple operations, work queues, or threads. However, the layout objects (CTTypesetter, CTFramesetter, CTRun, CTLine, CTFrame, and associated objects) should be used in a single operation, work queue, or thread.")
        attrStr.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: 10)) // 前景色
        attrStr.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 50), range: NSRange(location: 10, length: 20)) //字體
        attrStr.addAttribute(.backgroundColor, value: UIColor.yellow, range: NSRange(location: 30, length: 30))
        attrStr.addAttribute(.kern, value: 10, range: NSRange(location: 100, length: 110))
        let strokeStyles: [NSAttributedStringKey: Any] = [.strokeWidth: 10, .strokeColor: UIColor.blue]
        attrStr.addAttributes(strokeStyles, range: NSMakeRange(150, 60))
        
        let path = CGPath(rect: rect, transform: nil)
        let frameSetter = CTFramesetterCreateWithAttributedString(attrStr as CFAttributedString)
        let range = CFRange(location: 0, length: attrStr.length)
        let frame = CTFramesetterCreateFrame(frameSetter, range, path, nil)
        
        // 用CTFrameDraw
//        CTFrameDraw(frame, context)
        
        let lines: NSArray = CTFrameGetLines(frame) // 將CFArray轉成NSArray，不然哭出來的難用
        let count = /*lines.count*/CFArrayGetCount(lines)
        var origins: [CGPoint] = Array.init(repeating: .zero, count: count)
        CTFrameGetLineOrigins(frame, CFRange.zero, &origins)
        
        // 用CTLineDraw
//        for i in 0 ..< count {
//            let line = lines[i] as! CTLine
//            context.textPosition = origins[i]
//            CTLineDraw(line, context)
//        }
//
        // 用CTRunDraw
        for i in 0 ..< count {
            let line = lines[i] as! CTLine
            context.textPosition = origins[i]
            let runs: NSArray = CTLineGetGlyphRuns(line)
            runs.forEach { run in
                CTRunDraw(run as! CTRun, context, CFRange.zero)
            }
        }
    }
}
