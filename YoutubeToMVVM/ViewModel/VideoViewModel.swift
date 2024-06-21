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

class VideoModel {
    var title: String
    var thumbnailURL: String
    var channelTitle: String
    var videoID: String
    var viewCount: String? // 假設的觀看次數，可以從其他資料源獲取
    var daysSinceUpload: String? // 假設的上傳時間，可以從其他資料源獲取
    var accountImageURL: String // 新增這個屬性
    
    init(title: String, thumbnailURL: String, channelTitle: String, videoID: String, viewCount: String?, daysSinceUpload: String?, accountImageURL: String) {
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.channelTitle = channelTitle
        self.videoID = videoID
        self.viewCount = viewCount
        self.daysSinceUpload = daysSinceUpload
        self.accountImageURL = accountImageURL // 初始化該屬性
    }
    
    init(title: String, thumbnailURL: String, channelTitle: String, videoID: String, accountImageURL: String) {
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.channelTitle = channelTitle
        self.videoID = videoID
        self.accountImageURL = accountImageURL // 初始化該屬性
    }
}


class VideoViewModel: SearchAndLoadProtocol {
    
    var data: Observable<[VideoModel]> = Observable([])
    var dataLoadedCallback: (([VideoModel]) -> Void)?
    
    private var dataTask: URLSessionDataTask?
    weak var viewController: BaseViewController?
    
    
    func cancelSearch() {
        dataTask?.cancel()
    }
    
    deinit {
        cancelSearch()
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
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("VVM Error: \(String(describing: error))")
                completion(nil, nil)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                
                // Extract video IDs
                var videoIDs: [String] = []
                if let searchResponse = decodedResponse as? SearchResponse {
                    videoIDs = searchResponse.items.map { $0.id.videoID }
                    print("VVM searchYoutube videoIDs == \(videoIDs)")
                }
                
                completion(decodedResponse, videoIDs)
            } catch {
                print("VVM JSON decoding error: \(error)")
                completion(nil, nil)
            }
        }.resume()
    }

    
    func loadShortsCell﻿(withQuery query: String, for viewControllerType: ViewControllerType) {
//        let maxResults = viewControllerType == .home ? 4 : 18
        
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
            } else {
                print("VVM 無法為查詢 \(query) 檢索到結果")
            }

            print("VVM 正在處理查詢: \(query)")
        }
    }

    private func fetchVideoDetails(for ids: [String], maxResults: Int, for viewControllerType: ViewControllerType) {
        let idsString = ids.joined(separator: ",")
        let apiKey = "AIzaSyDC2moKhNm_ElfyiKoQeXKftoLHYzsWwWY"  // 替換成你的 YouTube API 金鑰
        let baseURL = "https://www.googleapis.com/youtube/v3/videos"
        
        var components = URLComponents(string: baseURL)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "part", value: "snippet,contentDetails,statistics"),
            URLQueryItem(name: "id", value: idsString),
            URLQueryItem(name: "key", value: apiKey)
        ]
        components.queryItems = queryItems
        
        guard let url = components.url else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(String(describing: error))")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(VideosResponse.self, from: data)
                DispatchQueue.main.async {
                    print("VVM fetchVideoDetails 收到的 VideosResponse: \(decodedResponse)")
                    self.handleVideosResponse(decodedResponse, for: viewControllerType)
                    print("VVM fetchVideoDetails")
                }
            } catch {
                print("JSON decoding error: \(error)")
            }
        }.resume()
    }

    
//    private func fetchVideoDetails(for ids: [String], maxResults: Int, for viewControllerType: ViewControllerType) {
//        let idsString = ids.joined(separator: ",")
//        searchYouTube(query: idsString, maxResults: maxResults, responseType: VideosResponse.self) { [weak self] response, _ in
//            guard let self = self else { return }
//            if let videosResponse = response {
//                DispatchQueue.main.async {
//                    print("VVM fetchVideoDetails 收到的 VideosResponse: \(videosResponse)")
//                    self.handleVideosResponse(videosResponse, for: viewControllerType)
//                    print("VVM fetchVideoDetails")
//                }
//            } else {
//                print("VVM 無法檢索到 \(idsString) 的結果")
//            }
//        }
//    }

    
    func loadVideoView(withQuery query: String, for viewControllerType: ViewControllerType) {
        var maxResults = 0
        
        if viewControllerType == .home || viewControllerType == .subscribe {
            maxResults = 5
//            print("VVM loadVideoView maxResults == \(maxResults)")
            
            searchYouTube(query: query, maxResults: maxResults, responseType: SearchResponse.self) { [weak self] (searchResponse, videoIDs) in
//                print("VVM videosYoutube videoIDs1 == \(videoIDs ?? [])")
                guard let self = self else { return }
//                print("VVM videosYoutube videoIDs2 == \(videoIDs ?? [])")
                
                if let videoIDs = videoIDs {
                    self.fetchVideoDetails(for: videoIDs, maxResults: maxResults, for: viewControllerType)
                } else {
                    print("VVM loadVideoView無法為查詢 \(query) 檢索到結果")
                }
                
                print("VVM loadVideoView正在處理查詢: \(query)")
            }
        }
    }
    
    private func handleSearchResponse(_ response: SearchResponse, for viewControllerType: ViewControllerType) {
        switch viewControllerType {
        case .home:
            handleCollectionViewResult(response, viewControllerType: .home, collectionView: viewController?.shortsFrameCollectionView)
            print("VVM .home")
        case .subscribe:
            handleCollectionViewResult(response, viewControllerType: .subscribe, collectionView: viewController?.subscribeHoriCollectionView)
            print("VVM .subscribe")
        case .content:
            handleContentSearchResult(response)
            print("VVM .content")
        case .shorts:
            print("VVM .shorts")
        }
    }

    private func handleContentSearchResult(_ response: SearchResponse) {
        var videoModels: [VideoModel] = []
        
        for item in response.items {
            let title = item.snippet.title
            let thumbnailURL = item.snippet.thumbnails.high.url
            let channelTitle = item.snippet.channelTitle
            let videoID = item.id.videoID
            let accountImageURL = item.snippet.thumbnails.thumbnailsDefault.url
            
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
        
        if viewControllerType == .home {
            handleCollectionViewResultHelper(videoContents, collectionView: collectionView)
        } else if viewControllerType == .subscribe {
            handleCollectionViewResultHelper(videoContents, collectionView: collectionView)
        }
    }

    private func handleCollectionViewResultHelper(_ videoContents: [VideoModel], collectionView: UICollectionView) {
        if let shortsCollectionView = collectionView as? ShortsFrameCollectionView {
            shortsCollectionView.videoContents = videoContents
        } else if let subscribeCollectionView = collectionView as? SubscribeHoriCollectionView {
            subscribeCollectionView.subVideoContents = videoContents
        }
        collectionView.reloadData()
    }
    
    private func handleVideosResponse(_ response: VideosResponse, for viewControllerType: ViewControllerType) {
        print("VVM 進入 handleVideosResponse 方法")
        print("VVM VideosResponse: \(response)")
        print("VVM Items count: \(response.items.count)")
        
        switch viewControllerType {
        case .home, .subscribe:
            print("VVM 處理 .home 或 .subscribe 類型")
            handleVideoViewsResult(response, maxResults: 5, for: viewControllerType)
            print("VVM .home, .subscribe")
        case .content:
            handleContentVideosResult(response, for: viewControllerType)
            print("VVM .content")
        case .shorts:
            print("VVM .shorts")
        }
    }

    
    private func handleContentVideosResult(_ response: VideosResponse, for viewControllerType: ViewControllerType) {
        var videoModels: [VideoModel] = []
        
        for item in response.items {
            let title = item.snippet.title
            let thumbnailURL = item.snippet.thumbnails.high.url
            let channelTitle = item.snippet.channelTitle
            let videoID = item.id
            let accountImageURL = item.snippet.thumbnails.thumbnailsDefault.url
            
            var viewCount: String?
            var daysSinceUpload: String?
            if viewControllerType == .home || viewControllerType == .subscribe {
                viewCount = item.statistics?.viewCount
                daysSinceUpload = item.snippet.publishedAt
            }
            
            let videoModel = VideoModel(title: title, thumbnailURL: thumbnailURL, channelTitle: channelTitle, videoID: videoID, viewCount: viewCount, daysSinceUpload: daysSinceUpload, accountImageURL: accountImageURL)
            videoModels.append(videoModel)
        }
        
        data.value = videoModels
        dataLoadedCallback?(videoModels)
    }
    
    private func handleContentSearchResult(response: SearchResponse) {
        var videoModels: [VideoModel] = []
        
        for item in response.items {
            let title = item.snippet.title
            let thumbnailURL = item.snippet.thumbnails.high.url
            let channelTitle = item.snippet.channelTitle
            let videoID = item.id.videoID
            let accountImageURL = item.snippet.thumbnails.thumbnailsDefault.url
            
            let videoModel = VideoModel(title: title, thumbnailURL: thumbnailURL, channelTitle: channelTitle, videoID: videoID, accountImageURL: accountImageURL)
            videoModels.append(videoModel)
        }
        
        data.value = videoModels
        dataLoadedCallback?(videoModels)
    }

    private func handleCollectionViewSearchResult(response: SearchResponse, viewControllerType: ViewControllerType, collectionView: UICollectionView?) {
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
        
        if viewControllerType == .home {
            updateCollectionView(videoContents: videoContents, collectionView: collectionView)
        } else if viewControllerType == .subscribe {
            updateCollectionView(videoContents: videoContents, collectionView: collectionView)
        }
    }

    private func updateCollectionView(videoContents: [VideoModel], collectionView: UICollectionView) {
        if let shortsCollectionView = collectionView as? ShortsFrameCollectionView {
            shortsCollectionView.videoContents = videoContents
        } else if let subscribeCollectionView = collectionView as? SubscribeHoriCollectionView {
            subscribeCollectionView.subVideoContents = videoContents
        }
        collectionView.reloadData()
    }

    private func handleVideoViewsResult(_ response: VideosResponse, maxResults: Int, for viewControllerType: ViewControllerType) {
        guard let viewController = self.viewController else {
            print("VVM viewController 為 nil")
            return
        }
        
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
        
        print("VVM 更新 viewModel 資料")
        
        viewController.videoViewModel.data.value = videoModels
        viewController.videoViewModel.dataLoadedCallback?(videoModels)
        
        // Add print statements to debug
        print("VVM Video models count: \(videoModels.count)")
        print("VVM Video models: \(videoModels)")
    }
    
}


