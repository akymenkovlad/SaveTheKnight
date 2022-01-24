//
//  CoinSprite.swift
//  SaveTheKnight
//
//  Created by Valados on 17.01.2022.
//

import Foundation
import SpriteKit

public class CoinSprite : SKSpriteNode {
    public static func newInstance() -> CoinSprite {
        let coin = CoinSprite(texture: SKTexture(imageNamed: "coin"), size: CGSize(width: 30, height: 30))
        
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width/2)
        coin.physicsBody?.categoryBitMask = CoinCategory
        coin.physicsBody?.contactTestBitMask = WorldFrameCategory | KnightCategory | FloorCategory | InvulnerableKnightCategory
        coin.physicsBody?.collisionBitMask = WorldFrameCategory | KnightCategory | FloorCategory | InvulnerableKnightCategory
        coin.zPosition = 3
        
        return coin
    }
}
