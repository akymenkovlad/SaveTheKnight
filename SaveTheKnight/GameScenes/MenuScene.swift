//
//  MenuScene.swift
//  SaveTheKnight
//
//  Created by Valados on 17.01.2022.
//

import SpriteKit

class MenuScene : SKScene {
    let startButtonTexture = SKTexture(imageNamed: "button_start")
    let soundButtonTexture = SKTexture(imageNamed: "speaker_on")
    let soundButtonTextureOff = SKTexture(imageNamed: "speaker_off")
    let shopButtonTexture = SKTexture(imageNamed: "shop")
    
    var startButton : SKSpriteNode! = nil
    var soundButton : SKSpriteNode! = nil
    var shopButton : SKSpriteNode! = nil
    
    let logoNode = SKLabelNode(text: "Protect the Knight")
    let highScoreNode = SKLabelNode(fontNamed: "CopperPlate")
    
    var selectedButton : SKSpriteNode?
    
    override func sceneDidLoad() {
        backgroundColor = SKColor(red:169/255.0, green:169/255.0, blue:169/255.0, alpha:1.0)
        
        //Setup logo - label initialized earlier
        logoNode.position = CGPoint(x: size.width / 2, y: size.height / 2 + 150)
        logoNode.verticalAlignmentMode = .top
        logoNode.fontName = "CopperPlate"
        logoNode.fontSize = 70
        addChild(logoNode)
        
        //Setup start button
        startButton = SKSpriteNode(texture: startButtonTexture)
        startButton.position = CGPoint(x: size.width / 2, y: size.height / 2 )
        addChild(startButton)
        
        let edgeMargin : CGFloat = 25
        //Setup sound button
        soundButton = SKSpriteNode(texture: SoundManager.sharedInstance.isMuted ? soundButtonTextureOff : soundButtonTexture)
        soundButton.position = CGPoint(x: size.width - soundButton.size.width / 2 - edgeMargin, y: soundButton.size.height / 2 + edgeMargin)
        addChild(soundButton)
        
        //Setup shop button
        shopButton = SKSpriteNode(texture: shopButtonTexture)
        shopButton.xScale = 0.4
        shopButton.yScale = 0.4
        shopButton.position = CGPoint(x: size.width/100  + shopButton.size.width / 2 + edgeMargin, y: shopButton.size.height / 2 + edgeMargin)
        addChild(shopButton)
        
        //Setup high score node
        let defaults = UserDefaults.standard
        
        let highScore = defaults.integer(forKey: ScoreKey)
        
        highScoreNode.text = "\(highScore)"
        highScoreNode.fontSize = 70
        highScoreNode.verticalAlignmentMode = .top
        highScoreNode.position = CGPoint(x: size.width / 2, y: startButton.position.y - startButton.size.height / 2 - 50)
        highScoreNode.zPosition = 1
        addChild(highScoreNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if selectedButton != nil {
                handleSoundButtonHover(isHovering: false)
            }
            
            if startButton.contains(touch.location(in: self)) {
                selectedButton = startButton
            } else if soundButton.contains(touch.location(in: self)) {
                selectedButton = soundButton
                handleSoundButtonHover(isHovering: true)
            } else if shopButton.contains(touch.location(in: self)) {
                selectedButton = shopButton
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            if selectedButton == soundButton {
                handleSoundButtonHover(isHovering: (soundButton.contains(touch.location(in: self))))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            if selectedButton == startButton {
                
                if (startButton.contains(touch.location(in: self))) {
                    handleStartButtonClick()
                }
                
            } else if selectedButton == soundButton {
                handleSoundButtonHover(isHovering: false)
                
                if (soundButton.contains(touch.location(in: self))) {
                    handleSoundButtonClick()
                }
            } else if selectedButton == shopButton {
                if (shopButton.contains(touch.location(in: self))) {
                    handleShopButtonClick()
                }
            }
        }
        
        selectedButton = nil
    }
    
    func handleSoundButtonHover(isHovering : Bool) {
        if isHovering {
            soundButton.alpha = 0.5
        } else {
            soundButton.alpha = 1.0
        }
    }
    
    func handleStartButtonClick() {
        let transition = SKTransition.reveal(with: .down, duration: 0.75)
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = .aspectFill
        view?.presentScene(gameScene, transition: transition)
    }
    
    func handleShopButtonClick() {
        let transition = SKTransition.reveal(with: .down, duration: 0.75)
        let gameScene = ShopScene(size: size)
        gameScene.scaleMode = .aspectFill
        view?.presentScene(gameScene, transition: transition)
    }
    
    func handleSoundButtonClick() {
        if SoundManager.sharedInstance.toggleMute() {
            //Is muted
            soundButton.texture = soundButtonTextureOff
        } else {
            //Is not muted
            soundButton.texture = soundButtonTexture
        }
    }
    
}
