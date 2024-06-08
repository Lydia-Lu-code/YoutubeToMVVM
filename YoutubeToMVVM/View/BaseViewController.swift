import UIKit

enum ViewControllerType: String {
    case home
    case subscribe
    case content
}


class BaseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ButtonCollectionCellDelegate, UICollectionViewDelegateFlowLayout, BarButtonItemsDelegate {
    // 實現 BarButtonItemsDelegate 的方法，這些方法將調用 barButtonItemsModel 的對應方法
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
    
    var barButtonItemsModel: BarButtonItemsModel!
    
    
    //    weak var delegate: BaseVCDelegate?
    
    var vcType: ViewControllerType?
    
    init(vcType: ViewControllerType) {
        self.vcType = vcType
        super.init(nibName: nil, bundle: nil)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let buttonTitles = ["📍", "全部", "音樂", "遊戲", "合輯", "直播中", "動畫", "寵物", "最新上傳", "讓你耳目一新的影片", "提供意見"]
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    // 定義一個 UIImageView 用於顯示播放器符號
    lazy var playerSymbolImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "play.circle")
        imageView.tintColor = UIColor.systemBlue
        imageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal) // 設置內容壓縮抗壓縮性
        return imageView
    }()
    
    // 定義一個 UILabel 用於顯示 "Shorts" 文字
    lazy var shortsLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Shorts"
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 18) // 設置粗體 18PT
        label.setContentCompressionResistancePriority(.required, for: .horizontal) // 設置內容壓縮抗壓縮性
        return label
    }()
    
    // 定義一個 StackView 用於將播放器符號和 "Shorts" 文字放在一起
    public lazy var shortsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8 // 設置元件間距
        stackView.distribution = .fill // 將分佈設置為填充
        stackView.alignment = .center // 將對齊方式設置為居中對齊
        stackView.addArrangedSubview(playerSymbolImageView)
        stackView.addArrangedSubview(shortsLbl)
        return stackView
    }()
    
    var singleVideoFrameView = VideoFrameView()
    var otherVideoFrameViews: [VideoFrameView] = []
    var showItems: [String] = []
    var viewCount = ""
    var subscribeSecItemView = SubscribeSecItemView()
    
    lazy var homeShortsFrameCollectionView: HomeShortsFrameCollectionView = {
        let collectionView = HomeShortsFrameCollectionView()
        return collectionView
    }()
    
    lazy var subscribeHoriCollectionView: SubscribeHoriCollectionView = {
        let collectionView = SubscribeHoriCollectionView()
        return collectionView
    }()
    
    var totalHeight: CGFloat =  0
    
    var videoIDs: [String] = []
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.isScrollEnabled = true
        totalHeight = calculateTotalHeight()
        
        setViews()
        setLayout()
//        setBarBtnItems()
        barButtonItemsModel = BarButtonItemsModel(viewController: self)
        barButtonItemsModel.setBarBtnItems()
        
        buttonCollectionView.register(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.identifier)
        
        // 將 scrollView 的 contentSize 設置為 contentView 的大小，確保能夠正確上下滾動
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: totalHeight)
        
        // 設置其他影片框架
        otherVideoFrameViews = setOtherVideoFrameViews()
        
    }
    
    func setViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(buttonCollectionView)
        contentView.addSubview(singleVideoFrameView)
        contentView.addSubview(shortsStackView)
        
        if vcType == .home {
            contentView.addSubview(homeShortsFrameCollectionView)
        } else if vcType == .subscribe {
            contentView.addSubview(subscribeSecItemView)
            contentView.addSubview(subscribeHoriCollectionView)
        }
    }
    
    func setLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        subscribeSecItemView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonCollectionView.translatesAutoresizingMaskIntoConstraints = false
        singleVideoFrameView.translatesAutoresizingMaskIntoConstraints = false
        shortsStackView.translatesAutoresizingMaskIntoConstraints = false
        homeShortsFrameCollectionView.translatesAutoresizingMaskIntoConstraints = false
        subscribeHoriCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: totalHeight)
        ])
        
        NSLayoutConstraint.activate([
            
            
            singleVideoFrameView.topAnchor.constraint(equalTo: buttonCollectionView.bottomAnchor),
            singleVideoFrameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            singleVideoFrameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            singleVideoFrameView.heightAnchor.constraint(equalToConstant: 300),
            
            shortsStackView.topAnchor.constraint(equalTo: singleVideoFrameView.bottomAnchor),
            shortsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            shortsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            shortsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        if vcType == .home {
            NSLayoutConstraint.activate([
                
                buttonCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
                buttonCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                buttonCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                buttonCollectionView.heightAnchor.constraint(equalToConstant: 60),
                
                homeShortsFrameCollectionView.topAnchor.constraint(equalTo: shortsStackView.bottomAnchor),
                homeShortsFrameCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                homeShortsFrameCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                homeShortsFrameCollectionView.heightAnchor.constraint(equalToConstant: 660)
            ])
        } else if vcType == .subscribe {
            NSLayoutConstraint.activate([
                subscribeSecItemView.topAnchor.constraint(equalTo: contentView.topAnchor),
                subscribeSecItemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                subscribeSecItemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                subscribeSecItemView.heightAnchor.constraint(equalToConstant: 90),
                
                buttonCollectionView.topAnchor.constraint(equalTo: subscribeSecItemView.bottomAnchor),
                buttonCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                buttonCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                buttonCollectionView.heightAnchor.constraint(equalToConstant: 60),
                
                subscribeHoriCollectionView.topAnchor.constraint(equalTo: shortsStackView.bottomAnchor),
                subscribeHoriCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                subscribeHoriCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                subscribeHoriCollectionView.heightAnchor.constraint(equalToConstant: 330)
            ])
        }
    }
    
    
    func calculateTotalHeight() -> CGFloat {
        switch vcType {
        case .home:
            return 1020
        case .subscribe:
            return 780
        default:
            return 0
        }
    }
    
    
    @objc func buttonTapped(_ sender: UIButton) {
        // 實現按鈕點擊的相應邏輯
    }
    
    func setOtherVideoFrameViews() -> [VideoFrameView] {
        var videoFrameViews: [VideoFrameView] = []
        
        // 先保留第一個框架的 reference
        
        let firstVideoFrameView = VideoFrameView()
        firstVideoFrameView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(firstVideoFrameView)
        videoFrameViews.append(firstVideoFrameView)
        
        if vcType == .home {
            // 設置第一個框架的約束
            NSLayoutConstraint.activate([
                firstVideoFrameView.topAnchor.constraint(equalTo: homeShortsFrameCollectionView.bottomAnchor, constant: 10),
            ])
            
        } else if vcType == .subscribe {
            NSLayoutConstraint.activate([
                firstVideoFrameView.topAnchor.constraint(equalTo: subscribeHoriCollectionView.bottomAnchor, constant: 10), // 垂直間距為 20
            ])
        }
        NSLayoutConstraint.activate([
            firstVideoFrameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            firstVideoFrameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            firstVideoFrameView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        var previousView: UIView = firstVideoFrameView
        
        // 建立並設置其他框架
        for _ in 1..<4 {
            let videoFrameView = VideoFrameView()
            videoFrameView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(videoFrameView)
            videoFrameViews.append(videoFrameView)
            
            // 設置約束，將下一個框架堆疊在前一個框架的下方
            NSLayoutConstraint.activate([
                videoFrameView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 10),
                videoFrameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                videoFrameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                videoFrameView.heightAnchor.constraint(equalToConstant: 300)
            ])
            
            // 更新 previousView 以便下一个 videoFrameView 堆叠在其下方
            previousView = videoFrameView
        }
        
        return videoFrameViews
    }
    
    // UICollectionViewDataSource 方法
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttonTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonCollectionViewCell.identifier, for: indexPath) as! ButtonCollectionViewCell
        let title = buttonTitles[indexPath.item]
        //        cell.delegate = self // 设置代理
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
    
    // ButtonCollectionCellDelegate 方法
    func didTapButton() {
        // 處理按鈕點擊事件
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = buttonTitles[indexPath.item]
        let width = title.size(withAttributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14) // 根據需要調整字體大小
        ]).width + 20 // 添加一些填充
        
        let height: CGFloat = 20
        let verticalSpacing: CGFloat = 20
        
        return CGSize(width: width, height: height + verticalSpacing)
    }
    
}

extension BaseViewController {
    
    // 將觀看次數轉換為人性化的格式
    func convertViewCount(_ viewCountString: String) -> String {
        guard let viewCount = Int(viewCountString) else {
            return viewCountString // 如果無法解析為整數，返回原始字串
        }
        
        if viewCount > 29999 {
            return "\(viewCount / 10000)萬"
        } else if viewCount > 19999 {
            return "\(viewCount / 10000).\(viewCount % 10000 / 1000)萬"
        } else if viewCount > 9999 {
            return "\(viewCount / 10000)萬"
        } else {
            return "\(viewCount)"
        }
    }
    
    func calculateTimeSinceUpload(from publishTime: String) -> String {
        // 將 publishTime 轉換為日期對象
        let dateFormatter = ISO8601DateFormatter()
        if let publishDate = dateFormatter.date(from: publishTime) {
            // 計算距今的時間間隔
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: publishDate, to: Date())
            
            // 判斷距離上傳的時間，決定顯示的格式
            if let years = components.year, years > 0 {
                return "\(years)年前"
            } else if let months = components.month, months > 0 {
                return "\(months)個月前"
            } else if let days = components.day, days > 0 {
                return "\(days)天前"
            } else if let hours = components.hour, hours > 0 {
                return "\(hours)個小時前"
            } else {
                return "剛剛"
            }
        }
        return ""
    }
    
    func loadDataVideoFrameView(withTitle title: String, thumbnailURL: String, channelTitle: String, accountImageURL: String, viewCount: String, daysSinceUpload: String, atIndex index: Int) {
        print(title)
        
        // 根據 index 獲取 videoFrameView
        guard let videoFrameView = getVideoFrameView(at: index) else {
            return
        }
        
        DispatchQueue.main.async {
            // 設置標題和其他信息
            videoFrameView.labelMidTitle.text = title
            videoFrameView.labelMidOther.text = "\(channelTitle)．觀看次數： \(self.convertViewCount(viewCount))次．\(daysSinceUpload)"
            
            // 設置影片縮圖
            self.setImage(from: thumbnailURL, to: videoFrameView.videoImgView)
            
            // 設置帳號圖片
            self.setImage(from: accountImageURL, to: videoFrameView.photoImageView)
        }
    }
    
    private func getVideoFrameView(at index: Int) -> VideoFrameView? {
        if index == 0 {
            return singleVideoFrameView
        } else if index >= 1 && index <= 4 {
            let adjustedIndex = index - 1
            if adjustedIndex < otherVideoFrameViews.count {
                return otherVideoFrameViews[adjustedIndex]
            }
        }
        return nil
    }
    
    func setImage(from urlString: String, to imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
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
    
    
    func searchYouTube(query: String, maxResults: Int, completion: @escaping (Welcome?) -> Void) {
        
        let apiKey = ""
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
    
    func doSearch(withKeywords keywords: [String], maxResults: Int = 5) {
        for keyword in keywords {
            searchYouTube(query: keyword, maxResults: maxResults) { [self] response in
                if let response = response {
                    for (i, item) in response.items.enumerated() {
                        showItems.append(keyword)
                        
                        loadDataVideoFrameView(withTitle: item.snippet.title,
                                               thumbnailURL: item.snippet.thumbnails.high.url,
                                               channelTitle: item.snippet.channelTitle,
                                               accountImageURL: item.snippet.thumbnails.high.url,
                                               viewCount: "987654321",
                                               daysSinceUpload: calculateTimeSinceUpload(from: item.snippet.publishedAt),
                                               atIndex: i)
                        
                        let videoID = item.id.videoID
                        videoIDs.append(videoID)
                    }
                } else {
                    print("Failed to fetch results for keyword: \(keyword)")
                }
            }
        }
    }
    
    func searchAndLoadHomeShortsCollectionView(withQueries queries: [String]) {
        for query in queries {
            searchYouTube(query: query, maxResults: 4) { [weak self] response in
                guard let self = self else { return }
                
                if let welcomeResponse = response {
                    DispatchQueue.main.async {
                        self.homeShortsFrameCollectionView.videoContents.removeAll()
                        self.homeShortsFrameCollectionView.welcome = welcomeResponse
                        
                        for item in welcomeResponse.items {
                            let title = item.snippet.title
                            let image = item.snippet.thumbnails.high.url
                            let videoContent = VideoContent(title: title, thumbnailURL: image)
                            self.homeShortsFrameCollectionView.videoContents.append(videoContent)
                        }
                        
                        self.homeShortsFrameCollectionView.reloadData()
                    }
                } else {
                    print("STV無法為查詢 \(query) 檢索到結果")
                }
                
                // 印出當前處理的查詢
                print("正在處理查詢: \(query)")
            }
        }
    }
    
    func searchAndLoadSubShortsCollectionView(withQueries queries: [String]) {
        for query in queries {
            searchYouTube(query: query, maxResults: 18) { [weak self] response in
                guard let self = self else { return }
                
                if let welcomeResponse = response {
                    DispatchQueue.main.async {
                        self.subscribeHoriCollectionView.subVideoContents.removeAll()
                        self.subscribeHoriCollectionView.welcome = welcomeResponse
                        
                        for item in welcomeResponse.items {
                            let title = item.snippet.title
                            let image = item.snippet.thumbnails.high.url
                            let videoContent = SubVideoContent(title: title, thumbnailURL: image)
                            self.subscribeHoriCollectionView.subVideoContents.append(videoContent)
                        }
                        
                        self.subscribeHoriCollectionView.reloadData()
                    }
                } else {
                    print("STV無法為查詢 \(query) 檢索到結果")
                }
                
                // 印出當前處理的查詢
                print("正在處理查詢: \(query)")
            }
        }
    }
    
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}



