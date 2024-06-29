import UIKit
import WebKit

class PlayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ButtonCollectionCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttonTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonCollectionViewCell.identifier, for: indexPath) as! ButtonCollectionViewCell
        let title = buttonTitles[indexPath.item]
        cell.button.setTitle(title, for: .normal)
        cell.button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        // 设置按钮的样式
        cell.button.backgroundColor = UIColor.darkGray // 默认灰色背景
        cell.button.setTitleColor(UIColor.white, for: .normal) // 默认白色文字
        cell.button.titleLabel?.font = UIFont.systemFont(ofSize: 14) // 按钮字体大小
        
        if indexPath.item == buttonTitles.count - 1 {
            // 如果是最后一个按钮，则设置特殊样式
            cell.button.backgroundColor = UIColor.clear // 透明背景
            cell.button.setTitleColor(UIColor.blue, for: .normal) // 蓝色文字
            cell.button.titleLabel?.font = UIFont.systemFont(ofSize: 13) // 缩小字体大小
        }
        
        // 添加按鈕點擊事件
        cell.button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        // 實現按鈕點擊的相應邏輯
    }
    
    func didTapButton() {
        
    }
    
    
    var videosData: [VideoModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var selectedVideoID: String?
    var selectedTitle: String?
    var selectedChannelTitle: String?
    let apiService = APIService() // 創建 APIService 的實例
    let baseViewController = BaseViewController(vcType: .home)
    
    var data: Observable<[VideoModel]> = Observable([])  // 明確指定型別並初始化為空陣列
    var dataLoadedCallback: (([VideoModel]) -> Void)?

    
    let playerView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let playerView = WKWebView(frame: .zero, configuration: configuration)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        return playerView
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let buttonTitles = ["📍", "全部", "音樂", "遊戲", "合輯", "直播中", "動畫", "寵物", "最新上傳", "讓你耳目一新的影片", "提供意見"]
    
    lazy var buttonCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        let buttonCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        buttonCollectionView.showsHorizontalScrollIndicator = false
        buttonCollectionView.delegate = self
        buttonCollectionView.dataSource = self
        buttonCollectionView.register(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.identifier)
        return buttonCollectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(playerView)
        view.addSubview(tableView)
        
        // 使用 selectedVideoID 进行操作，例如加载视频
        if let videoID = selectedVideoID {
            print("PVC selectedVideoID.videoID == \(videoID)")
            loadYouTubeVideo(videoID: videoID, height: 560)
            fetchDataForVideoID(videoID)
        }
        
        // 設置 WKWebView 的約束，應用 UIEdgeInsets
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.heightAnchor.constraint(equalToConstant: 220),
            
            tableView.topAnchor.constraint(equalTo: playerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 禁用playerView的滚动功能
        playerView.scrollView.isScrollEnabled = false
        
        // 设置TableView的代理和数据源
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(PlayerTableViewCell.self, forCellReuseIdentifier: "PlayerTableViewCell")
        
    }
    
    func loadYouTubeVideo(videoID: String, height: Int) {
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <body style="margin: 0; padding: 0;">
        <iframe width="100%" height="\(height)" src="https://www.youtube.com/embed/\(videoID)?autoplay=1&controls=1&showinfo=1&modestbranding=1&rel=0&loop=0&fs=0" frameborder="0" allowfullscreen="false"></iframe>
        </body>
        </html>
        """
        playerView.loadHTMLString(embedHTML, baseURL: nil)
    }
    
    func fetchDataForVideoID(_ videoID: String) {
        print("PVC fetchDataForVideoID.videoID == \(videoID)")
        apiService.getDataForVideoID(videoID) { [weak self] videoModel in
            guard let self = self, let videoModel = videoModel else {
                print("PVC fetchDataForVideoID() 未能獲取到有效數據")
                return
            }
            
            DispatchQueue.main.async {
                // 更新 videosData 並重新載入 tableView
                self.videosData = [videoModel]
                self.tableView.reloadData()
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(videosData.count, 15)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerTableViewCell", for: indexPath) as! PlayerTableViewCell
        
        switch indexPath.row {
        case 0:
            if let videoModel = videosData.first {
                cell.textLabel?.numberOfLines = 0
                let formattedViewCount = baseViewController.convertViewCount(videoModel.viewCount ?? "")
                let formattedUploadDate = baseViewController.calculateTimeSinceUpload(from: videoModel.daysSinceUpload ?? "")
                
                let firstLineAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 18)
                ]
                
                let secondLineAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12)
                ]
                
                let firstLine = NSMutableAttributedString(string: "\(videoModel.title)", attributes: firstLineAttributes)
                let secondLine = NSMutableAttributedString(string: "\n觀看次數：\(formattedViewCount)次．\(formattedUploadDate)", attributes: secondLineAttributes)
                
                let combinedText = NSMutableAttributedString()
                combinedText.append(firstLine)
                combinedText.append(secondLine)
                
                cell.textLabel?.attributedText = combinedText
            } else {
                cell.textLabel?.numberOfLines = 1
                cell.textLabel?.text = "預設標題"
            }
            cell.customLabel.attributedText = nil
            cell.button1.setTitle("", for: .normal)
            cell.button2.setTitle("", for: .normal)
            cell.button1.isHidden = true
            cell.button2.isHidden = true
            print("Setting up cell for row 0")
        case 1:
            // 設置第二個 cell 的內容
            if let videoModel = videosData.first {
                let lineAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 14)
                ]
                
                let line = NSAttributedString(string: " \(videoModel.channelTitle ?? "")", attributes: lineAttributes)
                let combinedText = NSMutableAttributedString()
                combinedText.append(line)
                
                cell.customLabel.attributedText = combinedText
                cell.button1.setTitle("bell", for: .normal)
                cell.button2.setTitle("訂閱", for: .normal)
                cell.button1.isHidden = false
                cell.button2.isHidden = false
                
            }
            cell.textLabel?.text = nil
            print("Setting up cell for row 1")
        case 2:
            // 設置第三個 cell 的內容
            cell.contentView.subviews.forEach { $0.removeFromSuperview() } // 清除舊的子視圖
            cell.contentView.addSubview(buttonCollectionView)
            buttonCollectionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                buttonCollectionView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                buttonCollectionView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                buttonCollectionView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                buttonCollectionView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
            print("Setting up cell for row 2")
        
        
        case 3:
            cell.textLabel?.text = "留言\n"
            print("Setting up cell for row 3")
        case 4:
            cell.textLabel?.text = "emo Shorts"
            print("Setting up cell for row 4")
        case 5:
            cell.textLabel?.text = "水平移動cell-1"
            print("Setting up cell for row 5")
        case 6:
            cell.textLabel?.text = "VideoViewFrame-1"
            print("Setting up cell for row 6")
        case 7:
            cell.textLabel?.text = "VideoViewFrame-2"
            print("Setting up cell for row 7")
        case 8:
            cell.textLabel?.text = "水平移動cell-2"
            print("Setting up cell for row 8")
            
        default:
            cell.textLabel?.text = "預設內容"
            cell.customLabel.attributedText = nil
            cell.button1.setTitle("", for: .normal)
            cell.button2.setTitle("", for: .normal)
            cell.button1.isHidden = true
            cell.button2.isHidden = true
            print("Setting up default cell")
        }
        
        return cell
    }

    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("PVC Selected row: \(indexPath.row)")
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0

        switch indexPath.row {
        case 0,3: height = 80
        case 1,2: height = 50
        case 4,7: height = 240
        case 5,6: height = 220
        default: height = 40
        }
        return height
    }
}
