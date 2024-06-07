import UIKit

class ContentTableViewCell: UITableViewCell {
    
    var section: Int = 0 // 保存 section 值的屬性
    var conVideoFrameViews: [ConVideoFrameView] = []
    
    private var scrollView: UIScrollView!
    private var stackView: UIStackView!
    
    // 初始化方法1：在 init(style:reuseIdentifier:) 中呼叫父類的指定初始化方法
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        createConVideoFrameViews(count: 16)
//        configureConVideoFrameViews(count: 16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
        createConVideoFrameViews(count: 16)
//        configureConVideoFrameViews(count: 16)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 重置視圖的狀態，取消異步任務等
    }
    
    private func calculateStackViewWidth() -> CGFloat {
        // 计算 stackView 的宽度
        let totalConVideoFrameViewWidth = 130 * 16 // 16 个 ConVideoFrameView 的总宽度
        let totalSpacingWidth = 5 * (16 - 1) // 16 个 ConVideoFrameView 之间的间距
        let totalPaddingWidth = 10 * 2 // 前后的间距
        let stackViewWidth = totalConVideoFrameViewWidth + totalSpacingWidth + totalPaddingWidth
        return CGFloat(stackViewWidth)
    }
    
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
    func createConVideoFrameViews(count: Int) {
        
        var conVideoFrameViews: [ConVideoFrameView] = []
        for _ in 0..<count {
            let conVideoFrameView = ConVideoFrameView()
            conVideoFrameView.widthAnchor.constraint(equalToConstant: 130).isActive = true
            conVideoFrameView.heightAnchor.constraint(equalToConstant: 160).isActive = true
            conVideoFrameViews.append(conVideoFrameView)
            stackView.addArrangedSubview(conVideoFrameView)
            
            // 在這裡設置 ConVideoFrameView 的預設值
            conVideoFrameView.titleLbl.text = "Custom Title"
            conVideoFrameView.channelId.text = "Custom Channel"
            conVideoFrameView.conVideoImgView.image = UIImage(named: "image2")
        }
        self.conVideoFrameViews = conVideoFrameViews
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
    

}
