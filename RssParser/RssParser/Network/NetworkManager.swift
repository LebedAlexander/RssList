import Foundation
import SwiftyXMLParser
import SDWebImage

final class NetworkManager: NSObject {
    
    //MARK: - Singleton
    static let shared = NetworkManager()
    
    //MARK: - Properties
    private let dispatchGroup = DispatchGroup()
    private let cacheImage = SDImageCache()
    public let requestQueue = DispatchQueue(label: "com.rssparser.queue", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .never, target: nil)
    
    //MARK: - Start reqeuests
    public func startRequest(completion: @escaping () -> ()) {
        
        CoreDataManager.shared.getRssResources.forEach({ requestToRss(url: $0.link, completion: nil) })
        dispatchGroup.notify(queue: .global(qos: .userInitiated)) { completion() }
    }
    
    //MARK: - Requests
    public func requestToRss(url: String?, completion: ((Bool) -> ())?) {
        
        if let urlString = url, let url = URL(string: urlString) {
            
            self.dispatchGroup.enter()
            
            let request = URLRequest(url: url)
            requestQueue.async {
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    
                    if let error = error {
                        
                        self.dispatchGroup.leave()
                        completion?(false)
                        
                        print(error.localizedDescription)
                    } else if let data = data {
                        
                        let xmlParser = XML.parse(data)
                        if let error = xmlParser.error {
                            
                            completion?(false)
                            print(error.localizedDescription)
                        } else {
                            
                            completion?(true)
                            self.mapping(xmlAccessor: xmlParser["rss", "channel", "item"], currentResources: urlString)
                        }
                    }
                }
                
                task.resume()
            }
        } else {
            
            completion?(false)
        }
    }
    
    //MARK: - Mapping
    private func mapping(xmlAccessor: XML.Accessor, currentResources: String) {
        
        let currentResources = CoreDataManager.shared.getCurrentRssResources(link: currentResources)
        
        xmlAccessor.forEach({ accessor in

            let rssModel = RssModel(accessor: accessor)
            if checkingTheFilterForDuplicates(model: rssModel) { return }
            
            cacheImageToMemory(imageURL: rssModel.imageURL)
            CoreDataManager.shared.addRssAttribution(model: rssModel, resource: currentResources)
        })
        
        self.dispatchGroup.leave()
    }
    
    //MARK: - Checking the filter for duplicates
    private func checkingTheFilterForDuplicates(model: RssModel) -> Bool {
        
        let filter = CoreDataManager.shared.getRssAttribution.filter({ $0.link == model.link })
        return filter.isEmpty ? false : true
    }
    
    //MARK: - Cache image to memory
    private func cacheImageToMemory(imageURL: String?) {
        
        if let imageURL = imageURL {
            
            SDWebImageManager.shared.loadImage(with: URL(string: imageURL)!, options: [], progress: nil) { (image, data, error, cacheType, finished, url) in
                
                print(finished)
            }
        }
    }
}
