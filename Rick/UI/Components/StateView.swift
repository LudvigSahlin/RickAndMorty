//
//  StateView.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-31.
//

import UIKit
import SwiftUI

class StateView: UIView {
  enum State {
    case loading(title: String)
    case error(onTryAgainTapped: () -> Void)
  }

  private lazy var errorImage = UIImage(systemName: "exclamationmark.triangle")!
  private lazy var loadingImage = UIImage(systemName: "photo")!

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .systemGray
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

  lazy var tryAgainButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Try again", for: .normal)
    button.backgroundColor = .systemOrange
    button.layer.cornerRadius = 8
    button.tintColor = .label
    button.addAction(UIAction { [weak self] _ in
      self?.onTryAgainButtonTappedClosure?()
    }, for: .touchUpInside)
    return button
  }()

  private override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private var onTryAgainButtonTappedClosure: (() -> Void)?

  init() {
    super.init(frame: .zero)
    addSubviews()
    setConstraints()
  }
  deinit {
    print("state view deinit")
  }

  private func addSubviews() {
    addSubview(imageView)
    addSubview(titleLabel)
    addSubview(subtitleLabel)
    addSubview(tryAgainButton)
  }

  private func setConstraints() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    tryAgainButton.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalToConstant: 100),
      imageView.heightAnchor.constraint(equalToConstant: 100),
      imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -40),

      titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
      titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
      titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),

      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
      subtitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
      subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),

      tryAgainButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -32),
      tryAgainButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
      tryAgainButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
      tryAgainButton.heightAnchor.constraint(equalToConstant: 40)
    ])
  }

  func setState(_ state: State) {
    switch state {
    case .loading(let title):
      imageView.image = loadingImage
      titleLabel.text = title
      subtitleLabel.text = ""
      tryAgainButton.isHidden = true
      onTryAgainButtonTappedClosure = nil

    case .error(let actionClosure):
      imageView.image = errorImage
      titleLabel.text = "Something went wrong!"
      subtitleLabel.text = "Please check your internet connection."
      tryAgainButton.isHidden = false
      onTryAgainButtonTappedClosure = actionClosure
    }
  }
}

#Preview {
  let stateView = StateView()
  stateView.imageView.image = UIImage(systemName: "photo")
  stateView.titleLabel.text = "Here is a title label"
  stateView.subtitleLabel.text = "Here is a subtitle label"
  stateView.backgroundColor = .systemGray6
  return stateView
}
