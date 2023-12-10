//
//  ThumbnailPageCell.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 24/10/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class ThumbnailPageCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var unfocusedConstraint: NSLayoutConstraint!
    
    private var focusedConstraint: NSLayoutConstraint!
    
    func configure(page: WikiPage) {
        let topImage = UIImageView()
        topImage.frame = imageView.frame
        topImage.contentMode = .scaleAspectFill
        if let thumbnail = page.thumbnail {
            topImage.kf.setImage(with: thumbnail.source)
        } else {
            topImage.image = UIImage(named: "ThumbnailCellPlaceholder")
        }
        for view in self.imageView.overlayContentView.subviews{
            view.removeFromSuperview()
        }
        self.imageView.overlayContentView.addSubview(topImage)
        titleLabel.text = page.title
    }
    
    func configure(searchResult: WikiSearchResult) {
        let topImage = UIImageView()
        topImage.frame = imageView.frame
        topImage.contentMode = .scaleAspectFill
        if let thumbnail = searchResult.thumbnail {
            topImage.kf.setImage(with: thumbnail.source)
        } else {
            topImage.image = UIImage(named: "ThumbnailCellPlaceholder")
        }
        for view in self.imageView.overlayContentView.subviews{
            view.removeFromSuperview()
        }
        self.imageView.overlayContentView.addSubview(topImage)
        
        titleLabel.text = searchResult.title
    }
    
    func configure(linkResult: WikiLinkResult) {
        let topImage = UIImageView()
        topImage.frame = imageView.frame
        topImage.contentMode = .scaleAspectFill
        if let thumbnail = linkResult.thumbnail {
            topImage.kf.setImage(with: thumbnail.source)
        } else {
            topImage.image = UIImage(named: "ThumbnailCellPlaceholder")
        }
        for view in self.imageView.overlayContentView.subviews{
            view.removeFromSuperview()
        }
        self.imageView.overlayContentView.addSubview(topImage)
        
        titleLabel.text = linkResult.title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        focusedConstraint = titleLabel.topAnchor.constraint(equalTo: imageView.focusedFrameGuide.bottomAnchor, constant: 6)
        imageView.adjustsImageWhenAncestorFocused = true
        titleLabel.layer.zPosition = 99
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        focusedConstraint.isActive = isFocused
        unfocusedConstraint.isActive = !isFocused
        
        titleLabel.textColor = isFocused ? .white : .secondaryLabel
    }
        
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        setNeedsUpdateConstraints()
        coordinator.addCoordinatedAnimations({
            self.layoutIfNeeded()
        }, completion: nil)
    }
}
