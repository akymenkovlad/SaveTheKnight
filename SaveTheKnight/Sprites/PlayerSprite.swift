//
//  KnightSprite.swift
//  SaveTheKnight
//
//  Created by Valados on 17.01.2022.
//

import Foundation
import SpriteKit

public class PlayerSprite : SKSpriteNode {
    
    private let playerSound = "player.wav"
    private var walkFrames: [SKTexture] = []
    private let walkingActionKey = "action_walking"
    private let movementSpeed: CGFloat = 300
    private var isMovingRight: Bool = true
    private var currentHits = 0
    private let maxHits = 3
    
    public static func newInstance() -> PlayerSprite {
        let defaults = UserDefaults.standard
        let texture = SKTexture(imageNamed: defaults.string(forKey: CharacterKey) ?? "digger")
        var scale: Double = 0.1
        switch defaults.string(forKey: CharacterKey) {
        case "digger":
            scale = 0.1
        case "tourist":
            scale = 0.15
        case "farmer":
            scale = 0.125
        default:
            break
        }
        let size = CGSize(width: texture.size().width * scale, height: texture.size().height * scale)
        let player = PlayerSprite(texture: texture, size: size)
        
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = PlayerCategory
        player.physicsBody?.collisionBitMask = FloorCategory | WorldFrameCategory
        player.physicsBody?.restitution = 0
        player.physicsBody?.mass = 100.0
        
        return player
    }
    
    public func addFrames() {
        let defaults = UserDefaults.standard
        let frames = defaults.value(forKey: FramesKey) as! [String]
        for frame in frames {
            walkFrames.append(SKTexture(imageNamed: frame))
        }
    }
    
    public func updatePosition(point : CGPoint) {
        position = point
    }
    
    public func turnAround() {
        isMovingRight = !isMovingRight
    }
    
    public func update() {
        
        if currentHits < maxHits {
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
                xScale = -1
            } else {
                //Move left
                physicsBody?.velocity.dx = -movementSpeed
                xScale = 1
            }
        }
    }
    
    public func hitByObject() {
        currentHits += 1
        if currentHits < maxHits {
            return
        }
        if !SoundManager.sharedInstance.isMuted {
            if action(forKey: "action_sound_effect") == nil {
                run(SKAction.playSoundFileNamed(playerSound, waitForCompletion: true),
                    withKey: "action_sound_effect")
            }
        }
    }
    
    public func reduceHits() {
        currentHits -= 1
    }
}
