//
//  CharacterSkinCollectionViewCell.swift
//  SaveTheKnight
//
//  Created by Valados on 20.01.2022.
//

import UIKit

protocol CharacterSkinCellDelegate: AnyObject {
    func actionButtonTapped(at index:IndexPath, with skin:Dictionary<String,Any>, state: ShopButtonStates)
}

class CharacterSkinCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "characterSkin"
    var delegate: CharacterSkinCellDelegate?
    var indexPath: IndexPath!
    var skin: Dictionary<String,Any>!
    var state: ShopButtonStates!
    
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var characterSkinImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.actionButton.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
        actionButton.layer.cornerRadius = actionButton.frame.height * 0.2
        infoLabel.textColor = .white
        infoLabel.addStroke(color: .black, width: 2)
    }
    
    func configure() {
        let image = UIImage(named: skin["texturePack"] as! String)!
        let price = skin["price"] as! Int
        let name = skin["name"] as! String
        
        switch skin["status"] as! String {
        case "bought":
            state = .bought
        case "onSale":
            state = .onSale
        case "selected":
            state = .selected
        default:
            break
        }
        
        characterSkinImageView.image = image
        infoLabel.text =
        """
        \(name)
        Price:\(price)
        """
        if skin["status"] as! String == "bought" {
            actionButton.setTitle("Select", for: .normal)
            actionButton.backgroundColor = .systemYellow
        } else if skin["status"] as! String == "onSale" {
            actionButton.setTitle("Buy", for: .normal)
            actionButton.backgroundColor = .systemBlue
        } else if skin["status"] as! String == "selected" {
            actionButton.setTitle("Selected ✓", for: .normal)
            actionButton.backgroundColor = .systemGreen
        }
        shadowDecorate()
    }

    @IBAction func actionButtonTapped(_ sender: Any) {
        delegate?.actionButtonTapped(at: indexPath, with: skin, state: state)
    }
}
extension CharacterSkinCollectionViewCell {
    func shadowDecorate() {
        let radius: CGFloat = 10
        contentView.layer.cornerRadius = radius
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
    
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: -1, y: -10),
                                                            size: CGSize(width: 227, height: 320)),
                                        cornerRadius: radius).cgPath
        layer.cornerRadius = radius
    }
}
