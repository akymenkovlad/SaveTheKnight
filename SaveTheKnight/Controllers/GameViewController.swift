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
        let defaults = UserDefaults.standard
        defaults.register(defaults: ["userCoins":0])
        defaults.register(defaults: [CharacterKey:"digger"])
        defaults.register(defaults: [EnemyKey:"bear"])
        defaults.register(defaults: [ProjectileKey:"bomb"])
        defaults.register(defaults: [ExtraProjectileKey:"dynamite"])
        defaults.register(defaults: [SoilKey:"digger_soil"])
        defaults.register(defaults: [BackgroundKey:"digger_background"])
        defaults.register(defaults: [FramesKey:["digger",
                                                "digger_2",
                                                "digger_3",
                                                "digger_4",
                                                "digger_5",
                                                "digger_6",
                                                "digger_7",
                                                "digger_8",
                                                "digger_9"]
                                    ])
        defaults.register(defaults: [TexturesKey:
                                        [ "digger":["index":0,
                                                    "name":"Digger",
                                                    "status":"selected",
                                                    "price":0,
                                                    "texturePack":"digger_skins",
                                                    "enemy":"bear",
                                                    "projectile":"bomb",
                                                    "soil":"digger_soil",
                                                    "background":"digger_background",
                                                    "frames":["digger",
                                                              "digger_2",
                                                              "digger_3",
                                                              "digger_4",
                                                              "digger_5",
                                                              "digger_6",
                                                              "digger_7",
                                                              "digger_8",
                                                              "digger_9"
                                                             ]
                                                   ],
                                          "tourist":["index":1,
                                                     "name":"Tourist",
                                                     "status":"onSale",
                                                     "price":400,
                                                     "texturePack":"tourist_skins",
                                                     "enemy":"iceman",
                                                     "projectile":"ice",
                                                     "soil":"tourist_soil",
                                                     "background":"tourist_background",
                                                     "frames":[ "tourist",
                                                                "tourist_2",
                                                                "tourist_3",
                                                                "tourist_4",
                                                                "tourist_5",
                                                                "tourist_6",
                                                                "tourist_7",
                                                                "tourist_8",
                                                                "tourist_9",
                                                                "tourist_10",
                                                                "tourist_11",
                                                                "tourist_12"
                                                              ]
                                                    ],
                                          "farmer":["index":2,
                                                    "name":"Farmer",
                                                    "status":"onSale",
                                                    "price":550,
                                                    "texturePack":"farmer_skins",
                                                    "enemy":"wolf",
                                                    "projectile":"bug",
                                                    "soil":"farmer_soil",
                                                    "background":"farmer_background",
                                                    "frames":["farmer",
                                                              "farmer_2",
                                                              "farmer_3",
                                                              "farmer_4",
                                                              "farmer_5",
                                                              "farmer_6",
                                                              "farmer_7",
                                                              "farmer_8",
                                                              "farmer_9",
                                                              "farmer_10"
                                                             ]
                                                   ],
                                        ]
                                    ])
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let sceneNode = MenuScene(size: view.frame.size)
        sceneNode.scaleMode = .aspectFill
        sceneNode.transitonDelegate = self as TransitionDelegate
        
        if let view = self.view as! SKView? {
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
extension GameViewController: TransitionDelegate {
    func goToShop() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CharacterSkinCollectionViewController") as! CharacterSkinCollectionViewController
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true, completion: nil)
    }
}
