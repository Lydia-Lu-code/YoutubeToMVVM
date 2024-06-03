import UIKit

class ContentTableViewCell: UITableViewCell {
    
    var section: Int = 0 // 保存 section 值的屬性
    
    private var scrollView: UIScrollView!
    private var stackView: UIStackView!
    
    // 初始化方法1：在 init(style:reuseIdentifier:) 中呼叫父類的指定初始化方法
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func calculateStackViewWidth() -> CGFloat {
        // 计算 stackView 的宽度
        let totalConVideoFrameViewWidth = 130 * 16 // 16 个 ConVideoFrameView 的总宽度
        let totalSpacingWidth = 10 * (16 - 1) // 16 个 ConVideoFrameView 之间的间距
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
    
    func configureConVideoFrameViews(count: Int) {
        // 清空之前的子视图
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 添加新的 ConVideoFrameView
        for _ in 0..<count {
            let conVideoFrameView = ConVideoFrameView()
            conVideoFrameView.widthAnchor.constraint(equalToConstant: 130).isActive = true
            conVideoFrameView.heightAnchor.constraint(equalToConstant: 160).isActive = true
            stackView.addArrangedSubview(conVideoFrameView)
        }
        
        // 强制更新布局
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 在布局子视图时调用 layoutIfNeeded 来确保所有约束都生效
        layoutIfNeeded()
    }

//    func setViews() {
//        // 根據 cell 所在的部分設置背景色
//        switch section {
//        case 0:
//            contentView.backgroundColor = .clear
//        case 1:
//            contentView.backgroundColor = .red // 第一部分的背景色為紅色
//        case 2:
//            contentView.backgroundColor = .green // 第二部分的背景色為綠色
//        default:
//            contentView.backgroundColor = .white // 其他部分的背景色為白色
//        }
//    }
}

