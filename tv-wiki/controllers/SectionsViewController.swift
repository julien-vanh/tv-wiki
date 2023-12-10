//
//  SectionsViewController.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 13/11/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import Foundation
import UIKit

class SectionsViewController : UIViewController {
    var pageContent = WikiPageContent(pageid: 1)

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sectionsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    private func initViews(){
        titleLabel.text = pageContent.title
        textView.text = ""
        textView.isSelectable = true
        textView.panGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]
        
        sectionsTable.delegate = self
        sectionsTable.dataSource = self
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self.textView {
            textView.backgroundColor = .white
            textView.textColor = .black
        } else {
            textView.backgroundColor = .clear
            textView.textColor = .label
        }
    }
}

extension SectionsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pageContent.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionTableCell", for: indexPath) as! SectionTableCell
        cell.configure(pageContent.sections[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let nextIndexPath = context.nextFocusedIndexPath {
            let sectionId = pageContent.sections[nextIndexPath.item].index
            
            WikipediaService.shared.getPageText(pageContent.pageid, sectionId: sectionId) { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let parseContent):
                    if let text = parseContent.text["*"]{
                        DispatchQueue.main.async {
                            self.textView.text = text.deleteHTMLTags()
                            self.textView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
                        }
                    }
                }
            }
        }
    }
}
