//import UIKit
//
//class TableHeaderView: UIView {
//    
//    let titleLbl: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = UIFont.boldSystemFont(ofSize: 18)
//        label.textColor = .black
//        return label
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//    
//    private func setupView() {
//        addSubview(titleLbl)
//        NSLayoutConstraint.activate([
//            titleLbl.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
//            titleLbl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
//            titleLbl.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
//            titleLbl.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
//        ])
//    }
//}
