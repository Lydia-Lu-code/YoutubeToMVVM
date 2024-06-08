import UIKit

class ContentTableViewCell: UITableViewCell {
    
    var conVideoFrameViews: [ConVideoFrameView] = []
    var viewCount: Int = 16
    
    private var scrollView: UIScrollView!
    private var stackView: UIStackView!
    
    // 初始化方法1：在 init(style:reuseIdentifier:) 中呼叫父類的指定初始化方法
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        createConVideoFrameViews(count: viewCount)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
        createConVideoFrameViews(count: viewCount)
    }
    
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        layoutIfNeeded()
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        // 重置視圖的狀態，取消異步任務等
//    }
    
    private func setupViews() {
        // 初始化 UIScrollView
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(scrollView)
        
        // 初始化 UIStackView
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        scrollView.addSubview(stackView)
        
        // 设置 UIScrollView 的约束
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        // 设置 UIStackView 的约束
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            stackView.widthAnchor.constraint(equalToConstant: calculateStackViewWidth()) // 设置 stackView 的宽度
        ])
    }

    

    // 在 ContentTableViewCell 中添加一個方法，用於創建所需數量的 ConVideoFrameView
    private func createConVideoFrameViews(count: Int) {
        for _ in 0..<count {
            let conVideoFrameView = ConVideoFrameView()
            conVideoFrameView.widthAnchor.constraint(equalToConstant: 130).isActive = true
            conVideoFrameView.heightAnchor.constraint(equalToConstant: 160).isActive = true
            conVideoFrameViews.append(conVideoFrameView)
            stackView.addArrangedSubview(conVideoFrameView)
        }
    }
    
    private func calculateStackViewWidth() -> CGFloat {
        let totalConVideoFrameViewWidth = 130 * viewCount
        let totalSpacingWidth = 5 * (viewCount - 1)
        let totalPaddingWidth = 10 * 2
        return CGFloat(totalConVideoFrameViewWidth + totalSpacingWidth + totalPaddingWidth)
    }
    
    func loadData(with viewModel: ConVideoFrameViewModel) {
        // 设置 ConVideoFrameView 的标题和频道标题
        for conVideoFrameView in conVideoFrameViews {
            conVideoFrameView.titleLbl.text = viewModel.title
            conVideoFrameView.channelId.text = viewModel.channelTitle
        }
        
        // 加载缩略图（假设所有 ConVideoFrameView 共享同一张缩略图）
        if let thumbnailURL = viewModel.thumbnailURL, let image = loadImage(from: thumbnailURL) {
            for conVideoFrameView in conVideoFrameViews {
                conVideoFrameView.conVideoImgView.image = image
            }
        }

    }
    
    private func loadImage(from urlString: String) -> UIImage? {
        guard let url = URL(string: urlString),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
}


//    func configureConVideoFrameViews(with viewModels: [ConVideoFrameViewModel]) {
//        // 根據 viewModels 配置 cell 的內容
//        // 例如，更新標題、頻道標題、縮略圖等
//        // 確保 conVideoFrameViews 陣列已經初始化並足夠大
//        guard conVideoFrameViews.count >= viewModels.count else {
//            return
//        }
//        
//        // 取 viewModels 陣列的前 viewCount 個元素進行處理
//        for (i, viewModel) in viewModels.prefix(viewCount).enumerated() {
//            // 檢查索引是否超出 conVideoFrameViews 陣列的範圍
//            guard i < conVideoFrameViews.count else {
//                break
//            }
//            
//            // 更新 conVideoFrameViews 中對應索引的元素
//            let videoFrameView = conVideoFrameViews[i]
//            DispatchQueue.main.async {
//                videoFrameView.titleLbl.text = viewModel.title
//                videoFrameView.channelId.text = viewModel.channelTitle
//                print("CON videoFrameView.titleLbl.text == \(videoFrameView.titleLbl.text)")
//                print("CON videoFrameView.channelId.text == \(videoFrameView.channelId.text)")
//                // 加載並設置圖片
//                if let url = URL(string: viewModel.thumbnailURL) {
//                    URLSession.shared.dataTask(with: url) { data, _, _ in
//                        if let data = data, let image = UIImage(data: data) {
//                            DispatchQueue.main.async {
//                                videoFrameView.conVideoImgView.image = image
//                            }
//                        }
//                    }.resume()
//                }
//            }
//        }
//    }

    
//    func setImage(from urlString: String, to imageView: UIImageView) {
//        guard let url = URL(string: urlString) else {
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            if error != nil {
//                return
//            }
//            guard let data = data, let image = UIImage(data: data) else {
//                return
//            }
//            DispatchQueue.main.async {
//                imageView.image = image
//            }
//        }.resume()
//    }
    


