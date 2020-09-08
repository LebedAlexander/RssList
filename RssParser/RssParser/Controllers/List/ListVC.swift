import UIKit
import SDWebImage
import Reachability

final class ListController: UIViewController {
    
    //MARK: - Enums
    private enum Cell {
        case list
        
        var identifier: String {
            switch self {
            case .list:
                return "ListCell"
            }
        }
    }
    
    private enum Storyboard {
        case news, addRss, resources
        
        var identifier: String {
            switch self {
            case .news:
                return "News"
            case .addRss:
                return "AddRss"
            case .resources:
                return "Resources"
            }
        }
    }
    
    //MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var moreInfoSwitch: UISwitch!
    
    //MARK: - Properties
    private var rssAttribution: [RssAttribution] = []
    private var dateFormatter: DateFormatter {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupCell()
        setupDataFromCoreData()
        setupRequest()
    }
    
    //MARK: - Setups
    private func setupRequest() {
        
        checkInternetConnection { [weak self] in
            NetworkManager.shared.startRequest { [weak self] in
                guard let self = self else { return }
                
                self.setupDataFromCoreData()
            }
        }
    }
    
    private func setupDataFromCoreData() {
        
        getAttribution { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Setup navigation
    private func setupNavigation() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add rss", style: .plain, target: self, action: #selector(addRssUrl(handler:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Resources", style: .plain, target: self, action: #selector(openResource(handler:)))
    }
    
    //MARK: - Setup cell
    private func setupCell() {
        
        tableView.register(UINib(nibName: Cell.list.identifier, bundle: nil), forCellReuseIdentifier: Cell.list.identifier)
    }
    
    //MARK: - Selectors
    @objc private func addRssUrl(handler: UIBarButtonItem) {
        
        openAddRss()
    }
    
    @objc private func openResource(handler: UIBarButtonItem) {

        openResources()
    }
    
    //MARK: - IBAction
    @IBAction func moreInfoValueChange(_ sender: UISwitch) {
        
        tableView.reloadData()
    }
    
    //MARK: - Manipulation with attribution
    private func getAttribution(completion: () -> ()) {

        //Get
        self.rssAttribution = CoreDataManager.shared.getRssAttribution
        
        //Filter
        self.rssAttribution = self.rssAttribution.filter({
            $0.resources!.isActive ? true : false
        })
        
        //Sorted
        self.rssAttribution.sort(by: {
            self.dateFormatter.date(from: $0.pubDate!)! > self.dateFormatter.date(from: $1.pubDate!)!
        })
        
        completion()
    }
    
    //MARK: - Open controllers
    private func openNews(rssAttribution: RssAttribution) {
        
        if let vc = UIStoryboard(name: Storyboard.news.identifier, bundle: nil).instantiateInitialViewController() as? NewsController {
            
            vc.rssAtribution = rssAttribution
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func openAddRss() {
        
        if let vc = UIStoryboard(name: Storyboard.addRss.identifier, bundle: nil).instantiateInitialViewController() as? AddRssController {
            
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func openResources() {
        
        if let vc = UIStoryboard(name: Storyboard.resources.identifier, bundle: nil).instantiateInitialViewController() as? ResourcesController {
            
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: - Check internet connection
    private func checkInternetConnection(completion: @escaping () -> ()) {
        
        let reachability = try! Reachability()
        
        reachability.whenReachable = { reachability in
            switch reachability.connection {
            case .wifi, .cellular:
                completion()
            default:
                break
            }
        }
    }
}

//MARK: - UITableViewDataSource
extension ListController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rssAttribution.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let listCell = tableView.dequeueReusableCell(withIdentifier: Cell.list.identifier) as? ListCell {
            
            listCell.configuration(attribution: rssAttribution[indexPath.row], isMoreInfo: moreInfoSwitch.isOn)
            return listCell
        } else {
            
            return UITableViewCell()
        }
    }
}

//MARK: - UITableViewDelegate
extension ListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let listCell = tableView.cellForRow(at: indexPath) as? ListCell {
            
            listCell.newsIsOpen()
            CoreDataManager.shared.rssNewsIsOpen(rssAttribution: rssAttribution[indexPath.row])
            openNews(rssAttribution: rssAttribution[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160.0
    }
}

//MARK: - ListDelegate
extension ListController: ListDelegate {
    
    func reloadRssTape() {
        
        setupDataFromCoreData()
        setupRequest()
    }
}
