//
//  PageContent.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 26/10/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import Foundation

enum LoadingError: Error{
    case timeout
}

class WikiPageContent : WikipediaPageParserDelegate {
    var pageid: Int
    var title = String()
    var extract = String()
    var thumbnailURL: URL?
    var links = [WikiLink]()
    var pageImages = [ImageMetadata]()
    var infobox = [(label: String, value: String)]()
    var sections = [WikiParseContentSection]()
    
    init(pageid: Int){
        self.pageid = pageid
    }
    
    init(page: WikiPage){
        pageid = page.pageid
        title = page.title
        extract = page.extract.addCarriageReturnAfterPoint()
        if let thumbnail = page.thumbnail {
            thumbnailURL = thumbnail.source
        }
        if let linkshere = page.linkshere {
            for linkhere in linkshere {
                links.append(linkhere)
            }
        }
    }
    
    public func populate(completion: @escaping() -> Void ) {
        DispatchQueue.global().async {
            let group = DispatchGroup()
            
            if(self.extract.isEmpty){
                group.enter()
                DispatchQueue.global().async {
                    self.loadPage(self.pageid, completion: {
                        group.leave()
                    })
                }
            }
            
            group.enter()
            DispatchQueue.global().async {
                self.loadImages(self.pageid, completion: {
                    group.leave()
                })
            }
            
            group.enter()
            DispatchQueue.global().async {
                self.loadInfobox(self.pageid, completion: {
                    group.leave()
                })
            }
            group.wait()
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    public func getCredits() -> String{
        return String.localizedStringWithFormat(NSLocalizedString("page.credit", comment: ""), self.title, self.title)
    }
    
    private func loadImages(_ pageid: Int, completion: @escaping() -> Void ) {
        WikipediaService.shared.getPageImages(pageid) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let value):
                self.pageImages = value
                print("images downloaded")
            }
            completion()
        }
    }
    
    private func loadPage(_ pageid: Int, completion: @escaping() -> Void ) {
        WikipediaService.shared.getPage(pageid) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let page):
                self.title = page.title
                self.extract = page.extract.addCarriageReturnAfterPoint()
                if let thumbnail = page.thumbnail {
                    self.thumbnailURL = thumbnail.source
                }
                if let linkshere = page.linkshere {
                    for linkhere in linkshere {
                        if mustFilter(linkhere.title) { break }
                        self.links.append(linkhere)
                    }
                }
                print("page downloaded")
            }
            completion()
        }
    }
    
    private func loadInfobox(_ pageid: Int, completion: @escaping() -> Void ) {
        WikipediaService.shared.getPageText(pageid, sectionId: nil) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let parseContent):
                self.sections = parseContent.sections
                
                guard let text = parseContent.text["*"] else {
                    completion()
                    return
                }
                let parser = WikipediaPageParser(text)
                parser.delegate = self
                parser.parse()
            }
            completion()
        }
    }
    
    internal func parsingFinished(infobox: [(label: String, value: String)]) {
        self.infobox = infobox;
        print("infobox downloaded")
    }
}
