//
//  FriendTextCell.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/4.
//

import UIKit

class FriendTextCell: UITableViewCell {
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.transform = CGAffineTransform(rotationAngle: .pi)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setText(message: Message) {
        textView.text = message.message
        timeLabel.text = Date.dateFormatter.string(from: Date(milliseconds: message.createdTime))
    }
}
