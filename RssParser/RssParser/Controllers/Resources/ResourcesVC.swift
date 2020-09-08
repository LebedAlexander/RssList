import UIKit

final class ResourcesController: UIViewController {
    
    //MARK: - Enum
    private enum Cell {
        case resources
        
        var identifier: String {
            switch self {
            case .resources:
                return "ResourcesCell"
            }
        }
    }
    
    //MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    private var resources: [RssResources] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    public weak var delegate: ListDelegate?
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCell()
        setupData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.reloadRssTape()
    }
    
    //MARK: - Setups
    private func setupData() {
        
        self.resources = CoreDataManager.shared.getRssResources
    }
    
    private func setupCell() {
        
        tableView.register(UINib(nibName: Cell.resources.identifier, bundle: nil), forCellReuseIdentifier: Cell.resources.identifier)
    }
}

//MARK: - UITableViewDataSource
extension ResourcesController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let resourcesCell = tableView.dequeueReusableCell(withIdentifier: Cell.resources.identifier) as? ResourcesCell {
            
            resourcesCell.configuration(resource: resources[indexPath.row])
            return resourcesCell
        } else {
            
            return UITableViewCell()
        }
    }
}

//MARK: - UITableViewDelegate
extension ResourcesController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let resourceCell = tableView.cellForRow(at: indexPath) as? ResourcesCell {
            
            resourceCell.resourceIsActive()
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
}
