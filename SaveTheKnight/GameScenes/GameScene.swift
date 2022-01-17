//
//  GameScene.swift
//  SaveTheKnight
//
//  Created by Valados on 17.01.2022.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var lastUpdateTime : TimeInterval = 0
    private var currentArrowSpawnTime : TimeInterval = 0
    private var arrowSpawnRate : TimeInterval = 0.7
    private let random = GKARC4RandomSource()
    private let coinEdgeMargin: CGFloat = 75.0
    
    private let hud = HudNode()
    private var knight: KnightSprite!
    private var coin: CoinSprite!
    private var floorNode: SKShapeNode!
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        
        floorNode = SKShapeNode(rectOf: CGSize(width: size.width, height: 5))
        floorNode.position = CGPoint(x: size.width / 2, y: 50)
        floorNode.fillColor = SKColor.red
        floorNode.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -size.width / 2, y: 0), to: CGPoint(x: size.width, y: 0))
        floorNode.physicsBody?.categoryBitMask = FloorCategory
        floorNode.physicsBody?.contactTestBitMask = ArrowCategory
        floorNode.physicsBody?.restitution = 0
        
        hud.setup(size: size)
        
        hud.quitButtonAction = {
            let transition = SKTransition.reveal(with: .up, duration: 0.75)
            let gameScene = MenuScene(size: self.size)
            gameScene.scaleMode = self.scaleMode
            self.view?.presentScene(gameScene, transition: transition)
            self.hud.quitButtonAction = nil
        }
        
        addChild(hud)
        addChild(floorNode)
        
        spawnKnight()
      //  spawnCoin()
        
        var worldFrame = frame
        worldFrame.origin.x -= 100
        worldFrame.origin.y -= 100
        worldFrame.size.height += 200
        worldFrame.size.width += 200
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: worldFrame)
        self.physicsWorld.contactDelegate = self
        self.physicsBody?.categoryBitMask = WorldFrameCategory
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first?.location(in: self)
        if let point = touchPoint {
            hud.touchBeganAtPoint(point: point)
            
            if !hud.quitButtonPressed {
                knight.setDestination(destinationX: point.x)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first?.location(in: self)
        
        
        if let point = touchPoint {
            if !hud.quitButtonPressed {
                knight.setDestination(destinationX: point.x)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first?.location(in: self)
        
        if let point = touchPoint {
            hud.touchEndedAtPoint(point: point)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        
        // Update the Spawn Timer
        currentArrowSpawnTime += dt
        
        if currentArrowSpawnTime > arrowSpawnRate {
            currentArrowSpawnTime = 0
            spawnArrow()
        }
        
        //Update Knight Position
        knight.update(deltaTime: dt)
    }
    
    func spawnArrow() {
        let arrow = SKShapeNode(rectOf: CGSize(width: 5, height: 35))
        arrow.position = CGPoint(x: size.width / 2, y:  size.height / 2)
        arrow.zPosition = 2
        arrow.fillColor = SKColor.blue
        arrow.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 5, height: 35))
        arrow.physicsBody?.categoryBitMask = ArrowCategory
        arrow.physicsBody?.contactTestBitMask = FloorCategory | KnightCategory | CoinCategory
        arrow.physicsBody?.restitution = 0.0
        
        let randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: size.width))
        arrow.position = CGPoint(x: randomPosition, y: size.height)
        
        addChild(arrow)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ArrowCategory || contact.bodyB.categoryBitMask == ArrowCategory {
            handleArrowHit(contact: contact)
        }
        
        if contact.bodyA.categoryBitMask == CoinCategory || contact.bodyB.categoryBitMask == CoinCategory {
            handleCoinHit(contact: contact)
            return
        }
        
        if contact.bodyA.categoryBitMask == KnightCategory || contact.bodyB.categoryBitMask == KnightCategory {
            handleKnightCollision(contact: contact)
            print("hit with knight")
            return
        }
        
        if contact.bodyA.categoryBitMask == WorldFrameCategory {
            contact.bodyB.node?.removeFromParent()
            contact.bodyB.node?.physicsBody = nil
            contact.bodyB.node?.removeAllActions()
        } else if contact.bodyB.categoryBitMask == WorldFrameCategory {
            contact.bodyA.node?.removeFromParent()
            contact.bodyA.node?.physicsBody = nil
            contact.bodyA.node?.removeAllActions()
        }
    }
    
    func spawnKnight() {
        if let currentKnight = knight, children.contains(currentKnight) {
            knight.removeFromParent()
            knight.removeAllActions()
            knight.physicsBody = nil
        }
        
        knight = KnightSprite.newInstance()
        knight.updatePosition(point: CGPoint(x: frame.midX, y: floorNode.position.y+knight.size.height/2))
        hud.resetPoints()
        
        addChild(knight)
    }
    
    func spawnCoin() {
        coin = CoinSprite.newInstance()
        var randomPosition : CGFloat = CGFloat(random.nextInt())
        randomPosition = randomPosition.truncatingRemainder(dividingBy: size.width - coinEdgeMargin * 2)
        randomPosition = CGFloat(abs(randomPosition))
        randomPosition += coinEdgeMargin
        
        coin.position = CGPoint(x: randomPosition, y: size.height)
        
        addChild(coin)
    }
    
    func handleKnightCollision(contact: SKPhysicsContact) {
        var otherBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == KnightCategory {
            otherBody = contact.bodyB
        } else {
            otherBody = contact.bodyA
        }
        
        switch otherBody.categoryBitMask {
        case ArrowCategory:
            knight.hitByArrow()
            if hud.isLose() {
                knight.physicsBody?.categoryBitMask = 0
                run(.wait(forDuration: 2.0), completion: {
                    self.knight.physicsBody?.categoryBitMask = KnightCategory
                })
            }
        case WorldFrameCategory:
            spawnKnight()
        default:
            print("Something hit the knight")
        }
    }
    
    func handleCoinHit(contact: SKPhysicsContact) {
        var otherBody : SKPhysicsBody
        var coinBody : SKPhysicsBody
        
        if(contact.bodyA.categoryBitMask == CoinCategory) {
            otherBody = contact.bodyB
            coinBody = contact.bodyA
        } else {
            otherBody = contact.bodyA
            coinBody = contact.bodyB
        }
        
        switch otherBody.categoryBitMask {
        case KnightCategory:
            hud.addPoint()
            fallthrough
        case WorldFrameCategory:
            coinBody.node?.removeFromParent()
            coinBody.node?.physicsBody = nil
            spawnCoin()
        default:
            print("something else touched the coin")
        }
    }
    func handleArrowHit(contact: SKPhysicsContact) {
        var otherBody : SKPhysicsBody
        var arrowBody : SKPhysicsBody
        
        if(contact.bodyA.categoryBitMask == ArrowCategory) {
            otherBody = contact.bodyB
            arrowBody = contact.bodyA
            
        } else {
            otherBody = contact.bodyA
            arrowBody = contact.bodyB
        }
        
        switch otherBody.categoryBitMask {
        case FloorCategory:
            arrowBody.node?.run(.wait(forDuration: 0.2), completion: {
                arrowBody.node?.removeFromParent()
                arrowBody.node?.physicsBody = nil
                arrowBody.node?.removeAllActions()
            })
        case KnightCategory:
            arrowBody.collisionBitMask = 0
        case CoinCategory:
            arrowBody.collisionBitMask = 0
        default:
            print("something else touched the arrow")
        }
    }
}
