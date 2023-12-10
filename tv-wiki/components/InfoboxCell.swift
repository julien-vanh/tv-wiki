//
//  InfoboxCell.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 29/10/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import Foundation
import UIKit

class InfoboxCell : UICollectionViewCell {
    @IBOutlet weak var labelLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    func configure(infoboxLine: (label: String, value: String)) {
        labelLabel.text = infoboxLine.label + " :"
        valueLabel.text = infoboxLine.value
    }
}
