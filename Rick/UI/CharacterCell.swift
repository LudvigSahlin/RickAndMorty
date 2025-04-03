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

  func setContent(_ character: Character) {
    characterContentView.setContent(character)
  }
}

class CharacterContentView: UIView {
  private lazy var backupImage = UIImage(systemName: "arrowshape.down.circle")!

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
      setContent(character)
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

      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
      subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
    ])
  }

  func setContent(_ character: Character) {
    id = character.id
    anImageView.image = backupImage
    titleLabel.text = character.name
    subtitleLabel.text = character.status
    Task {
      do {
        let imageData = try await ImageCache.shared.load(url: character.image)
        guard self.id == character.id else {
          print("cell was reused, return")
          return
        }
        guard let uiImage = UIImage(data: imageData) else {
          print("data could not create UIImage. Data count: \(imageData.count)")
          return
        }
        self.anImageView.image = uiImage
      } catch {
        print("Could not load character image")
      }
    }
  }
}

#Preview {
  lazy var sampleCharacter = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let characterData = try! Data(contentsOf: Bundle.main.url(forResource: "samplecharacter", withExtension: "json")!)
    let character = try! decoder.decode(Character.self, from: characterData)
    return character
  }()

  CharacterContentView(character: sampleCharacter)
}
