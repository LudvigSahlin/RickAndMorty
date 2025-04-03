//
//  ImageCache.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-04-03.
//

import Foundation

final class ImageCache: Sendable {
  static let shared = ImageCache()

  /// Image cache
  ///
  /// > Thread safe:
  /// > By NSCache documentation:
  /// >
  /// >  _"You can add, remove, and query items in the cache from different threads without having to lock the cache yourself."_
  nonisolated(unsafe)
  private let cache = NSCache<NSURL, NSData>()

  func storeImage(_ data: Data, key: URL) {
    cache.setObject(data as NSData, forKey: key as NSURL)
  }

  func fetchImage(key: URL) -> Data? {
    guard let localImage = cache.object(forKey: key as NSURL) else {
      return nil
    }
//    print("Used cached data for image with url: \(key)")
    return localImage as Data
  }
}
