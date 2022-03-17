//
//  Extensions.swift
//  SaveTheKnight
//
//  Created by Valados on 17.03.2022.
//

import SpriteKit
import UIKit

extension SKLabelNode {
    
    func setTextWithStroke(color:UIColor, width: CGFloat,text: String) {
        
        let font = UIFont(name: self.fontName!, size: self.fontSize)
        let attributedString = NSMutableAttributedString(string: text)
        
        let attributes:[NSAttributedString.Key:Any] = [.strokeColor: color, .strokeWidth: -width, .font: font!, .foregroundColor: self.fontColor!]
        attributedString.addAttributes(attributes, range: NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
    }
}
extension UILabel {
    
    func addStroke(color:UIColor, width: CGFloat) {
        
        let font = self.font
        let attributedString = NSMutableAttributedString(string: self.text ?? " ")
        
        let attributes:[NSAttributedString.Key:Any] = [.strokeColor: color, .strokeWidth: -width, .font: font!, .foregroundColor: self.textColor!]
        attributedString.addAttributes(attributes, range: NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
    }
}
extension SKSpriteNode {
    /// Initializes a textured sprite with a glow using an existing texture object.
    func addGlow(texture: SKTexture, glowRadius: CGFloat) {
        let glow: SKEffectNode = {
            let glow = SKEffectNode()
            glow.addChild(SKSpriteNode(texture: texture, size: CGSize(width: 50, height: 50)))
            glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": glowRadius])
            glow.shouldRasterize = true
            return glow
        }()
        let glowRoot: SKNode = {
            let node = SKNode()
            node.name = "Glow"
            node.zPosition = -1
            return node
        }()
        glowRoot.addChild(glow)
        addChild(glowRoot)
    }
}
