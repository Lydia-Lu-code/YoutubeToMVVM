import UIKit
import WebKit

class HomeVC: BaseViewController {
    
    let keywords = ["todo EP"]
    let queries = ["txt Dance shorts"]
    let viewModel = VideoViewModel()
    let homeShortsFrameCollectionView = HomeShortsFrameCollectionView()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.searchAndLoad(withQueries: ["query1", "query2"], for: .home)

        
//        doSearch(withKeywords: keywords)
//        searchAndLoadHomeShortsCollectionView(withQueries: queries)
    }
    
}


