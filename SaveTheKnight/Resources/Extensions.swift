//
//  Extensions.swift
//  SaveTheKnight
//
//  Created by Valados on 03.02.2022.
//

import SpriteKit

extension SKSpriteNode {

    func addGlow(radius: CGFloat = 30) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        addChild(effectNode)
        effectNode.addChild(SKSpriteNode(texture: texture, size: CGSize(width: radius*2, height: radius*2)))
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius":radius])
    }
}
