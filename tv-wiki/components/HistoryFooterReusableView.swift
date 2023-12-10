//
//  HistoryFooterReusableView.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 14/05/2020.
//  Copyright © 2020 Julien Vanheule. All rights reserved.
//

import UIKit

class HistoryFooterReusableView : UICollectionReusableView {
    @IBOutlet weak var deleteHistoryButton: UIButton!
    private var parent: HistoryViewController!
    
    func configure(parent: HistoryViewController){
        self.parent = parent
        
        deleteHistoryButton.setTitle(NSLocalizedString("Clear history", comment: ""), for: .normal)
        deleteHistoryButton.setTitleColor(.red, for: .focused)
        deleteHistoryButton.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        if let vc = parent {
            vc.deleteAllHistory()
        }
    }
}
