import UIKit
import WebKit


class SubscribeVC: BaseViewController {
 
    let keywords = ["2023 K-pop 一位安可舞台"]
    let queries = ["2024 Dance shorts"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        doSearch(withKeywords: keywords)
        searchAndLoadSubShortsCollectionView(withQueries: queries)
        
    }
}

