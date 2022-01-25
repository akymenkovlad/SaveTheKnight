//
//  CharacterSkinCollectionViewCell.swift
//  SaveTheKnight
//
//  Created by Valados on 20.01.2022.
//

import UIKit

protocol CharacterSkinCellDelegate: AnyObject {
    func selectButtonTapped(at index:IndexPath, with skin:Dictionary<String,Any>)
    func buyButtonTapped(at index:IndexPath, with skin:Dictionary<String,Any>)
}

class CharacterSkinCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "characterSkin"
    var delegate: CharacterSkinCellDelegate?
    var indexPath: IndexPath!
    var skin: Dictionary<String,Any>!
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var characterSkinImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.buyButton.addTarget(self, action: #selector(buyButtonTapped(_:)), for: .touchUpInside)
        self.selectButton.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
    }
    
    func configure() {
        let image = UIImage(named: skin["texture"] as! String)!
        let price = skin["price"] as! Int
        let name = skin["name"] as! String
        characterSkinImageView.image = image
        infoLabel.text = """
        \(name)
        Price:\(price)
        """
        if skin["status"] as! String == "bought" {
            buyButton.isHidden = true
            selectButton.isEnabled = true
            selectButton.isUserInteractionEnabled = true
            selectButton.setTitle("Select", for: .normal)
            selectButton.backgroundColor = .systemBlue
        } else if skin["status"] as! String == "onSale" {
            buyButton.isHidden = false
            selectButton.isEnabled = false
            selectButton.setTitle("Select", for: .normal)
            selectButton.backgroundColor = .systemBlue
        } else if skin["status"] as! String == "selected" {
            buyButton.isHidden = true
            selectButton.isEnabled = true
            selectButton.isUserInteractionEnabled = false
            selectButton.setTitle("Selected ✓", for: .normal)
            selectButton.backgroundColor = .systemGreen
        }
        
    }
    
    @IBAction func selectButtonTapped(_ sender: Any) {
        delegate?.selectButtonTapped(at: indexPath, with: skin)
    }
    @IBAction func buyButtonTapped(_ sender: Any) {
        delegate?.buyButtonTapped(at: indexPath, with: skin)
    }
}
