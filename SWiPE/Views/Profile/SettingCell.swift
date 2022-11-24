//
//  SettingCell.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/23.
//

import UIKit

class SettingCell: UITableViewCell {
    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardBackgroundView.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
