//
//  ImageMetadata.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 04/11/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//
import Foundation

class ImageMetadata {
    var title: String
    var url: URL?
    var artist: String?
    var description: String?
    
    init(_ wikiImage: WikiImage){
        title = wikiImage.title
        if let imageURL = URL(string: wikiImage.imageinfo[0].url) {
            url = imageURL
        }
        if let extmetadata = wikiImage.imageinfo[0].extmetadata {
            if let artist = extmetadata.Artist {
                self.artist = artist.value.deleteHTMLTags()
            }
            if let description = extmetadata.ImageDescription {
                self.description = description.value.deleteHTMLTags()
            }
        }
        
    }
}
