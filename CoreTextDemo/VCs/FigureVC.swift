//
//  FigureGestureVC.swift
//  CoreTextDemo
//
//  Created by Chiao-Te Ni on 2018/9/13.
//  Copyright © 2018年 aaron. All rights reserved.
//  原理：先繪製文字，並將圖片的空間空格出來。Then繪製圖片

import UIKit

class FigureVC: BaseVC {

    override func viewDidLoad() {
        view = FigureGestureDemoView()
        view.backgroundColor = .white
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

class FigureGestureDemoView: UIView {
    
    var imgNames: [String] = ["fig1.jpg", "fig2", "fig3.jpg"]
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // new context ＆ 將坐標系轉正
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.textMatrix = .identity
        context.translateBy(x: 0, y: rect.height)
        context.scaleBy(x: 1, y: -1)
        
        // new Frame
        let path = CGPath(rect: rect, transform: nil)
        let attrStr = NSMutableAttributedString(string: "This collection of documents is the API reference for the Core Text framework. Core Text provides a modern, low-level programming interface for laying out text and handling fonts. The Core Text layout engine is designed for high performance, ease of use, and close integration with Core Foundation. The text layout API provides high-quality typesetting, including character-to-glyph conversion, with ligatures, kerning, and so on. The complementary Core Text font technology provides automatic font substitution (cascading), font descriptors and collections, easy access to font metrics and glyph data, and many other features. \n\n  Multicore Considerations: All individual functions in Core Text are thread safe. Font objects (CTFont, CTFontDescriptor, and associated objects) can be used simultaneously by multiple operations, work queues, or threads. However, the layout objects (CTTypesetter, CTFramesetter, CTRun, CTLine, CTFrame, and associated objects) should be used in a single operation, work queue, or thread.")
        
        for i in 0 ... 2 {
            addRunDelegate(with: imgNames[i], attrKey: "img", insertIndex: (i+1) * 40, attribute: attrStr)
        }
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attrStr as CFAttributedString)
        let range = CFRange.zero//(location: 0, length: attrStr.length)
        let frame = CTFramesetterCreateFrame(frameSetter, range, path, nil)
        
        let lines: NSArray = CTFrameGetLines(frame) // 不宣告則預設CFArray 哭出來的難用
        let count = /*lines.count*/CFArrayGetCount(lines)
        var origins: [CGPoint] = Array.init(repeating: .zero, count: count)
        CTFrameGetLineOrigins(frame, CFRange.zero, &origins)
        
        // 連帶圖片進行繪製
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
                
                let attr = CTRunGetAttributes(run) as NSDictionary
                let width = CGFloat(CTRunGetTypographicBounds(run, CFRange.zero, &runAscent, &runDescent, nil))
                let leftSpacing = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                let runRect = CGRect(x: origin.x + leftSpacing, y: origin.y - runDescent, width: width, height: runAscent)
                
                drawImage(runRect: runRect, context: context, attributes: attr)
            }
        }
    }
    
    private func addRunDelegate(with imgName: String, attrKey: String, insertIndex: Int, attribute: NSMutableAttributedString) {
        var imgName = imgName
        var callBack = CTRunDelegateCallbacks(version: kCTRunDelegateCurrentVersion, dealloc: { refCon in
            print("RunDelegate dealloc!")
        }, getAscent: { refCon -> CGFloat in // 高度
            return 100
        }, getDescent: { refCon -> CGFloat in // 底部距離
            return 0
        }, getWidth: { refCon -> CGFloat in // 寬度
            return 100
        })
        
        // 1. 為圖片设置CTRunDelegate, 由delegate決定這個CTRun(預留給圖片)的大小
        guard let runDelegate = CTRunDelegateCreate(&callBack, &imgName) else { return }
        // 2. 設置任一字串給圖片留位置/建立CTRun
        let imgAttr = NSMutableAttributedString(string: " ")
        // 3. 使用runDelegate 佔一個位置
        imgAttr.addAttribute(kCTRunDelegateAttributeName as NSAttributedStringKey, value: runDelegate, range: NSMakeRange(0, 1))
        // 4. 設定參數，用於在forEach CTRun時辨別出是否是圖片預留位置
        imgAttr.addAttribute(NSAttributedStringKey(rawValue: attrKey), value: imgName, range: NSMakeRange(0, 1))
        // 5. 在attribute中插入要產生圖片CTRun的Attribute
        attribute.insert(imgAttr, at: insertIndex)
    }
    
    private func drawImage(runRect: CGRect, context: CGContext, attributes: NSDictionary) {
        guard let imgName = attributes.object(forKey: "img") as? String else { return }
        guard let img = UIImage(named: imgName)?.cgImage else { return }
        context.draw(img, in: runRect)
    }
}
