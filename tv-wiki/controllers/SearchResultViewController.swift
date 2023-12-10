//
//  SearchViewController.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 23/10/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import UIKit

class SearchResultViewController : UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    private var presentedVc: UIViewController!
    
    var searchResultsPages = [WikiSearchResult]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    var filterString = "" {
        didSet {
            guard filterString != oldValue else { return }
            
            // Apply the filter or show all items if the filter string is empty.
            if filterString.count < 3 {
                searchResultsPages = []
            }
            else {
                WikipediaService.shared.search(filterString) { [weak self] result in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .success(var searchResults):
                        searchResults.sort(by: {$0.index < $1.index})
                        self?.searchResultsPages = searchResults
                    }
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ThumbnailPageCell", bundle: nil), forCellWithReuseIdentifier: "ThumbnailPageCell")
    }
}


extension SearchResultViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterString = searchController.searchBar.text ?? ""
    }
}


extension SearchResultViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResultsPages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailPageCell", for: indexPath) as! ThumbnailPageCell
        cell.configure(searchResult: searchResultsPages[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let searchResult = searchResultsPages[indexPath.item]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WikiPageViewController") as! WikiPageViewController
        vc.pageid = searchResult.pageid
        vc.delegate = self
        present(vc, animated: true, completion: nil)
        self.presentedVc = vc
    }
}

extension SearchResultViewController : WikiPageViewControllerDelegate {
    func shouldRedirectToPage(pageId: Int) {
        self.presentedVc?.dismiss(animated: false) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WikiPageViewController") as! WikiPageViewController
            vc.pageid = pageId
            vc.delegate = self
            self.presentedVc = vc
            self.present(vc, animated: true, completion: nil)
        }
    }
}
