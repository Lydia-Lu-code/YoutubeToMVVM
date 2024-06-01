//
//  ContentTopItemView.swift
//  YoutubeViewController
//
//  Created by Lydia Lu on 2024/4/26.
//

import UIKit




class ContentTableViewCell: UITableViewCell {
    
    var section: Int = 0 // 保存 section 值的屬性
    
    // 初始化方法1：在 init(style:reuseIdentifier:) 中呼叫父類的指定初始化方法
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    // 初始化方法3：遵循 NSCoder 協議的初始化方法
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        // 根據 cell 所在的部分設置背景色
        switch section {
        case 0:
            contentView.backgroundColor = .clear
        case 1:
            contentView.backgroundColor = .red // 第一部分的背景色為紅色
        case 2:
            contentView.backgroundColor = .green // 第二部分的背景色為綠色
        default:
            contentView.backgroundColor = .white // 其他部分的背景色為白色
        }
    }

    

}
