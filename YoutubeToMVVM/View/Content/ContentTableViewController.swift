
//
//  YourContentViewController.swift
//  YoutubeViewController
//
//  Created by Lydia Lu on 2024/4/5.
//

import UIKit

class ContentTableViewController: UITableViewController, BarButtonItemsDelegate {

    var barButtonItemsModel: BarButtonItemsModel!
    var videoFrameViews: [ConVideoFrameView] = [] // 用來存放所有的 ConVideoFrameView
    var showItems: [String] = []
    var videoIDs: [String] = []

    lazy var contentTopView: ContentTopView = {
        let view = ContentTopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: "ContentTableViewCell")
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 0
        tableView.sectionHeaderTopPadding = 0
        
        
        doSearch(withKeywords: ["2024﻿ 韓﻿﻿﻿ 團綜"], maxResults: 4)
        
        // 初始化 barButtonItemsModel 並設置代理
        barButtonItemsModel = BarButtonItemsModel(viewController: self)
        barButtonItemsModel.setBarBtnItems()
        
        // 初始化 videoFrameViews，假設你已經有方法來創建並添加這些視圖到界面
        initializeVideoFrameViews()
    }
    
    private func initializeVideoFrameViews() {
        for videoFrameView in videoFrameViews {
            view.addSubview(videoFrameView) // 將視圖添加到父視圖中
            // 添加約束或設置視圖的位置和大小
        }
    }
    
    private func getVideoFrameView(at index: Int) -> ConVideoFrameView? {
        if index >= 0 && index < videoFrameViews.count {
            return videoFrameViews[index]
        }
        return nil
    }
    
    func searchYouTube(query: String, maxResults: Int, completion: @escaping (Welcome?) -> Void) {
        
//        let apiKey = ""
        let apiKey = "AIzaSyDC2moKhNm_ElfyiKoQeXKftoLHYzsWwWY"
        let baseURL = "https://www.googleapis.com/youtube/v3/search"
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "maxResults", value: "\(maxResults)"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        let url = components.url!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(String(describing: error))")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(json)
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
            let decoder = JSONDecoder()
            
            do {
                let searchResponse = try decoder.decode(Welcome.self, from: data)
                completion(searchResponse)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func doSearch(withKeywords keywords: [String], maxResults: Int) {
        var currentIndex = 0 // 用於追踪當前的索引
        
        for keyword in keywords {
            searchYouTube(query: keyword, maxResults: maxResults) { [self] response in
                if let response = response {
                    for (_, item) in response.items.enumerated() {
                        if currentIndex < maxResults{ // 確保不超過 16 筆資料
                            showItems.append(keyword)
                            print("CON showItems == \(showItems)")
                            loadDataVideoFrameView(withTitle: item.snippet.title,
                                                   thumbnailURL: item.snippet.thumbnails.high.url,
                                                   channelTitle: item.snippet.channelTitle, index: currentIndex)
                            
                            let videoID = item.id.videoID
                            videoIDs.append(videoID)
                            print("CON videoIDs == \(videoIDs)")
                            currentIndex += 1 // 增加索引
                        } else {
                            break
                        }
                    }
                } else {
                    print("Failed to fetch results for keyword: \(keyword)")
                }
            }
        }
    }

    func loadDataVideoFrameView(withTitle title: String, thumbnailURL: String, channelTitle: String, index: Int) {
        print(title)
        
        // 根據 index 獲取 videoFrameView
        guard let videoFrameView = getVideoFrameView(at: index) else {
            return
        }
        
        DispatchQueue.main.async {
            // 設置標題和其他信息
            videoFrameView.titleLbl.text = title
            videoFrameView.channelId.text = channelTitle
            
            // 設置影片縮圖
            self.setImage(from: thumbnailURL, to: videoFrameView.conVideoImgView)
        }
    }
    
    func setImage(from urlString: String, to imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if error != nil {
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }

    
    func setBarBtnItems() {
        barButtonItemsModel.setBarBtnItems()
    }
    
    func topButtonTapped(_ sender: UIBarButtonItem) {
        barButtonItemsModel.topButtonTapped(sender)
    }
    
    func presentSearchViewController() {
        barButtonItemsModel.presentSearchViewController()
    }
    
    func presentAlertController(title: String, message: String?) {
        barButtonItemsModel.presentAlertController(title: title, message: message)
    }
    
    func navigateToNotificationLogViewController() {
        barButtonItemsModel.navigateToNotificationLogViewController()
    }
    
    
    func resizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(origin: .zero, size: newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 9 // 5個部分
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else if section == 1 || section == 2 {
            return 1
        } else {
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell", for: indexPath) as! ContentTableViewCell
        
        // 設置 section 的值
        cell.section = indexPath.section
        
        // 配置 ConVideoFrameViews，例如堆叠16个
        cell.configureConVideoFrameViews(count: 16)

        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = UIView()
            
            // Add your custom content here
            let contentTopView = ContentTopView()
            contentTopView.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(contentTopView)
            
            NSLayoutConstraint.activate([
                contentTopView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
                contentTopView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
                contentTopView.topAnchor.constraint(equalTo: headerView.topAnchor),
                contentTopView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
            ])
            
            return headerView
        } else {
            let headerView = ContentHeaderView()
            headerView.delegate = self
            
            // SF Symbols array
            let sfSymbols = [
                "eye.fill",        // 觀看歷史
                "list.bullet",     // 播放清單
                "film.fill",       // 你的影片
                "arrow.down.circle", // 已下載的內容
                "tv.fill",         // 你的電影
                "crown.fill",      // Premium 會員福利
                "clock.fill",      // 已觀看時間
                "bubble.left.fill" // 說明和意見回饋
            ]
            
            // Create attributed string with SF Symbol and text
            func attributedTitle(title: String, symbol: String?) -> NSAttributedString {
                let completeString = NSMutableAttributedString()
                
                if let symbol = symbol, let symbolImage = UIImage(systemName: symbol) {
                    let imageAttachment = NSTextAttachment()
                    imageAttachment.image = symbolImage.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
                    
                    let imageString = NSAttributedString(attachment: imageAttachment)
                    completeString.append(imageString)
                } else {
                    print("No symbol for title: \(title)")
                }
                
                let titleString = NSAttributedString(string: " \(title)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
                completeString.append(titleString)
                return completeString
            }
            
            // Set different button titles and symbols for each section
            switch section {
            case 1:
                headerView.leftButton.setAttributedTitle(attributedTitle(title: "觀看歷史", symbol: nil), for: .normal)
                headerView.rightButton.setTitle("查看全部", for: .normal)
            case 2:
                headerView.leftButton.setAttributedTitle(attributedTitle(title: "播放清單", symbol: nil), for: .normal)
                headerView.rightButton.setTitle("查看全部", for: .normal)
            case 3:
                headerView.leftButton.setAttributedTitle(attributedTitle(title: "你的影片", symbol: sfSymbols[2]), for: .normal)
                headerView.rightButton.setTitle(" ", for: .normal)
            case 4:
                headerView.leftButton.setAttributedTitle(attributedTitle(title: "已下載的內容", symbol: sfSymbols[3]), for: .normal)
                headerView.rightButton.setTitle(" ", for: .normal)
            case 5:
                headerView.leftButton.setAttributedTitle(attributedTitle(title: "你的電影", symbol: sfSymbols[4]), for: .normal)
                headerView.rightButton.setTitle(" ", for: .normal)
            case 6:
                headerView.leftButton.setAttributedTitle(attributedTitle(title: "Premium 會員福利", symbol: sfSymbols[5]), for: .normal)
                headerView.rightButton.setTitle(" ", for: .normal)
            case 7:
                headerView.leftButton.setAttributedTitle(attributedTitle(title: "已觀看時間", symbol: sfSymbols[6]), for: .normal)
                headerView.rightButton.setTitle(" ", for: .normal)
            case 8:
                headerView.leftButton.setAttributedTitle(attributedTitle(title: "說明和意見回饋", symbol: sfSymbols[7]), for: .normal)
                headerView.rightButton.setTitle(" ", for: .normal)
            default:
                break
            }
            return headerView
        }
    }
    
    // 設置 header 的高度
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 150
        } else {
            return 45
        }
        
        
    }
    
    // 設置 cell 的高度
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
}


extension ContentTableViewController:ContentHeaderViewDelegate {
    func doSegueAction() {
        print("成功")
    }
    
}
////
////  YourContentViewController.swift
////  YoutubeViewController
////
////  Created by Lydia Lu on 2024/4/5.
////
//
//import UIKit
//
//struct ConVideoViewModel {
//    let title: String
//    let thumbnailURL: String
//    let channelTitle: String
//    let index: Int
//}
//
//class ContentTableViewModel {
//    var videoViewModels: [[ConVideoViewModel]] = [[]]
//
//    // 在此添加其他必要的邏輯，例如從網絡加載數據等
//}
//
//class ContentTableViewController: UITableViewController, BarButtonItemsDelegate {
//
//        
//    var barButtonItemsModel: BarButtonItemsModel!
//    var videoFrameViews: [ConVideoFrameView] = []
//    
//    lazy var contentTopView: ContentTopView = {
//        let view = ContentTopView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    var conVideoFrameView = ConVideoFrameView()
//    
//    //    let baseViewController = BaseViewController(vcType: .content)
//    
//    var showItems: [String] = []
//    var videoIDs: [String] = []
//
//    var viewModel: ContentTableViewModel!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        //        view.backgroundColor = .systemBackground
//        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: "ContentTableViewCell")
//        tableView.sectionHeaderHeight = UITableView.automaticDimension
//        tableView.estimatedSectionHeaderHeight = 0
//        tableView.sectionHeaderTopPadding = 0
//        
//        // 初始化 barButtonItemsModel 並設置代理
//        barButtonItemsModel = BarButtonItemsModel(viewController: self)
//        barButtonItemsModel.setBarBtnItems()
//        
//        viewModel = ContentTableViewModel()
//        loadSampleData()
//    }
//    
//    
//    func resizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
//        guard let image = image else { return nil }
//        
//        let size = image.size
//        let widthRatio = targetSize.width / size.width
//        let heightRatio = targetSize.height / size.height
//        
//        let newSize: CGSize
//        if widthRatio > heightRatio {
//            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
//        } else {
//            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
//        }
//        
//        let rect = CGRect(origin: .zero, size: newSize)
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
//        image.draw(in: rect)
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return newImage
//    }
//    
//    // Load sample data for testing purposes
//        func loadSampleData() {
//            let sampleData = (0..<16).map { index in
//                ConVideoViewModel(title: "Title \(index)", thumbnailURL: "image\(index % 3 + 1)", channelTitle: "Channel \(index)", index: index)
//            }
//            viewModel.videoViewModels = [sampleData]
//        }
//    
//    func setBarBtnItems() {
//        barButtonItemsModel.setBarBtnItems()
//    }
//    
//    func topButtonTapped(_ sender: UIBarButtonItem) {
//        barButtonItemsModel.topButtonTapped(sender)
//    }
//    
//    func presentSearchViewController() {
//        barButtonItemsModel.presentSearchViewController()
//    }
//    
//    func presentAlertController(title: String, message: String?) {
//        barButtonItemsModel.presentAlertController(title: title, message: message)
//    }
//    
//    func navigateToNotificationLogViewController() {
//        barButtonItemsModel.navigateToNotificationLogViewController()
//    }
//    
//    
//    
//    // MARK: - Table view data source
//    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 9 // 5個部分
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return 0
//        } else if section == 1 || section == 2 {
//            return 1
//        } else {
//            return 0
//        }
//    }
//    
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell", for: indexPath) as! ContentTableViewCell
//        
//        // 設置 section 的值
//        cell.section = indexPath.section
//        print("CON cell.section == \(cell.section)")
//        // 配置 ConVideoFrameViews，例如堆叠16个
//        cell.configureConVideoFrameViews(count: 16)
//
//        
//        return cell
//    }
//    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            let headerView = UIView()
//            
//            // Add your custom content here
//            let contentTopView = ContentTopView()
//            contentTopView.translatesAutoresizingMaskIntoConstraints = false
//            headerView.addSubview(contentTopView)
//            
//            NSLayoutConstraint.activate([
//                contentTopView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
//                contentTopView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
//                contentTopView.topAnchor.constraint(equalTo: headerView.topAnchor),
//                contentTopView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
//            ])
//            
//            return headerView
//        } else {
//            let headerView = ContentHeaderView()
//            headerView.delegate = self
//            
//            // SF Symbols array
//            let sfSymbols = [
//                "eye.fill",        // 觀看歷史
//                "list.bullet",     // 播放清單
//                "film.fill",       // 你的影片
//                "arrow.down.circle", // 已下載的內容
//                "tv.fill",         // 你的電影
//                "crown.fill",      // Premium 會員福利
//                "clock.fill",      // 已觀看時間
//                "bubble.left.fill" // 說明和意見回饋
//            ]
//            
//            // Create attributed string with SF Symbol and text
//            func attributedTitle(title: String, symbol: String?) -> NSAttributedString {
//                let completeString = NSMutableAttributedString()
//                
//                if let symbol = symbol, let symbolImage = UIImage(systemName: symbol) {
//                    let imageAttachment = NSTextAttachment()
//                    imageAttachment.image = symbolImage.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
//                    
//                    let imageString = NSAttributedString(attachment: imageAttachment)
//                    completeString.append(imageString)
//                } else {
//                    print("No symbol for title: \(title)")
//                }
//                
//                let titleString = NSAttributedString(string: " \(title)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)])
//                completeString.append(titleString)
//                return completeString
//            }
//            
//            // Set different button titles and symbols for each section
//            switch section {
//            case 1:
//                headerView.leftButton.setAttributedTitle(attributedTitle(title: "觀看歷史", symbol: nil), for: .normal)
//                headerView.rightButton.setTitle("查看全部", for: .normal)
//            case 2:
//                headerView.leftButton.setAttributedTitle(attributedTitle(title: "播放清單", symbol: nil), for: .normal)
//                headerView.rightButton.setTitle("查看全部", for: .normal)
//            case 3:
//                headerView.leftButton.setAttributedTitle(attributedTitle(title: "你的影片", symbol: sfSymbols[2]), for: .normal)
//                headerView.rightButton.setTitle(" ", for: .normal)
//            case 4:
//                headerView.leftButton.setAttributedTitle(attributedTitle(title: "已下載的內容", symbol: sfSymbols[3]), for: .normal)
//                headerView.rightButton.setTitle(" ", for: .normal)
//            case 5:
//                headerView.leftButton.setAttributedTitle(attributedTitle(title: "你的電影", symbol: sfSymbols[4]), for: .normal)
//                headerView.rightButton.setTitle(" ", for: .normal)
//            case 6:
//                headerView.leftButton.setAttributedTitle(attributedTitle(title: "Premium 會員福利", symbol: sfSymbols[5]), for: .normal)
//                headerView.rightButton.setTitle(" ", for: .normal)
//            case 7:
//                headerView.leftButton.setAttributedTitle(attributedTitle(title: "已觀看時間", symbol: sfSymbols[6]), for: .normal)
//                headerView.rightButton.setTitle(" ", for: .normal)
//            case 8:
//                headerView.leftButton.setAttributedTitle(attributedTitle(title: "說明和意見回饋", symbol: sfSymbols[7]), for: .normal)
//                headerView.rightButton.setTitle(" ", for: .normal)
//            default:
//                break
//            }
//            return headerView
//        }
//    }
//    
//    // 設置 header 的高度
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 150
//        } else {
//            return 45
//        }
//        
//        
//    }
//    
//    // 設置 cell 的高度
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 160
//    }
//    
//}
//
//
//extension ContentTableViewController:ContentHeaderViewDelegate {
//    func doSegueAction() {
//        print("成功")
//    }
//    
//}
