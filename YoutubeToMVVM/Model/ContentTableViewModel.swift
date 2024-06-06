////
////  ContentTableViewModel.swift
////  YoutubeToMVVM
////
////  Created by Lydia Lu on 2024/6/7.
////
//
//import Foundation
//
//class ContentTableViewModel {
//    var videoViewModels: [[ConVideoViewModel]] = [[]]
//
//    func searchVideos(withKeywords keywords: [String], maxResults: Int, completion: @escaping () -> Void) {
//        var currentIndex = 0 // 用於追踪當前的索引
//
//        for keyword in keywords {
//            searchYouTube(query: keyword, maxResults: maxResults) { [weak self] response in
//                guard let self = self else { return }
//
//                if let response = response {
//                    var videos: [ConVideoViewModel] = []
//                    for (_, item) in response.items.enumerated() {
//                        if currentIndex < maxResults { // 確保不超過 16 筆資料
//                            let videoViewModel = ConVideoViewModel(title: item.snippet.title,
//                                                                    thumbnailURL: item.snippet.thumbnails.high.url,
//                                                                    channelTitle: item.snippet.channelTitle,
//                                                                    index: currentIndex)
//                            videos.append(videoViewModel)
//                            currentIndex += 1 // 增加索引
//                        } else {
//                            break
//                        }
//                    }
//                    self.videoViewModels.append(videos)
//                } else {
//                    print("Failed to fetch results for keyword: \(keyword)")
//                }
//
//                // 在所有搜索完成後呼叫 completion block
//                completion()
//            }
//        }
//    }
//
//    func searchAndLoadVideoFrameViews(withQueries queries: [String], maxResults: Int, completion: @escaping () -> Void) {
//        for query in queries {
//            searchYouTube(query: query, maxResults: maxResults) { [weak self] response in
//                guard let self = self else { return }
//
//                if let welcomeResponse = response {
//                    var videoFrameViews: [ConVideoFrameView] = []
//                    for item in welcomeResponse.items {
//                        let title = item.snippet.title
//                        let image = item.snippet.thumbnails.high.url
//                        let conVideoFrameView = ConVideoFrameView()
//                        // 設置 conVideoFrameView 的標題和縮略圖等數據
//                        conVideoFrameView.titleLbl.text = title
//                        self.setImage(from: image, to: conVideoFrameView.conVideoImgView)
//
//                        videoFrameViews.append(conVideoFrameView)
//                    }
//
//                    // 將新數據加入到 tableView 中
//                    self.videoFrameViews = videoFrameViews
//
//                    // 呼叫 completion block
//                    completion()
//                } else {
//                    print("無法為查詢 \(query) 檢索到結果")
//                }
//            }
//        }
//    }
//}
//
