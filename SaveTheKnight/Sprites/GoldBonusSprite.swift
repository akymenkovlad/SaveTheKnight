//
//  GoldBonusSprite.swift
//  SaveTheKnight
//
//  Created by Valados on 24.01.2022.
//

import SpriteKit

public class GoldBonusSprite : SKSpriteNode {
    public static func newInstance() -> GoldBonusSprite {
        let coin = GoldBonusSprite(texture: SKTexture(imageNamed: "coin"), size: CGSize(width: 40, height: 40))
        let colorize = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0)
        coin.run(colorize)
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        coin.physicsBody?.categoryBitMask = GoldBonusCategory
        coin.physicsBody?.contactTestBitMask = WorldFrameCategory | KnightCategory | InvulnerableKnightCategory
        coin.physicsBody?.collisionBitMask = WorldFrameCategory | KnightCategory | InvulnerableKnightCategory
        coin.zPosition = 3
        
        return coin
    }
}
