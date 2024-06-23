import Foundation
import UIKit

class ShortsTableViewController: UITableViewController {
    
    var videoContent: String?
    var showItems: [SearchItem] = []
    var itemCount: Int = 0 // 新增一個變量來跟踪項目數量
    var videoViewModel: VideoViewModel? // 添加 videoViewModel 屬性
    
    var videosModel = VideoViewModel()
    var videoContents: [VideoModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        tableView.register(ShortsTableViewCell.self, forCellReuseIdentifier: "ShortsTableViewCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.decelerationRate = .fast // 設置快速滑動減速
        tableView.rowHeight = UIScreen.main.bounds.height // 將每個 cell 的高度設置為模擬器滿版畫面的高度
        tableView.delegate = self // 設置委託
        
        // 隱藏或設置 navigationItem 為透明
        navigationItem.title = "" // 將標題設置為空字符串
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        // 初始化 videoViewModel
        videoViewModel = VideoViewModel()
        
        // 设置数据加载回调
        videoViewModel?.dataLoadedCallback = { [weak self] videoModels in
            self?.tableView.reloadData()
        }
        
        // 加载视频数据
        videoViewModel?.loadShortsCell(withQuery: "txt dance shorts", for: .shorts)

        print("STVC videosModel == \(videoViewModel?.loadShortsCell(withQuery: "txt dance shorts", for: .shorts))")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 呼叫 exerciseAmbiguityInLayout 方法標識任何模糊的視圖
        view.exerciseAmbiguityInLayout()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // Assuming you have only one section
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let videoViewModel = videoViewModel else {
            print("STVC videoViewModel == 0")
            return 0
        }
        return videoViewModel.data.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShortsTableViewCell", for: indexPath) as! ShortsTableViewCell
        
        let video = videoViewModel?.data.value[indexPath.row]
        
        // 配置单元格
        cell.textLabel?.text = video?.title
        print("STVC video?.title == \(video?.title)")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 取得整個屏幕的高度
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight
    }
    
    // Overriding scroll view delegate method
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cellHeight = tableView.rowHeight
        let targetY = targetContentOffset.pointee.y
        let index = round(targetY / cellHeight)
        targetContentOffset.pointee = CGPoint(x: 0, y: index * cellHeight)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            snapToNextCell()
            alignCellToBottom()
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToNextCell()
        alignCellToBottom()
    }
    
    private func alignCellToBottom() {
        guard let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows else { return }
        guard let lastVisibleIndexPath = indexPathsForVisibleRows.last else { return }
        
        tableView.scrollToRow(at: lastVisibleIndexPath, at: .bottom, animated: true)
    }
    
    private func snapToNextCell() {
        let offsetY = tableView.contentOffset.y
        let cellHeight = UIScreen.main.bounds.height
        let currentIndex = Int(round(offsetY / cellHeight))
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        
        // 確保表格視圖中有行數
        guard numberOfRows > 0 else {
            return
        }
        
        let nextIndex = (currentIndex + 1) % numberOfRows
        let targetOffsetY = CGFloat(nextIndex) * cellHeight
        
        let indexPath = IndexPath(row: nextIndex, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

