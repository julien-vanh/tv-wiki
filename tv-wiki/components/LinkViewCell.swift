//
//  LinkViewCell.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 29/10/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class LinkViewCell: UICollectionViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var linkLabel: UILabel!
    
    func configure(linkTitle: String) {
        backgroundImageView.adjustsImageWhenAncestorFocused = true
        linkLabel.text = linkTitle
        backgroundImageView.overlayContentView.addSubview(linkLabel)
    }
}
