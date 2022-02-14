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
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        coin.physicsBody?.categoryBitMask = GoldBonusCategory
        coin.physicsBody?.contactTestBitMask = WorldFrameCategory | PlayerCategory | InvulnerablePlayerCategory
        coin.physicsBody?.collisionBitMask = WorldFrameCategory 
        coin.zPosition = 3
        
        var actions = [SKAction]()
        actions.append(.fadeAlpha(to: 0.5, duration: 0.3))
        actions.append(.fadeAlpha(to: 1, duration: 0.3))
        coin.run(.repeatForever(.sequence(actions)))
        
        return coin
    }
}
