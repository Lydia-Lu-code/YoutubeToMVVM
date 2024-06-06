import UIKit
import Foundation

enum SetBarBtnItems: CaseIterable {
    case search
    case notifications
    case display

    var systemName: String {
        switch self {
        case .search:
            return "magnifyingglass"
        case .notifications:
            return "bell"
        case .display:
            return "display"
        }
    }
}

protocol BarButtonItemsDelegate: AnyObject {
    func setBarBtnItems()
    func topButtonTapped(_ sender: UIBarButtonItem)
    func presentSearchViewController()
    func presentAlertController(title: String, message: String?)
    func navigateToNotificationLogViewController()
}

class BarButtonItemsModel: BarButtonItemsDelegate {
    weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func setBarBtnItems() {
        var barButtonItems: [UIBarButtonItem] = []
        for (index, item) in SetBarBtnItems.allCases.enumerated() {
            let barButtonItem = UIBarButtonItem(image: UIImage(systemName: item.systemName),
                                                style: .plain,
                                                target: self,
                                                action: #selector(topButtonTapped(_:)))
            barButtonItem.tag = index
            barButtonItems.append(barButtonItem)
        }
        viewController?.navigationItem.setRightBarButtonItems(barButtonItems, animated: true)
    }

    @objc func topButtonTapped(_ sender: UIBarButtonItem) {
        guard let itemType = SetBarBtnItems.allCases[safe: sender.tag] else { return }
        switch itemType {
        case .search:
            presentSearchViewController()
        case .notifications:
            navigateToNotificationLogViewController()
        case .display:
            presentAlertController(title: "選取裝置", message: nil)
        }
    }

    func presentSearchViewController() {
        guard let viewController = viewController else { return }
        let searchVC = SearchVC() // 假設 SearchViewController 是您的搜索視圖控制器類
        searchVC.title = viewController.navigationItem.searchController?.searchBar.text ?? "" // 使用搜索框的文本作为标题
        viewController.navigationController?.pushViewController(searchVC, animated: true)
    }

    func presentAlertController(title: String, message: String?) {
        guard let viewController = viewController else { return }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        // 設置標題文字左對齊
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = NSTextAlignment.left
        let titleAttributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.paragraphStyle: titleParagraphStyle])
        alertController.setValue(titleAttributedString, forKey: "attributedTitle")
        
        alertController.addAction(UIAlertAction(title: "透過電視代碼連結", style: .default, handler: { (_) in
            // buttonLeft 的處理代碼
        }))
        
        alertController.addAction(UIAlertAction(title: "了解詳情", style: .default, handler: { (_) in
            // buttonMid 的處理代碼
        }))
        
        // 設置選項文字靠左對齊
        for action in alertController.actions {
            action.setValue(NSTextAlignment.left.rawValue, forKey: "titleTextAlignment")
        }
        
        viewController.present(alertController, animated: true, completion: nil)
    }

    func navigateToNotificationLogViewController() {
        guard let viewController = viewController else { return }
        let notificationLogVC = NotificationLogVC()
        notificationLogVC.title = "通知"
        viewController.navigationController?.pushViewController(notificationLogVC, animated: true)
    }
}
