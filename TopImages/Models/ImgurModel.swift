//
//  ImgurModel.swift
//  TopImages
//
//  Created by Shimon Azulay on 07/12/2022.
//

import Foundation

struct ImgureResponse: Decodable {
  let data: [ImgureGallery]?
}

struct ImgureGallery: Decodable {
  let title: String?
  let views: Int?
  let link: String?
  let images: [ImgureImage]?
}

struct ImgureImage: Decodable {
  let link: String?
  let views: Int?
}
