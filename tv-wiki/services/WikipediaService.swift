//
//  WikipediaService.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 23/10/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import Foundation

enum WikipediaError: Error{
    case cannotBuildUrl
    case noDataAvailable
    case canNotProcessData
}

struct WikipediaService {
    static let shared = WikipediaService()
    
    let host: String
    let wikipedia_Accueil: String
    
    private init(){
        self.host = NSLocalizedString("wikipedia.host", comment: "")
        self.wikipedia_Accueil = NSLocalizedString("wikipedia.main-page", comment: "")
    }
    
    func getMainPageArticle(completion: @escaping(Result<[WikiLinkResult], WikipediaError>) -> Void ) {
        let urlString  = "\(self.host)?action=query&generator=links&titles=\(self.wikipedia_Accueil)&prop=pageimages&gplnamespace=0&gpllimit=150&format=json&pithumbsize=400"
        
        guard let URL = URL(string: urlString) else {
            completion(.failure(.cannotBuildUrl))
            return
        }
        
        let datatask = URLSession.shared.dataTask(with: URL) {data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            do {
                let response = try JSONDecoder().decode(WikiResponse.self, from: jsonData)
                
                var linksResult:[WikiLinkResult] = []
                for value in response.query.pages.values {
                    if case .linkResult(let linkResult) = value {
                        if mustFilter(linkResult.title){ break }
                        linksResult.append(linkResult)
                    }
                }
                completion(.success(linksResult))
            } catch {
                print("(getMainPageArticle) Unexpected error: \(error).")
                completion(.failure(.canNotProcessData))
            }
        }
        datatask.resume()
    }
    
    func search(_ pattern: String, completion: @escaping(Result<[WikiSearchResult], WikipediaError>) -> Void ) {
        let urlString  = "\(self.host)?action=query&generator=search&gsrsearch=\(pattern.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")&gsrnamespace=0&prop=pageimages&format=json&pithumbsize=400"
        
        guard let URL = URL(string: urlString) else {
            completion(.failure(.cannotBuildUrl))
            return
        }
        
        print("search \(pattern) : \(URL.absoluteString)")
        let datatask = URLSession.shared.dataTask(with: URL) {data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            do {
                let response = try JSONDecoder().decode(WikiResponse.self, from: jsonData)
                
                var searchResults:[WikiSearchResult] = []
                for value in response.query.pages.values {
                    if case .searchResult(let searchResult) = value {
                        if mustFilter(searchResult.title){ break }
                        searchResults.append(searchResult)
                    }
                }
                completion(.success(searchResults))
            } catch {
                print("(search) Unexpected error: \(error).")
                completion(.failure(.canNotProcessData))
            }
        }
        datatask.resume()
    }
    
    func getPage(_ pageid: Int, completion: @escaping(Result<WikiPage, WikipediaError>) -> Void ) {
        let urlString  = "\(self.host)?action=query&pageids=\(pageid)&prop=extracts%7Cpageimages%7Clinkshere&lhnamespace=0&lhlimit=20&lhprop=title%7Cpageid&exintro&explaintext&format=json&pithumbsize=400"
        
        guard let URL = URL(string: urlString) else {
            print(urlString)
            completion(.failure(.cannotBuildUrl))
            return
        }
        
        print("getPage \(pageid) : \(URL.absoluteString)")
        let datatask = URLSession.shared.dataTask(with: URL) {data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            do {
                let response = try JSONDecoder().decode(WikiResponse.self, from: jsonData)
                guard let result = response.query.pages.values.first else {
                    completion(.failure(.noDataAvailable))
                    return
                }
                
                if case .page(let value) = result {
                    completion(.success(value))
                } else {
                    completion(.failure(.canNotProcessData))
                }
            } catch {
                print("(getPage) Unexpected error: \(error).")
                completion(.failure(.canNotProcessData))
            }
        }
        datatask.resume()
    }
    
    
    func getPageImages(_ pageid: Int, limit: Int = 40, completion: @escaping(Result<[ImageMetadata], WikipediaError>) -> Void) {
        let imagesLimit = min(limit, 50) //Pas plus de 50 images retournées par l'aPI si resize
        let MAX_WIDTH = 800
        let urlString  = "\(self.host)?action=query&pageids=\(pageid)&generator=images&gimlimit=\(imagesLimit)&prop=imageinfo&iiprop=url%7Cmime%7Cextmetadata&iiurlwidth=\(MAX_WIDTH)&iiextmetadatafilter=ImageDescription%7CArtist&format=json"
        
        guard let URL = URL(string: urlString) else {
            completion(.failure(.cannotBuildUrl))
            return
        }
        
        print("getPageImages \(pageid) : \(URL.absoluteString)")
        let datatask = URLSession.shared.dataTask(with: URL) {data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            do {
                let response = try JSONDecoder().decode(WikiResponse.self, from: jsonData)
                print("getPageImages response OK")
                var images:[ImageMetadata] = []
                for value in response.query.pages.values {
                    if case .image(let image) = value {
                        if image.imageinfo[0].mime != "image/jpeg" {
                            continue
                        }
                        
                        if let metadata = image.imageinfo[0].extmetadata, let description = metadata.ImageDescription {
                            if description.value.uppercased().contains("CARTE ") || description.value.uppercased().contains("MAP ") {
                                //Pour supprimer les cartes vectorielles
                                continue
                            }
                        }
                            
                        let imageMetadata = ImageMetadata(image)
                        images.append(imageMetadata)
                        
                    }
                }
                completion(.success(images))
            } catch {
                print("(getPageImages) Unexpected error: \(error.localizedDescription).")
                completion(.failure(.canNotProcessData))
            }
        }
        datatask.resume()
    }
    
    func getPageText(_ pageid: Int, sectionId: String!, completion: @escaping(Result<WikiParseContent, WikipediaError>) -> Void ) {
        var urlString = "\(self.host)?action=parse&pageid=\(pageid)&prop=sections%7Ctext%7Cdisplaytitle&disableeditsection&format=json"
        if sectionId != nil {
            urlString = urlString + "&mobileformat&noimages&section=" + sectionId
        }
        guard let URL = URL(string: urlString) else {
            print(urlString)
            completion(.failure(.cannotBuildUrl))
            return
        }
        
        print("getPageText \(pageid) : \(URL.absoluteString)")
        let datatask = URLSession.shared.dataTask(with: URL) {data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            do {
                let response = try JSONDecoder().decode(WikiParseResponse.self, from: jsonData)
                guard let result = response.parse.text["*"] else {
                    completion(.failure(.noDataAvailable))
                    return
                }
                
                if !result.isEmpty {
                    completion(.success(response.parse))
                } else {
                    completion(.failure(.canNotProcessData))
                }
            } catch {
                print("(getPageText) Unexpected error: \(error).")
                completion(.failure(.canNotProcessData))
            }
        }
        datatask.resume()
    }
}

func mustFilter(_ title: String) -> Bool {
    return title.lowercased().contains("covid")
        || title.lowercased().contains("corona")
        || title.lowercased().contains("sex")
        || title.lowercased().contains("porn")
}
