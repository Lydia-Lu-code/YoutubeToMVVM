import UIKit

protocol ButtonCollectionCellDelegate: AnyObject {
    func didTapButton()
}

class ButtonCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ButtonCollectionViewCell"
    let button = UIButton()
    weak var delegate: ButtonCollectionCellDelegate?
    
    var title: String? {
        didSet {
            button.setTitle(title, for: .normal)
            setNeedsLayout() // 重新布局
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        button.frame = contentView.bounds // 設置按鈕的 frame
        
        // 根據按鈕的文字內容調整按鈕的寬度
        if let title = title {
            let titleSize = (title as NSString).size(withAttributes: [NSAttributedString.Key.font: button.titleLabel!.font!])
            let width = titleSize.width + 20 // 添加一些額外的間距
            button.frame.size.width = width
        }
    }
    
    private func setButton() {
        button.layer.cornerRadius = 15 // 圆角
        button.layer.masksToBounds = true
        
        button.setTitleColor(.white, for: .normal) // 文字颜色
        button.titleLabel?.textAlignment = .center // 文字居中对齐
        
        button.titleLabel?.adjustsFontSizeToFitWidth = true // 文字自适应按钮宽度
        button.titleLabel?.minimumScaleFactor = 1.0
        
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside) // 按钮点击事件
        
        contentView.addSubview(button) // 添加按钮到 contentView 上
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        delegate?.didTapButton()
    }
    
    
    
}





