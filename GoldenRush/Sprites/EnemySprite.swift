//
//  EnemySprite.swift
//  SaveTheKnight
//
//  Created by Valados on 24.01.2022.
//

import SpriteKit

public class EnemySprite : SKSpriteNode {
    
    private(set) var enemySound = ""
    private let movementSpeed: CGFloat = 200
    private var isMovingRight: Bool = true
    
    public static func newInstance() -> EnemySprite {
        let defaults = UserDefaults.standard
        let texture = SKTexture(imageNamed: defaults.string(forKey: EnemyKey) ?? "bear")
        let size = CGSize(width: texture.size().width * 0.175, height: texture.size().height * 0.175)
        
        let enemy = EnemySprite(texture: texture, size: size)
        
        enemy.zPosition = 1
        enemy.name = "enemy"
        enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: enemy.size.width - 10, height: enemy.size.height - 10))
        enemy.physicsBody?.allowsRotation = false
        enemy.physicsBody?.categoryBitMask = EnemyCategory
        enemy.physicsBody?.contactTestBitMask = FloorCategory | PlayerCategory | WorldFrameCategory | InvulnerablePlayerCategory
        enemy.physicsBody?.collisionBitMask = FloorCategory | PlayerCategory | WorldFrameCategory 
        enemy.physicsBody?.restitution = 0
        enemy.physicsBody?.mass = 100.0
        enemy.enemySound = defaults.string(forKey: EnemySoundKey)!
        
        return enemy
    }
    
    public func updatePosition(point : CGPoint) {
        position = point
    }
    
    public func setDirection() {
        isMovingRight = !isMovingRight
    }
    
    public func update(deltaTime : TimeInterval) {
        if isMovingRight {
            //Move right
            physicsBody?.velocity.dx = movementSpeed
            xScale = 1
        } else {
            //Move left
            physicsBody?.velocity.dx = -movementSpeed
            xScale = -1
        }
    }
}
