//
//  Article.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 23/10/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import Foundation

//Commun
struct WikiResponse: Decodable {
    var query: WikiQuery
}

struct WikiQuery: Decodable {
    var pages: [String: WikiResult]
}

enum WikiResult : Decodable{
    case page(WikiPage)
    case image(WikiImage)
    case searchResult(WikiSearchResult)
    case linkResult(WikiLinkResult)

    init(from decoder: Decoder) throws {
        if let page = try? decoder.singleValueContainer().decode(WikiPage.self) {
            self = .page(page)
            return
        }
        else if let image = try? decoder.singleValueContainer().decode(WikiImage.self) {
            self = .image(image)
            return
        }
        else if let searchResult = try? decoder.singleValueContainer().decode(WikiSearchResult.self) {
            self = .searchResult(searchResult)
            return
        }
        else if let linkResult = try? decoder.singleValueContainer().decode(WikiLinkResult.self) {
            self = .linkResult(linkResult)
            return
        }
        throw WikiResultError.unknownResult
    }

    enum WikiResultError:Error {
        case unknownResult
    }
}




//Page + thumbnail
struct WikiPage: Decodable {
    var pageid: Int
    var title: String
    var extract: String
    var thumbnail: WikiPageThumbnail?
    var pageimage: String?
    var linkshere: [WikiLink]?
}

struct WikiPageThumbnail: Decodable {
    var source: URL
    var width: Int
    var height: Int
}

struct WikiLink: Decodable {
    var pageid: Int
    var title: String
}

//Images urls d'une Page
struct WikiImage: Decodable {
    var title: String
    var imageinfo: [WikiImageInfo]
}

struct WikiImageInfo: Decodable{
    var url: String
    var mime: String
    var extmetadata:WikiImageExtmetadata?
    
    
    enum CodingKeys: String, CodingKey {
        case url
        case extmetadata
        case mime
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        url = try values.decode(String.self, forKey: .url)
        mime = try values.decode(String.self, forKey: .mime)
        
        do {
            extmetadata = try values.decode(WikiImageExtmetadata.self, forKey: .extmetadata)
        } catch {
            print("Cannot decode WikiImageExtmetadata")
        }
    }
}

struct WikiImageExtmetadata: Decodable{
    var ImageDescription:WikiMetadata?
    var Artist:WikiMetadata?
}

struct WikiMetadata: Decodable{
    var value: String
}

//Resultat de recherche
struct WikiSearchResult: Decodable {
    var index: Int
    var pageid: Int
    var title: String
    var thumbnail: WikiPageThumbnail?
    var pageimage: String?
}

//Parse
struct WikiParseResponse: Decodable {
    var parse: WikiParseContent
}

struct WikiParseContent: Decodable {
    var title: String
    var pageid: Int
    var text:[String: String]
    var displaytitle: String
    var sections: [WikiParseContentSection]
}

struct WikiParseContentSection : Decodable {
    var toclevel: Int
    var line: String
    var index: String
}

//Resultat de links pour la page principal
struct WikiLinkResult: Decodable {
    var pageid: Int
    var title: String
    var thumbnail: WikiPageThumbnail?
    var pageimage: String?
}
