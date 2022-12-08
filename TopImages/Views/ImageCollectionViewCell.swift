//
//  ImageCollectionViewCell.swift
//  TopImages
//
//  Created by Shimon Azulay on 05/12/2022.
//

import UIKit
import Combine

class ImageCollectionViewCell: UICollectionViewCell {
  static let identifier = "ImageCollectionViewCell"
  
  private lazy var labelsContainer: UIStackView = {
    let labelsContainer = UIStackView()
    labelsContainer.axis = .vertical
    labelsContainer.alignment = .fill
    labelsContainer.distribution = .fill
    labelsContainer.spacing = 5
    return labelsContainer
  }()
  
  private lazy var imageTitleLabel: UILabel = {
    let imageTitleLabel = UILabel()
    imageTitleLabel.textAlignment = .natural
    imageTitleLabel.numberOfLines = 0
    imageTitleLabel.lineBreakMode = .byWordWrapping
    imageTitleLabel.font = .systemFont(ofSize: 15)
    imageTitleLabel.textColor = .black
    return imageTitleLabel
  }()
  
  private lazy var imageViewsCountLabel: UILabel = {
    let imageTitleLabel = UILabel()
    imageTitleLabel.textAlignment = .natural
    imageTitleLabel.numberOfLines = 0
    imageTitleLabel.lineBreakMode = .byWordWrapping
    imageTitleLabel.font = .systemFont(ofSize: 10)
    imageTitleLabel.textColor = .black
    return imageTitleLabel
  }()
  
  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleToFill
    return imageView
  }()
  
  private lazy var activityIndicatorView: UIActivityIndicatorView = {
    let activityIndicatorView = UIActivityIndicatorView()
    activityIndicatorView.style = .medium
    activityIndicatorView.color = .black
    activityIndicatorView.hidesWhenStopped = true
    return activityIndicatorView
  }()
  
  private var cancellable: AnyCancellable?
  var viewModel: ImageViewModel? {
    didSet {
      guard let viewModel else { return }
      cancellable = viewModel.$imageData
        .sink { [weak self] imageData in
          if let imageData {
            self?.activityIndicatorView.stopAnimating()
            self?.imageView.image = UIImage(data: imageData)
          }
        }
    }
  }
  
  var image: Image? {
    didSet {
      guard let image else { return }
      activityIndicatorView.startAnimating()
      populateTexts(imageViewTitle: image.title, imageViewsCount: image.viewsCount)
      try? viewModel?.fetchImage(atUrl: image.url)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    imageTitleLabel.text = nil
    imageTitleLabel.isHidden = false
    imageViewsCountLabel.text = nil
    imageView.image = nil
    activityIndicatorView.stopAnimating()
  }
}

private extension ImageCollectionViewCell {
  func commonInit() {
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    layer.cornerRadius = 5
    layer.borderWidth = 2
    layer.masksToBounds = false
    
    contentView.addSubview(imageView)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
    
    contentView.addSubview(labelsContainer)
    labelsContainer.translatesAutoresizingMaskIntoConstraints = false
    labelsContainer.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5).isActive = true
    labelsContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    labelsContainer.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95).isActive = true
    labelsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
    
    contentView.addSubview(activityIndicatorView)
    activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    activityIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    activityIndicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    
    labelsContainer.addArrangedSubview(imageTitleLabel)
    labelsContainer.addArrangedSubview(imageViewsCountLabel)
  }
  
  func populateTexts(imageViewTitle: String? ,imageViewsCount: Int) {
    if let imageViewTitle {
      imageTitleLabel.text = "\(imageViewTitle)"
    } else {
      imageTitleLabel.isHidden = true
    }
    
    imageViewsCountLabel.text = "Views Count: \(imageViewsCount)"
  }
}
