//
//  ConVideoFrameView.swift
//  YoutubeToMVVM
//
//  Created by Lydia Lu on 2024/6/3.
//

import UIKit

class ConVideoFrameView: UIView {

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setConVideoFrameViewLayout()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var conVideoImgView : UIImageView = {
        let vidView = UIImageView()
        vidView.translatesAutoresizingMaskIntoConstraints = false
        vidView.backgroundColor = .lightGray
        vidView.contentMode = .scaleAspectFill // 將圖片的 contentMode 設置為 .scaleAspectFill，使圖片自動拉伸以填滿視圖
        vidView.clipsToBounds = true // 剪切超出視圖範圍的部分
        return vidView
    }()

    var titleLbl : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints  = false
        //        lbl.backgroundColor = .orange
        lbl.text = "Title﻿ Title﻿ Title﻿ Title﻿ Title﻿ Title﻿ Title﻿ Title﻿ Title﻿ Title﻿ Title﻿ " // 這裡設定了一個範例文字
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.numberOfLines = 2 // 兩行文字
        return lbl
    }()
    
    var contentLbl : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints  = false
        lbl.font = UIFont.systemFont(ofSize: 10)
        lbl.text = "Other" // 這裡設定了一個範例文字
        lbl.numberOfLines = 2 // 兩行文字
        return lbl
    }()
    
    var buttonRight : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints  = false
        btn.backgroundColor = .clear
        btn.setImage(UIImage(systemName: "ellipsis"), for: .normal) // 使用三個點符號作為示意圖
        btn.tintColor = .lightGray // 設定符號顏色
        
        return btn
    }()
    
    
    
    lazy var conVideoFrameView : UIView = {
        let vidFrameView = UIView()
        vidFrameView.translatesAutoresizingMaskIntoConstraints = false
        vidFrameView.addSubview(conVideoImgView)
        vidFrameView.addSubview(titleLbl)
        vidFrameView.addSubview(contentLbl)
        vidFrameView.addSubview(buttonRight)
        return vidFrameView
    }()
   
    private func setConVideoFrameViewLayout() {
        
        // 添加 imageView 到 VideoFrameView 中
        self.addSubview(conVideoFrameView)
        
        // 設置 videoView 的約束
        NSLayoutConstraint.activate([
            // 设置 conVideoFrameView 的高度和宽度为 160
            conVideoFrameView.heightAnchor.constraint(equalToConstant: 150),
            conVideoFrameView.widthAnchor.constraint(equalToConstant: 130),
            
            // 将 conVideoFrameView 垂直和水平居中于父视图
            conVideoFrameView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            conVideoFrameView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            buttonRight.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            buttonRight.topAnchor.constraint(equalTo: conVideoImgView.bottomAnchor, constant: 8), // buttonRight 的 topAnchor 設置為 videoView 的 bottomAnchor，間距為 8 個點
            
            buttonRight.heightAnchor.constraint(equalToConstant: 40), // imageView 的高度設置為 60
            buttonRight.widthAnchor.constraint(equalToConstant: 40) // imageView 的寬度設置為 60
        ])
        
        // 添加其他子视图的约束，例如 conVideoImgView、titleLbl、contentLbl、buttonRight 的约束
        NSLayoutConstraint.activate([
            // labelMidTitle 的约束
            
            
            conVideoImgView.topAnchor.constraint(equalTo: conVideoFrameView.topAnchor),
            conVideoImgView.leadingAnchor.constraint(equalTo: conVideoFrameView.leadingAnchor),
            conVideoImgView.trailingAnchor.constraint(equalTo: conVideoFrameView.trailingAnchor),
            conVideoImgView.heightAnchor.constraint(equalToConstant: 75),
            
            titleLbl.topAnchor.constraint(equalTo: conVideoImgView.bottomAnchor),
            titleLbl.leadingAnchor.constraint(equalTo: conVideoImgView.leadingAnchor),
            titleLbl.trailingAnchor.constraint(equalTo: conVideoImgView.trailingAnchor),
            titleLbl.heightAnchor.constraint(equalToConstant: 50),
            
            contentLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor),
            contentLbl.leadingAnchor.constraint(equalTo: conVideoImgView.leadingAnchor),
            contentLbl.trailingAnchor.constraint(equalTo: conVideoImgView.trailingAnchor),
            contentLbl.bottomAnchor.constraint(equalTo: conVideoFrameView.bottomAnchor)
            
        ])
    }

    
}
