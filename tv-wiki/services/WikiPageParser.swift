//
//  WikipediaPageParser.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 28/10/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

import Foundation

protocol WikipediaPageParserDelegate: AnyObject {
    func parsingFinished(infobox: [(label: String, value: String)])
}

class WikipediaPageParser : NSObject, XMLParserDelegate {
    var parser:XMLParser
    var infobox = [(label: String, value: String)]()
    var inInfobox = false
    var inInfoboxLabel = false
    var inInfoboxValue = false
    var label = ""
    var value = ""
    weak var delegate: WikipediaPageParserDelegate?
    
    init(_ text: String){
        let cleanedText = text.replacingOccurrences(of: "\\n", with: "").replacingOccurrences(of: "\\n", with: "\"")
        let xml = cleanedText.data(using: .utf8)! // our data in native format
        
        self.parser = XMLParser(data: xml)
        super.init()
        self.parser.delegate = self
    }
    
    func parse(){
        parser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        if elementName == "table" && attributeDict["class"] == "infobox_v2" {
            inInfobox = true
        }
        if elementName == "tr" && inInfobox {
            label = String()
            value = String()
        }
        if elementName == "th" && inInfobox {
            inInfoboxLabel = true
        }
        if elementName == "td" && inInfobox {
            inInfoboxValue = true
        }
    }

    // 2 balise de fin
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "table" {
            inInfobox = false
        }
        else if elementName == "tr" && inInfobox {
            if(!label.isEmpty && !value.isEmpty){
                infobox.append((label: label, value: value))
            }
        }
        else if elementName == "th" {
            inInfoboxLabel = false
        }
        else if elementName == "td" {
            inInfoboxValue = false
        }
    }

    // 3 dans l'element
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!data.isEmpty) {
            //print ("foundCharacters", data)
            if inInfoboxLabel {
                label += data
            }
            else if inInfoboxValue {
                value += data
            }
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        self.delegate?.parsingFinished(infobox: infobox)
    }
}
