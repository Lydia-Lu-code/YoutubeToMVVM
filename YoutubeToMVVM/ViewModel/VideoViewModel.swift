import Foundation
import UIKit

enum ViewControllerType: String {
    case home
    case subscribe
    case content
    case shorts
}

protocol SearchAndLoadProtocol {
    func searchYouTube<T: Decodable>(query: String, maxResults: Int, responseType: T.Type, completion: @escaping (T?, [String]?) -> Void)
}

class VideoModel: Decodable {
    var title: String
    var thumbnailURL: String
    var channelTitle: String
    var videoID: String
    var viewCount: String?
    var daysSinceUpload: String?
    var accountImageURL: String
    
    init(videoID: String, title: String, viewCount: String?, daysSinceUpload: String?, channelTitle: String) {
        self.videoID = videoID
        self.title = title
        self.viewCount = viewCount
        self.daysSinceUpload = daysSinceUpload
        self.channelTitle = channelTitle
        self.thumbnailURL = "" // 設置默認值
        self.accountImageURL = "" // 設置默認值
    }
    
    init(title: String, thumbnailURL: String, channelTitle: String, videoID: String, viewCount: String?, daysSinceUpload: String?, accountImageURL: String) {
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.channelTitle = channelTitle
        self.videoID = videoID
        self.viewCount = viewCount
        self.daysSinceUpload = daysSinceUpload
        self.accountImageURL = accountImageURL
    }
    
    init(title: String, thumbnailURL: String, channelTitle: String, videoID: String, accountImageURL: String) {
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.channelTitle = channelTitle
        self.videoID = videoID
        self.accountImageURL = accountImageURL
    }
}

class VideoViewModel: SearchAndLoadProtocol {
    var data: Observable<[VideoModel]> = Observable([])
    var dataLoadedCallback: (([VideoModel]) -> Void)?
    
    private var dataTask: URLSessionDataTask?
    weak var viewController: BaseViewController?
    weak var contentTableView: ContentTableViewController?
    weak var shortsTableView: ShortsTableViewController?
    
    var itemCount: Int = 0

    var shortsData: [VideoModel] = []
    
    

    func cancelSearch() {
        dataTask?.cancel()
    }
    
    deinit {
        cancelSearch()
    }
    
    func fetchComments(for videoId: String) {
        let apiKey = "AIzaSyDC2moKhNm_ElfyiKoQeXKftoLHYzsWwWY"
        let baseURL = "https://www.googleapis.com/youtube/v3/commentThreads"
        
        var components = URLComponents(string: baseURL)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "videoId", value: videoId),
            URLQueryItem(name: "key", value: apiKey)
        ]
        components.queryItems = queryItems
        
        guard let url = components.url else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching comments: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data returned")
                return
            }
            
            do {
                // Assuming response is in JSON format
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("JSON Response: \(json)")
                // Handle parsing of JSON response to extract comments
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        
        task.resume()
    }

    func searchYouTube<T: Decodable>(query: String, maxResults: Int, responseType: T.Type, completion: @escaping (T?, [String]?) -> Void) {
        let apiKey = "AIzaSyDC2moKhNm_ElfyiKoQeXKftoLHYzsWwWY"
        let baseURL = "https://www.googleapis.com/youtube/v3/search"
        
        var components = URLComponents(string: baseURL)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "maxResults", value: "\(maxResults)"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        components.queryItems = queryItems
        
        guard let url = components.url else {
            print("VVM Invalid URL")
            completion(nil, nil)
            return
        }
        
        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("VVM Error: \(String(describing: error))")
                completion(nil, nil)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                
                var videoIDs: [String] = []
                if let searchResponse = decodedResponse as? SearchResponse {
                    videoIDs = searchResponse.items.map { $0.id.videoID }
                }
                
                completion(decodedResponse, videoIDs)
            } catch {
                print("VVM JSON decoding error: \(error)")
                completion(nil, nil)
            }
        }
        dataTask?.resume()
    }
    
    func loadShortsCell(withQuery query: String, for viewControllerType: ViewControllerType) {
        var maxResults = 0
        switch viewControllerType {
        case .home:
            maxResults = 4
        case .subscribe:
            maxResults = 18
        case .content:
            maxResults = 16
        case .shorts:
            maxResults = 8
        }
        
        searchYouTube(query: query, maxResults: maxResults, responseType: SearchResponse.self) { [weak self] (searchResponse, videoIDs) in
            guard let self = self else { return }

            if let searchResponse = searchResponse {
                DispatchQueue.main.async {
                    self.handleSearchResponse(searchResponse, for: viewControllerType)
                }
                print("VVM videoIDs == \(videoIDs)")
            } else {
                print("VVM 無法為查詢 \(query) 檢索到結果")
            }
        }
    }
    
    func getShortsData() -> [VideoModel]? {
        return shortsData
    }
    
    func getVideoID(at index: Int) -> String? {
        return shortsData[safe: index]?.videoID
    }
    
    private func fetchVideoDetails(for ids: [String], maxResults: Int, for viewControllerType: ViewControllerType) {
        let idsString = ids.joined(separator: ",")
        let apiKey = "AIzaSyDC2moKhNm_ElfyiKoQeXKftoLHYzsWwWY"
        let baseURL = "https://www.googleapis.com/youtube/v3/videos"
        
        var components = URLComponents(string: baseURL)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "part", value: "snippet,contentDetails,statistics"),
            URLQueryItem(name: "id", value: idsString),
            URLQueryItem(name: "key", value: apiKey)
        ]
        components.queryItems = queryItems
        
        guard let url = components.url else {
            print("VVM Invalid URL")
            return
        }
        
        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("VVM Error: \(String(describing: error))")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(VideosResponse.self, from: data)
                DispatchQueue.main.async {
                    self.handleVideosResponse(decodedResponse, for: viewControllerType)
                }
            } catch {
                print("VVM JSON decoding error: \(error)")
            }
        }
        dataTask?.resume()
    }
    
    func loadVideoView(withQuery query: String, for viewControllerType: ViewControllerType) {
        let maxResults = (viewControllerType == .home || viewControllerType == .subscribe) ? 5 : 0
        
        searchYouTube(query: query, maxResults: maxResults, responseType: SearchResponse.self) { [weak self] (searchResponse, videoIDs) in
            guard let self = self else { return }
            
            if let videoIDs = videoIDs {
                print("VVM loadVideoView Video IDs: \(videoIDs)") // Add this line to print the video IDs
                self.fetchVideoDetails(for: videoIDs, maxResults: maxResults, for: viewControllerType)
            } else {
                print("VVM loadVideoView無法為查詢 \(query) 檢索到結果")
            }
        }
    }
    
    private func handleSearchResponse(_ response: SearchResponse, for viewControllerType: ViewControllerType) {
        switch viewControllerType {
        case .home:
            handleCollectionViewResult(response, viewControllerType: .home, collectionView: viewController?.shortsFrameCollectionView)
            print("VVM Search .home")
        case .subscribe:
            handleCollectionViewResult(response, viewControllerType: .subscribe, collectionView: viewController?.subscribeHoriCollectionView)
            print("VVM Search .subscribe")
        case .content:
            handleContentSearchResult(response)
        case .shorts:
            handleContentSearchResult(response)
            print("VVM Search .shorts")
        }
    }
    
    private func handleContentSearchResult(_ response: SearchResponse) {
        var videoModels: [VideoModel] = []
        
        for item in response.items {
            let title = item.snippet.title
            let thumbnailURL = item.snippet.thumbnails.high.url
            let channelTitle = item.snippet.channelTitle
            let videoID = item.id.videoID
            let accountImageURL = item.snippet.thumbnails.high.url
            
            let videoModel = VideoModel(title: title, thumbnailURL: thumbnailURL, channelTitle: channelTitle, videoID: videoID, accountImageURL: accountImageURL)
            videoModels.append(videoModel)
        }
        
        data.value = videoModels
        dataLoadedCallback?(videoModels)
    }
    
    private func handleCollectionViewResult(_ response: SearchResponse, viewControllerType: ViewControllerType, collectionView: UICollectionView?) {
        guard let collectionView = collectionView else { return }
        collectionView.reloadData()
        
        var videoContents: [VideoModel] = []
        
        for item in response.items {
            let title = item.snippet.title
            let thumbnailURL = item.snippet.thumbnails.high.url
            let channelTitle = item.snippet.channelTitle
            let videoID = item.id.videoID
            let accountImageURL = item.snippet.thumbnails.thumbnailsDefault.url
            
            let videoContent = VideoModel(title: title, thumbnailURL: thumbnailURL, channelTitle: channelTitle, videoID: videoID, accountImageURL: accountImageURL)
            videoContents.append(videoContent)
        }
        
        if let shortsCollectionView = collectionView as? ShortsFrameCollectionView {
            shortsCollectionView.videoContents = videoContents
        } else if let subscribeCollectionView = collectionView as? SubscribeHoriCollectionView {
            subscribeCollectionView.subVideoContents = videoContents
        }
    }
    
    private func handleVideosResponse(_ response: VideosResponse, for viewControllerType: ViewControllerType) {
        guard let viewController = self.viewController else {
            return
        }
        
        let maxResults = (viewControllerType == .home || viewControllerType == .subscribe) ? 5 : 0
        var videoModels: [VideoModel] = []
        
        for item in response.items.prefix(maxResults) {
            let title = item.snippet.title
            let thumbnailURL = item.snippet.thumbnails.high.url
            let channelTitle = item.snippet.channelTitle
            let videoID = item.id
            let viewCount = item.statistics?.viewCount
            let daysSinceUpload = item.snippet.publishedAt
            let accountImageURL = item.snippet.thumbnails.thumbnailsDefault.url
            
            let videoModel = VideoModel(title: title, thumbnailURL: thumbnailURL, channelTitle: channelTitle, videoID: videoID, viewCount: viewCount, daysSinceUpload: daysSinceUpload, accountImageURL: accountImageURL)
            videoModels.append(videoModel)
        }
        
        viewController.videoViewModel.data.value = videoModels
        viewController.videoViewModel.dataLoadedCallback?(videoModels)
    }

}

class APIService {
    
    func getDataForVideoID(_ videoID: String, completion: @escaping (VideoModel?) -> Void) {
        let apiKey = "AIzaSyDC2moKhNm_ElfyiKoQeXKftoLHYzsWwWY" // 替換為你的實際 API 金鑰
        let baseURL = "https://www.googleapis.com/youtube/v3/videos"
        
        var components = URLComponents(string: baseURL)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "part", value: "snippet,statistics"),
            URLQueryItem(name: "id", value: videoID),
            URLQueryItem(name: "key", value: apiKey)
        ]
        components.queryItems = queryItems
        
        guard let url = components.url else {
            print("無效的 URL")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("API 獲取數據時出錯: \(String(describing: error))")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let items = json["items"] as? [[String: Any]],
                   let firstItem = items.first {
                    let id = videoID
                    let snippet = firstItem["snippet"] as? [String: Any] ?? [:]
                    let statistics = firstItem["statistics"] as? [String: Any] ?? [:]
                    
                    let title = snippet["title"] as? String ?? "無標題"
                    let channelTitle = snippet["channelTitle"] as? String ?? "未知頻道"
                    let publishedAt = snippet["publishedAt"] as? String ?? "未知日期"
                    let viewCount = statistics["viewCount"] as? String ?? "觀看次數未知"
                    let thumbnailURL = (snippet["thumbnails"] as? [String: Any])?["high"] as? String ?? ""
                    let accountImageURL = thumbnailURL
                    
                    let videoModel = VideoModel(title: title, thumbnailURL: thumbnailURL, channelTitle: channelTitle, videoID: id, viewCount: viewCount, daysSinceUpload: publishedAt, accountImageURL: accountImageURL)
                    
                    completion(videoModel)
                } else {
                    print("無法解析 JSON")
                    completion(nil)
                }
            } catch {
                print("JSON 解析錯誤: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
    }

}

