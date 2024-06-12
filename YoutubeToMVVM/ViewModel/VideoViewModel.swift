import Foundation

enum ViewControllerType: String {
    case home
    case subscribe
    case content
}

protocol SearchAndLoadProtocol {
    func searchAndLoad(withQueries queries: [String], for viewControllerType: ViewControllerType)
}

struct VideoContent {
    let title: String
    let thumbnailURL: String
}

struct SubVideoContent {
    let title: String
    let thumbnailURL: String
}

class ConVideoFrameViewModel {
    let title: String
    let thumbnailURL: String
    let channelTitle: String
    let videoID: String
    
    init(title: String, thumbnailURL: String, channelTitle: String, videoID: String) {
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.channelTitle = channelTitle
        self.videoID = videoID
    }
}

class VideoViewModel: SearchAndLoadProtocol {
    var data: Observable<[ConVideoFrameViewModel]> = Observable([])
    var showItems: [String] = []
    var videoIDs: [String] = []

    var shortsFrameCollectionView: ShortsFrameCollectionView?
    var subscribeHoriCollectionView: SubscribeHoriCollectionView?

    var dataLoadedCallback: (([ConVideoFrameViewModel]) -> Void)?
    
    private var dataTask: URLSessionDataTask?
    
    weak var viewController: BaseViewController?
    
    // 提供取消任務的方法
    func cancelSearch() {
        dataTask?.cancel()
    }
    
    // 在視圖控制器被釋放時調用取消任務的方法
    deinit {
        cancelSearch()
    }

    func searchYouTube(query: String, maxResults: Int, completion: @escaping (Welcome?) -> Void) {
        let apiKey = "AIzaSyDC2moKhNm_ElfyiKoQeXKftoLHYzsWwWY"
        let baseURL = "https://www.googleapis.com/youtube/v3/search"
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "maxResults", value: "\(maxResults)"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        let url = components.url!
        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(String(describing: error))")
                completion(nil)
                return
            }
            
            do {
                let searchResponse = try JSONDecoder().decode(Welcome.self, from: data)
                completion(searchResponse)
            } catch {
                completion(nil)
            }
        }
        dataTask?.resume()
    }
    
    func searchAndLoad(withQueries queries: [String], for viewControllerType: ViewControllerType) {
        let maxResults = viewControllerType == .home ? 4 : 18
        
        for query in queries {
            searchYouTube(query: query, maxResults: maxResults) { [weak self] response in
                guard let self = self else { return }
                
                if let welcomeResponse = response {
                    DispatchQueue.main.async {
                        switch viewControllerType {
                        case .home:
                            self.handleHomeSearchResult(welcomeResponse)
                        case .subscribe:
                            self.handleSubscribeSearchResult(welcomeResponse, collectionView: self.subscribeHoriCollectionView)
                        case .content:
                            // contentVC 的處理方式略有不同，所以不在這裡實現
                            print("VideoViewModel == .content")
                            break
                        }
                    }
                } else {
                    print("無法為查詢 \(query) 檢索到結果")
                }
                
                print("正在處理查詢: \(query)")
            }
        }
    }
    
    private func handleHomeSearchResult(_ response: Welcome) {
        guard let collectionView = shortsFrameCollectionView else { return }
        collectionView.videoContents.removeAll()
        collectionView.welcome = response
        
        for item in response.items {
            let title = item.snippet.title
            let image = item.snippet.thumbnails.high.url
            let videoContent = VideoContent(title: title, thumbnailURL: image)
            collectionView.videoContents.append(videoContent)

        }
        
        collectionView.reloadData()
    }
    
    private func handleSubscribeSearchResult(_ response: Welcome, collectionView: SubscribeHoriCollectionView?) {
        guard let collectionView = collectionView else { return }
        collectionView.subVideoContents.removeAll()
        collectionView.welcome = response
        
        for item in response.items {
            let title = item.snippet.title
            let image = item.snippet.thumbnails.high.url
            let videoContent = SubVideoContent(title: title, thumbnailURL: image)
            collectionView.subVideoContents.append(videoContent)
        }
        
        collectionView.reloadData()
    }
}

extension VideoViewModel {
    func loadFiveVideos(for viewControllerType: ViewControllerType) {
        let query = "New Jeans" // Define your search query here
        let maxResults = 5
        
        searchYouTube(query: query, maxResults: maxResults) { [weak self] response in
            guard let self = self else { return }
            
            if let welcomeResponse = response {
                DispatchQueue.main.async {
                    self.handleFiveVideoResult(welcomeResponse, for: viewControllerType)
                }
            } else {
                print("Failed to retrieve results for query \(query)")
            }
        }
    }
    
    private func handleFiveVideoResult(_ response: Welcome, for viewControllerType: ViewControllerType) {
        guard let viewController = self.viewController else { return }
        
        var videoModels: [ConVideoFrameViewModel] = []
        
        for item in response.items.prefix(5) { // Get only the first five items
            let title = item.snippet.title
            let thumbnailURL = item.snippet.thumbnails.high.url
            let channelTitle = item.snippet.channelTitle
            let videoID = item.id.videoID
            
            let videoModel = ConVideoFrameViewModel(title: title, thumbnailURL: thumbnailURL, channelTitle: channelTitle, videoID: videoID)
            videoModels.append(videoModel)
        }
        
        viewController.videoViewModel.data.value = videoModels
        viewController.videoViewModel.dataLoadedCallback?(videoModels)
    }
}
