//
//  ImageViewCell.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 29/10/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class ImageViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    
    func configure(image: ImageMetadata) {
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.kf.indicatorType = .activity
        if image.url != nil {
            imageView.kf.setImage(with: image.url)
        } else {
            imageView.image = UIImage(named: "ThumbnailCellPlaceholder")
        }
    }
}
