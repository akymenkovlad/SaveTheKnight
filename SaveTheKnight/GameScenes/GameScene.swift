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
    private var currentBombSpawnTime : TimeInterval = 0
    private var bombSpawnRate : TimeInterval = 10
    private var currentHeartSpawnTime : TimeInterval = 0
    private var heartSpawnRate : TimeInterval = 15
    
    private let random = GKARC4RandomSource()
    private let edgeMargin: CGFloat = 30.0
    
    private let hud = HudNode()
    private var knight: KnightSprite!
    private var coin: CoinSprite!
    private var floorNode: SKShapeNode!
    private var background = SKSpriteNode(imageNamed: "background")
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        
        background.zPosition = -10
        background.size = frame.size
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2 )
        
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
        addChild(background)
        
        spawnKnight()
        spawnCoin()
        
        var worldFrame = frame
        worldFrame.origin.y -= 50
        worldFrame.size.height += 100
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: worldFrame)
        self.physicsWorld.contactDelegate = self
        self.physicsBody?.categoryBitMask = WorldFrameCategory
    }
    
    //MARK: Updating scene
    override func update(_ currentTime: TimeInterval) {
        let score = hud.score
        // Initialize _lastUpdateTime if it has not already been
        if self.lastUpdateTime == 0 {
            self.lastUpdateTime = currentTime
        }
        switch score {
        case 0...10:
            arrowSpawnRate = ArrowSpawnRate
            bombSpawnRate = BombSpawnRate
        case 11...20:
            arrowSpawnRate = ArrowSpawnRate - 0.1
            bombSpawnRate = BombSpawnRate - 1
        case 21...30:
            arrowSpawnRate = ArrowSpawnRate - 0.2
            bombSpawnRate = BombSpawnRate - 2
        case 31...40:
            arrowSpawnRate = ArrowSpawnRate - 0.3
            bombSpawnRate = BombSpawnRate - 3
        case 41...50:
            arrowSpawnRate = ArrowSpawnRate - 0.4
            bombSpawnRate = BombSpawnRate - 4
        case 51...60:
            arrowSpawnRate = ArrowSpawnRate - 0.5
            bombSpawnRate = BombSpawnRate - 5
        case 61...70:
            arrowSpawnRate = ArrowSpawnRate - 0.6
            bombSpawnRate = BombSpawnRate - 6
        default:
            break
        }
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        // Update the Spawn Timer
        currentArrowSpawnTime += dt
        currentBombSpawnTime += dt
        currentHeartSpawnTime += dt
        if currentArrowSpawnTime > arrowSpawnRate {
            currentArrowSpawnTime = 0
            spawnArrow()
        }
        if currentBombSpawnTime > bombSpawnRate {
            currentBombSpawnTime = 0
            spawnBomb()
        }
        if currentHeartSpawnTime > heartSpawnRate {
            currentHeartSpawnTime = 0
            if hud.health < 3 {
                spawnHeart()
            }
        }
        //Update Knight Position
        knight.update(deltaTime: dt)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ArrowCategory || contact.bodyB.categoryBitMask == ArrowCategory {
            handleArrowHit(contact: contact)
        }
        
        if contact.bodyA.categoryBitMask == BombCategory || contact.bodyB.categoryBitMask == BombCategory {
            handleBombHit(contact: contact)
        }
        
        if contact.bodyA.categoryBitMask == HeartCategory || contact.bodyB.categoryBitMask == HeartCategory {
            handleHeartHit(contact: contact)
        }
        
        if contact.bodyA.categoryBitMask == CoinCategory || contact.bodyB.categoryBitMask == CoinCategory {
            handleCoinHit(contact: contact)
            return
        }
        
        if contact.bodyA.categoryBitMask == KnightCategory || contact.bodyB.categoryBitMask == KnightCategory {
            handleKnightCollision(contact: contact)
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
    
    func createRandomPosition() -> CGFloat {
        var randomPosition : CGFloat = CGFloat(random.nextInt())
        randomPosition = randomPosition.truncatingRemainder(dividingBy: size.width - edgeMargin * 2)
        randomPosition = CGFloat(abs(randomPosition))
        randomPosition += edgeMargin
        return randomPosition
    }
    
    //MARK: Handling touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first?.location(in: self)
        if let point = touchPoint {
            hud.touchBeganAtPoint(point: point)
            if !hud.quitButtonPressed {
                knight.turnAround()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first?.location(in: self)
        
        if let point = touchPoint {
            hud.touchEndedAtPoint(point: point)
        }
    }
    
    //MARK: Knight creation and contact
    
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
    
    func handleKnightCollision(contact: SKPhysicsContact) {
        var otherBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == KnightCategory {
            otherBody = contact.bodyB
        } else {
            otherBody = contact.bodyA
        }
        
        switch otherBody.categoryBitMask {
        case ArrowCategory,BombCategory:
            knight.hitByObject()
            if hud.isLose() {
                knight.physicsBody?.categoryBitMask = 0
                run(.wait(forDuration: 2.0), completion: {
                    self.knight.physicsBody?.categoryBitMask = KnightCategory
                })
            }
        case HeartCategory:
            knight.reduceHits()
        default:
            print("Something hit the knight")
        }
    }
    //MARK: Coin creation and contact
    func spawnCoin() {
        coin = CoinSprite.newInstance()
        coin.position = CGPoint(x: createRandomPosition(), y: size.height)
        addChild(coin)
    }
    
    func handleCoinHit(contact: SKPhysicsContact) {
        var otherBody : SKPhysicsBody
        var coinBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == CoinCategory {
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
    //MARK: Arrow creation and contact
    func spawnArrow() {
        let arrow = SKSpriteNode(texture: SKTexture(imageNamed: "arrow"), size: CGSize(width: 15, height: 40))
        arrow.position = CGPoint(x: size.width / 2, y:  size.height / 2)
        arrow.zPosition = 2
        arrow.physicsBody = SKPhysicsBody(rectangleOf: arrow.size)
        arrow.physicsBody?.categoryBitMask = ArrowCategory
        arrow.physicsBody?.contactTestBitMask = FloorCategory | KnightCategory | CoinCategory | HeartCategory | BombCategory
        arrow.physicsBody?.restitution = 0.0
        arrow.position = CGPoint(x: createRandomPosition(), y: size.height)
        
        addChild(arrow)
    }
    
    func handleArrowHit(contact: SKPhysicsContact) {
        var otherBody : SKPhysicsBody
        var arrowBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == ArrowCategory {
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
        case KnightCategory,CoinCategory,BombCategory,HeartCategory:
            arrowBody.node?.removeFromParent()
            arrowBody.node?.physicsBody = nil
            arrowBody.node?.removeAllActions()
            
        default:
            print("something else touched the arrow")
        }
    }
    //MARK: Bomb creation and contact
    func spawnBomb() {
        let bomb = SKSpriteNode(texture: SKTexture(imageNamed: "bomb"), size: CGSize(width: 40, height: 40))
        bomb.physicsBody = SKPhysicsBody(rectangleOf: bomb.size)
        bomb.physicsBody?.categoryBitMask = BombCategory
        bomb.physicsBody?.contactTestBitMask = FloorCategory | KnightCategory
        bomb.physicsBody?.restitution = 0.0
        bomb.zPosition = 3
        bomb.position = CGPoint(x: createRandomPosition(), y: size.height)
        
        addChild(bomb)
    }
    
    func handleBombHit(contact: SKPhysicsContact) {
        var otherBody : SKPhysicsBody
        var bombBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == BombCategory {
            otherBody = contact.bodyB
            bombBody = contact.bodyA
            
        } else {
            otherBody = contact.bodyA
            bombBody = contact.bodyB
        }
        
        switch otherBody.categoryBitMask {
        case FloorCategory:
            var actions = [SKAction]()
            actions.append(.fadeAlpha(to: 0.5, duration: 0.3))
            actions.append(.fadeAlpha(to: 1, duration: 0.3))
            bombBody.node?.run(.repeatForever(.sequence(actions)))
            bombBody.node?.run(.wait(forDuration: 3.0), completion: {
                let explosion = SKEmitterNode(fileNamed: "Explosion")!
                explosion.position = bombBody.node!.position
                self.addChild(explosion)
                self.run(.wait(forDuration: 0.5), completion: {
                    explosion.removeFromParent()
                })
                bombBody.node?.removeFromParent()
                bombBody.node?.physicsBody = nil
                bombBody.node?.removeAllActions()
            })
        case KnightCategory:
            let explosion = SKEmitterNode(fileNamed: "Explosion")!
            explosion.position = bombBody.node!.position
            addChild(explosion)
            run(.wait(forDuration: 0.5), completion: {
                explosion.removeFromParent()
            })
            bombBody.node?.removeFromParent()
            bombBody.node?.physicsBody = nil
            bombBody.node?.removeAllActions()
        default:
            print("something else touched the bomb")
        }
    }
    //MARK: Heart creation and contact
    func spawnHeart() {
        let heart = SKSpriteNode(texture: SKTexture(imageNamed: "heart"), size: CGSize(width: 30, height: 30))
        heart.physicsBody = SKPhysicsBody(rectangleOf: heart.size)
        heart.physicsBody?.categoryBitMask = HeartCategory
        heart.physicsBody?.contactTestBitMask = FloorCategory | KnightCategory
        heart.physicsBody?.restitution = 0.0
        heart.zPosition = 3
        heart.position = CGPoint(x: createRandomPosition(), y: size.height)
        
        addChild(heart)
    }
    
    func handleHeartHit(contact: SKPhysicsContact) {
        var otherBody : SKPhysicsBody
        var heartBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == HeartCategory {
            otherBody = contact.bodyB
            heartBody = contact.bodyA
            
        } else {
            otherBody = contact.bodyA
            heartBody = contact.bodyB
        }
        
        switch otherBody.categoryBitMask {
        case FloorCategory:
            var actions = [SKAction]()
            actions.append(.wait(forDuration: 1))
            actions.append(.fadeAlpha(to: 0.5, duration: 0.3))
            actions.append(.fadeAlpha(to: 1, duration: 0.3))
            heartBody.node?.run(.repeatForever(.sequence(actions)))
            heartBody.node?.run(.wait(forDuration: 5.0), completion: {
                heartBody.node?.removeFromParent()
                heartBody.node?.physicsBody = nil
                heartBody.node?.removeAllActions()
            })
        case KnightCategory:
            hud.addHealth()
            heartBody.node?.removeFromParent()
            heartBody.node?.physicsBody = nil
            heartBody.node?.removeAllActions()
        default:
            print("something else touched the heart")
        }
    }
}
