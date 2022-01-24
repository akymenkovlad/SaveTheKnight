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
        
        coinAmount.setTitle("Coins:\(coins)", for: .normal)
        coinAmount.isUserInteractionEnabled = false
        
        defaults.register(defaults: [CharacterKey:"knight"])
        defaults.register(defaults: [TexturesKey:[
            "knight":["name":"Knight","status":"selected","price":0],
            "mummy":["name":"Mummy","status":"onSale","price":400],
            "god":["name":"God","status":"onSale","price":500],
        ]])
        
        
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
            let skin = ["name": values["name"]!,"column":index,"texture":key,"status": values["status"]!,"price":values["price"]!]
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return skins.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if let skinCell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterSkinCollectionViewCell.identifier, for: indexPath) as? CharacterSkinCollectionViewCell {
            guard skins.count > 0 else { return cell }
            skinCell.indexPath = indexPath
            let skin = skins[indexPath.row]
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
        defaults.set(textures, forKey: TexturesKey)
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
