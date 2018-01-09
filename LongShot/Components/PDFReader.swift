//
//  PDFReader.swift
//  LongShot
//
//  Created by Brandon on 2018-01-02.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit

public class PDFReader {
    private (set) var pageCount: Int = 0
    private var document: CGPDFDocument? = nil
    
    public init(url: URL) {
        var provider = CGDataProvider(url: url as CFURL)
        
        if provider == nil {
            if let data = try? Data(contentsOf: url) {
                provider = CGDataProvider(data: data as CFData)
            }
        }
        
        if let provider = provider {
            self.document = CGPDFDocument(provider)
            self.pageCount = self.document?.numberOfPages ?? 0
        }
    }
    
    public func page(at index: Int) -> PDFPage? {
        if let document = self.document {
            return PDFPage(page: document.page(at: index + 1)!)
        }
        return nil
    }
}

public class PDFPage : UIView {
    private let page: CGPDFPage!
    private var pageBounds: CGRect = .zero
    private var quality: CGInterpolationQuality = .default
    
    public convenience init(page: CGPDFPage) {
        self.init(page: page, quality: .default, scale: CGSize(width: UIScreen.main.bounds.width / 4.0, height: UIScreen.main.bounds.height / 4.0))
    }
    
    public init(page: CGPDFPage, quality: CGInterpolationQuality, scale: CGSize) {
        self.page = page
        self.quality = quality
        super.init(frame: .zero)
        
        let tileLayer = self.layer as! CATiledLayer
        tileLayer.levelsOfDetail = 16
        tileLayer.levelsOfDetailBias = 15
        tileLayer.tileSize = scale
        
        self.pageBounds = UIScreen.main.bounds
        self.isOpaque = false
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.pageBounds = self.bounds
    }
    
    open override class var layerClass: AnyClass {
        return CATiledLayer.self
    }
    
    open override func draw(_ layer: CALayer, in ctx: CGContext) {
        self.drawPage(ctx: ctx, bounds: self.pageBounds)
    }
    
    private func drawPage(ctx: CGContext, bounds: CGRect) {
        ctx.saveGState()
        self.page.draw(in: ctx, bounds: bounds, quality: self.quality, backgroundColour: .clear, calculatedScaling: false)
        ctx.restoreGState()
    }
}

public extension CGPDFPage {
    func draw(in ctx: CGContext, bounds: CGRect, quality: CGInterpolationQuality = .default, backgroundColour: UIColor = .white, calculatedScaling: Bool = false) {
        var bounds = bounds
        if bounds.isNull {
            bounds = self.getBoxRect(.mediaBox)
        }
        
        let components = backgroundColour.componentsF()
        ctx.setFillColor(red: components.red, green: components.green, blue: components.blue, alpha: components.alpha)
        ctx.fill(bounds)
        
        switch self.rotationAngle {
        case 0:
            ctx.translateBy(x: 0.0, y: bounds.size.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
            
        case 90:
            ctx.translateBy(x: 0.0, y: bounds.size.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
            
        case 180:
            ctx.translateBy(x: 0.0, y: bounds.size.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
            ctx.rotate(by: .pi)
            
        case 270:
            ctx.translateBy(x: bounds.size.width, y: bounds.size.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
            ctx.rotate(by: .pi / 2.0)
            
        default:
            ctx.translateBy(x: 0.0, y: bounds.size.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
        }
        
        if calculatedScaling {
            if !bounds.isNull {
                let pageRect = self.getBoxRect(.mediaBox)
                ctx.scaleBy(x: bounds.size.width / pageRect.size.width, y: bounds.size.height / pageRect.size.height)
            }
        }
        else {
            if !bounds.isNull {
                ctx.concatenate(self.getDrawingTransform(.mediaBox, rect: bounds, rotate: 0, preserveAspectRatio: true))
            }
        }
        
        ctx.interpolationQuality = quality
        ctx.setRenderingIntent(.defaultIntent)
        ctx.drawPDFPage(self)
    }
}
