//
//  MenuScene.swift
//  SaveTheKnight
//
//  Created by Valados on 17.01.2022.
//

import SpriteKit

protocol TransitionDelegate: SKSceneDelegate {
    func goToShop()
}

class MenuScene : SKScene {
    let startButtonTexture = SKTexture(imageNamed: "start_button")
    let soundButtonTexture = SKTexture(imageNamed: "volume_on")
    let soundButtonTextureOff = SKTexture(imageNamed: "volume_off")
    let shopButtonTexture = SKTexture(imageNamed: "shop")
    let backgroundTextture = SKTexture(imageNamed: "menu_background")
    
    var startButton: SKSpriteNode! = nil
    var soundButton: SKSpriteNode! = nil
    var shopButton: SKSpriteNode! = nil
    var background: SKSpriteNode! = nil
    
    let logoNode = SKLabelNode(text: "Protect the Knight")
    let highScoreNode = SKLabelNode(fontNamed: "CopperPlate")
    
    var selectedButton : SKSpriteNode?
    weak var transitonDelegate: TransitionDelegate?
    
    override func sceneDidLoad() {
        backgroundColor = SKColor(red:169/255.0, green:169/255.0, blue:169/255.0, alpha:1.0)
        
        background = SKSpriteNode(texture: backgroundTextture, size: size)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -100
        addChild(background)
        
        //Setup logo - label initialized earlier
        logoNode.position = CGPoint(x: size.width / 2, y: size.height / 2 + 150)
        logoNode.verticalAlignmentMode = .top
        logoNode.fontName = "CopperPlate"
        logoNode.fontSize = 70
        addChild(logoNode)
        
        //Setup start button
        startButton = SKSpriteNode(texture: startButtonTexture)
        startButton.position = CGPoint(x: size.width / 2, y: size.height / 2 )
        startButton.xScale = 0.4
        startButton.yScale = 0.4
        addChild(startButton)
        
        let edgeMargin : CGFloat = 20
        //Setup sound button
        soundButton = SKSpriteNode(texture: SoundManager.sharedInstance.isMuted ? soundButtonTextureOff : soundButtonTexture)
        soundButton.xScale = 0.5
        soundButton.yScale = 0.5
        soundButton.position = CGPoint(x: size.width - soundButton.size.width / 2 - edgeMargin, y: soundButton.size.height / 2 + edgeMargin)
        addChild(soundButton)
        
        //Setup shop button
        shopButton = SKSpriteNode(texture: shopButtonTexture)
        shopButton.xScale = 0.4
        shopButton.yScale = 0.4
        shopButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - startButton.size.height - edgeMargin)
        addChild(shopButton)
        
        //Setup high score node
        let defaults = UserDefaults.standard
        
        let highScore = defaults.integer(forKey: ScoreKey)
        
        highScoreNode.text = "HighScore:\(highScore)"
        highScoreNode.horizontalAlignmentMode = .center
        highScoreNode.fontSize = 50
        highScoreNode.position = CGPoint(x: size.width / 2, y: shopButton.position.y - shopButton.size.height / 2 - 50)
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
        gameScene.transitonDelegate = transitonDelegate
        view?.presentScene(gameScene, transition: transition)
    }
    
    func handleShopButtonClick() {
        guard let delegate = transitonDelegate else { return }
        delegate.goToShop()
        return
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
