//
//  OwnCallCell.swift
//  SWiPE
//
//  Created by Zoe on 2022/12/1.
//

import UIKit

class OwnCallCell: UITableViewCell, CellConfiguraable {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.transform = CGAffineTransform(rotationAngle: .pi)
        setUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setUI() {
        userImage.layer.cornerRadius = 25
        timeLabel.textColor = CustomColor.text.color
        phoneLabel.textColor = CustomColor.base.color
    }
    
    func setText(message: Message) {
        phoneLabel.text = message.message
        timeLabel.text = Date.dateFormatter.string(from: Date.init(milliseconds: message.createdTime))
    }
    
    func setup(message: Message, userData: User) {
        userImage.loadImage(userData.story)
        phoneLabel.text = message.message
        timeLabel.text = Date.dateFormatter.string(from: Date.init(milliseconds: message.createdTime))
    }
}
