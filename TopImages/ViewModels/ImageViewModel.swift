//
//  ImageViewModel.swift
//  TopImages
//
//  Created by Shimon Azulay on 05/12/2022.
//

import Foundation

class ImageViewModel: ObservableObject {
  @Published var imageData: Data?
  
  let imageFetcher: ImageFetcher
  let imageDataCache: ImageDataCache
  
  init(imageFetcher: ImageFetcher,
       imageDataCache: ImageDataCache) {
    self.imageFetcher = imageFetcher
    self.imageDataCache = imageDataCache
  }
  
  func fetchImage(atUrl url: URL) throws {
    if let imageData = imageDataCache.getItem(forKey: url.absoluteString) {
      self.imageData = imageData
      return
    }
    
    Task { @MainActor [weak self] in
      let imageData = try await imageFetcher.fetchImageData(atUrl: url)
      self?.imageDataCache.setItem(forKey: url.absoluteString, item: imageData)
      self?.imageData = imageData
    }
  }
}
