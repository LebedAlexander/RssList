import Foundation
import SwiftyXMLParser

public struct RssModel {
    
    public var imageURL: String?
    public var link: String?
    public var title: String?
    public var description: String?
    public var date: String?
    
    public init(accessor: XML.Accessor) {
        
        self.imageURL = accessor["enclosure"].attributes["url"]
        self.link = accessor["link"].text
        self.title = accessor["title"].text
        self.description = accessor["description"].text
        self.date = accessor["pubDate"].text
    }
}
