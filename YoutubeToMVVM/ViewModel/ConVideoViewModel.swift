// ConVideoViewModel.swift

import Foundation

class ConVideoViewModel {
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

    func searchYouTubeToContent(query: String, maxResults: Int, completion: @escaping (Welcome?) -> Void) {
        let apiKey = ""
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

    func doSearch(withKeywords keywords: [String], maxResults: Int) {
        var currentIndex = 0
        var allVideoFrameViewModels: [ConVideoFrameViewModel] = []

        let dispatchGroup = DispatchGroup()
        
        for keyword in keywords {
            dispatchGroup.enter()
            print("VideoVM.keyword == \(keyword)")
            searchYouTubeToContent(query: keyword, maxResults: maxResults) { [weak self] response in
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

