// ConVideoViewModel.swift

import Foundation
import UIKit

class VideoViewModel {
    var data: Observable<[ConVideoFrameViewModel]> = Observable([])
    var showItems: [String] = []
    var videoIDs: [String] = []

    private var dataTask: URLSessionDataTask?
    
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

    func doSearchForContent(withKeywords keywords: [String], maxResults: Int) {
        var currentIndex = 0
        var allVideoFrameViewModels: [ConVideoFrameViewModel] = []

        let dispatchGroup = DispatchGroup()
        
        for keyword in keywords {
            dispatchGroup.enter()
            print("VideoVM.keyword == \(keyword)")
            searchYouTube(query: keyword, maxResults: maxResults) { [weak self] response in
                defer { dispatchGroup.leave() }
                guard let self = self else { return }
                if let response = response {
                    for item in response.items {
                        if currentIndex < maxResults {
                            self.showItems.append(keyword)
                            let videoFrameViewModel = ConVideoFrameViewModel(
                                title: item.snippet.title,
                                thumbnailURL: item.snippet.thumbnails.high.url,
                                channelTitle: item.snippet.channelTitle,
                                videoID: item.id.videoID
                            )
                            allVideoFrameViewModels.append(videoFrameViewModel)
                            self.videoIDs.append(item.id.videoID)
                            currentIndex += 1
                        } else {
                            break
                        }
                    }
                } else {
                    print("Failed to fetch results for keyword: \(keyword)")
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.data.value = allVideoFrameViewModels
        }
    }
    
    func loadDataVideoFrameView(withTitle title: String, thumbnailURL: String, channelTitle: String, accountImageURL: String, viewCount: String, daysSinceUpload: String, atIndex index: Int) {
        print(title)
        
        // 根據 index 獲取 videoFrameView
        guard let videoFrameView = getVideoFrameView(at: index) else {
            return
        }
        
        DispatchQueue.main.async {
            // 設置標題和其他信息
            videoFrameView.labelMidTitle.text = title
            videoFrameView.labelMidOther.text = "\(channelTitle)．觀看次數： \(self.convertViewCount(viewCount))次．\(daysSinceUpload)"
            
            // 設置影片縮圖
            self.setImage(from: thumbnailURL, to: videoFrameView.videoImgView)
            
            // 設置帳號圖片
            self.setImage(from: accountImageURL, to: videoFrameView.photoImageView)
        }
    }
    
    func setImage(from urlString: String, to imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }
    
    func doSearch(withKeywords keywords: [String], maxResults: Int = 5) {
        for keyword in keywords {
            searchYouTube(query: keyword, maxResults: maxResults) { [self] response in
                if let response = response {
                    for (i, item) in response.items.enumerated() {
                        showItems.append(keyword)
                        
                        loadDataVideoFrameView(withTitle: item.snippet.title,
                                               thumbnailURL: item.snippet.thumbnails.high.url,
                                               channelTitle: item.snippet.channelTitle,
                                               accountImageURL: item.snippet.thumbnails.high.url,
                                               viewCount: "987654321",
                                               daysSinceUpload: calculateTimeSinceUpload(from: item.snippet.publishedAt),
                                               atIndex: i)
                        
                        let videoID = item.id.videoID
                        videoIDs.append(videoID)
                    }
                } else {
                    print("Failed to fetch results for keyword: \(keyword)")
                }
            }
        }
    }
    
    func searchAndLoadHomeShortsCollectionView(withQueries queries: [String]) {
        for query in queries {
            searchYouTube(query: query, maxResults: 4) { [weak self] response in
                guard let self = self else { return }
                
                if let welcomeResponse = response {
                    DispatchQueue.main.async {
                        self.homeShortsFrameCollectionView.videoContents.removeAll()
                        self.homeShortsFrameCollectionView.welcome = welcomeResponse
                        
                        for item in welcomeResponse.items {
                            let title = item.snippet.title
                            let image = item.snippet.thumbnails.high.url
                            let videoContent = VideoContent(title: title, thumbnailURL: image)
                            self.homeShortsFrameCollectionView.videoContents.append(videoContent)
                        }
                        
                        self.homeShortsFrameCollectionView.reloadData()
                    }
                } else {
                    print("STV無法為查詢 \(query) 檢索到結果")
                }
                
                // 印出當前處理的查詢
                print("正在處理查詢: \(query)")
            }
        }
    }
    
    func searchAndLoadSubShortsCollectionView(withQueries queries: [String]) {
        for query in queries {
            searchYouTube(query: query, maxResults: 18) { [weak self] response in
                guard let self = self else { return }
                
                if let welcomeResponse = response {
                    DispatchQueue.main.async {
                        self.subscribeHoriCollectionView.subVideoContents.removeAll()
                        self.subscribeHoriCollectionView.welcome = welcomeResponse
                        
                        for item in welcomeResponse.items {
                            let title = item.snippet.title
                            let image = item.snippet.thumbnails.high.url
                            let videoContent = SubVideoContent(title: title, thumbnailURL: image)
                            self.subscribeHoriCollectionView.subVideoContents.append(videoContent)
                        }
                        
                        self.subscribeHoriCollectionView.reloadData()
                    }
                } else {
                    print("STV無法為查詢 \(query) 檢索到結果")
                }
                
                // 印出當前處理的查詢
                print("正在處理查詢: \(query)")
            }
        }
    }
    
    
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

