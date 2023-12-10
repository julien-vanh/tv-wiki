//
//  WikiPageViewController.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 28/10/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import Foundation
import UIKit
import TVUIKit
import AVKit

let MAX_ITEM_IN_HISTORY = 30

protocol WikiPageViewControllerDelegate {
    func shouldRedirectToPage(pageId: Int)
}

class WikiPageViewController: UIViewController {
    var delegate:WikiPageViewControllerDelegate?
    var pageid = 0
    var page: WikiPage?
    var pageContent = WikiPageContent(pageid: 1)
    var mustScrollToTop = true
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var thumbnailWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var extractTextView: UITextView!
    @IBOutlet weak var extractHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var playCaptionButton: TVCaptionButtonView!
    @IBOutlet weak var sectionsCaptionButton: TVCaptionButtonView!
    @IBOutlet weak var favoriteCaptionButton: TVCaptionButtonView!
    
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var imagesHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var infoboxCollectionView: UICollectionView!
    @IBOutlet weak var infoboxHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var linksCollectionView: UICollectionView!
    @IBOutlet weak var linksHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var creditLabel: UILabel!
    let buttonImageConfig = UIImage.SymbolConfiguration(textStyle: .headline)
    
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var speechUtterance = AVSpeechUtterance()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        self.speechSynthesizer.delegate = self
        
        if let alreadyLoadedPage = self.page {
            self.pageContent = WikiPageContent(page: alreadyLoadedPage)
        } else {
            self.pageContent = WikiPageContent(pageid: pageid)
        }
        
        LoadingOverlay.shared.showOverlay(view: self.view)
        self.pageContent.populate(completion: {
            self.displayPageContent()
            LoadingOverlay.shared.hideOverlayView()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.saveInHistory()
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if(press.type == UIPress.PressType.playPause) {
                self.playClicked(self)
            } else {
                super.pressesEnded(presses, with: event)
            }
        }
    }
    
    private func saveInHistory(){
        var history = [Int]()
        
        if let cloudHistory = NSUbiquitousKeyValueStore.default.array(forKey: "history") {
            history = cloudHistory as! [Int]
        }
        
        if let index = history.firstIndex(of: pageid) {
            history.remove(at: index)
        }
        history.append(pageid)
        if history.count > MAX_ITEM_IN_HISTORY {
            history.remove(at: 0)
        }
        NSUbiquitousKeyValueStore.default.set(history, forKey: "history")
    }
    
    private func initViews(){
        scrollView.delegate = self
        titleLabel.text = ""
        
        extractTextView.text = ""
        extractTextView.isSelectable = true
        extractTextView.panGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]
        
        //Play button
        playCaptionButton.contentImage = UIImage(systemName: "play", withConfiguration: buttonImageConfig)
        playCaptionButton.title = NSLocalizedString("button.play", comment: "")
        playCaptionButton.subtitle = ""
        let pushPlay1 = UITapGestureRecognizer(target: self, action: #selector(playClicked))
        pushPlay1.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        self.playCaptionButton.addGestureRecognizer(pushPlay1)
        
        //Full text button
        sectionsCaptionButton.contentImage = UIImage(systemName: "list.dash", withConfiguration: buttonImageConfig)
        sectionsCaptionButton.title = NSLocalizedString("button.sections", comment: "")
        sectionsCaptionButton.subtitle = ""
        let pushPlay2 = UITapGestureRecognizer(target: self, action: #selector(playClicked))
        pushPlay2.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        self.sectionsCaptionButton.addGestureRecognizer(pushPlay2)
        
        //Bookmark button
        var favorites = [Int]()
        if let cloudFavorites = NSUbiquitousKeyValueStore.default.array(forKey: "favorites") {
            favorites = cloudFavorites as! [Int]
        }
        if favorites.firstIndex(of: pageid) != nil {
            favoriteCaptionButton.contentImage = UIImage(systemName: "bookmark.fill", withConfiguration: buttonImageConfig)
            favoriteCaptionButton.title = NSLocalizedString("button.favorites.added", comment: "")
        } else {
            favoriteCaptionButton.contentImage = UIImage(systemName: "bookmark", withConfiguration: buttonImageConfig)
            favoriteCaptionButton.title = NSLocalizedString("button.favorites.add", comment: "")
        }
        favoriteCaptionButton.subtitle = ""
        let pushPlay3 = UITapGestureRecognizer(target: self, action: #selector(playClicked))
        pushPlay3.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        self.favoriteCaptionButton.addGestureRecognizer(pushPlay3)
        
        
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        imagesCollectionView.register(UINib(nibName: "ImageViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageViewCell")
        
        infoboxCollectionView.delegate = self
        infoboxCollectionView.dataSource = self
        infoboxCollectionView.isUserInteractionEnabled = false
        infoboxCollectionView.register(UINib(nibName: "InfoboxCell", bundle: nil), forCellWithReuseIdentifier: "InfoboxCell")
        
        linksCollectionView.delegate = self
        linksCollectionView.dataSource = self
        linksCollectionView.register(UINib(nibName: "LinkViewCell", bundle: nil), forCellWithReuseIdentifier: "LinkViewCell")
        
        creditLabel.text = ""
    }
    
    
    private func displayPageContent(){
        titleLabel.text = pageContent.title
        extractTextView.text = pageContent.extract
        self.speechUtterance = AVSpeechUtterance(string: pageContent.extract)
        //self.speechUtterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Amelie-compact")
        //self.speechUtterance.rate = 0.53
        self.speechUtterance.pitchMultiplier = 1.2
        
        if let thumbnail = pageContent.thumbnailURL {
            thumbnailImageView.kf.indicatorType = .activity
            thumbnailImageView.kf.setImage(with: thumbnail)
        } else {
            //PAs d'image, le texte prend toute la largeur, réduction de la hauteur pour reter au dessus des boutons
            thumbnailWidthConstraint.constant = 0.0
            extractHeightConstraint.constant = 600.0
        }
        
        if pageContent.pageImages.count == 0 {
            imagesHeightConstraint.constant = 0.0
        }
        if pageContent.infobox.count == 0 {
            infoboxHeightConstraint.constant = 0.0
        } else {
            let nbInfoboxItem = pageContent.infobox.count
            let nbInfoboxLine = CGFloat(Double(nbInfoboxItem)/2.0)
            infoboxHeightConstraint.constant = 50.0 + 50.0 + 60.0 * nbInfoboxLine.rounded(.up)
        }
 
        if pageContent.links.count == 0 {
            linksHeightConstraint.constant = 0.0
        }
 
        creditLabel.text = self.pageContent.getCredits()
        self.view.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
        self.imagesCollectionView.reloadData()
        self.infoboxCollectionView.reloadData()
        self.linksCollectionView.reloadData()
    }
    
    @IBAction func favoritesClickedAction(_ sender: Any) {
        var favorites = [Int]()
        
        if let cloudFavorites = NSUbiquitousKeyValueStore.default.array(forKey: "favorites") {
            favorites = cloudFavorites as! [Int]
        }
        
        if let index = favorites.firstIndex(of: pageid) {
            favorites.remove(at: index)
            favoriteCaptionButton.contentImage = UIImage(systemName: "bookmark", withConfiguration: buttonImageConfig)
            favoriteCaptionButton.title = NSLocalizedString("button.favorites.add", comment: "")
        } else {
            favorites.append(pageid)
            if favorites.count > MAX_ITEM_IN_HISTORY {
                favorites.remove(at: 0)
            }
            favoriteCaptionButton.contentImage = UIImage(systemName: "bookmark.fill", withConfiguration: buttonImageConfig)
            favoriteCaptionButton.title = NSLocalizedString("button.favorites.added", comment: "")
        }
        NSUbiquitousKeyValueStore.default.set(favorites, forKey: "favorites")
    }
    
    @IBAction func playClicked(_ sender: Any) {
        
        if speechSynthesizer.isSpeaking {
            if speechSynthesizer.isPaused {
                self.speechSynthesizer.continueSpeaking()
            } else {
                self.speechSynthesizer.pauseSpeaking(at: .immediate)
            }
        } else {
            self.speechSynthesizer.speak(self.speechUtterance)
        }
    }
    
    private func displayPlayButton(paused: Bool){
        if paused {
            playCaptionButton.contentImage = UIImage(systemName: "pause", withConfiguration: buttonImageConfig)
            playCaptionButton.title = NSLocalizedString("button.pause", comment: "")
        } else {
            playCaptionButton.contentImage = UIImage(systemName: "play", withConfiguration: buttonImageConfig)
            playCaptionButton.title = NSLocalizedString("button.play", comment: "")
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DisplaySections" {
            if let destinationVC = segue.destination as? SectionsViewController {
                destinationVC.pageContent = pageContent
            }
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self.extractTextView {
            extractTextView.backgroundColor = .white
            extractTextView.textColor = .black
        } else {
            extractTextView.backgroundColor = .clear
            extractTextView.textColor = .label
        }
        
        self.mustScrollToTop = context.nextFocusedView == self.playCaptionButton
            || context.nextFocusedView == self.sectionsCaptionButton
            || context.nextFocusedView == self.favoriteCaptionButton
            || context.nextFocusedView == self.extractTextView
    }
    
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        if context.previouslyFocusedView == self.extractTextView {
            if extractTextView.contentOffset.y >= (extractTextView.contentSize.height - extractTextView.frame.size.height) {
                //extractView scoll reached the bottom
                return true
            }
            if context.nextFocusedView == self.favoriteCaptionButton {
                //one can always go to favorites button
                return true
            }
            return false
        }
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.speechSynthesizer.stopSpeaking(at: .immediate)
    }
}

extension WikiPageViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.linksCollectionView {
            return pageContent.links.count
        } else if collectionView == self.infoboxCollectionView {
            return pageContent.infobox.count
        } else {
            return pageContent.pageImages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.linksCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LinkViewCell", for: indexPath) as! LinkViewCell
            cell.configure(linkTitle: pageContent.links[indexPath.item].title)
            return cell
        } else if collectionView == self.infoboxCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoboxCell", for: indexPath) as! InfoboxCell
            cell.configure(infoboxLine: pageContent.infobox[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as! ImageViewCell
            cell.configure(image: pageContent.pageImages[indexPath.item])
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.linksCollectionView {
            let pageid = self.pageContent.links[indexPath.item].pageid
            if delegate != nil {
                delegate?.shouldRedirectToPage(pageId: pageid)
            }
        } else if collectionView == self.imagesCollectionView {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ImagesPageViewController") as! ImagesPageViewController
            vc.images = self.pageContent.pageImages
            vc.currentIndex = indexPath.item
            present(vc, animated: true, completion: nil)
        }
    }
}

extension WikiPageViewController : AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        print("Playing range \(characterRange.location)/\(self.pageContent.extract.count)")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        displayPlayButton(paused: false)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        displayPlayButton(paused: true)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        displayPlayButton(paused: true)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        displayPlayButton(paused: false)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        displayPlayButton(paused: false)
    }
    
    
}

extension WikiPageViewController : UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //Force the scrollview to the top when buttons are selected
        if mustScrollToTop {
            targetContentOffset.pointee = CGPoint.zero
        }
        
    }
}
