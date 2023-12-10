//
//  String+HTML.swift
//  PrettyWiki
//
//  Created by Julien Vanheule on 04/11/2019.
//  Copyright © 2019 Julien Vanheule. All rights reserved.
//

extension String {
    func deleteHTMLTags() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    func addCarriageReturnAfterPoint() -> String {
        return self
        //let cleanedText = self.replacingOccurrences(of: "\\n", with: "")
        //return cleanedText.replacingOccurrences(of: ".", with: ".\\n\\r")
    }
}
