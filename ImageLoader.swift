//
//  ImageLoader.swift
//  YoutubeToMVVM
//
//  Created by Lydia Lu on 2024/6/7.
//

import Foundation
import UIKit

class ImageLoader {
    static func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            let image = UIImage(data: data)
            completion(image)
        }.resume()
    }
}
