//
//  CharacterCell.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-29.
//

import UIKit

class CharacterCell: UITableViewCell {
  private lazy var characterContentView = CharacterContentView(character: nil)

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addSubviews()
    setConstraints()
    accessoryType = .disclosureIndicator
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func addSubviews() {
    contentView.addSubview(characterContentView)
  }

  private func setConstraints() {
    characterContentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      characterContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
      characterContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      characterContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      characterContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    ])
  }

  /// In addition to setting texts and resetting the image, this function will also store the `id` of the character.
  ///
  /// See also ``setAsynconousData(_:id:)``
  func setSyncronousData(_ character: Character) {
    characterContentView.setSyncronousData(character)
  }

  /// If the user scrolls quickly, the cell might have been reused during the image fetch.
  /// - Parameter image: Will be ignored if the cell has been reused.
  /// - Parameter id: Used to check if the cell has been reused. See also ``setSyncronousData(_:)``, where a new `id` might have been set.
  func setAsynconousData(_ image: UIImage, id: Int) {
    characterContentView.setAsynconousData(image, id: id)
  }
}

class CharacterContentView: UIView {
  private lazy var backupImage = UIImage(systemName: "photo")!

  private lazy var anImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.layer.cornerRadius = 25
    imageView.clipsToBounds = true
    imageView.tintColor = .systemGray
    return imageView
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.preferredFont(forTextStyle: .title2)
    return label
  }()

  private lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    return label
  }()

  /// Typically used to check if the cell has been reused during the loading of the image.
  private var id: Int = -1

  init(character: Character?) {
    super.init(frame: .zero)
    addSubviews()
    setConstraints()
    if let character {
      setSyncronousData(character)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func addSubviews() {
    addSubview(anImageView)
    addSubview(titleLabel)
    addSubview(subtitleLabel)
  }

  private func setConstraints() {
    anImageView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      anImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
      anImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
      anImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
      anImageView.heightAnchor.constraint(equalToConstant: 100),
      anImageView.widthAnchor.constraint(equalToConstant: 100),

      titleLabel.topAnchor.constraint(equalTo: anImageView.topAnchor),
      titleLabel.leadingAnchor.constraint(equalTo: anImageView.trailingAnchor, constant: 16),
      titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),

      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
      subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
    ])
  }

  func setSyncronousData(_ character: Character) {
    id = character.id
    anImageView.image = backupImage
    titleLabel.text = character.name
    subtitleLabel.text = character.status
  }

  func setAsynconousData(_ image: UIImage, id: Int) {
    guard self.id == id else {
      print("Cell was reused, return.")
      return
    }
    anImageView.image = image
  }
}

#Preview {
  CharacterContentView(character: Character.sampleCharacter)
}

#Preview("Long names") {
  let character = Character(id: 0,
                            name: "Rick Sanchez Rick Sanchez",
                            status: "Rick Sanchez Rick Sanchez Rick Sanchez Rick Sanchez",
                            species: "",
                            type: "",
                            gender: "",
                            image: URL(string: "www.example.com")!,
                            episode: [URL(string: "www.example.com")!],
                            url: URL(string: "www.example.com")!,
                            created: "")
  CharacterContentView(character: character)
}
