//
//  SecondViewController.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 23/10/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
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
        self.tabBarItem = UITabBarItem(title: NSLocalizedString("tabbar.favorites", comment: ""), image: nil, tag: 1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ThumbnailPageCell", bundle: nil), forCellWithReuseIdentifier: "ThumbnailPageCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchfavoritePages()
    }
    
    private func fetchfavoritePages(){
        self.pages.removeAll()
        if var cloudFavorites = NSUbiquitousKeyValueStore.default.array(forKey: "favorites"){
            var idx = 0
            cloudFavorites.reverse()
            for favorite in cloudFavorites as! [Int] {
                idx = idx+1
                let index:Int = idx
                WikipediaService.shared.getPage(favorite) { [weak self] result in
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
}

extension FavoritesViewController: UICollectionViewDelegate, UICollectionViewDataSource {

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
}

extension FavoritesViewController : WikiPageViewControllerDelegate {
    func shouldRedirectToPage(pageId: Int) {
        self.dismiss(animated: false) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WikiPageViewController") as! WikiPageViewController
            vc.pageid = pageId
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
}
