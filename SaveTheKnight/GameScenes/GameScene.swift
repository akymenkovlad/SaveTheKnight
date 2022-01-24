//
//  GameScene.swift
//  SaveTheKnight
//
//  Created by Valados on 17.01.2022.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    weak var transitonDelegate: TransitionDelegate?
    
    private var lastUpdateTime : TimeInterval = 0
    private var currentArrowSpawnTime : TimeInterval = 0
    private var arrowSpawnRate : TimeInterval = 0.7
    private var currentBombSpawnTime : TimeInterval = 0
    private var bombSpawnRate : TimeInterval = 20
    private var currentHeartSpawnTime : TimeInterval = 0
    private var heartSpawnRate : TimeInterval = 15
    private var currentEnemySpawnTime : TimeInterval = 10
    private var enemySpawnRate : TimeInterval = 10
    private var currentInvBonusSpawnTime : TimeInterval = 0
    private var invBonusSpawnRate : TimeInterval = 20
    private var currentGoldBonusSpawnTime : TimeInterval = 0
    private var goldBonusSpawnRate : TimeInterval = 15
    
    private let random = GKARC4RandomSource()
    private let edgeMargin: CGFloat = 30.0
    
    private let hud = HudNode()
    private var knight: KnightSprite!
    private var enemy: EnemySprite!
    private var coin: CoinSprite!
    private var goldBonus: GoldBonusSprite!
    private var invulnerabilityBonus: InvulnerabiltyBonusSprite!
    private var floorNode: SKShapeNode!
    private var background = SKSpriteNode(imageNamed: "background")
    
    var swipeUp : UISwipeGestureRecognizer!
    var tap : UITapGestureRecognizer!
    
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -3)
        
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
            self.moveToMenu()
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
    
    override func didMove(to view: SKView) {
        swipeUp  = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp(sender:)))
        swipeUp.direction = .up
        tap = UITapGestureRecognizer(target: self, action: #selector(turn(sender:)))
        tap.numberOfTapsRequired = 1
        
        view.addGestureRecognizer(swipeUp)
        view.addGestureRecognizer(tap)
    }
    @objc func swipedUp(sender: UISwipeGestureRecognizer) {
        let jumpRange = floorNode.position.y + knight.size.height / 2 + 10
        if knight.position.y <= jumpRange {
            let jumpUpAction = SKAction.moveBy(x: 0, y: 100, duration: 0.2)
            let jumpDownAction = SKAction.moveBy(x: 0, y: -100, duration: 0.5)
            let sequence = SKAction.sequence([jumpUpAction,jumpDownAction])
            knight.run(sequence)
        }
    }
    @objc func turn(sender: UISwipeGestureRecognizer) {
        knight.turnAround()
    }
    func moveToMenu() {
        let transition = SKTransition.reveal(with: .up, duration: 0.5)
        let gameScene = MenuScene(size: self.size)
        gameScene.scaleMode = self.scaleMode
        gameScene.transitonDelegate = transitonDelegate
        self.view?.removeGestureRecognizer(tap)
        self.view?.removeGestureRecognizer(swipeUp)
        self.view?.presentScene(gameScene, transition: transition)
    }
    //MARK: Updating scene
    override func update(_ currentTime: TimeInterval) {
        let score = hud.score
        // Initialize _lastUpdateTime if it has not already been
        if self.lastUpdateTime == 0 {
            self.lastUpdateTime = currentTime
        }
        let level = updateGameLevel(with: score)
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        // Update the Spawn Timer
        currentArrowSpawnTime += dt
        currentBombSpawnTime += dt
        currentEnemySpawnTime += dt
        currentInvBonusSpawnTime += dt
        currentGoldBonusSpawnTime += dt
        
        // Spawn objects
        
        switch level {
        case 2...:
            if currentBombSpawnTime > bombSpawnRate {
                currentBombSpawnTime = 0
                spawnBomb()
            }
            fallthrough
        case 1:
            if currentEnemySpawnTime > enemySpawnRate {
                currentEnemySpawnTime = 0
                enemySpawnRate = TimeInterval(Int.random(in: 10...20))
                spawnEnemy()
            }
            if let enemy = enemy {
                //Update Enemy Position
                enemy.update(deltaTime: dt)
            }
            fallthrough
        case 0:
            if currentArrowSpawnTime > arrowSpawnRate {
                currentArrowSpawnTime = 0
                spawnArrow()
            }
        default:
            break
        }
        if hud.health < 3 {
            currentHeartSpawnTime += dt
            if currentHeartSpawnTime > heartSpawnRate {
                currentHeartSpawnTime = 0
                spawnHeart()
            }
        }
        if currentInvBonusSpawnTime > invBonusSpawnRate {
            currentInvBonusSpawnTime = 0
            invBonusSpawnRate = TimeInterval(Int.random(in: 20...30))
            spawnInvulnerabilityBonus()
        }
        if currentGoldBonusSpawnTime > goldBonusSpawnRate {
            currentGoldBonusSpawnTime = 0
            goldBonusSpawnRate = TimeInterval(Int.random(in: 15...30))
            spawnGoldBonus()
        }
        //Update Knight Position
        knight.update(deltaTime: dt)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ArrowCategory || contact.bodyB.categoryBitMask == ArrowCategory {
            handleArrowContact(contact: contact)
        }
        
        if contact.bodyA.categoryBitMask == BombCategory || contact.bodyB.categoryBitMask == BombCategory {
            handleBombContact(contact: contact)
        }
        
        if contact.bodyA.categoryBitMask == HeartCategory || contact.bodyB.categoryBitMask == HeartCategory {
            handleHeartContact(contact: contact)
        }
        
        if contact.bodyA.categoryBitMask == CoinCategory || contact.bodyB.categoryBitMask == CoinCategory {
            handleCoinContact(contact: contact)
        }
        
        if contact.bodyA.categoryBitMask == InvulnerabilityBonusCategory || contact.bodyB.categoryBitMask == InvulnerabilityBonusCategory {
            handleInvulnerabilityBonusContact(contact: contact)
        }
        if contact.bodyA.categoryBitMask == GoldBonusCategory || contact.bodyB.categoryBitMask == GoldBonusCategory {
            handleGoldBonusContact(contact: contact)
        }
        if contact.bodyA.categoryBitMask == EnemyCategory || contact.bodyB.categoryBitMask == EnemyCategory {
            handleEnemyContact(contact: contact)
        }
        if contact.bodyA.categoryBitMask == KnightCategory || contact.bodyB.categoryBitMask == KnightCategory {
            handleKnightContact(contact: contact)
            return
        }
    }
    
    func createRandomPosition() -> CGFloat {
        var randomPosition : CGFloat = CGFloat(random.nextInt())
        randomPosition = randomPosition.truncatingRemainder(dividingBy: size.width - edgeMargin * 2)
        randomPosition = CGFloat(abs(randomPosition))
        randomPosition += edgeMargin
        return randomPosition
    }
    
    func updateGameLevel(with score: Int) -> Int {
        let level = score / 5
        arrowSpawnRate = ArrowSpawnRate - 0.05 * Double(level)
        bombSpawnRate = BombSpawnRate - 1 * Double(level)
        return level
    }
    //MARK: Handling touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first?.location(in: self)
        if let point = touchPoint {
            hud.touchBeganAtPoint(point: point)
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
        knight.updatePosition(point: CGPoint(x: frame.midX, y: floorNode.position.y+knight.size.width/2+5))
        hud.resetPoints()
        addChild(knight)
    }
    
    func handleKnightContact(contact: SKPhysicsContact) {
        var otherBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == KnightCategory {
            otherBody = contact.bodyB
        } else {
            otherBody = contact.bodyA
        }
        
        switch otherBody.categoryBitMask {
        case ArrowCategory,BombCategory,EnemyCategory:
            knight.hitByObject()
            if hud.isLose() {
                knight.physicsBody?.categoryBitMask = 0
                run(.wait(forDuration: 1), completion: {
                    self.moveToMenu()
                })
            }
        case HeartCategory:
            knight.reduceHits()
        default:
            break
        }
    }
    //MARK: Coin creation and contact
    func spawnCoin() {
        coin = CoinSprite.newInstance()
        coin.position = CGPoint(x: createRandomPosition(), y: size.height)
        addChild(coin)
    }
    
    func handleCoinContact(contact: SKPhysicsContact) {
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
        case FloorCategory:
            coinBody.isDynamic = false
        case InvulnerableKnightCategory:
            fallthrough
        case KnightCategory:
            hud.addPoint()
            let coins = UserDefaults.standard.value(forKey: "userCoins") as! Int
            UserDefaults.standard.set(coins+1, forKey: "userCoins")
            print("Coins:\(coins+1)")
            hud.updateUserCoins()
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
        let arrow = SKSpriteNode(texture: SKTexture(imageNamed: "arrow"), size: CGSize(width: 25, height: 50))
        arrow.position = CGPoint(x: size.width / 2, y:  size.height / 2)
        arrow.zPosition = 2
        arrow.physicsBody = SKPhysicsBody(rectangleOf: arrow.size)
        arrow.physicsBody?.categoryBitMask = ArrowCategory
        arrow.physicsBody?.contactTestBitMask = FloorCategory | KnightCategory
        arrow.physicsBody?.collisionBitMask = KnightCategory | FloorCategory
        arrow.physicsBody?.restitution = 0.0
        arrow.position = CGPoint(x: createRandomPosition(), y: size.height)
        arrow.physicsBody?.mass = 1
        arrow.physicsBody?.density = 0.1
        let fire = SKEmitterNode(fileNamed: "Fire")!
        arrow.addChild(fire)
        fire.position = CGPoint(x: 0, y: -arrow.size.height / 2)
        addChild(arrow)
    }
    
    func handleArrowContact(contact: SKPhysicsContact) {
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
        case KnightCategory:
            arrowBody.node?.removeFromParent()
            arrowBody.node?.physicsBody = nil
            arrowBody.node?.removeAllActions()
        case CoinCategory,BombCategory,HeartCategory:
            arrowBody.node?.physicsBody?.collisionBitMask = 0
        default:
            print("something else touched the arrow")
        }
    }
    //MARK: Bomb creation and contact
    func spawnBomb() {
        let bomb = SKSpriteNode(texture: SKTexture(imageNamed: "bomb"), size: CGSize(width: 40, height: 40))
        bomb.physicsBody = SKPhysicsBody(circleOfRadius: bomb.size.width/2)
        bomb.physicsBody?.categoryBitMask = BombCategory
        bomb.physicsBody?.contactTestBitMask = FloorCategory | KnightCategory
        bomb.physicsBody?.collisionBitMask = FloorCategory | KnightCategory
        bomb.physicsBody?.restitution = 0.0
        bomb.zPosition = 3
        bomb.position = CGPoint(x: createRandomPosition(), y: size.height)
        
        addChild(bomb)
    }
    
    func handleBombContact(contact: SKPhysicsContact) {
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
            bombBody.node?.physicsBody?.isDynamic = false
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
        heart.physicsBody?.contactTestBitMask = FloorCategory | KnightCategory | InvulnerableKnightCategory
        heart.physicsBody?.collisionBitMask = FloorCategory | KnightCategory | InvulnerableKnightCategory
        heart.physicsBody?.restitution = 0.0
        heart.zPosition = 3
        heart.position = CGPoint(x: createRandomPosition(), y: size.height)
        
        addChild(heart)
    }
    
    func handleHeartContact(contact: SKPhysicsContact) {
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
            actions.append(.fadeAlpha(to: 0.5, duration: 0.5))
            actions.append(.fadeAlpha(to: 1, duration: 0.5))
            heartBody.node?.run(.repeatForever(.sequence(actions)))
            heartBody.node?.run(.wait(forDuration: 5.0), completion: {
                heartBody.node?.removeFromParent()
                heartBody.node?.physicsBody = nil
                heartBody.node?.removeAllActions()
            })
        case InvulnerableKnightCategory:
            knight.reduceHits()
            fallthrough
        case KnightCategory:
            hud.addHealth()
            heartBody.node?.removeFromParent()
            heartBody.node?.physicsBody = nil
            heartBody.node?.removeAllActions()
        default:
            print("something else touched the heart")
        }
    }
    //MARK: Enemy creation and contact
    func spawnEnemy() {
        enemy = EnemySprite.newInstance()
        if knight.position.x >= frame.midX {
            enemy.updatePosition(point: CGPoint(x: frame.minX + enemy.size.width/2 + 5, y: floorNode.position.y + enemy.size.height/2 + 5))
        } else {
            enemy.updatePosition(point: CGPoint(x: frame.maxX - enemy.size.width/2 - 5, y: floorNode.position.y + enemy.size.height/2 + 5))
            enemy.setDirection()
        }
        addChild(enemy)
    }
    
    func handleEnemyContact(contact: SKPhysicsContact) {
        var enemyBody : SKPhysicsBody
        var otherBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == EnemyCategory {
            enemyBody = contact.bodyA
            otherBody = contact.bodyB
            
        } else {
            enemyBody = contact.bodyB
            otherBody = contact.bodyA
        }
        
        switch otherBody.categoryBitMask {
        case WorldFrameCategory,KnightCategory:
            enemyBody.node?.removeFromParent()
            enemyBody.node?.physicsBody = nil
            enemyBody.node?.removeAllActions()
        default:
            break
        }
    }
    //MARK: Invulnerability bonus creation and contact
    func spawnInvulnerabilityBonus() {
        invulnerabilityBonus = InvulnerabiltyBonusSprite.newInstance()
        invulnerabilityBonus.position = CGPoint(x: createRandomPosition(), y: size.height)
        addChild(invulnerabilityBonus)
    }
    
    func handleInvulnerabilityBonusContact(contact: SKPhysicsContact) {
        var invBody : SKPhysicsBody
        var otherBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == InvulnerabilityBonusCategory {
            invBody = contact.bodyA
            otherBody = contact.bodyB
            
        } else {
            invBody = contact.bodyB
            otherBody = contact.bodyA
        }
        
        switch otherBody.categoryBitMask {
        case KnightCategory:
            var actions = [SKAction]()
            actions.append(.fadeOut(withDuration: 0.5))
            actions.append(.fadeIn(withDuration: 0.5))
            knight.run(.repeat(.sequence(actions), count: 5))
            knight.physicsBody?.categoryBitMask = InvulnerableKnightCategory
            knight.physicsBody?.collisionBitMask = WorldFrameCategory | FloorCategory | HeartCategory | CoinCategory | GoldBonusCategory
            self.run(.wait(forDuration: 5.0), completion: {
                self.knight.physicsBody?.categoryBitMask = KnightCategory
                self.knight.physicsBody?.collisionBitMask = ArrowCategory | WorldFrameCategory | EnemyCategory | FloorCategory | HeartCategory | BombCategory | CoinCategory | GoldBonusCategory | InvulnerabilityBonusCategory
            })
            fallthrough
        case WorldFrameCategory:
            invBody.node?.removeFromParent()
            invBody.node?.physicsBody = nil
            invBody.node?.removeAllActions()
        default:
            break
        }
    }
    //MARK: Gold bonus creation and contact
    func spawnGoldBonus() {
        goldBonus = GoldBonusSprite.newInstance()
        goldBonus.position = CGPoint(x: createRandomPosition(), y: size.height)
        addChild(goldBonus)
    }
    
    func handleGoldBonusContact(contact: SKPhysicsContact) {
        var goldBody : SKPhysicsBody
        var otherBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == GoldBonusCategory {
            goldBody = contact.bodyA
            otherBody = contact.bodyB
            
        } else {
            goldBody = contact.bodyB
            otherBody = contact.bodyA
        }
        
        switch otherBody.categoryBitMask {
        case KnightCategory:
            for _ in 0...19 {
                hud.addPoint()
            }
            let coins = UserDefaults.standard.value(forKey: "userCoins") as! Int
            UserDefaults.standard.set(coins+10, forKey: "userCoins")
            print("Coins:\(coins+10)")
            hud.updateUserCoins()
            fallthrough
        case WorldFrameCategory:
            goldBody.node?.removeFromParent()
            goldBody.node?.physicsBody = nil
            goldBody.node?.removeAllActions()
        default:
            break
        }
    }
}
