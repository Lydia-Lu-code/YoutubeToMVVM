//import Foundation
//import UIKit
//
//protocol SetBarBtnItems: NSObjectProtocol {
//    func setupBarButtonItems()
//    func searchButtonTapped()
//    func notificationsButtonTapped()
//    func displayButtonTapped()
//}
//
//
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
//
//
//extension SetBarBtnItems where Self: UIViewController {
//    
//    func setupBarButtonItems() {
//        let searchButton = UIBarButtonItem(
//            image: UIImage(systemName: BarButtonItemType.search.systemName),
//            style: .plain,
//            target: nil,
//            action: nil
//        )
//        searchButton.action = #selector(handleSearchButtonTap)
//        
//        let notificationsButton = UIBarButtonItem(
//            image: UIImage(systemName: BarButtonItemType.notifications.systemName),
//            style: .plain,
//            target: nil,
//            action: nil
//        )
//        notificationsButton.action = #selector(handleNotificationsButtonTap)
//        
//        let displayButton = UIBarButtonItem(
//            image: UIImage(systemName: BarButtonItemType.display.systemName),
//            style: .plain,
//            target: nil,
//            action: nil
//        )
//        displayButton.action = #selector(handleDisplayButtonTap)
//        
//        navigationItem.rightBarButtonItems = [searchButton, notificationsButton, displayButton]
//    }
//    
//    @objc private func handleSearchButtonTap() {
//        searchButtonTapped()
//    }
//    
//    @objc private func handleNotificationsButtonTap() {
//        notificationsButtonTapped()
//    }
//    
//    @objc private func handleDisplayButtonTap() {
//        displayButtonTapped()
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
//}
//
//
//
//
