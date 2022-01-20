//
//  ShopScene.swift
//  SaveTheKnight
//
//  Created by Valados on 18.01.2022.
//

import SpriteKit

class ShopScene: SKScene {
    
    private var characterSkins = [SKSpriteNode]()
    private var shapeNode = SKShapeNode(rectOf: CGSize(width: 150, height: 150))
    private var grid: Grid!
    private let shopHud = ShopHudNode()
    private lazy var buyButton = SKSpriteNode(texture: SKTexture(imageNamed: "buy_button"),size: CGSize(width: 150, height: 75))
    private lazy var priceLabel = SKLabelNode(fontNamed: "Copperplate")

    private var textures: [String: Dictionary<String, Any>]!
    private lazy var chosenColumn: Int = 0
    private lazy var skinPrice: Int = 0
    private lazy var chosenSkin: String = ""
    
    override func  sceneDidLoad() {
        backgroundColor = SKColor(red:169/255.0, green:169/255.0, blue:169/255.0, alpha:1.0)
        
        let defaults = UserDefaults.standard
        defaults.register(defaults: [CharacterKey:"knight"])
        defaults.register(defaults: [TexturesKey:[
            "knight":["status":"bought","price":0],
            "mummy":["status":"onSale","price":4],
            "god":["status":"onSale","price":3]
        ]])
        
        textures = defaults.value(forKey: TexturesKey) as? [String : Dictionary<String, Any>]
        let keys = textures.keys
        
        shapeNode.fillColor = .clear
        shapeNode.strokeColor = .systemYellow
        shapeNode.lineWidth = 5
        shapeNode.zPosition = 10
        
        grid = Grid(blockSize: 150, rows: 1, cols: textures.count)
        
        grid.position = CGPoint (x:frame.midX, y:frame.midY)
        
        var index = 0
        for key in keys {
            let values = textures[key]!
            let charTexture = SKSpriteNode(texture: SKTexture(imageNamed: key), size: CGSize(width: 100, height: 100))
            charTexture.position = grid.gridPosition(row: 0, col: index)
            charTexture.name = "texture"
            charTexture.userData = ["row":0,"column":index,"texture":key,"status": values["status"]!,"price":values["price"]!]
            characterSkins.append(charTexture)
            index += 1
        }
        let chosenTexture = defaults.string(forKey: CharacterKey)
        
        for button in characterSkins {
            grid.addChild(button)
            if button.userData!["texture"] as? String == chosenTexture {
                shapeNode.position = grid.gridPosition(row: button.userData?["row"] as! Int, col: button.userData?["column"] as! Int)
            }
        }
        
        shopHud.setup(size: size)
        
        shopHud.backButtonAction = {
            self.handleBackButtonClick()
            self.shopHud.backButtonAction = nil
        }
        addChild(grid)
        grid.addChild(shapeNode)
        addChild(shopHud)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first?.location(in: self)
        if let point = touchPoint {
            shopHud.touchBeganAtPoint(point: point)
            if !shopHud.backButtonPressed {
                guard let touchedNode = self.atPoint(touchPoint!) as? SKSpriteNode else { return }
                if touchedNode.name == "buy" {
                    let defaults = UserDefaults.standard
                    let coins = defaults.value(forKey: "userCoins") as! Int
                    if coins >= textures[chosenSkin]!["price"] as! Int {
                        textures[chosenSkin]!["status"] = "bought"
                        let currentCoins = coins - (textures[chosenSkin]!["price"] as! Int)
                        defaults.set(textures, forKey: TexturesKey)
                        defaults.set(currentCoins, forKey: "userCoins")
                        defaults.set(chosenSkin, forKey: CharacterKey)
                        characterSkins[chosenColumn].userData!["status"] = "bought"
                        buyButton.removeFromParent()
                        priceLabel.removeFromParent()
                        shopHud.updateUserCoins()
                    }
                }
                else if touchedNode.name == "texture" {
                    guard let userData = touchedNode.userData else { return }
                    if let index = userData["column"] as? Int {
                        switch index {
                        case 0..<textures.count:
                            if userData["status"] as! String == "bought" {
                                let defaults = UserDefaults.standard
                                defaults.set(userData["texture"], forKey: CharacterKey)
                                buyButton.isHidden = true
                                priceLabel.isHidden = true
                            } else if userData["status"] as! String == "onSale" {
                                if !grid.children.contains(where: { $0.name == "buy" }) {
                                    buyButton.name = "buy"
                                    grid.addChild(buyButton)
                                    grid.addChild(priceLabel)
                                }
                                let positon = grid.gridPosition(row: userData["row"] as! Int, col: userData["column"] as! Int)
                                buyButton.position.x = positon.x
                                buyButton.position.y = positon.y - 75 - buyButton.size.height / 2
                                buyButton.isHidden = false
                                
                                chosenColumn = userData["column"] as! Int
                                skinPrice = userData["price"] as! Int
                                chosenSkin = userData["texture"] as! String
                                
                                priceLabel.text = "Price:\(skinPrice)"
                                priceLabel.fontSize = 30
                                priceLabel.position.x = positon.x
                                priceLabel.position.y = position.y + 75 + priceLabel.frame.height / 2
                                priceLabel.isHidden = false
                            }
                            shapeNode.position = grid.gridPosition(row: userData["row"] as! Int, col: userData["column"] as! Int)
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first?.location(in: self)
        
        if let point = touchPoint {
            shopHud.touchEndedAtPoint(point: point)
        }
        
    }
    
    func handleBackButtonClick() {
        let transition = SKTransition.reveal(with: .down, duration: 0.75)
        let gameScene = MenuScene(size: size)
        gameScene.scaleMode = .aspectFill
        view?.presentScene(gameScene, transition: transition)
    }
}
