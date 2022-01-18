//
//  KnightSprite.swift
//  SaveTheKnight
//
//  Created by Valados on 17.01.2022.
//

import Foundation
import SpriteKit

public class KnightSprite : SKSpriteNode {
    
    private let knightSound = "knight.wav"
    private let movementSpeed: CGFloat = 300
    private var isMovingRight: Bool = true
    private var timeSinceLastHit: TimeInterval = 2
    private let maxFlailTime:  TimeInterval = 2
    private var currentHits = 0
    private let maxHits = 3
    
    public static func newInstance() -> KnightSprite {
        let knight = KnightSprite(texture: SKTexture(imageNamed: "knight"), size: CGSize(width: 30, height: 50))
        
        knight.zPosition = 1
        knight.physicsBody = SKPhysicsBody(rectangleOf: knight.size)
        knight.physicsBody?.isDynamic = true
        knight.physicsBody?.categoryBitMask = KnightCategory
        knight.physicsBody?.contactTestBitMask = ArrowCategory | WorldFrameCategory
        knight.physicsBody?.restitution = 0
        
        return knight
    }
    
    public func updatePosition(point : CGPoint) {
        position = point
    }
    
    public func turnAround() {
        isMovingRight = !isMovingRight
    }
    
    public func update(deltaTime : TimeInterval) {
        timeSinceLastHit += deltaTime
        
        if timeSinceLastHit >= maxFlailTime {
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
    
    public func hitByObject() {
        currentHits += 1
        if currentHits < maxHits {
            return
        }
        timeSinceLastHit = 0
        currentHits = 0
        if SoundManager.sharedInstance.isMuted {
            return
        }
        if action(forKey: "action_sound_effect") == nil {
            run(SKAction.playSoundFileNamed(knightSound, waitForCompletion: true),
                withKey: "action_sound_effect")
        }
    }
    
    public func reduceHits(){
        currentHits -= 1
    }
}
