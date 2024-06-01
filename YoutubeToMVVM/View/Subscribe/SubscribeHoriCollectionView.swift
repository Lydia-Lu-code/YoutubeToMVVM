import UIKit

struct SubVideoContent {
    let title: String
    let thumbnailURL: String
}

class SubscribeHoriCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var subVideoContents: [SubVideoContent] = []
    var welcome: Welcome?
    static let identifier = "SubscribeHoriCollectionView"
      
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal // 設置水平滾動方向
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal // 設置水平滾動方向
        self.collectionViewLayout = layout
        commonInit()
    }
    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        commonInit()
//    }

    private func commonInit() {
        self.isScrollEnabled = true
        self.delegate = self
        self.dataSource = self
        self.register(ShortsCollectionViewCell.self, forCellWithReuseIdentifier: SubscribeHoriCollectionView.identifier)
//        self.backgroundColor = .darkGray
        print("SUB Common init called")
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = welcome?.items.count ?? subVideoContents.count
        print("SUB Number of items: \(count)")
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubscribeHoriCollectionView.identifier, for: indexPath) as! ShortsCollectionViewCell
        
        print("SUB Configuring cell at index \(indexPath.item)")
        
        if let welcome = welcome {
            let item = welcome.items[indexPath.item]
            cell.titleLabel.text = item.snippet.title
            print("SUB Title: \(item.snippet.title)")
            if let url = URL(string: item.snippet.thumbnails.high.url) {
                cell.setImage(from: url)
            }
        } else {
            let videoContent = subVideoContents[indexPath.item]
            cell.titleLabel.text = videoContent.title
            print("SUB Title: \(videoContent.title)")
            if let url = URL(string: videoContent.thumbnailURL) {
                cell.setImage(from: url)
            }
        }
        
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 30) / 2
        print("SUB Cell size: \(CGSize(width: width, height: 285))")
        return CGSize(width: width, height: 320)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        print("SUB Minimum line spacing for section \(section): 10")
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        print("SUB Insets for section \(section): \(insets)")
        return insets
    }

}
