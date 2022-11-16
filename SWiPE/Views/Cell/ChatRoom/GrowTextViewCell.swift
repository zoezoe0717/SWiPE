//
//  GrowTextViewCell.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/14.
//

import UIKit

protocol GrowCellDelegate: AnyObject {
    func updateHeightOfRow(_ cell: GrowTextViewCell, _ textView: UITextView)
}

class GrowTextViewCell: UITableViewCell {
    @IBOutlet weak var inputTextView: UITextView!
    weak var delegate: GrowCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputTextView.delegate = self
        self.contentView.transform = CGAffineTransform(rotationAngle: .pi)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension GrowTextViewCell: UITextViewDelegate {
    func updateHeightOfRow(_ cell: GrowTextViewCell, _ textView: UITextView) {
        if let delegate = delegate {
            delegate.updateHeightOfRow(self, textView)
        }
    }
}
