//
//  ImageCache.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-04-03.
//

import Foundation

actor ImageCache {
  static let shared = ImageCache()
  private let cache = NSCache<NSURL, NSData>()

  func load(url: URL) async throws -> Data {
    if let localImage = cache.object(forKey: url as NSURL) {
      print("Used cached data for image with url: \(url)")
      return localImage as Data
    }
    let (data, _) = try await URLSession.shared.data(from: url as URL)
    cache.setObject(data as NSData, forKey: url as NSURL)
    return data
  }
}
