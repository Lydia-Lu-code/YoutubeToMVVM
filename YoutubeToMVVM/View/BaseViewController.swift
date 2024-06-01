import UIKit

protocol BaseVCDelegate: AnyObject {
    func didTapMenuButton()
    func didTapNotificationLogButtonMid()
}




class BaseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ButtonCollectionCellDelegate, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: BaseVCDelegate?
    

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
        imageView.widthAnchor.constraint(equalToConstant: 35).isActive = true // 設置寬度為 50
        imageView.heightAnchor.constraint(equalToConstant: 35).isActive = true // 設置高度為 50
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
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    lazy var subscribeHoriCollectionView: SubscribeHoriCollectionView = {
        let collectionView = SubscribeHoriCollectionView()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var totalHeight:CGFloat =  0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.isScrollEnabled = true
        totalHeight = calculateTotalHeight()
        
        setupViews()
        setLayout()
        
        setupRightBarButtonItems()
        
        buttonCollectionView.register(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.identifier)
        
        // 將 scrollView 的 contentSize 設置為 contentView 的大小，確保能夠正確上下滾動
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: totalHeight)
        
        // 設置其他影片框架
        otherVideoFrameViews = setupOtherVideoFrameViews()
    }
    
    func setupViews() {
        if self is HomeVC {
            view.addSubview(scrollView)
            scrollView.addSubview(contentView)
            contentView.addSubview(buttonCollectionView)
            contentView.addSubview(singleVideoFrameView)
            contentView.addSubview(shortsStackView)
            contentView.addSubview(homeShortsFrameCollectionView)
        } else if self is SubscribeVC {
            view.addSubview(scrollView)
            scrollView.addSubview(contentView)
            contentView.addSubview(subscribeSecItemView)
            contentView.addSubview(buttonCollectionView)
            contentView.addSubview(singleVideoFrameView)
            contentView.addSubview(shortsStackView)
            contentView.addSubview(subscribeHoriCollectionView)
        }
    }
    
    
    
    func setLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.heightAnchor.constraint(equalToConstant: contentView.intrinsicContentSize.height).isActive = true
        subscribeSecItemView.translatesAutoresizingMaskIntoConstraints = false
        buttonCollectionView.translatesAutoresizingMaskIntoConstraints = false
        singleVideoFrameView.translatesAutoresizingMaskIntoConstraints = false
        shortsStackView.translatesAutoresizingMaskIntoConstraints = false
//        subscribeHoriCollectionView.translatesAutoresizingMaskIntoConstraints = false
        

        
        
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
        
        // 在这里根据条件设置 subscribeSecItemView
        if self is HomeVC {
            NSLayoutConstraint.activate([

                
                buttonCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
                buttonCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                buttonCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                buttonCollectionView.heightAnchor.constraint(equalToConstant: 60),
            ])
            
        }else if self is SubscribeVC {
            NSLayoutConstraint.activate([
                
                subscribeSecItemView.topAnchor.constraint(equalTo: contentView.bottomAnchor),
                subscribeSecItemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                subscribeSecItemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//                subscribeSecItemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor), // 确保它的底部与 contentView 的底部对齐
                subscribeSecItemView.heightAnchor.constraint(equalToConstant: 90), // 根据需要设置高度

                buttonCollectionView.topAnchor.constraint(equalTo: subscribeSecItemView.bottomAnchor),
                buttonCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                buttonCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                buttonCollectionView.heightAnchor.constraint(equalToConstant: 60),
            ])
        }
        
            
            NSLayoutConstraint.activate([

            
            // 确保 singleVideoFrameView 在 subscribeSecItemView 下面
            singleVideoFrameView.topAnchor.constraint(equalTo: buttonCollectionView.bottomAnchor),
            singleVideoFrameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor), // 使用 self. 来明确指定
            singleVideoFrameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor), // 使用 self. 来明确指定
            singleVideoFrameView.heightAnchor.constraint(equalToConstant: 370), // 使用 self. 来明确指定

            // 确保 shortsStackView 在 singleVideoFrameView 下面
            shortsStackView.topAnchor.constraint(equalTo: singleVideoFrameView.bottomAnchor), // 使用 self. 来明确指定
            shortsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor), // 使用 self. 来明确指定
            shortsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor), // 使用 self. 来明确指定
            shortsStackView.heightAnchor.constraint(equalToConstant: 60), // 使用 self. 来明确指定
            
            
            
        ])
        
        
        if self is HomeVC {
            NSLayoutConstraint.activate([
                homeShortsFrameCollectionView.topAnchor.constraint(equalTo: shortsStackView.bottomAnchor),
                homeShortsFrameCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                homeShortsFrameCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                homeShortsFrameCollectionView.heightAnchor.constraint(equalToConstant: 600),
            ])
            
            
        } else if self is SubscribeVC {
            NSLayoutConstraint.activate([
                
                subscribeHoriCollectionView.topAnchor.constraint(equalTo: shortsStackView.bottomAnchor),
                subscribeHoriCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                subscribeHoriCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                subscribeHoriCollectionView.heightAnchor.constraint(equalToConstant: 300),
                
                
                
            ])
        }
        
    }
    
    private func calculateTotalHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        
        totalHeight += 60 // buttonCollectionView 的高度
        totalHeight += 370 // singleVideoFrameView 的高度
        totalHeight += 60 // shortsStackView 的高度
        
        if self is HomeVC {
            totalHeight += 600 // shortsFrameCollectionView 的高度
        } else if self is SubscribeVC {
            totalHeight += 390 // 減去訂閱頁面的高度
        }
        
        //        totalHeight += 600 // shortsFrameCollectionView 的高度
        totalHeight += CGFloat(4 * 370) // 其他 VideoFrameView 的高度
        //        totalHeight += CGFloat(otherVideoFrameViews.count * 300)
        
        totalHeight += CGFloat(4 - 1) * 2 // 添加视图之间的间距
        //        totalHeight += CGFloat(otherVideoFrameViews.count - 1) * 20
        totalHeight += 30 // 假设 contentView 的顶部和底部边距都是 20
        return totalHeight
    }
    
    @objc func didTapMenuButton() {
        delegate?.didTapMenuButton()
        delegate?.didTapNotificationLogButtonMid()
    }
    
    func setupRightBarButtonItems() {
        let btn1 = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(topButtonTapped))
        let btn2 = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: self, action: #selector(topButtonTapped))
        let btn3 = UIBarButtonItem(image: UIImage(systemName: "display.2"), style: .plain, target: self, action: #selector(topButtonTapped))
        
        self.navigationItem.setRightBarButtonItems([btn1, btn2, btn3], animated: true)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        // 實現按鈕點擊的相應邏輯
    }
    
    @objc func topButtonTapped(_ sender: UIBarButtonItem) {
        switch sender {
        case navigationItem.rightBarButtonItems?[2]:
            presentAlertController(title: "選取裝置", message: nil)
        case navigationItem.rightBarButtonItems?[1]:
            navigateToNotificationLogViewController()
        case navigationItem.rightBarButtonItems?[0]:
            presentSearchViewController()
        default:
            break
        }
    }
  
    func presentSearchViewController() {
        guard let viewController = findViewController() else {
            print("無法找到視圖控制器")
            return
        }
        
        let searchVC = SearchVC() // 假設 SearchViewController 是您的搜索視圖控制器類
        searchVC.title = navigationItem.searchController?.searchBar.text ?? "" // 使用搜索框的文本作为标题
        viewController.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    private func presentAlertController(title: String, message: String?) {
        guard let viewController = findViewController() else {
            print("無法找到視圖控制器")
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        // 設置標題文字左對齊
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = NSTextAlignment.left
        let titleAttributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.paragraphStyle: titleParagraphStyle])
        alertController.setValue(titleAttributedString, forKey: "attributedTitle")
        
        alertController.addAction(UIAlertAction(title: "透過電視代碼連結", style: .default, handler: { (_) in
            // buttonLeft 的處理代碼
        }))
        
        alertController.addAction(UIAlertAction(title: "了解詳情", style: .default, handler: { (_) in
            // buttonMid 的處理代碼
        }))
        
        // 設置選項文字靠左對齊
        for action in alertController.actions {
            action.setValue(NSTextAlignment.left.rawValue, forKey: "titleTextAlignment")
        }
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    private func navigateToNotificationLogViewController() {
        guard let viewController = findViewController() else {
            print("無法找到視圖控制器")
            return
        }
        
        let notificationLogVC = NotificationLogVC()
        notificationLogVC.title = "通知"
        viewController.navigationController?.pushViewController(notificationLogVC, animated: true)
    }
    
    
    
    
    
    private func findViewController() -> UIViewController? {
        // 從當前視圖控制器的 next 開始向上查找
        var nextResponder = self.next
        while let responder = nextResponder {
            // 如果找到 UIViewController 實例，返回它
            if let viewController = responder as? UIViewController {
                return viewController
            }
            // 否則，繼續遍歷下一個響應者
            nextResponder = responder.next
        }
        // 如果沒有找到 UIViewController 實例，返回 nil
        return nil
    }
    
//    func presentSearchViewController() {
//        guard let searchViewController = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") else { return }
//        searchViewController.modalPresentationStyle = .fullScreen
//        present(searchViewController, animated: true, completion: nil)
//    }
//
//    func presentAlertController(title: String?, message: String?) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
//        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
//        present(alertController, animated: true, completion: nil)
//    }
//
//    func navigateToNotificationLogViewController() {
//        guard let notificationLogVC = storyboard?.instantiateViewController(withIdentifier: "NotificationLogVC") as? NotificationLogVC else { return }
//        navigationController?.pushViewController(notificationLogVC, animated: true)
//    }
    
    func setupOtherVideoFrameViews() -> [VideoFrameView] {
        var videoFrameViews: [VideoFrameView] = []
        
        // 先保留第一個框架的 reference
        
        let firstVideoFrameView = VideoFrameView()
        firstVideoFrameView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(firstVideoFrameView)
        videoFrameViews.append(firstVideoFrameView)
        
        if self is HomeVC {
        // 設置第一個框架的約束
        NSLayoutConstraint.activate([
            firstVideoFrameView.topAnchor.constraint(equalTo: singleVideoFrameView.bottomAnchor, constant: 700), // 垂直間距為 20
        ])
            
        } else if self is SubscribeVC {
            NSLayoutConstraint.activate([
                firstVideoFrameView.topAnchor.constraint(equalTo: singleVideoFrameView.bottomAnchor, constant: 400), // 垂直間距為 20
            ])
        }
            NSLayoutConstraint.activate([
            firstVideoFrameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            firstVideoFrameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            firstVideoFrameView.heightAnchor.constraint(equalToConstant: 350)
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
                videoFrameView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20),
                videoFrameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                videoFrameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                videoFrameView.heightAnchor.constraint(equalToConstant: 350)
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
            print("Index out of range or videoFrameView is nil.")
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
            print("Invalid URL string: \(urlString)")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching image: \(error)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to extract image from data.")
                return
            }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
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
                print("Failed to decode JSON: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    func doSearch(withKeywords keywords: [String], maxResults: Int = 5) {
        for keyword in keywords {
            searchYouTube(query: keyword, maxResults: maxResults) { [self] response in
                if let response = response {
                    print("Results for '\(keyword)':")
                    for (i, item) in response.items.enumerated() {
                        showItems.append(keyword)
                        
                        loadDataVideoFrameView(withTitle: item.snippet.title,
                                               thumbnailURL: item.snippet.thumbnails.high.url,
                                               channelTitle: item.snippet.channelTitle,
                                               accountImageURL: item.snippet.thumbnails.high.url,
                                               viewCount: "987654321",
                                               daysSinceUpload: calculateTimeSinceUpload(from: item.snippet.publishedAt),
                                               atIndex: i)
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





