//
//  HudNode.swift
//  SaveTheKnight
//
//  Created by Valados on 17.01.2022.
//

import SpriteKit

class HudNode : SKNode {
    private let scoreKey = "SAVEKNIGHT_HIGHSCORE"
    private let scoreNode = SKLabelNode(fontNamed: "Copperplate")
    private (set) var score : Int = 0
    private var highScore : Int = 0
    private var showingHighScore = false
    
    private var quitButton : SKSpriteNode!
    private let quitButtonTexture = SKTexture(imageNamed: "quit_button")
    var quitButtonAction : (() -> ())?
    private(set) var quitButtonPressed = false
    
    private var healthPoints =  [SKSpriteNode]()
    private var health: Int = 3
    
    //Setup hud here
    public func setup(size: CGSize) {
        let defaults = UserDefaults.standard
        
        highScore = defaults.integer(forKey: scoreKey)
        
        scoreNode.text = "\(score)"
        scoreNode.fontSize = 50
        scoreNode.position = CGPoint(x: size.width / 2, y: size.height - 50)
        scoreNode.zPosition = 1
        
        quitButton = SKSpriteNode(texture: quitButtonTexture)
        quitButton.yScale = 0.5
        quitButton.xScale = 0.5
        let margin : CGFloat = 5
        quitButton.position = CGPoint(x: size.width - quitButton.size.width/2-margin, y: size.height - quitButton.size.height/2-margin)
        quitButton.zPosition = 1000
        
        for i in 0..<3 {
            let healthNode = SKSpriteNode(imageNamed: "heart")
            healthNode.xScale = 0.2
            healthNode.yScale = 0.2
            let x = Double(i)/2.0
            healthNode.position = CGPoint(x: size.width/20 + healthNode.size.width*x+margin, y: size.height - healthNode.size.height/2-margin)
            healthNode.zPosition = 1000
            
            healthPoints.append(healthNode)
            addChild(healthPoints[i])
        }
        
        addChild(quitButton)
        addChild(scoreNode)
    }
    
    public func addPoint() {
        score += 1
        
        updateScoreboard()
        
        if score > highScore {
            
            let defaults = UserDefaults.standard
            
            defaults.set(score, forKey: scoreKey)
            
            if !showingHighScore {
                showingHighScore = true
                
                scoreNode.run(SKAction.scale(to: 1.25, duration: 0.25))
                scoreNode.fontColor = SKColor.yellow
            }
        }
    }
    
    public func resetPoints() {
        score = 0
        
        updateScoreboard()
        
        if showingHighScore {
            showingHighScore = false
            
            scoreNode.run(SKAction.scale(to: 1.0, duration: 0.25))
            scoreNode.fontColor = SKColor.white
        }
    }
    
    private func updateScoreboard() {
        scoreNode.text = "\(score)"
    }
    
    public func isLose() -> Bool {
        health -= 1
        if health == 0 {
            healthPoints[health].run( .fadeOut(withDuration: 0.2))
            resetPoints()
            health = 3
            for healthPoint in healthPoints {
                healthPoint.run(.wait(forDuration: 2), completion: { healthPoint.alpha = 1.0 })
            }
            return true
        } else {
            healthPoints[health].run( .fadeOut(withDuration: 0.2))
            return false
        }
    }
    
    func touchBeganAtPoint(point: CGPoint) {
        let containsPoint = quitButton.contains(point)
        
        if quitButtonPressed && !containsPoint {
            quitButtonPressed = false
        } else if containsPoint {
            quitButtonPressed = true
        }
    }
    
    func touchEndedAtPoint(point: CGPoint) {
        if quitButton.contains(point) && quitButtonAction != nil {
            quitButtonAction!()
        }
    }
}
