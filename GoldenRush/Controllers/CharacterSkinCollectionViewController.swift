//
//  CharacterSkinCollectionViewController.swift
//  SaveTheKnight
//
//  Created by Valados on 20.01.2022.
//

import UIKit

class CharacterSkinCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var coinAmount: UIButton!
    private var textures: [String: Dictionary<String, Any>]!
    private var skins: [[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = "Shop"
        self.navigationController?.navigationBar.barTintColor = .white
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black, NSAttributedString.Key.font: UIFont(name: "Devanagari Sangam MN Bold", size: 22)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes as [NSAttributedString.Key : Any]

        let defaults = UserDefaults.standard
        
        let coins = defaults.integer(forKey: "userCoins")
        
        let quote = " \(coins)"
        let font = UIFont.systemFont(ofSize: 25, weight: .bold)
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.strokeColor: UIColor.black, NSAttributedString.Key.strokeWidth: -2] as [NSAttributedString.Key : Any]
        let attributedCoins = NSAttributedString(string: quote, attributes: attributes)
        coinAmount.setAttributedTitle(attributedCoins, for: .normal)
        coinAmount.isUserInteractionEnabled = false
        configureDataForCollectionView()
    }
    
    func configureDataForCollectionView() {
        let defaults = UserDefaults.standard
        textures = defaults.value(forKey: TexturesKey) as? [String : Dictionary<String, Any>]
        let keys = textures.keys
        var index = 0
        var collection: [[String:Any]] = []
        for key in keys {
            let values = textures[key]!
            let skin = ["name": values["name"]!,
                        "index":values["index"]!,
                        "texture":key,
                        "status": values["status"]!,
                        "price":values["price"]!,
                        "texturePack":values["texturePack"]!,
                        "enemy":values["enemy"]!,
                        "projectile":values["projectile"]!,
                        "soil":values["soil"]!,
                        "background":values["background"]!,
                        "frames":values["frames"]!,
                        "enemySound":values["enemySound"]!
            ]
            collection.append(skin)
            index += 1
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.skins = collection
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func returnToMenu(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return skins.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if let skinCell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterSkinCollectionViewCell.identifier, for: indexPath) as? CharacterSkinCollectionViewCell {
            guard skins.count > 0 else { return cell }
            skinCell.indexPath = indexPath
            let skin = skins.first(where: { skin in
                skin["index"] as! Int == indexPath.row
            })
            skinCell.delegate = self
            skinCell.skin = skin
            skinCell.configure()
            cell = skinCell
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 50, bottom: 0, right: 50)
    }
    
}
extension CharacterSkinCollectionViewController: CharacterSkinCellDelegate {
    func actionButtonTapped(at index: IndexPath, with skin: Dictionary<String, Any>,state: ShopButtonStates) {
        let defaults = UserDefaults.standard
        switch state {
        case .selected:
            break
        case .bought:
            let defaultSkin = defaults.string(forKey: CharacterKey)
            let chosenSkin = skin["texture"] as! String
            if let skin = textures.first(where: { $0.key == defaultSkin }) {
                textures[skin.key]!["status"] = "bought"
            }
            textures[chosenSkin]!["status"] = "selected"
            defaults.set(chosenSkin, forKey: CharacterKey)
            defaults.set(skin["enemy"], forKey: EnemyKey)
            defaults.set(skin["projectile"], forKey: ProjectileKey)
            defaults.set(skin["extraProjectile"], forKey: ExtraProjectileKey)
            defaults.set(skin["soil"], forKey: SoilKey)
            defaults.set(skin["background"], forKey: BackgroundKey)
            defaults.set(textures, forKey: TexturesKey)
            defaults.set(skin["frames"], forKey: FramesKey)
            defaults.set(skin["enemySound"], forKey: EnemySoundKey)
        case .onSale:
            let chosenSkin = skin["texture"] as! String
            let coins = defaults.value(forKey: "userCoins") as! Int
            if coins >= textures[chosenSkin]!["price"] as! Int {
                textures[chosenSkin]!["status"] = "bought"
                let currentCoins = coins - (textures[chosenSkin]!["price"] as! Int)
                defaults.set(textures, forKey: TexturesKey)
                defaults.set(currentCoins, forKey: "userCoins")
                let quote = " \(currentCoins)"
                let font = UIFont.systemFont(ofSize: 25, weight: .bold)
                let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.strokeColor: UIColor.black, NSAttributedString.Key.strokeWidth: -2] as [NSAttributedString.Key : Any]
                let attributedCoins = NSAttributedString(string: quote, attributes: attributes)
                coinAmount.setAttributedTitle(attributedCoins, for: .normal)
            }
        }
        configureDataForCollectionView()
        
    }
}
