////
////  UIBarButtonItem+Extension.swift
////  YoutubeViewController
////
////  Created by Lydia Lu on 2024/5/8.
////
//
//import UIKit
//import Foundation
//
//extension HomeVC {
//    func setupRightBarButtonItems() {
//        // 固定寬度，避免切換模式時位移
////        let fixedWidth = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        fixedWidth.width = 14 // 調整寬度，以適應您的設計
//        
//        let btn1 = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(topButtonTapped))
//        let btn2 = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: self, action: #selector(topButtonTapped))
//        let btn3 = UIBarButtonItem(image: UIImage(systemName: "display.2"), style: .plain, target: self, action: #selector(topButtonTapped))
//        
//        // 将按钮添加到导航栏上
//        self.navigationItem.setRightBarButtonItems([btn1, btn2, btn3], animated: true)
//    }
//    
//    @objc func topButtonTapped(_ sender: UIBarButtonItem) {
//        switch sender {
//        case navigationItem.rightBarButtonItems?[2]: // buttonLeft
//            print("Home Left button tapped")
//            presentAlertController(title: "﻿選取裝置", message: nil)
//        case navigationItem.rightBarButtonItems?[1]: // buttonMid
//            print("Home Middle button tapped")
//            navigateToNotificationLogViewController()
//        case navigationItem.rightBarButtonItems?[0]: // buttonRight
//            print("Home Right button tapped")
//            presentSearchViewController()
//        default:
//            break
//        }
//    }
//    
//    func presentSearchViewController() {
//        guard let viewController = findViewController() else {
//            print("無法找到視圖控制器")
//            return
//        }
//        
//        let searchVC = SearchVC() // 假設 SearchViewController 是您的搜索視圖控制器類
//        searchVC.title = navigationItem.searchController?.searchBar.text ?? "" // 使用搜索框的文本作为标题
//        viewController.navigationController?.pushViewController(searchVC, animated: true)
//    }
//    
//    private func presentAlertController(title: String, message: String?) {
//        guard let viewController = findViewController() else {
//            print("無法找到視圖控制器")
//            return
//        }
//
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
//
//        // 設置標題文字左對齊
//        let titleParagraphStyle = NSMutableParagraphStyle()
//        titleParagraphStyle.alignment = NSTextAlignment.left
//        let titleAttributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.paragraphStyle: titleParagraphStyle])
//        alertController.setValue(titleAttributedString, forKey: "attributedTitle")
//
//        alertController.addAction(UIAlertAction(title: "透過電視代碼連結", style: .default, handler: { (_) in
//            // buttonLeft 的處理代碼
//        }))
//
//        alertController.addAction(UIAlertAction(title: "了解詳情", style: .default, handler: { (_) in
//            // buttonMid 的處理代碼
//        }))
//
//        // 設置選項文字靠左對齊
//        for action in alertController.actions {
//            action.setValue(NSTextAlignment.left.rawValue, forKey: "titleTextAlignment")
//        }
//
//        viewController.present(alertController, animated: true, completion: nil)
//    }
//    private func navigateToNotificationLogViewController() {
//        guard let viewController = findViewController() else {
//            print("無法找到視圖控制器")
//            return
//        }
//        
//        let notificationLogVC = NotificationLogVC()
//        notificationLogVC.title = "通知"
//        viewController.navigationController?.pushViewController(notificationLogVC, animated: true)
//    }
//    
//    private func findViewController() -> UIViewController? {
//        if let viewController = self.next as? UIViewController {
//            return viewController
//        } else {
//            var nextResponder = self.next
//            while let responder = nextResponder {
//                if let viewController = responder as? UIViewController {
//                    return viewController
//                }
//                nextResponder = responder.next
//            }
//        }
//        return nil
//    }
//}
