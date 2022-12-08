//
//  ViewController.swift
//  TopImages
//
//  Created by Shimon Azulay on 05/12/2022.
//

import UIKit
import Combine

class TopImagesShowcaseViewController: UIViewController {
  private lazy var collctionView: UICollectionView = {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                          heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 5,
                                                 leading: 5,
                                                 bottom: 5,
                                                 trailing: 5)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                           heightDimension: .fractionalWidth(0.5))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                   subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    let layout = UICollectionViewCompositionalLayout(section: section)
    return UICollectionView(frame: .zero, collectionViewLayout: layout)
  }()
  
  private var shouldReload = false
  private var cancellable: AnyCancellable?
  private var images = [Image]()
  
  let viewModel: TopImagesViewModel
  
  init(viewModel: TopImagesViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupCollectionView()
    setupViewModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    try? viewModel.fetchMore()
  }
}

private extension TopImagesShowcaseViewController {
  func setupView() {
    view.backgroundColor = .white
    navigationItem.title = "Top Cat Images"
  }
  
  func setupCollectionView() {
    collctionView.backgroundColor = .white
    view.addSubview(collctionView)
    collctionView.translatesAutoresizingMaskIntoConstraints = false
    collctionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    collctionView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    collctionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    collctionView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    collctionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
    collctionView.delegate = self
    collctionView.dataSource = self
  }
  
  func setupViewModel() {
    cancellable = viewModel.$images
      .sink { [weak self] fetchedImages in
        self?.images.append(contentsOf: fetchedImages)
        self?.collctionView.reloadData()
        self?.shouldReload = true
      }
  }
}

extension TopImagesShowcaseViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if shouldReload,
       indexPath.row > images.count - 10 {
      shouldReload = false
      try? viewModel.fetchMore()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    images.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let image = images[indexPath.row]
    var cell = ImageCollectionViewCell()
    if let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell {
      cell = reusableCell
    }
    
    cell.viewModel = ImageViewModel(imageFetcher: viewModel.imageFetcher,
                                    imageDataCache: viewModel.imageDataCache)
    cell.image = image
    
    return cell
  }
}
