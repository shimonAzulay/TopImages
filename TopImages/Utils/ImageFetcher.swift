//
//  ImageFetcher.swift
//  TopImages
//
//  Created by Shimon Azulay on 05/12/2022.
//

import Foundation

enum ImageDataFetcherError: Error {
  case badResponse
  case badResponseData
  case badImageUrl
}

enum SortMethod: CustomStringConvertible {
  case top
  case time
  
  var description: String {
    switch self {
    case .top: return "top"
    case .time: return "time"
    }
  }
}

enum TimeWindow: CustomStringConvertible {
  case all
  case week
  case month
  case year
  
  var description: String {
    switch self {
    case .all: return "all"
    case .week: return "week"
    case .month: return "month"
    case .year: return "year"
    }
  }
}

enum FileType: CustomStringConvertible {
  case jpg
  case gif
  
  var description: String {
    switch self {
    case .jpg: return "jpg"
    case .gif: return "gif"
    }
  }
}

enum ImageSize: CustomStringConvertible {
  case small
  case med
  case big
  
  var description: String {
    switch self {
    case .small: return "small"
    case .med: return "med"
    case .big: return "big"
    }
  }
}

protocol ImageFetcher {
  func fetchImages(of imageName: String,
                   sort: SortMethod,
                   timeWindow: TimeWindow,
                   page: Int,
                   fileType: FileType,
                   imageSize: ImageSize) async throws -> [Image]
  
  func fetchImageData(atUrl url: URL) async throws -> Data
}


class ImgurImageFetcher: ImageFetcher {
  private let clientId = "fc3afbe5c234a1e"
  private let clientSecret = "802636e83bb5cbd4c979a2c1c10360cb9a3d9bda"
  private let base = "https://api.imgur.com/3"
  private let service = "/gallery"
  private let method = "/search"
  
  func fetchImages(of imageName: String,
                   sort: SortMethod,
                   timeWindow: TimeWindow,
                   page: Int,
                   fileType: FileType,
                   imageSize: ImageSize) async throws -> [Image] {
    guard let urlRequest = makeImgurUrlRequest(of: imageName,
                                               sort: sort,
                                               timeWindow: timeWindow,
                                               page: page,
                                               fileType: fileType,
                                               imageSize: imageSize) else {
      throw ImageDataFetcherError.badImageUrl
    }
    
    return try await Task.retrying {
      let (data, response) = try await URLSession.shared.data(for: urlRequest)
      guard let httpResponse = response as? HTTPURLResponse,
            200..<300 ~= httpResponse.statusCode else {
        throw ImageDataFetcherError.badResponse
      }
      
      let decoder = JSONDecoder()
      let imgurResponse = try decoder.decode(ImgureResponse.self, from: data)
      
      let images = imgurResponse.data?.reduce([Image]()) { currentImages, gallery in
        var currentImages = currentImages
        if let imageGallery = gallery.images?.first(where: { $0.link != nil && $0.views != nil }),
           let imageUrlString = imageGallery.link,
           let imageViewsCount = gallery.views,
           let url = URL(string: imageUrlString) {
          currentImages.append(Image(title: gallery.title, url: url, viewsCount: imageViewsCount))
        } else if let imageUrlString = gallery.link,
                  let imageViewsCount = gallery.views,
                  let url = URL(string: imageUrlString) {
          currentImages.append(Image(title: gallery.title, url: url, viewsCount: imageViewsCount))
        }
        
        return currentImages
      }
      
      guard let images else {
        throw ImageDataFetcherError.badResponseData
      }
      
      return images
    }
    .value
  }

  func fetchImageData(atUrl url: URL) async throws -> Data {
    return try await Task.retrying {
      try Data(contentsOf: url)
    }
    .value
  }
}

private extension ImgurImageFetcher {
  func performFetchImageData(from url: URL) async throws -> Data {
    try Data(contentsOf: url)
  }
  
  func makeImgurUrlRequest(of imageName: String,
                           sort: SortMethod,
                           timeWindow: TimeWindow,
                           page: Int,
                           fileType: FileType,
                           imageSize: ImageSize) -> URLRequest? {
    let urlString = "\(base)\(service)\(method)/\(sort)/\(timeWindow)/\(page)?q=\(imageName)&q_type=\(fileType)&q_size_px=\(imageSize)"
    
    guard let url = URL(string: urlString) else { return nil }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue("Client-ID \(clientId)", forHTTPHeaderField: "Authorization")
    
    return urlRequest
  }
}
