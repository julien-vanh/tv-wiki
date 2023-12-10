//
//  PageImageViewControler.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 29/10/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

private enum State {
    case closed
    case open
}
 
extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

class PageImageViewController : UIViewController {
    var image:ImageMetadata!
    private var currentState: State = .closed
    
    @IBOutlet weak var imageDescriptionView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var authorTextView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomImageDescriptionViewConstraint: NSLayoutConstraint!
    var transitionAnimator:UIViewPropertyAnimator!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomImageDescriptionViewConstraint.constant = -360
        
        imageView.kf.indicatorType = .activity
        if image.url != nil {
            imageView.kf.setImage(with: image.url)
        }
        
        if image.artist != nil {
            authorTextView.text = image.artist
        } else {
            authorTextView.text = ""
        }
        
        if image.description != nil {
            descriptionTextView.text = image.description
        } else {
            descriptionTextView.text = ""
        }
        
        
    }
    
    
    
    public func toogleImageDescriptionView() {
        if currentState == .closed {
            bottomImageDescriptionViewConstraint.constant = -60
        } else {
            bottomImageDescriptionViewConstraint.constant = -360
        }
        currentState = currentState.opposite
        self.view.layoutIfNeeded()
    }
    
    
}

