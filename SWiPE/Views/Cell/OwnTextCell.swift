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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.transform = CGAffineTransform(rotationAngle: .pi)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setText(message: Message) {
        textView.text = message.message
    }
}