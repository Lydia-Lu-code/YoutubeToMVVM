import UIKit
import WebKit

class HomeVC: BaseViewController {
    
    let keywords = ["todo EP"]
    let queries = ["txt Dance shorts"]

    override func viewDidLoad() {
        super.viewDidLoad()
        doSearch(withKeywords: keywords)
        searchAndLoadHomeShortsCollectionView(withQueries: queries)
    }
    
}


