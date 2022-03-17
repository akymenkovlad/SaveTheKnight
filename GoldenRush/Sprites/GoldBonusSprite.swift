//
//  GoldBonusSprite.swift
//  SaveTheKnight
//
//  Created by Valados on 24.01.2022.
//

import SpriteKit

public class GoldBonusSprite : SKSpriteNode {
    public static func newInstance() -> GoldBonusSprite {
        let coin = GoldBonusSprite(texture: SKTexture(imageNamed: "coin"), size: CGSize(width: 60, height: 60))
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        coin.physicsBody?.restitution = 1.0
        coin.physicsBody?.categoryBitMask = GoldBonusCategory
        coin.physicsBody?.contactTestBitMask = WorldFrameCategory | PlayerCategory | InvulnerablePlayerCategory | FloorCategory
        coin.physicsBody?.collisionBitMask = WorldFrameCategory | FloorCategory
        coin.zPosition = 3
        
        coin.addGlow(texture: SKTexture(imageNamed: "coin"), glowRadius: 50)
        
        return coin
    }
}
