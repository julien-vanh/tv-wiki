//
//  SecondViewController.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 23/10/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pages = [Int:WikiPage]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tabBarItem = UITabBarItem(title: NSLocalizedString("tabbar.history", comment: ""), image: nil, tag: 1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ThumbnailPageCell", bundle: nil), forCellWithReuseIdentifier: "ThumbnailPageCell")
        collectionView.register(HistoryFooterReusableView.self, forSupplementaryViewOfKind: "HistoryFooterReusableView", withReuseIdentifier: "HistoryFooterReusableView")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchfavoritePages()
    }
    
    private func fetchfavoritePages(){
        self.pages.removeAll()
        if var cloudHistory = NSUbiquitousKeyValueStore.default.array(forKey: "history"){
            var idx = 0
            cloudHistory.reverse()
            for historyItem in cloudHistory as! [Int] {
                idx = idx+1
                let index:Int = idx
                WikipediaService.shared.getPage(historyItem) { [weak self] result in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .success(let value):
                        self?.pages[index] = value
                        
                    }
                }
            }
        }
    }
    
    public func deleteAllHistory(){
        NSUbiquitousKeyValueStore.default.set([], forKey: "history")
        self.pages.removeAll()
    }
}

extension HistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailPageCell", for: indexPath) as! ThumbnailPageCell
        let keys = self.pages.keys.sorted()
        let page = self.pages[keys[indexPath.item]]!
        cell.configure(page: page)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let keys = self.pages.keys.sorted()
        let page = self.pages[keys[indexPath.item]]!
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WikiPageViewController") as! WikiPageViewController
        vc.pageid = page.pageid
        vc.page = page
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.pages.count > 0 ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HistoryFooterReusableView", for: indexPath) as! HistoryFooterReusableView
        footerView.configure(parent: self)
        return footerView
    }
}

extension HistoryViewController : WikiPageViewControllerDelegate {
    func shouldRedirectToPage(pageId: Int) {
        self.dismiss(animated: false) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WikiPageViewController") as! WikiPageViewController
            vc.pageid = pageId
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
}
