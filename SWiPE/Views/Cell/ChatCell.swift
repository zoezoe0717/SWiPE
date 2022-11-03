//
//  ChatCell.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/3.
//

import UIKit

class ChatCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUI(friend: User) {
        avatarImageView.loadImage(friend.story)
        nameLabel.text = friend.name
    }
}
