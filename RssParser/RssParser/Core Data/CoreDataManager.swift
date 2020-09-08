import Foundation
import CoreData

final class CoreDataManager: NSObject {
    
    //MARK: - Singleton
    static let shared = CoreDataManager()
    
    //MARK: - Get
    public var getRssResources: [RssResources] {
        get {
            guard let rssResources = try? context.fetch(RssResources.fetchRequest()) as? [RssResources] else {
                return []
            }
            
            return rssResources
        }
    }
    
    public var getRssAttribution: [RssAttribution] {
        get {
            guard let rssAttribution = try? context.fetch(RssAttribution.fetchRequest()) as? [RssAttribution] else {
                return []
            }
            
            return rssAttribution
        }
    }
    
    public func getCurrentRssResources(link: String) -> RssResources {
        
        let filter = getRssResources.filter({ $0.link == link })
        return filter.first!
    }
    
    //MARK: - Add
    public func addRssResources(link: String) {
        
        let rssResources = RssResources(context: context)
        
        rssResources.link = link
        rssResources.isActive = true
        
        saveContext()
    }
    
    public func addRssAttribution(model: RssModel, resource: RssResources) {
        
        let rssAttribution = RssAttribution(context: context)
        
        rssAttribution.imageURL = model.imageURL
        rssAttribution.link = model.link
        rssAttribution.title = model.title
        rssAttribution.declaration = model.description
        rssAttribution.pubDate = model.date
        rssAttribution.resources = resource
        rssAttribution.isOpen = false
        rssAttribution.html = nil
        
        saveContext()
    }
    
    public func rssNewsIsOpen(rssAttribution: RssAttribution) {
        
        rssAttribution.isOpen = true
        
        saveContext()
    }
    
    public func rssAddHTML(rssAttribution: RssAttribution, html: String) {
        
        rssAttribution.html = html
        
        saveContext()
    }
    
    public func rssResourceIsActive(rssResource: RssResources) {
        
        rssResource.isActive = !rssResource.isActive
        
        saveContext()
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var context = persistentContainer.viewContext
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

