////
////  SetBarBtnItems.swift
////  YoutubeToMVVM
////
////  Created by Lydia Lu on 2024/6/3.
////
//
//import UIKit
//
//
//protocol BarButtonItemHandler: AnyObject {
//    func handleBarButtonItemTapped(_ item: SetBarBtnItems)
//}
//
//// 將枚舉名稱改為 BarButtonItemType，避免與類名衝突
//enum BarButtonItemType: CaseIterable {
//    case search, notifications, display
//    
//    var systemName: String {
//        switch self {
//        case .search:
//            return "magnifyingglass"
//        case .notifications:
//            return "bell"
//        case .display:
//            return "display.2"
//        }
//    }
//}
//class SetBarBtnItems: UIBarButtonItem {
//
//    
//    
//}
//
//extension SetBarBtnItems {
//    func barButtonItem(target: Any?, action: Selector) -> UIBarButtonItem {
//        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: self.systemName),
//                                            style: .plain,
//                                            target: target,
//                                            action: action)
//        barButtonItem.tag = SetBarBtnItems.allCases.firstIndex(of: self) ?? 0
//        return barButtonItem
//    }
//}
//
//extension BarButtonItemHandler {
//    @objc func handleBarButtonItemTapped(_ sender: UIBarButtonItem) {
//        guard let item = SetBarBtnItems.allCases.first(where: { $0.hashValue == sender.tag }) else { return }
//        handleBarButtonItemTapped(item)
//    }
//}
////    func setBarBtnItems() {
////        let searchBarButtonItem = SetBarBtnItems.search.barButtonItem(target: self)
////        let notificationsBarButtonItem = SetBarBtnItems.notifications.barButtonItem(target: self)
////        let displayBarButtonItem = SetBarBtnItems.display.barButtonItem(target: self)
////
////        navigationItem.rightBarButtonItems = [displayBarButtonItem, notificationsBarButtonItem, searchBarButtonItem]
////    }
//
//    func handleBarButtonItemTapped(_ item: SetBarBtnItems) {
//        switch item {
//        case .search:
//            searchButtonTapped()
//        case .notifications:
//            notificationsButtonTapped()
//        case .display:
//            displayButtonTapped()
//        }
//    }
//
//    func searchButtonTapped() {
//        let searchVC = SearchVC()
//        searchVC.title = navigationItem.searchController?.searchBar.text ?? ""
//        navigationController?.pushViewController(searchVC, animated: true)
//    }
//
//    func notificationsButtonTapped() {
//        let alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: .actionSheet)
//
//        // 設置標題文字左對齊
//        let titleParagraphStyle = NSMutableParagraphStyle()
//        titleParagraphStyle.alignment = .left
//        let titleAttributedString = NSMutableAttributedString(string: "Title", attributes: [NSAttributedString.Key.paragraphStyle: titleParagraphStyle])
//        alertController.setValue(titleAttributedString, forKey: "attributedTitle")
//
//        alertController.addAction(UIAlertAction(title: "透過電視代碼連結", style: .default, handler: { _ in
//            // buttonLeft 的處理代碼
//        }))
//
//        alertController.addAction(UIAlertAction(title: "了解詳情", style: .default, handler: { _ in
//            // buttonMid 的處理代碼
//        }))
//
//        // 設置選項文字靠左對齊
//        for action in alertController.actions {
//            action.setValue(NSTextAlignment.left.rawValue, forKey: "titleTextAlignment")
//        }
//
//        present(alertController, animated: true, completion: nil)
//    }
//
//    func displayButtonTapped() {
//        let notificationLogVC = NotificationLogVC()
//        notificationLogVC.title = "通知"
//        navigationController?.pushViewController(notificationLogVC, animated: true)
//    }
//
//    private func findViewController() -> UIViewController? {
//        // 從當前視圖控制器的 next 開始向上查找
//        var nextResponder = self.next
//        while let responder = nextResponder {
//            // 如果找到 UIViewController 實例，返回它
//            if let viewController = responder as? UIViewController {
//                return viewController
//            }
//            // 否則，繼續遍歷下一個響應者
//            nextResponder = responder.next
//        }
//        // 如果沒有找到 UIViewController 實例，返回 nil
//        return nil
//    }
