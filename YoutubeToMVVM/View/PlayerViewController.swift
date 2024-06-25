import UIKit
import WebKit

class PlayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var shortsData: [VideoModel] = []
    var clickedVideoIDs: [String] = []
    
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
        
        view.backgroundColor = .white
        
        view.addSubview(playerView)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), // 与safe area顶部对齐
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 768/1280),

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
        
        // 加载YouTube视频
        loadYouTubeVideo(videoID: "xvfWTtX9D9c", height: 590)
    }
    
    func configure(withVideoID videoID: String) {
        // 處理接收到的影片ID
        print("PlayerViewController received videoID: \(videoID)")
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
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20 // 示例行数
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerTableViewCell", for: indexPath)
        cell.textLabel?.text = "Row \(indexPath.row)"
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "﻿|內容微恐﻿|﻿ |內容微恐﻿|﻿ |內容微恐﻿|﻿ |內容微恐﻿|﻿ |內容微恐﻿|﻿ |內容微恐﻿|﻿ |內容微恐﻿|﻿ |內容微恐﻿|﻿ |內容微恐﻿|﻿ ﻿"
        case 1:
//            cell.imageView
            cell.textLabel?.text = "﻿懸疑漫畫﻿"
//            cell.Button
        case 2:
            cell.textLabel?.text = "﻿水平移動﻿按鈕"
        case 3:
            cell.textLabel?.text = "﻿留言"
        case 4:
            cell.textLabel?.text = "emo Shorts"
        case 5:
            cell.textLabel?.text = "﻿水平移動cell-1"
        case 6:
            cell.textLabel?.text = "﻿VideoViewFrame-1"
        case 7:
            cell.textLabel?.text = "﻿VideoViewFrame-2"
        case 8:
            cell.textLabel?.text = "﻿水平移動cell-2"
        default:
            break
        }
        
        
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Selected row: \(indexPath.row)")
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        
        if indexPath.row == 0 || indexPath.row == 3 {
            height = 90
        } else if indexPath.row == 1 || indexPath.row == 2 {
            height = 45
        } else if indexPath.row == 5 || indexPath.row == 8 {
            height = 260
        } else if indexPath.row == 6 || indexPath.row == 7 {
                height = 240

        } else {
            height = 45 // 默认行高，你可以根据需要设置
        }
        
        return height
    }
    
}
