//
//  Info.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-31.
//

struct Info: Decodable {
  /// The length of the response
  let count: Int
  /// The amount of pages
  let pages: Int
  ///(url)  Link to the next page (if it exists)
  let next: String?
  ///(url)  Link to the previous page (if it exists)
  let prev: String?
}
