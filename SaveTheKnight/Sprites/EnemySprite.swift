//
//  EnemySprite.swift
//  SaveTheKnight
//
//  Created by Valados on 24.01.2022.
//

import SpriteKit

public class EnemySprite : SKSpriteNode {
    
    private let walkFrames = [
        SKTexture(imageNamed: "god"),
        SKTexture(imageNamed: "mummy")
    ]
    private let walkingActionKey = "action_walking"
    private let movementSpeed: CGFloat = 200
    private var isMovingRight: Bool = true
    
    public static func newInstance() -> EnemySprite {
        let enemy = EnemySprite(texture: SKTexture(imageNamed: "god"), size: CGSize(width: 40, height: 30))
        
        enemy.zPosition = 1
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size )
        enemy.physicsBody?.allowsRotation = false
        enemy.physicsBody?.categoryBitMask = EnemyCategory
        enemy.physicsBody?.contactTestBitMask = FloorCategory | KnightCategory | WorldFrameCategory
        enemy.physicsBody?.collisionBitMask = FloorCategory | KnightCategory | WorldFrameCategory
        enemy.physicsBody?.restitution = 0
        enemy.physicsBody?.mass = 100.0
        
        return enemy
    }
    
    public func updatePosition(point : CGPoint) {
        position = point
    }
    
    public func setDirection() {
        isMovingRight = !isMovingRight
    }
    
    public func update(deltaTime : TimeInterval) {
        if action(forKey: walkingActionKey) == nil {
            let walkingAction = SKAction.repeatForever(
                SKAction.animate(with: walkFrames,
                                 timePerFrame: 0.1,
                                 resize: false,
                                 restore: true))
            run(walkingAction, withKey:walkingActionKey)
        }
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
