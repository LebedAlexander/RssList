import UIKit

final class ResourcesCell: UITableViewCell {
    
    //MARK: - IBOutlet
    @IBOutlet weak var rssUrlLabel: UILabel!
    
    //MARK: - Properties
    private var resource: RssResources?
    
    //MARK: - Configuration
    public func configuration(resource: RssResources) {
        
        self.resource = resource
        self.rssUrlLabel.text = resource.link
        self.accessoryType = resource.isActive ? .checkmark : .none
    }
    
    public func resourceIsActive() {
        
        if let resource = resource {
            
            accessoryType = accessoryType == .none ? .checkmark : .none
            CoreDataManager.shared.rssResourceIsActive(rssResource: resource)
        }
    }
}
