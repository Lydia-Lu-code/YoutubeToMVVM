import UIKit
import WebKit

class HomeVC: BaseViewController {
    
    let keywords = ["todo EP"]
    let queries = ["txt Dance shorts"]

    override func viewDidLoad() {
        super.viewDidLoad()
        doSearch(withKeywords: keywords)
        setBarBtnItems() // 調用新的方法來設置右側的 UIBarButtonItem
        searchAndLoadHomeShortsCollectionView(withQueries: queries)
    }
    
}


