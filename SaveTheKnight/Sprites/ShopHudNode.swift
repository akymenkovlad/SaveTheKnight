//
//  ShopHudNode.swift
//  SaveTheKnight
//
//  Created by Valados on 19.01.2022.
//

import SpriteKit

class ShopHudNode : SKNode {
    private let shopNode = SKLabelNode(fontNamed: "Copperplate")
    
    private var backButton : SKSpriteNode!
    private let backButtonTexture = SKTexture(imageNamed: "back_button")
    var backButtonAction : (() -> ())?
    private(set) var backButtonPressed = false
    
    private var coin : SKSpriteNode!
    private let coinTexture = SKTexture(imageNamed: "coin")
    private let coinAmount = SKLabelNode(fontNamed: "Copperplate")
    private var coins: Int = UserDefaults.standard.value(forKey: "userCoins") as! Int
    
    //Setup hud here
    public func setup(size: CGSize) {
        
        shopNode.text = "Shop"
        shopNode.fontSize = 50
        shopNode.position = CGPoint(x: size.width / 2, y: size.height - 50)
        shopNode.zPosition = 1000
        
        backButton = SKSpriteNode(texture: backButtonTexture)
        backButton.size = CGSize(width: 75, height: 75)
        backButton.position = CGPoint(x: size.width / 20, y: size.height - backButton.size.height / 2)
        backButton.zPosition = 1000
        
        coin = SKSpriteNode(texture: coinTexture)
        coin.size = CGSize(width: 50, height: 50)
        coin.position = CGPoint(x: size.width - coin.size.width, y: size.height - 40)
        coin.zPosition = 1000
        
        coinAmount.text = "\(coins)"
        coinAmount.fontSize = 50
        coinAmount.position = CGPoint(x: coin.position.x - 25 - coinAmount.frame.width/2, y: size.height - 50)
        coinAmount.zPosition = 1000
        
        addChild(backButton)
        addChild(shopNode)
        addChild(coin)
        addChild(coinAmount)
    }

    func updateUserCoins(){
        let defaults = UserDefaults.standard
        coins = defaults.value(forKey: "userCoins") as! Int
        coinAmount.text = "\(coins)"
    }
    
    func touchBeganAtPoint(point: CGPoint) {
        let containsPoint = backButton.contains(point)
        
        if backButtonPressed && !containsPoint {
            backButtonPressed = false
        } else if containsPoint {
            backButtonPressed = true
        }
    }
    
    func touchEndedAtPoint(point: CGPoint) {
        if backButton.contains(point) && backButtonAction != nil {
            backButtonAction!()
        }
    }
}
