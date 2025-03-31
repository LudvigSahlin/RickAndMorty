//
//  Character.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-29.
//

import Foundation

struct Character: Decodable {
  /// The id of the character.
  let id: Int
  /// The name of the character.
  let name: String
  /// The status of the character ('Alive', 'Dead' or 'unknown').
  let status: String
  /// The species of the character.
  let species: String
  /// The type or subspecies of the character.
  /// - Note: May be empty string.
  let type: String
  /// The gender of the character ('Female', 'Male', 'Genderless' or 'unknown').
  let gender: String
//  /// Name and link to the character's origin location.
//  let origin: object  Name
//  /// Name and link to the character's last known location endpoint.
//  let location: object  Name
  /// (url) Link to the character's image.
  /// All images are 300x300px and most are medium shots or portraits since they are intended to be used as avatars.
  let image: URL
  ///(urls)  List of episodes in which this character appeared.
  let episode: [URL]
  ///(url)  Link to the character's own URL endpoint.
  let url: URL
  /// Time at which the character was created in the database.
  let created: String
}
