//
//  FirstViewController.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 23/10/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import UIKit
import TVUIKit

class DiscoverViewController: UIViewController  {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var discoverCollectionView: UICollectionView!
    
    @IBOutlet weak var linksTitle: UILabel!
    @IBOutlet weak var linksCollectionView: UICollectionView!
    
    var linksResults = [WikiLinkResult]() {
        didSet {
            DispatchQueue.main.async {
                self.discoverCollectionView.reloadData()
            }
        }
    }
    var linksWithoutThumbnail = [WikiLinkResult]() {
        didSet {
            DispatchQueue.main.async {
                self.linksCollectionView.reloadData()
            }
        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tabBarItem = UITabBarItem(title: NSLocalizedString("tabbar.discover", comment: ""), image: nil, tag: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViews()
        
        WikipediaService.shared.getMainPageArticle { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let linksResults):
                var resultWithThumbnail = [WikiLinkResult]()
                var resultsWithoutThumbnail = [WikiLinkResult]()
                for linkResult in linksResults {
                    if linkResult.thumbnail != nil {
                        resultWithThumbnail.append(linkResult)
                    } else {
                        resultsWithoutThumbnail.append(linkResult)
                    }
                }
                self?.linksResults = resultWithThumbnail
                self?.linksWithoutThumbnail = resultsWithoutThumbnail
            }
        }
    }
    
    private func isCovidArticle(_ result: WikiLinkResult) -> Bool {
        return result.title.lowercased().contains("covid") || result.title.lowercased().contains("coronavirus")
    }
    
    private func initViews(){
        titleLabel.text = NSLocalizedString("discover.title", comment: "")
        
        discoverCollectionView.delegate = self
        discoverCollectionView.dataSource = self
        discoverCollectionView.register(UINib(nibName: "ThumbnailPageCell", bundle: nil), forCellWithReuseIdentifier: "ThumbnailPageCell")
        
        linksTitle.text = NSLocalizedString("discover.links", comment: "")
        
        linksCollectionView.delegate = self
        linksCollectionView.dataSource = self
        linksCollectionView.register(UINib(nibName: "LinkViewCell", bundle: nil), forCellWithReuseIdentifier: "LinkViewCell")
    }
}



extension DiscoverViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.linksCollectionView {
            return linksWithoutThumbnail.count
        } else {
            return linksResults.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.linksCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LinkViewCell", for: indexPath) as! LinkViewCell
            cell.configure(linkTitle: linksWithoutThumbnail[indexPath.item].title)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailPageCell", for: indexPath) as! ThumbnailPageCell
            cell.configure(linkResult: linksResults[indexPath.item])
            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pageid:Int;
        if collectionView == self.linksCollectionView {
            pageid = self.linksWithoutThumbnail[indexPath.item].pageid
        } else {
            pageid = self.linksResults[indexPath.item].pageid
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WikiPageViewController") as! WikiPageViewController
        vc.pageid = pageid
        vc.delegate = self
        
        present(vc, animated: true, completion: nil)
    }
}

extension DiscoverViewController : WikiPageViewControllerDelegate {
    func shouldRedirectToPage(pageId: Int) {
        self.dismiss(animated: false) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WikiPageViewController") as! WikiPageViewController
            vc.pageid = pageId
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
}

