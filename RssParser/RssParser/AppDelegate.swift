import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        firstLaunch()
        return true
    }
    
    //MARK: - First launch
    private func firstLaunch() {
        
        if !UserDefaults.standard.bool(forKey: "firstLaunch") {
            
            CoreDataManager.shared.addRssResources(link: "http://lenta.ru/rss")
            UserDefaults.standard.set(true, forKey: "firstLaunch")
        }
    }
}

