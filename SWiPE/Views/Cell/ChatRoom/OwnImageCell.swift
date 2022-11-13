//
//  OwnImageCell.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/9.
//

import UIKit

class OwnImageCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.transform = CGAffineTransform(rotationAngle: .pi)
        messageImage.layer.cornerRadius = 20
        userImage.layer.cornerRadius = 25
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(message: Message) {
        messageImage.loadImage(message.message)
        timeLabel.text = Date.dateFormatter.string(from: Date(milliseconds: message.createdTime))
    }
}
