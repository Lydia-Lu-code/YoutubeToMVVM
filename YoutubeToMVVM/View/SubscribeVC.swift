import UIKit

//class SubscribeVC: BaseViewController {
class SubscribeVC: BaseViewController {
 
    let keywords = ["2023 K-pop 一位安可舞台"]
    let queries = ["2024 Dance shorts"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        doSearch(withKeywords: keywords)
        setupRightBarButtonItems() // 調用新的方法來設置右側的 UIBarButtonItem
        searchAndLoadSubShortsCollectionView(withQueries: queries)
        
    }
}

