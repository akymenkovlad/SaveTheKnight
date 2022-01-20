//
//  GameViewController.swift
//  SaveTheKnight
//
//  Created by Valados on 17.01.2022.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SoundManager.sharedInstance.startPlaying()
        UserDefaults.standard.register(defaults: ["userCoins":0])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let sceneNode = MenuScene(size: view.frame.size)
        sceneNode.scaleMode = .aspectFill
        
        if let view = self.view as! SKView? {
            if let currentScene = view.scene {
                print("Current scene is: \(currentScene)")
            }
            else {
                print("Current scene is nil")
            }
            view.presentScene(sceneNode)
            view.ignoresSiblingOrder = true
            
            view.showsPhysics = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
