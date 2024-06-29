import UIKit

class PlayerTableViewCell: UITableViewCell {
    
    let customLabel = UILabel()
    let button1 = UIButton(type: .system)
    let button2 = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // Configure label
        customLabel.numberOfLines = 0
        customLabel.textAlignment = .left
        customLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure buttons
        button1.setTitle("Button 1", for: .normal)
        button1.translatesAutoresizingMaskIntoConstraints = false
        button2.setTitle("Button 2", for: .normal)
        button2.translatesAutoresizingMaskIntoConstraints = false
        
        // Add label and buttons to contentView
        contentView.addSubview(customLabel)
        contentView.addSubview(button1)
        contentView.addSubview(button2)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            customLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            customLabel.trailingAnchor.constraint(equalTo: button1.leadingAnchor, constant: -16),
            customLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            button1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button1.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            button2.trailingAnchor.constraint(equalTo: button1.leadingAnchor, constant: -8),
            button2.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}


////
////  PlayerTableViewCell.swift
////  YoutubeToMVVM
////
////  Created by Lydia Lu on 2024/6/26.
////
//
//import UIKit
//
//class PlayerTableViewCell: UITableViewCell {
//
//    let customLabel = UILabel()
//    let button1 = UIButton(type: .system)
//    let button2 = UIButton(type: .system)
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupViews()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupViews()
//    }
//    
//    private func setupViews() {
//        // 設置標籤屬性
//        customLabel.numberOfLines = 0
//        customLabel.textAlignment = .left
//        customLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        // 設置按鈕屬性
//        button1.setTitle("按鈕1", for: .normal)
//        button1.translatesAutoresizingMaskIntoConstraints = false
//        button2.setTitle("按鈕2", for: .normal)
//        button2.translatesAutoresizingMaskIntoConstraints = false
//        
//        // 添加標籤和按鈕到內容視圖
//        contentView.addSubview(customLabel)
//        contentView.addSubview(button1)
//        contentView.addSubview(button2)
//        
//        // 設置標籤和按鈕的自動佈局
//        NSLayoutConstraint.activate([
//            customLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//             customLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
//             customLabel.trailingAnchor.constraint(equalTo: button1.leadingAnchor, constant: -16),
//             customLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
//
//            
//            button1.trailingAnchor.constraint(equalTo: button2.leadingAnchor, constant: -8),
//            button1.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            
//            button2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            button2.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
//        ])
//    }
//}