import UIKit

final class AddRssController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var addUrlTextField: UITextField!
    
    //MARK: - Properties
    public weak var delegate: ListDelegate?
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - IBAction
    @IBAction func addRssAction(_ sender: UIButton) {
    
        checkTextField { (text) in
            NetworkManager.shared.requestToRss(url: text) { (queue, result) in
                if result {
                    queue.sync {
                        CoreDataManager.shared.addRssResources(link: text)
                    }
                    
                    DispatchQueue.main.async {
                        self.delegate?.reloadRssTape()
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                 
                    self.openAlert(title: "Oops", message: "Bad URL")
                }
            }
        }
    }
    
    //MARK: - Make sure the text field is empty
    private func checkTextField(completion: (String) -> ()) {
        
        if let text = addUrlTextField.text, !text.isEmpty {
            
            completion(text)
        } else {
            
            self.openAlert(title: "Oops", message: "Please fill in all fields")
        }
    }
    
    //MARK: - Open alert
    private func openAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
