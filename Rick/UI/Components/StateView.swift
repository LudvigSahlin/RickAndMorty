//
//  StateView.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-31.
//

import UIKit
import SwiftUI

class StateView: UIView {

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .largeTitle)
    return label
  }()

  lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .subheadline)
    return label
  }()

  private override init(frame: CGRect) {
    super.init(frame: frame)
  }

  init() {
    super.init(frame: .zero)
    addSubviews()
    setConstraints()
  }

  private func addSubviews() {
    addSubview(imageView)
    addSubview(titleLabel)
    addSubview(subtitleLabel)
  }

  private func setConstraints() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalToConstant: 40),
      imageView.heightAnchor.constraint(equalToConstant: 40),
      imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -40),

      titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
      titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
      titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),

      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
      subtitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
      subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
