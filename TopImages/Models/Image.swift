//
//  Image.swift
//  TopImages
//
//  Created by Shimon Azulay on 07/12/2022.
//

import Foundation

struct Image: Codable {
  let title: String?
  let url: URL
  let viewsCount: Int
}
