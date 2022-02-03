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
        
        let defaults = UserDefaults.standard
        
        let coins = defaults.integer(forKey: "userCoins")
        
        let quote = "\(coins)"
        let font = UIFont.systemFont(ofSize: 25, weight: .bold)
        let attributes = [NSAttributedString.Key.font: font]
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
                        "frames":values["frames"]!
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 250, height: 350)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let leftInset = 50.0
        let rightInset = leftInset
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
}
extension CharacterSkinCollectionViewController: CharacterSkinCellDelegate {
    func selectButtonTapped(at index: IndexPath, with skin: Dictionary<String, Any>) {
        print("select \(index)")
        let defaults = UserDefaults.standard
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
        configureDataForCollectionView()
    }
    
    func buyButtonTapped(at index: IndexPath, with skin: Dictionary<String, Any>) {
        print("buy \(index)")
        let chosenSkin = skin["texture"] as! String
        let defaults = UserDefaults.standard
        let coins = defaults.value(forKey: "userCoins") as! Int
        if coins >= textures[chosenSkin]!["price"] as! Int {
            textures[chosenSkin]!["status"] = "bought"
            let currentCoins = coins - (textures[chosenSkin]!["price"] as! Int)
            defaults.set(textures, forKey: TexturesKey)
            defaults.set(currentCoins, forKey: "userCoins")
            coinAmount.setTitle("Coins:\(currentCoins)", for: .normal)
            configureDataForCollectionView()
        }
    }
}
