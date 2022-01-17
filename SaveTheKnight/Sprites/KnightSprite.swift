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
    private var destination : CGPoint!
    private let movementSpeed: CGFloat = 300
    private var timeSinceLastHit: TimeInterval = 2
    private let maxFlailTime:  TimeInterval = 2
    private var currentArrowHits = 0
    private let maxArrowHits = 3
    
    public static func newInstance() -> KnightSprite {
        let knight = KnightSprite(color: .brown, size: CGSize(width: 30, height: 50))
        
        knight.zPosition = 1
        knight.physicsBody = SKPhysicsBody(rectangleOf: knight.size)
        knight.physicsBody?.isDynamic = false
        knight.physicsBody?.categoryBitMask = KnightCategory
        knight.physicsBody?.contactTestBitMask = ArrowCategory | WorldFrameCategory
        knight.physicsBody?.restitution = 0
        
        return knight
    }
    
    public func updatePosition(point : CGPoint) {
        position = point
        destination = point
    }
    
    public func setDestination(destinationX : CGFloat) {
        self.destination.x = destinationX
    }
    
    public func update(deltaTime : TimeInterval) {
        timeSinceLastHit += deltaTime
        
        if timeSinceLastHit >= maxFlailTime {
            let distance = abs(destination.x - position.x)
            let distanceForInterval = movementSpeed * CGFloat(deltaTime)
            
            if distance > distanceForInterval {
                if destination.x < position.x {
                    //Move left
                    position.x -= distanceForInterval
                } else {
                    //Move right
                    position.x += distanceForInterval
                }
            } else {
                position.x = destination.x
            }
        }
    }
    
    public func hitByArrow() {
        currentArrowHits += 1
        if currentArrowHits < maxArrowHits {
            return
        }
        timeSinceLastHit = 0
        currentArrowHits = 0
        if SoundManager.sharedInstance.isMuted {
            return
        }
        if action(forKey: "action_sound_effect") == nil {
            run(SKAction.playSoundFileNamed(knightSound, waitForCompletion: true),
                withKey: "action_sound_effect")
        }
    }
}
