//
//  OwnTextCell.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/4.
//

import UIKit

class OwnTextCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
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
    }
    
    func setText(message: Message) {
        textView.text = message.message
        timeLabel.text = Date.dateFormatter.string(from: Date.init(milliseconds: message.createdTime))
    }
}
