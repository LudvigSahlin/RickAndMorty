/*
 See the LICENSE.txt file for this sample’s licensing information.

 Abstract:
 The Image cache.
 */
import UIKit
import Foundation

class ImageCache2 {

  static let shared = ImageCache2()
  var placeholderImage = UIImage(systemName: "rectangle")!

  private let cache = NSCache<NSURL, UIImage>()
  private var callbacks = [NSURL: [(Item, UIImage?) -> Swift.Void]]()

  func localImage(url: NSURL) -> UIImage? {
    cache.object(forKey: url)
  }

  /// Returns the cached image if available, otherwise asynchronously loads and caches it.
  func load(url: NSURL, item: Item, completion: @escaping (Item, UIImage?) -> Swift.Void) {
    // Check for a cached image.
    if let cachedImage = localImage(url: url) {
      DispatchQueue.main.async {
        completion(item, cachedImage)
      }
      return
    }
    // In case there are more than one requestor for the image, we append their completion block.
    if callbacks[url] != nil {
      callbacks[url]?.append(completion)
      return
    } else {
      callbacks[url] = [completion]
    }
    // Go fetch the image.
    ImageURLProtocol.urlSession().dataTask(with: url as URL) { (data, response, error) in
      // Check for the error, then data and try to create the image.
      guard let data,
            let uiImage = UIImage(data: data),
            let blocks = self.callbacks[url],
            error == nil else {
        DispatchQueue.main.async {
          completion(item, nil)
        }
        return
      }
      // Cache the image.
      self.cache.setObject(uiImage, forKey: url, cost: data.count)
      // Iterate over each requestor for the image and pass it back.
      for block in blocks {
        DispatchQueue.main.async {
          block(item, uiImage)
        }
        return
      }
    }.resume()
  }
}

struct Item: Hashable {
  var image: UIImage
  let url: URL
  let identifier = UUID()

  init(image: UIImage, url: URL) {
    self.image = image
    self.url = url
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }

  static func == (lhs: Item, rhs: Item) -> Bool {
    lhs.identifier == rhs.identifier
  }
}
