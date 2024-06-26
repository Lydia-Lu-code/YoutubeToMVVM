import UIKit
import WebKit

class PlayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var shortsData: [VideoModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var selectedVideoID: String?
    var selectedTitle: String?
    var selectedChannelTitle: String?
    let apiService = APIService() // 創建 APIService 的實例
    
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
        
        // 注册TableView的单元格
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlayerTableViewCell")
        
        // 添加示例數據
//        setupExampleData()
        
    }
    
    func loadYouTubeVideo(videoID: String, height: Int) {
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <body style="margin: 0; padding: 0;">
        <iframe width="100%" height="\(height)" src="https://www.youtube.com/embed/\(videoID)" frameborder="0" allowfullscreen></iframe>
        </body>
        </html>
        """
        playerView.loadHTMLString(embedHTML, baseURL: nil)
    }
    
    func fetchDataForVideoID(_ videoID: String) {
        print("PVC fetchDataForVideoID.videoID == \(videoID)")
        apiService.getDataForVideoID(videoID) { [weak self] (videoModel: VideoModel?) in
            guard let videoModel = videoModel else {
                print("PVC fetchDataForVideoID() 未能獲取到有效數據")
                return
            }
            
            DispatchQueue.main.async {
                // 儲存從 API 返回的數據
                self?.shortsData.append(videoModel)
                
                // 更新 UI 或者 tableView
                self?.tableView.reloadData()
                
                // 在成功取得數據後，可以繼續處理並顯示需要的資訊
                self?.showVideoDetails(videoModel)
            }
        }
    }



    func showVideoDetails(_ videoModel: VideoModel) {
        // 在這裡更新 UI 顯示影片的詳細資訊，例如標題、觀看次數、上傳日期、頻道標題等
        print("PVC 影片標題: \(videoModel.title)")
        print("PVC 觀看次數: \(videoModel.viewCount ?? "未知")")
        print("PVC 上傳日期: \(videoModel.daysSinceUpload ?? "未知")")
        print("PVC 頻道標題: \(videoModel.channelTitle)")
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shortsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerTableViewCell", for: indexPath)
        
        let videoModel = shortsData[indexPath.row]
        
        // 根據 indexPath.row 的不同情況來設置 cell 的內容
        switch indexPath.row {
        case 0:
            cell.textLabel?.numberOfLines = 3
            cell.textLabel?.text = """
            標題: \(videoModel.title ?? "無標題")
            觀看次數: \(videoModel.viewCount ?? "觀看次數未知")
            上傳日期: \(videoModel.daysSinceUpload ?? "上傳日期未知")
            """
        case 1:
            cell.textLabel?.text = "帳號ID: \(videoModel.channelTitle)﻿"
        case 2:
            cell.textLabel?.text = "水平移動按鈕"
        case 3:
            cell.textLabel?.text = "留言"
        case 4:
            cell.textLabel?.text = "emo Shorts"
        case 5:
            cell.textLabel?.text = "水平移動cell-1"
        case 6:
            cell.textLabel?.text = "VideoViewFrame-1"
        case 7:
            cell.textLabel?.text = "VideoViewFrame-2"
        case 8:
            cell.textLabel?.text = "水平移動cell-2"
        default:
            break
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
        
        if indexPath.row == 0 || indexPath.row == 3 {
            height = 80
        } else if indexPath.row == 1 || indexPath.row == 2 {
            height = 40
        } else if indexPath.row == 5 || indexPath.row == 8 {
            height = 240
        } else if indexPath.row == 6 || indexPath.row == 7 {
            height = 220
        } else {
            height = 40 // 默认行高，你可以根据需要设置
        }
        
        return height
    }
}
