import UIKit

final class ListCell: UITableViewCell {
    
    //MARK: - IBOutlet
    @IBOutlet weak var rssImageView: UIImageView!
    @IBOutlet weak var rssTitleLabel: UILabel!
    @IBOutlet weak var rssDescriptionLabel: UILabel!
    @IBOutlet weak var rssOpenView: UIView!
    
    //MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        rssOpenView.layer.cornerRadius = rssOpenView.bounds.size.width / 2
    }
    
    //MARK: - Configuration
    public func configuration(attribution: RssAttribution, isMoreInfo: Bool) {
        
        loadImage(fromURL: attribution.imageURL)
        rssTitleLabel.text = attribution.title
        rssDescriptionLabel.text = attribution.declaration
        rssDescriptionLabel.isHidden = isMoreInfo ? false : true
        rssOpenView.isHidden = attribution.isOpen ? false : true
    }
    
    //MARK: - Open news
    public func newsIsOpen() {
        
        rssOpenView.isHidden = false
    }
    
    //MARK: - Load image
    private func loadImage(fromURL: String?) {
        
        if let imageURL = fromURL {
            
            rssImageView.sd_setImage(with: URL(string: imageURL), completed: nil)
        } else {
            
            rssImageView.image = nil
        }
    }
}
