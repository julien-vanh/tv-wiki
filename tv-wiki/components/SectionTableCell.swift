//
//  SectionTableCell.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 13/11/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import Foundation
import UIKit

class SectionTableCell : UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    private var level: Int = 1
    
    func configure(_ content: WikiParseContentSection){
        var title = ""
        for _ in 1..<content.toclevel {
            title += "   "
        }
        title += content.line.deleteHTMLTags()
        titleLabel.text = title
        
        level = content.toclevel
        configureTitleLabel()
    }
    
    private func configureTitleLabel(){
        switch level {
        case 1:
            titleLabel.textColor = UIColor.label
            titleLabel.font = titleLabel.font.withSize(50)
        case 2:
            titleLabel.textColor = UIColor.secondaryLabel
            titleLabel.font = titleLabel.font.withSize(42)
        default:
            titleLabel.textColor = UIColor.tertiaryLabel
            titleLabel.font = titleLabel.font.withSize(36)
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        if isFocused {
            titleLabel.textColor = .darkGray
        } else {
            configureTitleLabel()
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        setNeedsUpdateConstraints()
        coordinator.addCoordinatedAnimations({
            self.layoutIfNeeded()
        }, completion: nil)
    }
}
