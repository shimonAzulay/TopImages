//
//  TopImagesViewModel.swift
//  TopImages
//
//  Created by Shimon Azulay on 05/12/2022.
//

import Foundation

class TopImagesViewModel: ObservableObject {
  private var page = 1
  private let imageName = "Cats"
  
  let imageDataCache = ImageDataCache()
  let imageFetcher: ImageFetcher
  @Published var images = [Image]()
  
  init(imageFetcher: ImageFetcher) {
    self.imageFetcher = imageFetcher
  }
  
  func fetchMore() throws {
    print("Fetching page #\(page)")
    Task { @MainActor [weak self] in
      let images = try await imageFetcher.fetchImages(of: imageName,
                                                      sort: .top,
                                                      timeWindow: .all,
                                                      page: page,
                                                      fileType: .jpg,
                                                      imageSize: .small)
      self?.page += 1
      self?.images = images
    }
  }
}
